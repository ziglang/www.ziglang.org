// zig-doctest: build-system --fail "unable to execute binary" -- test --summary all
const std = @import("std");

const test_targets = [_]std.zig.CrossTarget{
    .{}, // native
    .{
        .cpu_arch = .x86_64,
        .os_tag = .linux,
    },
    .{
        .cpu_arch = .aarch64,
        .os_tag = .macos,
    },
};

pub fn build(b: *std.Build) void {
    const test_step = b.step("test", "Run unit tests");

    for (test_targets) |target| {
        const unit_tests = b.addTest(.{
            .root_source_file = .{ .path = "main.zig" },
            .target = target,
        });

        const run_unit_tests = b.addRunArtifact(unit_tests);
        test_step.dependOn(&run_unit_tests.step);
    }
}
