// zig-doctest: build-system
const std = @import("std");

pub fn build(b: *std.Build) void {
    const tool = b.addExecutable(.{
        .name = "generate_struct",
        .root_source_file = .{ .path = "tools/generate_struct.zig" },
    });

    const tool_step = b.addRunArtifact(tool);
    const output = tool_step.addOutputFileArg("person.zig");

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "hello",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    exe.addAnonymousModule("person", .{ .source_file = output });

    b.installArtifact(exe);
}
