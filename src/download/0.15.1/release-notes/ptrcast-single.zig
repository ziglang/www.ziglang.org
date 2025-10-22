const std = @import("std");

test "value to byte slice with @ptrCast" {
    const val: u32 = 1;
    const bytes: []const u8 = @ptrCast(&val);
    switch (@import("builtin").target.cpu.arch.endian()) {
        .little => try std.testing.expect(std.mem.eql(u8, bytes, "\x01\x00\x00\x00")),
        .big => try std.testing.expect(std.mem.eql(u8, bytes, "\x00\x00\x00\x01")),
    }
}

// test
