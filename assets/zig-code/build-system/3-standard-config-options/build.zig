// zig-doctest: build-system -- -Dtarget=x86_64-windows -Doptimize=ReleaseSmall
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "hello",
        .root_source_file = .{ .path = "hello.zig" },
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);
}
