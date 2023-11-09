// zig-doctest: build-system
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libfizzbuzz = b.addSharedLibrary(.{
        .name = "fizzbuzz",
        .root_source_file = .{ .path = "fizzbuzz.zig" },
        .target = target,
        .optimize = optimize,
    });

    //const exe = b.addExecutable(.{
    //    .name = "demo",
    //    .root_source_file = .{ .path = "demo.zig" },
    //    .target = target,
    //    .optimize = optimize,
    //});

    //exe.linkLibrary(libfizzbuzz);

    b.installArtifact(libfizzbuzz);
}
