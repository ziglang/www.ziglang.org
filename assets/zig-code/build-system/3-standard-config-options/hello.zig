// zig-doctest: syntax --name hello
const std = @import("std");

pub fn main() !void {
    std.debug.print("Hello World!\n", .{});
}
