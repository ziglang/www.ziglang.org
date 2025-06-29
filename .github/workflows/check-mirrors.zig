const mirrors_list_url = "https://ziglang.org/download/community-mirrors.txt";
const download_json_url = "https://ziglang.org/download/index.json";
const release_tarball_template = "https://ziglang.org/download/{s}/{s}";
const master_tarball_template = "https://ziglang.org/builds/{s}";

/// This is a list of *release* tarballs which will be compared between ziglang.org and each mirror.
/// As well as this list, we check some tarballs for the latest "master" build: see `master_targets`.
const tarball_names: []const []const u8 = &.{
    // TODO: once 0.15.0 is released, add some FreeBSD/NetBSD tarballs!

    // 0.14.1 (new tarball name format, some new targets)
    "zig-0.14.1.tar.xz",
    "zig-x86_64-windows-0.14.1.zip",
    "zig-aarch64-macos-0.14.1.tar.xz",
    // This is every 'zig-xxx-linux-0.14.1.tar.xz' (same order as on the website)
    "zig-x86_64-linux-0.14.1.tar.xz",
    "zig-aarch64-linux-0.14.1.tar.xz",
    "zig-armv7a-linux-0.14.1.tar.xz",
    "zig-riscv64-linux-0.14.1.tar.xz",
    "zig-powerpc64le-linux-0.14.1.tar.xz",
    "zig-x86-linux-0.14.1.tar.xz",
    "zig-loongarch64-linux-0.14.1.tar.xz",
    "zig-s390x-linux-0.14.1.tar.xz",

    // 0.10.1 (last stage1 release)
    "zig-0.10.1.tar.xz",
    "zig-bootstrap-0.10.1.tar.xz",
    "zig-linux-i386-0.10.1.tar.xz",
    "zig-macos-aarch64-0.10.1.tar.xz",
    "zig-windows-x86_64-0.10.1.zip",

    // 0.7.1 (oldest supported patch release)
    "zig-0.7.1.tar.xz",
    "zig-linux-x86_64-0.7.1.tar.xz",

    // 0.6.0 (oldest supported version)
    "zig-0.6.0.tar.xz",
    "zig-linux-x86_64-0.6.0.tar.xz",
};

/// We don't request *every* build of 'master' from the mirrors; that'd probably cause them to cache
/// a bunch of tarballs pointlessly. Instead, just request this common-ish subset. We do request all
/// of the *signatures* though, since they won't use much space in the mirrors' caches and will be
/// fast to fetch.
const master_targets: []const []const u8 = &.{
    "x86_64-linux",
    "x86_64-freebsd",
    "x86_64-netbsd",
    "x86_64-windows",
    "aarch64-macos",
    "x86-windows",
    "armv7a-linux",
};

const File = struct {
    name: []const u8,
    version: ?[]const u8,
    kind: enum { tarball, minisig },

    const Result = union(enum) {
        /// Value is query time in nanoseconds.
        ok: u64,
        content_mismatch,
        bad_status: std.http.Status,
        err: anyerror,

        pub fn format(res: Result, comptime fmt: []const u8, options: std.fmt.FormatOptions, w: anytype) !void {
            if (fmt.len != 0) std.fmt.invalidFmtError(fmt, res);
            _ = options;
            switch (res) {
                .ok => |query_ns| try w.print("{}", .{std.fmt.fmtDuration(query_ns)}),
                .content_mismatch => try w.writeAll(":warning: incorrect contents"),
                .err => |err| try w.print(":warning: error: {s}", .{@errorName(err)}),
                .bad_status => |s| try w.print(":warning: bad status: {d} {s}", .{ @intFromEnum(s), s.phrase() orelse "?" }),
            }
        }
    };
};

pub fn main() Allocator.Error!u8 {
    const gpa = std.heap.smp_allocator;

    var arena_state: std.heap.ArenaAllocator = .init(gpa);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    const args = std.process.argsAlloc(arena) catch @panic("argsAlloc failed");
    if (args.len != 2) @panic("bad usage");
    const out_filename = args[1];

    var http_client: std.http.Client = .{ .allocator = gpa };
    http_client.initDefaultProxies(arena) catch |err| {
        std.debug.panic("failed to init http client: {s}", .{@errorName(err)});
    };
    defer http_client.deinit();

    const mirrors: []const []const u8 = mirrors: {
        if (true) break :mirrors &.{
            "https://pkg.machengine.org/zig",
            "https://zig.linus.dev/zig",
            "https://does.not.exist.com",
        };
        const raw: []const u8 = try httpGetZsf(arena, &http_client, mirrors_list_url);
        var buf: std.ArrayListUnmanaged([]const u8) = .empty;
        var it = std.mem.tokenizeScalar(u8, raw, '\n');
        while (it.next()) |mirror| try buf.append(arena, mirror);
        break :mirrors buf.items;
    };

    const download_json_raw: []const u8 = try httpGetZsf(arena, &http_client, download_json_url);
    const download_json: std.json.Value = std.json.parseFromSliceLeaky(std.json.Value, arena, download_json_raw, .{}) catch |err| {
        std.debug.panic("failed to parse download json: {s}", .{@errorName(err)});
    };
    const master_tarballs = parseMasterTarballs(arena, &download_json) catch |err| {
        std.debug.panic("failed to get master build info: {s}", .{@errorName(err)});
    };

    // allocated into gpa
    var files: std.ArrayListUnmanaged(File) = .empty;
    defer files.deinit(gpa);

    {
        const tarball_name = try std.fmt.allocPrint(arena, "zig-{s}.tar.xz", .{master_tarballs.version});
        const minisig_name = try std.fmt.allocPrint(arena, "{s}.minisig", .{tarball_name});
        try files.append(gpa, .{ .name = tarball_name, .version = null, .kind = .tarball });
        try files.append(gpa, .{ .name = minisig_name, .version = null, .kind = .minisig });
    }
    {
        const tarball_name = try std.fmt.allocPrint(arena, "zig-bootstrap-{s}.tar.xz", .{master_tarballs.version});
        const minisig_name = try std.fmt.allocPrint(arena, "{s}.minisig", .{tarball_name});
        try files.append(gpa, .{ .name = tarball_name, .version = null, .kind = .tarball });
        try files.append(gpa, .{ .name = minisig_name, .version = null, .kind = .minisig });
    }
    for (master_tarballs.tar_xz_targets) |target| {
        const tarball_name = try std.fmt.allocPrint(arena, "zig-{s}-{s}.tar.xz", .{ target, master_tarballs.version });
        const minisig_name = try std.fmt.allocPrint(arena, "{s}.minisig", .{tarball_name});
        for (master_targets) |t| {
            if (std.mem.eql(u8, target, t)) {
                try files.append(gpa, .{ .name = tarball_name, .version = null, .kind = .tarball });
                break;
            }
        }
        try files.append(gpa, .{ .name = minisig_name, .version = null, .kind = .minisig });
    }
    for (master_tarballs.zip_targets) |target| {
        const tarball_name = try std.fmt.allocPrint(arena, "zig-{s}-{s}.zip", .{ target, master_tarballs.version });
        const minisig_name = try std.fmt.allocPrint(arena, "{s}.minisig", .{tarball_name});
        for (master_targets) |t| {
            if (std.mem.eql(u8, target, t)) {
                try files.append(gpa, .{ .name = tarball_name, .version = null, .kind = .tarball });
                break;
            }
        }
        try files.append(gpa, .{ .name = minisig_name, .version = null, .kind = .minisig });
    }
    for (tarball_names) |tarball_name| {
        const zig_version = releaseTarballVersion(tarball_name);
        const minisig_name = try std.fmt.allocPrint(arena, "{s}.minisig", .{tarball_name});
        try files.append(gpa, .{ .name = tarball_name, .version = zig_version, .kind = .tarball });
        try files.append(gpa, .{ .name = minisig_name, .version = zig_version, .kind = .minisig });
    }

    {
        var n_tarball: usize = 0;
        var n_minisig: usize = 0;
        for (files.items) |*f| switch (f.kind) {
            .tarball => n_tarball += 1,
            .minisig => n_minisig += 1,
        };
        std.log.info("{d} mirrors; {d} tarballs; {d} signatures", .{ mirrors.len, n_tarball, n_minisig });
    }

    var main_out: std.ArrayListUnmanaged(u8) = .empty;
    defer main_out.deinit(gpa);

    try main_out.appendSlice(gpa, "| File Name | Zig Version |");
    for (mirrors) |mirror_url| try main_out.writer(gpa).print(" `{s}` |", .{mirror_url});
    try main_out.appendSlice(gpa, " \n|-|-|");
    for (mirrors) |_| try main_out.appendSlice(gpa, "-:|");
    try main_out.append(gpa, '\n');

    var sig_out = try main_out.clone(gpa);
    defer sig_out.deinit(gpa);

    var any_failures = false;
    const results = try arena.alloc(File.Result, mirrors.len);
    const total_tarball_time = try arena.alloc(u64, mirrors.len);
    const total_minisig_time = try arena.alloc(u64, mirrors.len);
    const div_tarball_time = try arena.alloc(u64, mirrors.len);
    const div_minisig_time = try arena.alloc(u64, mirrors.len);
    @memset(total_tarball_time, 0);
    @memset(total_minisig_time, 0);
    @memset(div_tarball_time, 0);
    @memset(div_minisig_time, 0);

    for (files.items) |*file| {
        std.log.info("{s}", .{file.name});
        try checkFile(gpa, arena, &http_client, mirrors, file, results);

        const total_time, const div_time, const out = switch (file.kind) {
            .tarball => .{ total_tarball_time, div_tarball_time, &main_out },
            .minisig => .{ total_minisig_time, div_minisig_time, &sig_out },
        };

        for (results, total_time, div_time) |res, *total_ns, *n| {
            switch (res) {
                .ok => |ns| {
                    total_ns.* += ns;
                    n.* += 1;
                },
                else => any_failures = true,
            }
        }

        const w = out.writer(gpa);
        try w.print("| `{s}` | {s}", .{ file.name, file.version orelse "master" });
        for (results) |res| try w.print(" | {}", .{res});
        try w.writeAll(" |\n");
    }

    try main_out.appendSlice(gpa, "| **Avg. time** | |");
    for (total_tarball_time, div_tarball_time) |total_ns, n| {
        const avg_ns: u64 = if (n == 0) 0 else total_ns / n;
        try main_out.writer(gpa).print(" {} |", .{std.fmt.fmtDuration(avg_ns)});
    }
    try sig_out.appendSlice(gpa, "| **Avg. time** | |");
    for (total_minisig_time, div_minisig_time) |total_ns, n| {
        const avg_ns: u64 = if (n == 0) 0 else total_ns / n;
        try sig_out.writer(gpa).print(" {} |", .{std.fmt.fmtDuration(avg_ns)});
    }

    var out_file = std.fs.cwd().createFile(out_filename, .{}) catch |err| {
        std.debug.panic("failed to open output file '{s}': {s}", .{ out_filename, @errorName(err) });
    };
    defer out_file.close();

    out_file.writer().print(
        \\## Tarballs
        \\
        \\{s}
        \\
        \\## Signatures
        \\
        \\{s}
        \\
    , .{ main_out.items, sig_out.items }) catch |err| {
        std.debug.panic("failed to write output: {s}", .{@errorName(err)});
    };

    if (any_failures) {
        return 1;
    } else {
        return 0;
    }
}

fn checkFile(
    gpa: Allocator,
    arena: Allocator,
    http_client: *std.http.Client,
    mirrors: []const []const u8,
    file: *const File,
    /// One element per element of `mirrors`.
    results: []File.Result,
) Allocator.Error!void {
    const trusted_url = if (file.version) |version|
        try std.fmt.allocPrint(arena, release_tarball_template, .{ version, file.name })
    else
        try std.fmt.allocPrint(arena, master_tarball_template, .{file.name});

    const trusted_data = try httpGetZsf(gpa, http_client, trusted_url);
    defer gpa.free(trusted_data);

    var wg: std.Thread.WaitGroup = .{};

    var oom: std.atomic.Value(bool) = .init(false);
    for (mirrors, results) |mirror_url, *mirror_result| {
        const url = try std.fmt.allocPrint(arena, "{s}/{s}", .{ mirror_url, file.name });
        wg.spawnManager(
            checkOneFile,
            .{ gpa, http_client, url, trusted_data, &oom, mirror_result },
        );
    }
    wg.wait();
    if (oom.raw) return error.OutOfMemory;
}

fn checkOneFile(
    gpa: Allocator,
    http_client: *std.http.Client,
    url: []const u8,
    trusted_data: []const u8,
    oom: *std.atomic.Value(bool),
    result: *File.Result,
) void {
    result.* = if (httpGet(gpa, http_client, url)) |get_result| switch (get_result) {
        .success => |success| res: {
            defer gpa.free(success.data);
            if (std.mem.eql(u8, success.data, trusted_data)) {
                break :res .{ .ok = success.query_ns };
            } else {
                break :res .content_mismatch;
            }
        },
        .err => |err| .{ .err = err },
        .bad_status => |s| .{ .bad_status = s },
    } else |err| switch (err) {
        error.OutOfMemory => return oom.store(true, .monotonic),
    };
}

const GetResult = union(enum) {
    err: anyerror,
    bad_status: std.http.Status,
    success: struct {
        /// Allocated into `gpa`, caller must free
        data: []u8,
        query_ns: u64,
    },
};
fn httpGet(
    gpa: Allocator,
    http_client: *std.http.Client,
    url: []const u8,
) Allocator.Error!GetResult {
    var buf: std.ArrayList(u8) = .init(gpa);
    defer buf.deinit();
    var timer = std.time.Timer.start() catch @panic("std.time.Timer not supported");
    const res = http_client.fetch(.{
        .method = .GET,
        .location = .{ .url = url },
        .response_storage = .{ .dynamic = &buf },
        .max_append_size = 512 * 1024 * 1024,
    }) catch |err| return .{ .err = err };
    if (res.status != .ok) {
        return .{ .bad_status = res.status };
    }
    return .{ .success = .{
        .data = try buf.toOwnedSlice(),
        .query_ns = timer.read(),
    } };
}
fn httpGetZsf(
    gpa: Allocator,
    http_client: *std.http.Client,
    url: []const u8,
) Allocator.Error![]u8 {
    switch (try httpGet(gpa, http_client, url)) {
        .err => |err| std.debug.panic("fetch '{s}' failed: {s}", .{ url, @errorName(err) }),
        .bad_status => |status| std.debug.panic("fetch '{s}' failed: bad status: {d} {s}", .{ url, @intFromEnum(status), status.phrase() orelse "?" }),
        .success => |res| return res.data,
    }
}

const MasterTarballs = struct {
    version: []const u8,
    /// Every target (e.g. 'x86_64-linux', 'aarch64-macos') which a .tar.xz binary tarball exists for.
    /// The tarball basename is 'zig-[target]-[version].tar.xz'.
    tar_xz_targets: []const []const u8,
    /// Every target (e.g. 'x86-windows') which a .zip binary tarball exists for.
    /// The tarball basename is 'zig-[target]-[version].zip'.
    zip_targets: []const []const u8,
};

fn parseMasterTarballs(arena: Allocator, root: *const std.json.Value) !MasterTarballs {
    var tar_xz_targets: std.ArrayListUnmanaged([]const u8) = .empty;
    var zip_targets: std.ArrayListUnmanaged([]const u8) = .empty;

    if (root.* != .object) return error.RootNotObject;
    const master_val = root.object.getPtr("master") orelse return error.DownloadMissingMaster;

    if (master_val.* != .object) return error.MasterNotObject;
    var master = try master_val.object.clone();

    const version_val = (master.fetchSwapRemove("version") orelse return error.MasterMissingVersion).value;
    if (version_val != .string) return error.VersionNotString;
    const version_str = version_val.string;

    _ = master.swapRemove("date");
    _ = master.swapRemove("docs");
    _ = master.swapRemove("stdDocs");
    _ = master.swapRemove("src");
    _ = master.swapRemove("bootstrap");

    for (master.keys(), master.values()) |target_name, *val| {
        if (val.* != .object) return error.BuildIsNotObject;
        const tarball_url_val = val.object.getPtr("tarball") orelse return error.BuildMissingTarball;
        if (tarball_url_val.* != .string) return error.TarballNotString;
        const tarball_url = tarball_url_val.string;
        if (std.mem.endsWith(u8, tarball_url, ".tar.xz")) {
            try tar_xz_targets.append(arena, target_name);
        } else if (std.mem.endsWith(u8, tarball_url, ".zip")) {
            try zip_targets.append(arena, target_name);
        } else {
            return error.BadTarballExtension;
        }
    }
    return .{
        .version = version_str,
        .tar_xz_targets = tar_xz_targets.items,
        .zip_targets = zip_targets.items,
    };
}

/// Asserts that `basename` is a valid release (i.e. *not* prerelease!) Zig tarball name.
fn releaseTarballVersion(basename: []const u8) []const u8 {
    assert(std.mem.startsWith(u8, basename, "zig-"));
    const ext_len = if (std.mem.endsWith(u8, basename, ".tar.xz"))
        ".tar.xz".len
    else if (std.mem.endsWith(u8, basename, ".zip"))
        ".zip".len
    else
        unreachable;
    const stem = basename[0 .. basename.len - ext_len];
    // `stem` is e.g. 'zig-x86_64-linux-0.14.1'
    const i = std.mem.lastIndexOfScalar(u8, stem, '-').?;
    const version = stem[i + 1 ..];
    assert(std.ascii.isDigit(version[0]));
    assert(std.ascii.isDigit(version[version.len - 1]));
    assert(std.mem.count(u8, version, ".") == 2);
    return version;
}

const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
