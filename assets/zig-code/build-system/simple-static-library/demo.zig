const std = @import("std");

extern fn fizzbuzz(n: usize) ?[*:0]const u8;

pub fn main() !void {
    const stdout = std.io.getStdOut();
    var bw = std.io.bufferedWriter(stdout.writer());
    const w = bw.writer();
    for (0..100) |n| {
        if (fizzbuzz(n)) |s| {
            try w.print("{s}\n", .{s});
        } else {
            try w.print("{d}\n", .{n});
        }
    }
    try bw.flush();
}

// syntax
