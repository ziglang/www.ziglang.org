const std = @import("std");

pub fn build(b: *std.Build) void {
    const lang = b.option([]const u8, "language", "language of the greeting") orelse "en";
    const tool = b.addExecutable(.{
        .name = "word_select",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/word_select.zig"),
            .target = b.graph.host,
        }),
    });

    const tool_step = b.addRunArtifact(tool);
    tool_step.addArg("--input-file");
    tool_step.addFileArg(b.path("tools/words.json"));
    tool_step.addArg("--output-file");
    const output = tool_step.addOutputFileArg("word.txt");
    tool_step.addArgs(&.{ "--lang", lang });

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
// additional_option=--summary
// additional_option=all
