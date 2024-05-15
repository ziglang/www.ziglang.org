// zig-doctest: build-system -- --summary all
const std = @import("std");

pub fn build(b: *std.Build) void {
    const tool = b.addExecutable(.{
        .name = "generate_struct",
        .root_source_file = b.path("tools/generate_struct.zig"),
        .target = b.host,
    });

    const tool_step = b.addRunArtifact(tool);
    const output = tool_step.addOutputFileArg("person.zig");

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "hello",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addAnonymousImport("person", .{
        .root_source_file = output,
    });

    b.installArtifact(exe);
}
