// zig-doctest: build-system -- --summary all
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libfizzbuzz = b.addSharedLibrary(.{
        .name = "fizzbuzz",
        .root_source_file = b.path("fizzbuzz.zig"),
        .target = target,
        .optimize = optimize,
        .version = .{ .major = 1, .minor = 2, .patch = 3 },
    });

    b.installArtifact(libfizzbuzz);
}
