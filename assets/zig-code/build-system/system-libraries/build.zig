// zig-doctest: build-system -- --summary all
const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "zip",
        .root_source_file = .{ .path = "zip.zig" },
        .target = b.host,
    });

    exe.linkSystemLibrary("z");
    exe.linkLibC();

    b.installArtifact(exe);
}
