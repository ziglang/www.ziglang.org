const std = @import("std");

pub fn main() void {
    const msg = "hello this  is dog";
    var it = std.mem.tokenizeAny(u8, msg, " ");
    while (it.next()) |item| {
        std.debug.print("{s}\n", .{item});
    }
}

// exe=succeed
