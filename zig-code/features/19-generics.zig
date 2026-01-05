const std = @import("std");

fn List(comptime T: type) type {
    return struct {
        items: []T,
        len: usize,
    };
}

pub fn main() void {
    var buffer: [10]i32 = undefined;
    var list: List(i32) = .{
        .items = &buffer,
        .len = 0,
    };
    list.items[0] = 1234;
    list.len += 1;

    std.debug.print("{d}\n", .{list.items.len});
}

// exe=succeed
