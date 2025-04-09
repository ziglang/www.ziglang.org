const Buffer = struct {
    data: std.ArrayListUnmanaged(u32),
    fn initCapacity(allocator: std.mem.Allocator, capacity: usize) !Buffer {
        return .{ .data = try .initCapacity(allocator, capacity) };
    }
};
test "initialize Buffer with decl literal" {
    var b: Buffer = try .initCapacity(std.testing.allocator, 5);
    defer b.data.deinit(std.testing.allocator);
    b.data.appendAssumeCapacity(123);
    try std.testing.expectEqual(1, b.data.items.len);
    try std.testing.expectEqual(123, b.data.items[0]);
}
const std = @import("std");

// test
