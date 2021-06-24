// zig-doctest: run --fail "Memory leak detected" --name leak
const std = @import("std");

pub fn main() !void {
    var gpalloc = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(!gpalloc.deinit());

    const alloc = &gpalloc.allocator;

    const u32_ptr = try alloc.create(u32);
    _ = u32_ptr; // silences unused variable error

    // oops I forgot to free!
}
