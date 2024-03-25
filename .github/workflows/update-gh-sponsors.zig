const std = @import("std");

const url = "https://api.github.com/graphql";
const env_key = "GH_TOKEN";

// For debugging with a local netcat:
// const url = "http://localhost:3000";
// const env_key = "TERM";

const github_endpoint = std.Uri.parse(url) catch unreachable;
const gql_query = blk: {
    var q =
        \\query {{
        \\  organization(login: \"ziglang\") {{
        \\    sponsorshipsAsMaintainer(first:100{s}, includePrivate: false, activeOnly: true,orderBy: {{field: CREATED_AT, direction: ASC}}) {{
        \\      pageInfo {{
        \\        endCursor
        \\        hasNextPage
        \\      }}
        \\      nodes {{
        \\        sponsorEntity {{
        \\          ... on User {{
        \\            id
        \\            name
        \\            login
        \\            twitterUsername
        \\            websiteUrl
        \\          }}
        \\          ... on Organization {{
        \\            id
        \\            name
        \\            login
        \\            twitterUsername
        \\            websiteUrl
        \\          }}
        \\        }}
        \\        isOneTimePayment
        \\        tier {{
        \\          isCustomAmount
        \\          monthlyPriceInDollars
        \\        }}
        \\      }}
        \\    }}
        \\  }}
        \\}}    
    .*;
    std.mem.replaceScalar(u8, &q, '\n', ' ');
    break :blk q;
};

const GqlReply = struct {
    data: struct {
        organization: struct {
            sponsorshipsAsMaintainer: struct {
                pageInfo: PageInfo,
                nodes: []const Sponsorship,
            },
        },
    },

    const PageInfo = struct {
        endCursor: ?[]const u8,
        hasNextPage: bool,
    };

    const Sponsorship = struct {
        isOneTimePayment: bool,
        tier: struct {
            isCustomAmount: bool,
            monthlyPriceInDollars: usize,
        },
        sponsorEntity: Sponsor,
    };

    const Sponsor = struct {
        id: []const u8,
        name: ?[]const u8,
        login: []const u8,
        twitterUsername: ?[]const u8,
        websiteUrl: ?[]const u8,
    };
};

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer _ = gpa.deinit();

    var arena_allocator = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena_allocator.deinit();

    const arena = arena_allocator.allocator();

    var gh: std.http.Client = .{
        .allocator = gpa.allocator(),
    };
    defer gh.deinit();

    const gh_token = std.process.getEnvVarOwned(arena, env_key) catch |err| {
        std.debug.print("Unable to find environment variable: `{s}`.\n", .{env_key});
        return err;
    };

    const bearer = try std.fmt.allocPrint(arena, "bearer {s}", .{gh_token});

    var replies = std.ArrayList(GqlReply).init(gpa.allocator());
    defer replies.deinit();

    var current: GqlReply.PageInfo = .{
        .hasNextPage = true,
        .endCursor = null,
    };

    const header_buf = try gpa.allocator().alloc(u8, 4 * 1024 * 1024);
    defer gpa.allocator().free(header_buf);

    while (current.hasNextPage) {
        std.debug.print(
            "starting request ({}, {?s})\n",
            .{ current.hasNextPage, current.endCursor },
        );

        var request = try gh.open(.POST, github_endpoint, .{
            .server_header_buffer = header_buf,
            .extra_headers = &.{
                .{ .name = "Authorization", .value = bearer },
            },
        });
        defer request.deinit();
        request.transfer_encoding = .chunked;

        var buf = std.io.bufferedWriter(request.writer());
        const w = buf.writer();

        try request.send(.{});
        try w.writeAll(
            \\{"query":"
        );
        if (current.endCursor) |end_cursor| {
            var b: [100]u8 = undefined;
            const query_argument = try std.fmt.bufPrint(
                &b,
                \\, after: \"{s}\"
            ,
                .{end_cursor},
            );
            try w.print(&gql_query, .{query_argument});
        } else {
            try w.print(&gql_query, .{""});
        }
        try w.writeAll(
            \\"}
        );
        try buf.flush();
        try request.finish();
        try request.wait();

        const json_data = try request.reader().readAllAlloc(arena, 1 * 1024 * 1024);

        try replies.append(
            try std.json.parseFromSliceLeaky(
                GqlReply,
                arena,
                json_data,
                .{},
            ),
        );

        current = replies.items[replies.items.len - 1].data.organization.sponsorshipsAsMaintainer.pageInfo;
    }

    var with_link = std.ArrayList(GqlReply.Sponsor).init(gpa.allocator());
    defer with_link.deinit();
    var name_only = std.ArrayList(GqlReply.Sponsor).init(gpa.allocator());
    defer name_only.deinit();

    for (replies.items) |r| {
        for (r.data.organization.sponsorshipsAsMaintainer.nodes) |s| {
            if (s.isOneTimePayment) continue;
            const amount = s.tier.monthlyPriceInDollars;
            if (amount < 200) continue;
            if (amount < 400) {
                try name_only.append(s.sponsorEntity);
            } else {
                try with_link.append(s.sponsorEntity);
            }
        }
    }

    var buffered_out = std.io.bufferedWriter(std.io.getStdOut().writer());
    const out = buffered_out.writer();
    for (with_link.items) |s| {
        const name = s.name orelse s.login;
        const link = blk: {
            if (s.websiteUrl) |w| {
                if (std.mem.startsWith(u8, w, "http")) break :blk w;
                break :blk try std.fmt.allocPrint(arena, "https://{s}", .{w});
            }
            if (s.twitterUsername) |t| {
                break :blk try std.fmt.allocPrint(
                    arena,
                    "https://twitter.com/{s}",
                    .{t},
                );
            }
            break :blk try std.fmt.allocPrint(arena, "https://github.com/{s}", .{s.login});
        };

        try out.print(
            \\<li><a href="{s}" rel="nofollow noopener" target="_blank" class="external-link">{s}</a></li>
            \\
        ,
            .{ link, name },
        );
    }

    for (name_only.items) |s| {
        const name = s.name orelse s.login;
        try out.print(
            \\<li>{s}</li>
            \\
        ,
            .{name},
        );
    }

    try buffered_out.flush();
}
