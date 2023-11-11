// zig-doctest: syntax --name main
const std = @import("std");

pub fn main() !void {
    std.debug.print("hello world\n", .{});
}
