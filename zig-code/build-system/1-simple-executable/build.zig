const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "hello",
        .root_module = b.createModule(.{
            .root_source_file = b.path("hello.zig"),
            .target = b.graph.host,
        }),
    });

    b.installArtifact(exe);
}

// build=succeed
// additional_option=--summary
// additional_option=all
