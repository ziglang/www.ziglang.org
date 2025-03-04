const Buffer = struct {
    foo: std.ArrayListUnmanaged(u32) = .empty,
};
test "default initialize Buffer" {
    var b: Buffer = .{};
    defer b.foo.deinit(std.testing.allocator);
    try b.foo.append(std.testing.allocator, 123);
    try std.testing.expectEqual(1, b.foo.items.len);
    try std.testing.expectEqual(123, b.foo.items[0]);
}
const std = @import("std");

// test
