//! External dependencies:
//! * 7z
//! * tar
//! * xz
//! * gzip
//! * minisign
//! * git
//! * cmake
//! * ninja

const std = @import("std");
const Allocator = std.mem.Allocator;
const mem = std.mem;
const fatal = std.debug.panic;
const log = std.log;

const Target = struct {
    triple: []const u8,
    cpu: []const u8,
    key: []const u8,
    is_windows: bool = false,

    fn ext(t: Target) []const u8 {
        return if (t.is_windows) ".zip" else ".tar.xz";
    }
};
const targets = [_]Target{
    .{
        .triple = "x86_64-linux-musl",
        .cpu = "baseline",
        .key = "x86_64-linux",
    },
    .{
        .triple = "aarch64-macos-none",
        .cpu = "apple_a14",
        .key = "aarch64-macos",
    },
    .{
        .triple = "x86-windows-gnu",
        .cpu = "baseline",
        .key = "x86-windows",
        .is_windows = true,
    },
    .{
        .triple = "x86_64-macos-none",
        .cpu = "baseline",
        .key = "x86_64-macos",
    },
    .{
        .triple = "aarch64-linux-musl",
        .cpu = "baseline",
        .key = "aarch64-linux",
    },
    .{
        .triple = "riscv64-linux-musl",
        .cpu = "baseline",
        .key = "riscv64-linux",
    },
    .{
        .triple = "powerpc64le-linux-musl",
        .cpu = "baseline",
        .key = "powerpc64le-linux",
    },
    //.{
    //    .triple = "powerpc-linux-musl",
    //    .cpu = "baseline",
    //    .key = "powerpc-linux",
    //},
    .{
        .triple = "x86-linux-musl",
        .cpu = "baseline",
        .key = "x86-linux",
    },
    .{
        .triple = "x86_64-windows-gnu",
        .cpu = "baseline",
        .key = "x86_64-windows",
        .is_windows = true,
    },
    .{
        .triple = "aarch64-windows-gnu",
        .cpu = "baseline",
        .key = "aarch64-windows",
        .is_windows = true,
    },
    .{
        .triple = "arm-linux-musleabihf",
        .cpu = "baseline",
        .key = "armv7a-linux",
    },
    .{
        .triple = "loongarch64-linux-musl",
        .cpu = "baseline",
        .key = "loongarch64-linux",
    },
};

var arena_instance = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const arena = arena_instance.allocator();

pub fn main() !void {
    var env_map = try std.process.getEnvMap(arena);
    const args = try std.process.argsAlloc(arena);

    const www_prefix = args[1]; // example: "/var/www/html";
    const index_json_template_filename = args[1]; // example: "index.json";
    const now = std.time.timestamp();

    const website_dir = try std.fs.cwd().openDir(".", .{});
    const zig_dir = try std.fs.cwd().openDir("../zig", .{ .iterate = true });
    const work_dir = try std.fs.cwd().openDir("../..", .{});
    const bootstrap_dir = try work_dir.openDir("zig-bootstrap", .{ .iterate = true });
    const www_dir = try std.fs.cwd().makeOpenPath(www_prefix, .{});
    const builds_dir = try www_dir.makeOpenPath("builds", .{ .iterate = true });
    const std_docs_dir = try www_dir.makeOpenPath("documentation/master/std", .{});

    const GITHUB_OUTPUT = env_map.get("GITHUB_OUTPUT").?;
    const github_output = try std.fs.cwd().createFile(GITHUB_OUTPUT, .{});
    defer github_output.close();

    try env_map.put("PATH", "/home/ci/local/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin");
    try env_map.put("XZ_OPT", "-9");
    try env_map.put("CMAKE_GENERATOR", "Ninja");

    // Override the cache directories because they won't actually help other CI runs
    // which will be testing alternate versions of zig, and ultimately would just
    // fill up space on the hard drive for no reason.
    try env_map.put("ZIG_GLOBAL_CACHE_DIR", try bootstrap_dir.realpathAlloc(arena, "out/zig-global-cache"));
    try env_map.put("ZIG_LOCAL_CACHE_DIR", try bootstrap_dir.realpathAlloc(arena, "out/zig-local-cache"));

    const is_release = if (env_map.get("ZIG_RELEASE")) |ZIG_RELEASE| mem.eql(u8, ZIG_RELEASE, "true") else false;
    const zig_ver = if (env_map.get("ZIG_COMMIT")) |ZIG_COMMIT| v: {
        // Manually triggered workflow.
        try github_output.writeAll("skipped=yes\n"); // Prevent website deploy
        run(&env_map, zig_dir, &.{ "git", "checkout", ZIG_COMMIT });
        if (is_release) {
            log.info("Building development version from commit: {s}", .{ZIG_COMMIT});
        } else {
            log.info("Building release version from tag: {s}", .{ZIG_COMMIT});
        }
        break :v ZIG_COMMIT;
    } else v: {
        if (is_release) fatal("release requires explicit ZIG_COMMIT env var", .{});
        const GH_TOKEN = env_map.get("GH_TOKEN").?;
        const json_text = try fetch(
            "https://api.github.com/repos/ziglang/zig/actions/runs?branch=master&status=success&per_page=1&event=push",
            .{
                .authorization = .{ .override = print("Bearer {s}", .{GH_TOKEN}) },
            },
            &.{
                .{ .name = "accept", .value = "application/vnd.github+json" },
            },
        );
        const last_success = pluckLastSuccessFromJson(json_text);
        run(&env_map, zig_dir, &.{ "git", "checkout", last_success });
        const zig_ver = try zigVer(&env_map, zig_dir);
        log.info("Last commit with green CI: {s}", .{last_success});
        log.info("Zig version: {s}", .{zig_ver});

        const last_tarball = pluckLastTarballFromJsonFile(www_dir, "download/index.json");
        log.info("Last deployed version: {s}", .{last_tarball});

        if (std.mem.eql(u8, zig_ver, last_tarball)) {
            try github_output.writeAll("skipped=yes\n");
            log.info("Versions are equal, nothing to do here.", .{});
            return;
        }
        break :v zig_ver;
    };
    log.info("zig version: {s}", .{zig_ver});

    try work_dir.deleteTree("tarballs");
    var tarballs_dir = try work_dir.makeOpenPath("tarballs", .{});
    defer tarballs_dir.close();
    const zig_ver_sub_path = print("zig-{s}", .{zig_ver});
    var tarballs_zig_dir = try work_dir.makeOpenPath(zig_ver_sub_path, .{});
    defer tarballs_zig_dir.close();
    try copyTree(zig_dir, tarballs_zig_dir, &.{
        ".github",
        ".gitignore",
        ".gitattributes",
        ".git",
        ".mailmap",
        "ci",
        "build",
        "build-release",
        "build-debug",
        "zig-cache",
    });

    var template_map: std.StringHashMapUnmanaged([]const u8) = .empty;
    try template_map.put(arena, "master_version", zig_ver);
    try template_map.put(arena, "master_date", timestamp(now));

    const src_tarball_name = print("zig-{s}.tar.xz", .{zig_ver});
    run(&env_map, tarballs_dir, &.{
        "tar",
        "cfJ",
        src_tarball_name,
        print("zig-{s}/", .{zig_ver}),
        "--sort=name",
    });
    signAndMove(&env_map, tarballs_dir, src_tarball_name, builds_dir);
    try addTemplateEntry(&template_map, "src", builds_dir, src_tarball_name);

    run(&env_map, bootstrap_dir, &.{ "git", "clean", "-fd" });
    run(&env_map, bootstrap_dir, &.{ "git", "reset", "--hard", "HEAD" });
    run(&env_map, bootstrap_dir, &.{ "git", "fetch" });

    const branch = env_map.get("ZIG_BOOTSTRAP_BRANCH") orelse "master";
    run(&env_map, bootstrap_dir, &.{ "git", "checkout", print("origin/{s}", .{branch}) });

    {
        try bootstrap_dir.deleteTree("zig");
        try std.fs.rename(work_dir, zig_ver_sub_path, bootstrap_dir, "zig");
    }
    try updateLine(bootstrap_dir, "build", "ZIG_VERSION=", print("ZIG_VERSION=\"{s}\"\n", .{
        zig_ver,
    }));
    try updateLine(bootstrap_dir, "build.bat", "set ZIG_VERSION=", print("set ZIG_VERSION=\"{s}\"\r\n", .{
        zig_ver,
    }));
    try updateLine(bootstrap_dir, "README.md", " * zig ", print(" * zig {s}\n", .{
        zig_ver,
    }));
    try bootstrap_dir.deleteTree("out");

    {
        var tarballs_bootstrap_dir = try tarballs_dir.makeOpenPath(print("zig-bootstrap-{s}", .{zig_ver}), .{});
        defer tarballs_bootstrap_dir.close();
        try copyTree(bootstrap_dir, tarballs_bootstrap_dir, &.{
            ".git",
            ".gitattributes",
            ".github",
            ".gitignore",
        });
    }

    const bootstrap_src_tarball_name = print("zig-bootstrap-{s}.tar.xz", .{zig_ver});
    run(&env_map, tarballs_dir, &.{
        "tar",
        "cfJ",
        bootstrap_src_tarball_name,
        print("zig-bootstrap-{s}/", .{zig_ver}),
        "--sort=name",
    });
    signAndMove(&env_map, tarballs_dir, bootstrap_src_tarball_name, builds_dir);
    try addTemplateEntry(&template_map, "bootstrap", builds_dir, bootstrap_src_tarball_name);

    const zig_exe = try bootstrap_dir.realpathAlloc(arena, "out/host/bin/zig");

    for (targets) |target| {
        // NOTE: Debian's cmake (3.18.4) is too old for zig-bootstrap.
        run(&env_map, bootstrap_dir, &.{ "./build", target.triple, target.cpu });
    }

    // Delete builds older than 30 days so the server does not run out of disk space.
    try deleteOld(builds_dir, now);

    for (targets) |target| {
        const bootstrap_basename = print("zig-{s}-{s}", .{ target.triple, target.cpu });
        const user_basename = print("zig-{s}-{s}", .{ target.key, zig_ver });
        std.fs.rename(bootstrap_dir, bootstrap_basename, tarballs_dir, user_basename) catch |err| {
            fatal("failed to rename {s} to {s}: {s}", .{ bootstrap_basename, user_basename, @errorName(err) });
        };

        const tarball_filename = if (target.is_windows) t: {
            const tarball_filename = print("{s}.zip", .{user_basename});
            run(&env_map, tarballs_dir, &.{
                "7z", "a", tarball_filename, print("{s}/", .{user_basename}),
            });
            break :t tarball_filename;
        } else t: {
            const tarball_filename = print("{s}.tar.xz", .{user_basename});
            run(&env_map, tarballs_dir, &.{
                "tar", "cfJ", tarball_filename, print("{s}/", .{user_basename}), "--sort=name",
            });
            break :t tarball_filename;
        };
        signAndMove(&env_map, tarballs_dir, tarball_filename, builds_dir);
        try addTemplateEntry(&template_map, target.key, builds_dir, tarball_filename);
    }

    const index_json_basename = print("zig-{s}-index.json", .{zig_ver});
    try render(&template_map, index_json_template_filename, tarballs_dir, index_json_basename, .plain);
    signAndMove(&env_map, tarballs_dir, index_json_basename, builds_dir);

    // Instead of updating via git, update directly to prevent the www.ziglang.org git
    // repo from growing too big.
    _ = website_dir;
    //try updateWebsiteRepo(&env_map, builds_dir, index_json_basename, website_dir, "assets/download/index.json");
    try builds_dir.copyFile(index_json_basename, www_dir, "download/index.json", .{});
    const langref_path = print("zig-{s}-{s}/doc/langref.html", .{ targets[0].key, zig_ver });
    try tarballs_dir.copyFile(langref_path, www_dir, "documentation/master/index.html", .{});

    // Standard library autodocs are intentionally excluded from tarballs of
    // Zig but we want to host them on the website.
    run(&env_map, bootstrap_dir, &.{ zig_exe, "build-obj", "-fno-emit-bin", "-femit-docs=std", "zig/lib/std/std.zig" });

    gzipCopy(&env_map, bootstrap_dir, "std/index.html", std_docs_dir);
    gzipCopy(&env_map, bootstrap_dir, "std/main.js", std_docs_dir);
    gzipCopy(&env_map, bootstrap_dir, "std/main.wasm", std_docs_dir);
    gzipCopy(&env_map, bootstrap_dir, "std/sources.tar", std_docs_dir);

    if (is_release) {
        const download_dir = try www_dir.makeOpenPath(print("download/{s}", .{zig_ver}), .{});
        copyToRelease(builds_dir, download_dir, print("zig-{s}.tar.xz", .{zig_ver}));
        copyToRelease(builds_dir, download_dir, print("zig-{s}.tar.xz.minisign", .{zig_ver}));
        copyToRelease(builds_dir, download_dir, print("zig-bootstrap-{s}.tar.xz", .{zig_ver}));
        copyToRelease(builds_dir, download_dir, print("zig-bootstrap-{s}.tar.xz.minisign", .{zig_ver}));
        for (targets) |target| {
            copyToRelease(builds_dir, download_dir, print("zig-{s}-{s}.{s}", .{
                target.key, zig_ver, target.ext(),
            }));
            copyToRelease(builds_dir, download_dir, print("zig-{s}-{s}.{s}.minisign", .{
                target.key, zig_ver, target.ext(),
            }));
        }
    }
}

fn copyToRelease(builds_dir: std.fs.Dir, download_dir: std.fs.Dir, basename: []const u8) void {
    builds_dir.copyFile(basename, download_dir, basename, .{}) catch |err| {
        fatal("failed to copy {s} from builds to dowload dir: {s}", .{ basename, @errorName(err) });
    };
    // TODO update the json template with the new data
}

fn zigVer(env_map: *const std.process.EnvMap, dir: std.fs.Dir) ![]const u8 {
    // Make the `zig version` number consistent.
    // This will affect the "git describe" command below.
    run(env_map, dir, &.{ "git", "config", "core.abbrev", "9" });
    if (dir.access(".git/shallow", .{})) |_| {
        run(env_map, dir, &.{ "git", "fetch", "--tags", "--unshallow" });
    } else |err| switch (err) {
        error.FileNotFound => {
            run(env_map, dir, &.{ "git", "fetch", "--tags" });
        },
        else => |e| fatal("failed to check .git/shallow: {s}", .{@errorName(e)}),
    }

    const build_zig_contents = try dir.readFileAlloc(arena, "build.zig", 100 * 1024);
    const zig_version = v: {
        var line_it = mem.tokenizeAny(u8, build_zig_contents, "\r\n");
        while (line_it.next()) |line| {
            if (mem.startsWith(u8, line, "const zig_version: std.SemanticVersion = ")) {
                var it = mem.tokenizeAny(u8, line, " =.{,");
                var ver: std.SemanticVersion = .{ .major = 0, .minor = 0, .patch = 0 };
                while (it.next()) |token| {
                    if (mem.eql(u8, token, "major")) {
                        ver.major = try std.fmt.parseInt(u32, it.next().?, 0);
                    } else if (mem.eql(u8, token, "minor")) {
                        ver.minor = try std.fmt.parseInt(u32, it.next().?, 0);
                    } else if (mem.eql(u8, token, "patch")) {
                        ver.patch = try std.fmt.parseInt(u32, it.next().?, 0);
                    }
                }
                break :v ver;
            }
        }
        fatal("unable to find zig version in build.zig", .{});
    };

    const result = try std.process.Child.run(.{
        .allocator = arena,
        .cwd_dir = dir,
        .argv = &.{ "git", "describe", "--match", "*.*.*", "--tags" },
        .env_map = env_map,
    });

    switch (result.term) {
        .Exited => |code| {
            if (code != 0) {
                std.debug.print("{s}", .{result.stderr});
                std.process.exit(code);
            }
        },
        .Signal, .Stopped, .Unknown => {
            std.debug.print("{s}", .{result.stderr});
            std.process.exit(1);
        },
    }

    const git_describe = mem.trim(u8, result.stdout, " \n\r");

    const version_string = print("{d}.{d}.{d}", .{
        zig_version.major, zig_version.minor, zig_version.patch,
    });

    switch (mem.count(u8, git_describe, "-")) {
        0 => {
            // Tagged release version (e.g. 0.10.0).
            if (!mem.eql(u8, git_describe, version_string)) {
                fatal("Zig version '{s}' does not match Git tag '{s}'", .{
                    version_string, git_describe,
                });
            }
            return version_string;
        },
        2 => {
            // Untagged development build (e.g. 0.10.0-dev.2025+ecf0050a9).
            var it = mem.splitScalar(u8, git_describe, '-');
            const tagged_ancestor = it.first();
            const commit_height = it.next().?;
            const commit_id = it.next().?;

            const ancestor_ver = try std.SemanticVersion.parse(tagged_ancestor);
            if (zig_version.order(ancestor_ver) != .gt) {
                fatal("Zig version '{}' must be greater than tagged ancestor '{}'", .{ zig_version, ancestor_ver });
            }

            // Check that the commit hash is prefixed with a 'g' (a Git convention).
            if (commit_id.len < 1 or commit_id[0] != 'g') {
                fatal("Unexpected `git describe` output: {s}", .{git_describe});
            }

            // The version is reformatted in accordance with the https://semver.org specification.
            return print("{s}-dev.{s}+{s}", .{
                version_string, commit_height, commit_id[1..],
            });
        },
        else => {
            fatal("Unexpected `git describe` output: {s}", .{git_describe});
        },
    }
}

fn run(env_map: *const std.process.EnvMap, dir: std.fs.Dir, argv: []const []const u8) void {
    var child: std.process.Child = .init(argv, arena);
    child.cwd_dir = dir;
    child.env_map = env_map;
    const term = child.spawnAndWait() catch |err| {
        fatal("following command failed with {s}:\n{s}", .{ @errorName(err), allocPrintCmd(argv) });
    };
    switch (term) {
        .Exited => |code| {
            if (code == 0) return;
            fatal("following command exited with failure code {d}:\n{s}", .{ code, allocPrintCmd(argv) });
        },
        else => {
            fatal("following command terminated abnormally via {s}:\n{s}", .{ @tagName(term), allocPrintCmd(argv) });
        },
    }
}

fn allocPrintCmd(argv: []const []const u8) []u8 {
    var buf: std.ArrayListUnmanaged(u8) = .empty;
    for (argv) |arg| {
        buf.appendSlice(arena, arg) catch @panic("OOM");
        buf.append(arena, ' ') catch @panic("OOM");
    }
    buf.items.len -= 1;
    return buf.toOwnedSlice(arena) catch @panic("OOM");
}

fn fetch(url: []const u8, headers: std.http.Client.Request.Headers, extra_headers: []const std.http.Header) ![]u8 {
    var response: std.ArrayList(u8) = .init(arena);
    var client: std.http.Client = .{ .allocator = arena };
    const result = try client.fetch(.{
        .location = .{ .url = url },
        .response_storage = .{ .dynamic = &response },
        .headers = headers,
        .extra_headers = extra_headers,
    });
    if (result.status != .ok) fatal("fetch from {s} result: {s}", .{ url, @tagName(result.status) });
    return response.items;
}

fn pluckLastSuccessFromJson(json_text: []const u8) []const u8 {
    // ".workflow_runs[0].head_sha"
    const Response = struct {
        workflow_runs: []const WorkflowRun,
        const WorkflowRun = struct {
            head_sha: []const u8,
        };
    };
    const parsed = std.json.parseFromSliceLeaky(Response, arena, json_text, .{
        .ignore_unknown_fields = true,
        .parse_numbers = false,
    }) catch |err| {
        fatal("{s} when parsing this json text:\n{s}", .{ @errorName(err), json_text });
    };
    if (parsed.workflow_runs.len < 1) fatal("no workflow runs returned", .{});
    return parsed.workflow_runs[0].head_sha;
}

test pluckLastSuccessFromJson {
    try std.testing.expectEqualStrings("f925e1379aa53228610df9b7ffc3d87dbcce0dbb", pluckLastSuccessFromJson(example_response));
}

fn pluckLastTarballFromJsonFile(dir: std.fs.Dir, file_path: []const u8) []const u8 {
    // .master.version
    const json_text = dir.readFileAlloc(arena, file_path, 100 * 1024 * 1024) catch |err| {
        fatal("failed to open {s}: {s}", .{ file_path, @errorName(err) });
    };
    const Releases = struct {
        master: struct {
            version: []const u8,
        },
    };
    const parsed = std.json.parseFromSliceLeaky(Releases, arena, json_text, .{
        .ignore_unknown_fields = true,
        .parse_numbers = false,
    }) catch |err| {
        fatal("{s} when parsing this json text:\n{s}", .{ @errorName(err), json_text });
    };
    return parsed.master.version;
}

fn print(comptime fmt: []const u8, args: anytype) []u8 {
    return std.fmt.allocPrint(arena, fmt, args) catch @panic("OOM");
}

fn copyTree(src_dir: std.fs.Dir, dest_dir: std.fs.Dir, exclude: []const []const u8) !void {
    var it = try src_dir.walk(arena);
    next_entry: while (try it.next()) |entry| {
        for (exclude) |p| {
            if (mem.startsWith(u8, entry.path, p) and
                (entry.path.len == p.len or entry.path[p.len] == '/'))
            {
                continue :next_entry;
            }
        }
        switch (entry.kind) {
            .directory => {
                try dest_dir.makePath(entry.path);
            },
            .file => {
                src_dir.copyFile(entry.path, dest_dir, entry.path, .{}) catch |err| {
                    fatal("failed to copy {s}: {s}", .{ entry.path, @errorName(err) });
                };
            },
            else => continue,
        }
    }
}

fn updateLine(dir: std.fs.Dir, file_path: []const u8, prefix: []const u8, replacement: []const u8) !void {
    const contents = dir.readFileAlloc(arena, file_path, 10 * 1024 * 1024) catch |err| {
        fatal("failed to read {s}: {s}", .{ file_path, @errorName(err) });
    };
    var output: std.ArrayListUnmanaged(u8) = .empty;
    defer output.deinit(arena);
    var it = mem.splitScalar(u8, contents, '\n');
    while (it.next()) |line| {
        if (mem.startsWith(u8, line, prefix)) {
            try output.appendSlice(arena, replacement);
            try output.appendSlice(arena, it.rest());
            break;
        } else {
            try output.appendSlice(arena, line);
            try output.append(arena, '\n');
        }
    } else fatal("did not find match of '{s}' in {s}", .{ prefix, file_path });

    try dir.writeFile(.{
        .sub_path = file_path,
        .data = output.items,
    });
}

fn signAndMove(
    env_map: *const std.process.EnvMap,
    src_dir: std.fs.Dir,
    basename: []const u8,
    dest_dir: std.fs.Dir,
) void {
    std.fs.rename(src_dir, basename, dest_dir, basename) catch |err| {
        fatal("failed to move {s}: {s}", .{ basename, @errorName(err) });
    };
    run(env_map, dest_dir, &.{ "minisign", "-Sm", basename });
}

fn deleteOld(builds_dir: std.fs.Dir, now: i64) !void {
    var it = try builds_dir.walk(arena);
    while (try it.next()) |entry| {
        switch (entry.kind) {
            .file => {
                const stat = try builds_dir.statFile(entry.path);
                const delta_ns = now - stat.ctime;
                const days = @divTrunc(delta_ns, std.time.ns_per_day);
                if (days > 30) {
                    log.info("deleting {d}-day-old tarball {s}", .{ days, entry.path });
                    //try builds_dir.remove(entry.path); // TODO enable after verifying output
                } else {
                    log.info("not deleting {d}-day-old tarball {s}", .{ days, entry.path });
                }
            },
            else => continue,
        }
    }
}

fn addTemplateEntry(
    map: *std.StringHashMapUnmanaged([]const u8),
    name: []const u8,
    dir: std.fs.Dir,
    tarball_basename: []const u8,
) !void {
    const file = try dir.openFile(tarball_basename, .{});
    defer file.close();
    const size = (try file.stat()).size;
    const digest = try sha256sum(file, size);
    try map.put(arena, print("{s}_tarball", .{name}), tarball_basename);
    try map.put(arena, print("{s}_shasum", .{name}), print("{}", .{std.fmt.fmtSliceHexLower(&digest)}));
    try map.put(arena, print("{s}_bytesize", .{name}), print("{d}", .{size}));
}

fn sha256sum(file: std.fs.File, size: u64) ![32]u8 {
    var hasher: std.crypto.hash.sha2.Sha256 = .init(.{});
    var buffer: [4000]u8 = undefined;
    var remaining = size;
    while (remaining > 0) {
        const buf = buffer[0..@min(remaining, buffer.len)];
        const n = try file.read(buf);
        if (n == 0) return error.EndOfStream;
        hasher.update(buf);
        remaining -= n;
    }
    return hasher.finalResult();
}

fn timestamp(now: i64) []const u8 {
    const epoch_seconds: std.time.epoch.EpochSeconds = .{ .secs = @intCast(@divTrunc(now, std.time.ns_per_s)) };
    const epoch_day = epoch_seconds.getEpochDay();
    const year_day = epoch_day.calculateYearDay();
    const month_day = year_day.calculateMonthDay();
    return print("{d}-{d:0>2}-{d:0>2}", .{ year_day.year, @intFromEnum(month_day.month), month_day.day_index + 1 });
}

test timestamp {
    try std.testing.expectEqualStrings("2025-05-21", timestamp(1747871443764528578));
}

fn render(
    vars: *const std.StringHashMapUnmanaged([]const u8),
    in_file: []const u8,
    out_dir: std.fs.Dir,
    out_file: []const u8,
    fmt: enum {
        html,
        plain,
    },
) !void {
    const in_contents = try std.fs.cwd().readFileAlloc(arena, in_file, 1 * 1024 * 1024);

    var buffer = std.ArrayList(u8).init(arena);
    defer buffer.deinit();

    const State = enum {
        Start,
        OpenBrace,
        VarName,
        EndBrace,
    };
    const writer = buffer.writer();
    var state = State.Start;
    var var_name_start: usize = undefined;
    var line: usize = 1;
    for (in_contents, 0..) |byte, index| {
        switch (state) {
            State.Start => switch (byte) {
                '{' => {
                    state = State.OpenBrace;
                },
                else => try writer.writeByte(byte),
            },
            State.OpenBrace => switch (byte) {
                '{' => {
                    state = State.VarName;
                    var_name_start = index + 1;
                },
                else => {
                    try writer.writeByte('{');
                    try writer.writeByte(byte);
                    state = State.Start;
                },
            },
            State.VarName => switch (byte) {
                '}' => {
                    const var_name = in_contents[var_name_start..index];
                    if (vars.get(var_name)) |value| {
                        const trimmed = mem.trim(u8, value, " \r\n");
                        if (fmt == .html and mem.endsWith(u8, var_name, "bytesize")) {
                            const size = try std.fmt.parseInt(u64, trimmed, 10);
                            try writer.print("{:.1}", .{std.fmt.fmtIntSizeDec(size)});
                        } else {
                            try writer.writeAll(trimmed);
                        }
                    } else {
                        std.debug.print("line {d}: missing variable: {s}\n", .{ line, var_name });
                        try writer.writeAll("(missing)");
                    }
                    state = State.EndBrace;
                },
                else => {},
            },
            State.EndBrace => switch (byte) {
                '}' => {
                    state = State.Start;
                },
                else => {
                    fatal("line {d}: invalid byte: '0x{x}'", .{ line, byte });
                },
            },
        }
        if (byte == '\n') {
            line += 1;
        }
    }
    try out_dir.writeFile(.{ .sub_path = out_file, .data = buffer.items });
}

fn updateWebsiteRepo(
    env_map: *std.process.EnvMap,
    builds_dir: std.fs.Dir,
    index_json_basename: []const u8,
    website_dir: std.fs.Dir,
    assets_json_path: []const u8,
) !void {
    try builds_dir.copyFile(index_json_basename, website_dir, assets_json_path, .{});

    run(env_map, website_dir, &.{ "git", "config", "user.email", "ziggy@ziglang.org" });
    run(env_map, website_dir, &.{ "git", "config", "user.name", "Ziggy" });
    run(env_map, website_dir, &.{ "git", "add", "assets/download/index.json", "Ziggy" });
    run(env_map, website_dir, &.{ "git", "commit", "-m", "CI: update master branch builds" });
    run(env_map, website_dir, &.{ "git", "push" });
}

fn gzipCopy(env_map: *std.process.EnvMap, bootstrap_dir: std.fs.Dir, src: []const u8, dest_dir: std.fs.Dir) void {
    // TODO std lib is missing a way to pass an open file descriptor to a child process
    const argv = [_][]const u8{ "gzip", "-c", "-9", src };
    const result = std.process.Child.run(.{
        .allocator = arena,
        .cwd_dir = bootstrap_dir,
        .argv = &argv,
        .env_map = env_map,
    }) catch |err| {
        fatal("failed to run the following command with {s}:\n{s}", .{ @errorName(err), allocPrintCmd(&argv) });
    };
    switch (result.term) {
        .Exited => |code| {
            if (code != 0) {
                std.debug.print("{s}", .{result.stderr});
                fatal("following command exited with code {d}:\n{s}", .{ code, allocPrintCmd(&argv) });
            }
        },
        else => {
            std.debug.print("{s}", .{result.stderr});
            fatal("following command terminated abnormally:\n{s}", .{allocPrintCmd(&argv)});
        },
    }
    const new_name = print("documentation/master/{s}.gz", .{src});
    dest_dir.writeFile(.{
        .sub_path = new_name,
        .data = result.stdout,
    }) catch |err| {
        fatal("failed to write {s}: {s}", .{ new_name, @errorName(err) });
    };
}

const example_response =
    \\{
    \\  "total_count": 1305,
    \\  "workflow_runs": [
    \\    {
    \\      "id": 15156676549,
    \\      "head_sha": "f925e1379aa53228610df9b7ffc3d87dbcce0dbb"
    \\    }
    \\  ]
    \\}
;

const example_release_json =
    \\{
    \\  "master": {
    \\    "version": "0.14.0",
    \\    "date": "2025-03-05"
    \\  }
    \\}
;
