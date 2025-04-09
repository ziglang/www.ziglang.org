const std = @import("std");
const config = @import("config");

const semver = std.SemanticVersion.parse(config.version) catch unreachable;

extern fn foo_bar() void;

pub fn main() !void {
    if (semver.major < 1) {
        @compileError("too old");
    }
    std.debug.print("version: {s}\n", .{config.version});

    if (config.have_libfoo) {
        foo_bar();
    }
}

// syntax
