const std = @import("std");

test "simple test" {
    const allocator = std.testing.allocator;

    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(allocator);

    try list.append(allocator, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

// syntax
