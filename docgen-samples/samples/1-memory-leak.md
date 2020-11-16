{#code_begin|exe_err|leak#}
const std = @import("std");

pub fn main() !void {
     var gpalloc = std.heap.GeneralPurposeAllocator(.{}){};
     defer std.debug.assert(!gpalloc.deinit());
     
     const alloc = &gpalloc.allocator;
     
     const u32_ptr = try alloc.create(u32);
     // oops I forgot to free!
}
{#code_end#}
