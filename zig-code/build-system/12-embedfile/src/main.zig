const std = @import("std");
const word = @embedFile("word");

pub fn main() !void {
    std.log.info("Hello {s}\n", .{word});
}

// syntax
