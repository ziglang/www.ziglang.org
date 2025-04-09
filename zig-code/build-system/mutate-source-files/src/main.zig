const std = @import("std");
const Protocol = @import("protocol.zig");

pub fn main() !void {
    const header = try std.io.getStdIn().reader().readStruct(Protocol.Header);
    std.debug.print("header: {any}\n", .{header});
}

// syntax
