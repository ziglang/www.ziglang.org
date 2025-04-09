const std = @import("std");
const word = @embedFile("word");

pub fn main() !void {
    try std.io.getStdOut().writer().print("Hello {s}\n", .{word});
}

// syntax
