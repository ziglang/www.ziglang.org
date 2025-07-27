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

    const Result = union(enum) {
        /// Value is query time in nanoseconds.
        ok: u64,
        content_mismatch,
        bad_status: std.http.Status,
        fetch_error: GetResult.FetchError,

        pub fn format(res: Result, comptime fmt: []const u8, options: std.fmt.FormatOptions, w: anytype) !void {
            if (fmt.len != 0) std.fmt.invalidFmtError(fmt, res);
            _ = options;
            switch (res) {
                .ok => |query_ns| try w.print("{}", .{std.fmt.fmtDuration(query_ns)}),
                .content_mismatch => try w.writeAll(":warning: incorrect contents"),
                .fetch_error => |fe| try w.print(":warning: error: {s}", .{@errorName(fe.err)}),
                .bad_status => |s| try w.print(":warning: bad status: {d} {s}", .{ @intFromEnum(s), s.phrase() orelse "?" }),
            }
        }
    };
};

const Mirror = struct {
    url: []const u8,
    username: []const u8,
    email: []const u8,

    total_ns: u64,
    ns_div: u64,
    file_result: File.Result,

    const Parsed = struct {
        url: []const u8,
        username: []const u8,
        email: []const u8,
    };

    fn fromParsed(p: Parsed) Mirror {
        return .{
            .url = p.url,
            .username = p.username,
            .email = p.email,
            .total_ns = 0,
            .ns_div = 0,
            .file_result = undefined,
        };
    }
};

pub fn main() Allocator.Error!u8 {
    const gpa = std.heap.smp_allocator;

    var arena_state: std.heap.ArenaAllocator = .init(gpa);
    defer arena_state.deinit();
    var thread_safe_arena_state: std.heap.ThreadSafeAllocator = .{
        .child_allocator = arena_state.allocator(),
    };
    const arena = thread_safe_arena_state.allocator();

    const args = std.process.argsAlloc(arena) catch @panic("argsAlloc failed");
    if (args.len != 3) @panic("usage: check-mirrors <mirrors.ziggy> <out.md>");
    const mirrors_path = args[1];
    const out_path = args[2];

    var http_client: std.http.Client = .{ .allocator = gpa };
    http_client.initDefaultProxies(arena) catch |err| {
        std.debug.panic("failed to init http client: {s}", .{@errorName(err)});
    };
    defer http_client.deinit();

    const mirrors: []Mirror = mirrors: {
        const raw = std.fs.cwd().readFileAllocOptions(arena, mirrors_path, 1024 * 1024 * 8, null, .of(u8), 0) catch |err| {
            std.debug.panic("failed to read mirrors file '{s}': {s}", .{ mirrors_path, @errorName(err) });
        };
        const parsed = ziggy.parseLeaky([]const Mirror.Parsed, arena, raw, .{}) catch |err| {
            std.debug.panic("failed to parse mirrors file '{s}': {s}", .{ mirrors_path, @errorName(err) });
        };
        const mirrors = try arena.alloc(Mirror, parsed.len);
        for (mirrors, parsed) |*m, p| m.* = .fromParsed(p);
        break :mirrors mirrors;
    };

    const download_json_raw: []const u8 = try httpGetZsf(arena, arena, &http_client, download_json_url);
    const download_json: std.json.Value = std.json.parseFromSliceLeaky(std.json.Value, arena, download_json_raw, .{}) catch |err| {
        std.debug.panic("failed to parse download json: {s}", .{@errorName(err)});
    };
    const master_tarballs = parseMasterTarballs(arena, &download_json) catch |err| {
        std.debug.panic("failed to get master build info: {s}", .{@errorName(err)});
    };

    // allocated into gpa
    var tarballs: std.ArrayListUnmanaged(File) = .empty;
    defer tarballs.deinit(gpa);
    var minisigs: std.ArrayListUnmanaged(File) = .empty;
    defer minisigs.deinit(gpa);

    {
        const tarball_name = try std.fmt.allocPrint(arena, "zig-{s}.tar.xz", .{master_tarballs.version});
        const minisig_name = try std.fmt.allocPrint(arena, "{s}.minisig", .{tarball_name});
        try tarballs.append(gpa, .{ .name = tarball_name, .version = null });
        try minisigs.append(gpa, .{ .name = minisig_name, .version = null });
    }
    {
        const tarball_name = try std.fmt.allocPrint(arena, "zig-bootstrap-{s}.tar.xz", .{master_tarballs.version});
        const minisig_name = try std.fmt.allocPrint(arena, "{s}.minisig", .{tarball_name});
        try tarballs.append(gpa, .{ .name = tarball_name, .version = null });
        try minisigs.append(gpa, .{ .name = minisig_name, .version = null });
    }
    for (master_tarballs.tar_xz_targets) |target| {
        const tarball_name = try std.fmt.allocPrint(arena, "zig-{s}-{s}.tar.xz", .{ target, master_tarballs.version });
        const minisig_name = try std.fmt.allocPrint(arena, "{s}.minisig", .{tarball_name});
        for (master_targets) |t| {
            if (std.mem.eql(u8, target, t)) {
                try tarballs.append(gpa, .{ .name = tarball_name, .version = null });
                break;
            }
        }
        try minisigs.append(gpa, .{ .name = minisig_name, .version = null });
    }
    for (master_tarballs.zip_targets) |target| {
        const tarball_name = try std.fmt.allocPrint(arena, "zig-{s}-{s}.zip", .{ target, master_tarballs.version });
        const minisig_name = try std.fmt.allocPrint(arena, "{s}.minisig", .{tarball_name});
        for (master_targets) |t| {
            if (std.mem.eql(u8, target, t)) {
                try tarballs.append(gpa, .{ .name = tarball_name, .version = null });
                break;
            }
        }
        try minisigs.append(gpa, .{ .name = minisig_name, .version = null });
    }
    for (tarball_names) |tarball_name| {
        const zig_version = releaseTarballVersion(tarball_name);
        const minisig_name = try std.fmt.allocPrint(arena, "{s}.minisig", .{tarball_name});
        try tarballs.append(gpa, .{ .name = tarball_name, .version = zig_version });
        try minisigs.append(gpa, .{ .name = minisig_name, .version = zig_version });
    }

    std.log.info("{d} mirrors; {d} tarballs; {d} signatures", .{ mirrors.len, tarballs.items.len, minisigs.items.len });

    var root_prog_node = std.Progress.start(.{ .root_name = "check" });
    defer root_prog_node.end();
    const tarballs_prog_node = root_prog_node.start("tarballs", tarballs.items.len);
    const minisigs_prog_node = root_prog_node.start("signatures", minisigs.items.len);

    var any_failures = false;

    var out_al: std.ArrayListUnmanaged(u8) = .empty;
    defer out_al.deinit(gpa);
    const out = out_al.writer(gpa);

    var error_traces_out: std.ArrayListUnmanaged(u8) = .empty;
    defer error_traces_out.deinit(gpa);

    try out.writeAll("## Tarballs\n\n");

    // Write a table header that looks like this (minus the whitespace on the second line):
    //   | File Name | Zig Version | @uname1 | @uname2 | @uname3 |
    //   |-          |-            |-        |-        |-        |
    try out.writeAll("| File Name | Zig Version |");
    for (mirrors) |m| try out.print(" @{s} |", .{m.username});
    try out.writeAll("\n|-|-|");
    for (mirrors) |_| try out.writeAll("-:|");

    for (tarballs.items) |*file| {
        const prog_node = tarballs_prog_node.start(file.name, mirrors.len);
        defer prog_node.end();
        try checkFile(gpa, arena, &http_client, mirrors, file, prog_node);
        try out.print("\n| `{s}` | {s} |", .{ file.name, file.version orelse "master" });
        for (mirrors) |m| {
            if (m.file_result != .ok) any_failures = true;
            try out.print(" {} |", .{m.file_result});
            trace: {
                if (builtin.strip_debug_info) break :trace;
                const fe = switch (m.file_result) {
                    .fetch_error => |fe| fe,
                    else => break :trace,
                };
                const ert = fe.ert orelse break :trace;
                const self_info = std.debug.getSelfDebugInfo() catch break :trace;
                try error_traces_out.append(gpa, '\n');
                std.debug.writeStackTrace(ert, error_traces_out.writer(gpa), self_info, .no_color) catch |err| switch (err) {
                    error.OutOfMemory => |e| return e,
                    else => {},
                };
                try error_traces_out.append(gpa, '\n');
            }
        }
    }
    try out.writeAll("\n| **Avg. time** | |");
    for (mirrors) |*m| {
        const avg_ns: u64 = if (m.ns_div == 0) 0 else m.total_ns / m.ns_div;
        try out.print(" {} |", .{std.fmt.fmtDuration(avg_ns)});
        // Reset for below
        m.total_ns = 0;
        m.ns_div = 0;
    }

    if (error_traces_out.items.len > 0) {
        try out.print("\n\n### Error Traces\n\n```{s}```", .{error_traces_out.items});
        error_traces_out.clearRetainingCapacity();
    }

    try out.writeAll("\n\n## Signatures\n\n");

    // Same table header as before
    try out.writeAll("| File Name | Zig Version |");
    for (mirrors) |m| try out.print(" @{s} |", .{m.username});
    try out.writeAll("\n|-|-|");
    for (mirrors) |_| try out.writeAll("-:|");

    for (minisigs.items) |*file| {
        const prog_node = minisigs_prog_node.start(file.name, mirrors.len);
        defer prog_node.end();
        try checkFile(gpa, arena, &http_client, mirrors, file, prog_node);
        try out.print("\n| `{s}` | {s} |", .{ file.name, file.version orelse "master" });
        for (mirrors) |m| {
            if (m.file_result != .ok) any_failures = true;
            try out.print(" {} |", .{m.file_result});
            trace: {
                if (builtin.strip_debug_info) break :trace;
                const fe = switch (m.file_result) {
                    .fetch_error => |fe| fe,
                    else => break :trace,
                };
                const ert = fe.ert orelse break :trace;
                const self_info = std.debug.getSelfDebugInfo() catch break :trace;
                try error_traces_out.append(gpa, '\n');
                std.debug.writeStackTrace(ert, error_traces_out.writer(gpa), self_info, .no_color) catch |err| switch (err) {
                    error.OutOfMemory => |e| return e,
                    else => {},
                };
                try error_traces_out.append(gpa, '\n');
            }
        }
    }
    try out.writeAll("\n| **Avg. time** | |");
    for (mirrors) |*m| {
        const avg_ns: u64 = if (m.ns_div == 0) 0 else m.total_ns / m.ns_div;
        try out.print(" {} |", .{std.fmt.fmtDuration(avg_ns)});
        // No need to reset, we're not doing any more checks
    }

    if (error_traces_out.items.len > 0) {
        try out.print("\n\n### Error Traces\n\n```{s}```", .{error_traces_out.items});
        error_traces_out.clearRetainingCapacity();
    }

    try out.writeByte('\n');

    {
        var out_file = std.fs.cwd().createFile(out_path, .{}) catch |err| {
            std.debug.panic("failed to open output file '{s}': {s}", .{ out_path, @errorName(err) });
        };
        defer out_file.close();

        out_file.writeAll(out_al.items) catch |err| {
            std.debug.panic("failed to write output: {s}", .{@errorName(err)});
        };
    }

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
    /// Each mirror will have `file_result` populated.
    /// If that result is `.ok`, `total_ns` and `ns_div` are also updated.
    mirrors: []Mirror,
    file: *const File,
    prog_node: std.Progress.Node,
) Allocator.Error!void {
    const trusted_url = if (file.version) |version|
        try std.fmt.allocPrint(arena, release_tarball_template, .{ version, file.name })
    else
        try std.fmt.allocPrint(arena, master_tarball_template, .{file.name});

    const trusted_data = try httpGetZsf(gpa, arena, http_client, trusted_url);
    defer gpa.free(trusted_data);

    var wg: std.Thread.WaitGroup = .{};

    var oom: std.atomic.Value(bool) = .init(false);
    for (mirrors) |*m| {
        wg.spawnManager(
            checkOneFile,
            .{ gpa, arena, http_client, m, file, trusted_data, &oom, prog_node },
        );
    }
    wg.wait();
    if (oom.raw) return error.OutOfMemory;
}

fn checkOneFile(
    gpa: Allocator,
    arena: Allocator,
    http_client: *std.http.Client,
    mirror: *Mirror,
    file: *const File,
    trusted_data: []const u8,
    oom: *std.atomic.Value(bool),
    prog_node: std.Progress.Node,
) void {
    const mirror_prog_node = prog_node.start(mirror.username, 0);
    defer mirror_prog_node.end();

    const url = std.fmt.allocPrint(arena, "{s}/{s}?source=health-check", .{ mirror.url, file.name }) catch |err| switch (err) {
        error.OutOfMemory => return oom.store(true, .monotonic),
    };

    mirror.file_result = if (httpGet(gpa, arena, http_client, url)) |get_result| switch (get_result) {
        .success => |success| res: {
            defer gpa.free(success.data);
            if (std.mem.eql(u8, success.data, trusted_data)) {
                mirror.total_ns += success.query_ns;
                mirror.ns_div += 1;
                break :res .{ .ok = success.query_ns };
            } else {
                break :res .content_mismatch;
            }
        },
        .fetch_error => |fe| .{ .fetch_error = fe },
        .bad_status => |s| .{ .bad_status = s },
    } else |err| switch (err) {
        error.OutOfMemory => return oom.store(true, .monotonic),
    };
}

const GetResult = union(enum) {
    fetch_error: FetchError,
    bad_status: std.http.Status,
    success: struct {
        /// Allocated into `gpa`, caller must free
        data: []u8,
        query_ns: u64,
    },
    const FetchError = struct {
        err: anyerror,
        /// `ert.instruction_addresses` is allocated into `arena`.
        ert: ?std.builtin.StackTrace,
    };
};
fn httpGet(
    gpa: Allocator,
    arena: Allocator,
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
    }) catch |err| {
        const ert: ?std.builtin.StackTrace = if (@errorReturnTrace()) |ert| ert: {
            const new_addrs = try arena.dupe(usize, ert.instruction_addresses);
            break :ert .{ .index = ert.index, .instruction_addresses = new_addrs };
        } else null;
        return .{ .fetch_error = .{
            .err = err,
            .ert = ert,
        } };
    };
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
    arena: Allocator,
    http_client: *std.http.Client,
    url: []const u8,
) Allocator.Error![]u8 {
    switch (try httpGet(gpa, arena, http_client, url)) {
        .fetch_error => |fe| std.debug.panic("fetch '{s}' failed: {s}", .{ url, @errorName(fe.err) }),
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
const builtin = @import("builtin");
const ziggy = @import("ziggy");
