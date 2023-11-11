// zig-doctest: syntax --name zip
const std = @import("std");

extern fn zlibVersion() [*:0]const u8;

pub fn main() !void {
    std.debug.print("linked against zlib version: {s}\n", .{zlibVersion()});
}
