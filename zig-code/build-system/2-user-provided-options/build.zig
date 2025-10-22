const std = @import("std");

pub fn build(b: *std.Build) void {
    const windows = b.option(bool, "windows", "Target Microsoft Windows") orelse false;

    const exe = b.addExecutable(.{
        .name = "hello",
        .root_module = b.createModule(.{
            .root_source_file = b.path("example.zig"),
            .target = b.resolveTargetQuery(.{
                .os_tag = if (windows) .windows else null,
            }),
        }),
    });

    b.installArtifact(exe);
}

// build=succeed
// additional_option=--help
