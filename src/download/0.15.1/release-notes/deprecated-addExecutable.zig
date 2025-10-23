pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "foo",
        .root_source_file = b.path("src/main.zig"),
        .target = b.graph.host,
        .optimize = .Debug,
    });
    b.installArtifact(exe);
}

test {
    _ = &build;
}
const std = @import("std");

// test_error=no field named 'root_source_file' in struct 'Build.ExecutableOptions'
