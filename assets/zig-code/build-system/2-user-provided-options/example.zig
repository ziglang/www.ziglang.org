// zig-doctest: syntax --name example
const std = @import("std");

pub fn main() !void {
    std.debug.print("Hello World!\n", .{});
}
