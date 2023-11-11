// zig-doctest: build-system -- -Dversion=1.2.3 --summary all
const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "app",
        .root_source_file = .{ .path = "app.zig" },
    });

    const version = b.option([]const u8, "version", "application version string") orelse "0.0.0";
    const enable_foo = detectWhetherToEnableLibFoo();

    const options = b.addOptions();
    options.addOption([]const u8, "version", version);
    options.addOption(bool, "have_libfoo", enable_foo);

    exe.addOptions("config", options);

    b.installArtifact(exe);
}

fn detectWhetherToEnableLibFoo() bool {
    return false;
}
