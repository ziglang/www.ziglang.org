{#code_begin|exe|generics#}
const std = @import("std");

fn List(comptime T: type) type {
    return struct {
        items: []T,
        len: usize,
    };
}

pub fn main() void {
    var buffer: [10]i32 = undefined;
    var list = List(i32){
        .items = &buffer,
        .len = 0,
    };

    std.debug.print("{}\n", .{list.items.len});
}
{#code_end#}