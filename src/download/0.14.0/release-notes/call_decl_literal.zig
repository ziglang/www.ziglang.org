const S = struct {
    x: u32,
    y: u32,
    fn init(val: u32) S {
        return .{ .x = val + 1, .y = val + 2 };
    }
};
test "call decl literal" {
    const a: S = .init(100);
    try std.testing.expectEqual(101, a.x);
    try std.testing.expectEqual(102, a.y);
}
const std = @import("std");

// test
