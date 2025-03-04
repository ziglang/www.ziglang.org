const S = struct {
    x: u32,
    y: u32,
    const default: S = .{ .x = 1, .y = 2 };
    const other: S = .{ .x = 3, .y = 4 };
};
const Wrapper = struct {
    val: S = .default,
};
test "decl literal initializing struct field" {
    const a: Wrapper = .{};
    try std.testing.expectEqual(1, a.val.x);
    try std.testing.expectEqual(2, a.val.y);
    const b: Wrapper = .{ .val = .other };
    try std.testing.expectEqual(3, b.val.x);
    try std.testing.expectEqual(4, b.val.y);
}
const std = @import("std");

// test
