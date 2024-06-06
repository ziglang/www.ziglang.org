const std = @import("std");

pub fn build(b: *std.Build) void {
    const doctest_dep = b.dependency("doctest", .{
        .target = b.host,
        .optimize = .Debug,
    });
    const doctest_exe = doctest_dep.artifact("doctest");
    const docgen_exe = doctest_dep.artifact("docgen");

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
