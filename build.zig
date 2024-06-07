const std = @import("std");
const assert = std.debug.assert;

/// Used for updating the langref documentation version links of old releases.
const releases = [_][]const u8{
    "0.1.0",
    "0.1.1",
    "0.2.0",
    "0.3.0",
    "0.4.0",
    "0.5.0",
    "0.6.0",
    "0.7.0",
    "0.7.1",
    "0.8.0",
    "0.8.1",
    "0.9.0",
    "0.9.1",
    "0.10.0",
    "0.10.1",
    "0.11.0",
    "0.12.0",
    "0.13.0",
};

pub fn build(b: *std.Build) void {
    const doctest_dep = b.dependency("doctest", .{
        .target = b.host,
        .optimize = .Debug,
    });
    const doctest_exe = doctest_dep.artifact("doctest");
    const docgen_exe = doctest_dep.artifact("docgen");

    installReleaseNotes(b, doctest_exe, docgen_exe);

    for (releases) |release| {
        const input_wf = b.addWriteFiles();
        _ = input_wf.add("vernav", verNavHtml(b.allocator, release));

        const docgen_cmd = b.addRunArtifact(docgen_exe);
        docgen_cmd.addArgs(&.{"--code-dir"});
        docgen_cmd.addDirectoryArg(input_wf.getDirectory());

        docgen_cmd.addFileArg(b.path(b.fmt("src/documentation/{s}/index.html", .{release})));
        const generated = docgen_cmd.addOutputFileArg("index.html");

        const copy_generated = b.addWriteFiles();
        copy_generated.addCopyFileToSource(generated, b.fmt("content/documentation/{s}/index.html", .{release}));

        b.getInstallStep().dependOn(&copy_generated.step);
    }
}

fn installReleaseNotes(
    b: *std.Build,
    doctest_exe: *std.Build.Step.Compile,
    docgen_exe: *std.Build.Step.Compile,
) void {
    const dirname = "src/download/0.13.0/release-notes";
    var dir = b.build_root.handle.openDir(dirname, .{ .iterate = true }) catch |err| {
        std.debug.panic("unable to open '{s}' directory: {s}", .{ dirname, @errorName(err) });
    };
    defer dir.close();

    var wf = b.addWriteFiles();
    var it = dir.iterateAssumeFirstIteration();
    while (it.next() catch @panic("failed to read dir")) |entry| {
        if (std.mem.startsWith(u8, entry.name, ".") or entry.kind != .file)
            continue;

        const out_basename = b.fmt("{s}.out", .{std.fs.path.stem(entry.name)});
        const cmd = b.addRunArtifact(doctest_exe);
        cmd.addArgs(&.{
            "--zig",        b.graph.zig_exe,
            // TODO: enhance doctest to use "--listen=-" rather than operating
            // in a temporary directory
            "--cache-root", b.cache_root.path orelse ".",
        });
        if (b.zig_lib_dir) |p| {
            cmd.addArg("--zig-lib-dir");
            cmd.addDirectoryArg(p);
        }
        cmd.addArgs(&.{"-i"});
        cmd.addFileArg(b.path(b.fmt("{s}/{s}", .{ dirname, entry.name })));

        cmd.addArgs(&.{"-o"});
        _ = wf.addCopyFile(cmd.addOutputFileArg(out_basename), out_basename);
    }

    const docgen_cmd = b.addRunArtifact(docgen_exe);
    docgen_cmd.addArgs(&.{"--code-dir"});
    docgen_cmd.addDirectoryArg(wf.getDirectory());

    docgen_cmd.addFileArg(b.path("src/download/0.13.0/release-notes.html"));
    const generated = docgen_cmd.addOutputFileArg("release-notes.html");

    const copy_generated = b.addWriteFiles();
    copy_generated.addCopyFileToSource(generated, "content/download/0.13.0/release-notes.html");

    b.getInstallStep().dependOn(&copy_generated.step);
}

fn verNavHtml(arena: std.mem.Allocator, active_release: []const u8) []const u8 {
    errdefer @panic("OOM");
    var buffer: std.ArrayListUnmanaged(u8) = .{};
    var found = false;
    for (releases, 0..) |release, i| {
        if (std.mem.eql(u8, release, active_release)) {
            found = true;
            try buffer.appendSlice(arena, release);
            try buffer.appendSlice(arena, " |\n");
        } else {
            skip: {
                if (i + 1 >= releases.len) break :skip;
                const next_str = releases[i + 1];
                const this_parsed = std.SemanticVersion.parse(release) catch
                    std.debug.panic("bad semantic version: '{s}'", .{release});
                const next_parsed = std.SemanticVersion.parse(next_str) catch
                    std.debug.panic("bad semantic version: '{s}'", .{next_str});
                if (next_parsed.major == this_parsed.major and
                    next_parsed.minor == this_parsed.minor)
                {
                    assert(next_parsed.patch > this_parsed.patch);
                    continue;
                }
            }

            try buffer.appendSlice(arena, "<a href=\"https://ziglang.org/documentation/");
            try buffer.appendSlice(arena, release);
            try buffer.appendSlice(arena, "/\">");
            try buffer.appendSlice(arena, release);
            try buffer.appendSlice(arena, "</a> |\n");
        }
    }
    if (!found) std.debug.panic("release '{s}' not found", .{active_release});

    try buffer.appendSlice(arena, "<a href=\"https://ziglang.org/documentation/master/\">master</a>");

    return buffer.items;
}
