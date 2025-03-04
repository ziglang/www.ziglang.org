const S = struct {
    x: u32,
    const default: S = .{ .x = 123 };
};
test "decl literal" {
    const val: S = .default;
    try std.testing.expectEqual(123, val.x);
}
const std = @import("std");

// test
