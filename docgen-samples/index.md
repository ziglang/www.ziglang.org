{#code_begin|syntax#}
const std = @import("std");

// This is a placeholder!
// TODO: find a better example
//       currently available space: 28Lx50C

pub fn main() void {
    const msg = "hello this is dog";
    var it = std.mem.tokenize(msg, " ");
    while (it.next()) |item| {
        std.debug.print("{}\n", .{item});
    }
}
{#code_end#}