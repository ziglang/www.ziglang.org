// zig-doctest: test --name optional_syntax
const std = @import("std");
const assert = std.debug.assert;

test "null @intToPtr" {
    const ptr: ?*i32 = @ptrFromInt(0x0);
    assert(ptr == null);
}
