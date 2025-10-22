const std = @import("std");

pub fn build(b: *std.Build) void {
    const lang = b.option([]const u8, "language", "language of the greeting") orelse "en";
    const tool_run = b.addSystemCommand(&.{"jq"});
    tool_run.addArgs(&.{
        b.fmt(
            \\.["{s}"]
        , .{lang}),
        "-r", // raw output to omit quotes around the selected string
    });
    tool_run.addFileArg(b.path("words.json"));

    const output = tool_run.captureStdOut();

    b.getInstallStep().dependOn(&b.addInstallFileWithDir(output, .prefix, "word.txt").step);

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "hello",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const install_artifact = b.addInstallArtifact(exe, .{
        .dest_dir = .{ .override = .prefix },
    });
    b.getInstallStep().dependOn(&install_artifact.step);
}

// build=succeed
// additional_option=-Dlanguage=ja
// additional_option=--summary
// additional_option=all
