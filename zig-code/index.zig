const std = @import("std");
const parseInt = std.fmt.parseInt;

test "parse integers" {
    const input = "123 67 89,99";
    const gpa = std.testing.allocator;

    var list: std.ArrayList(u32) = .empty;
    // Ensure the list is freed at scope exit.
    // Try commenting out this line!
    defer list.deinit(gpa);

    var it = std.mem.tokenizeAny(u8, input, " ,");
    while (it.next()) |num| {
        const n = try parseInt(u32, num, 10);
        try list.append(gpa, n);
    }

    const expected = [_]u32{ 123, 67, 89, 99 };

    for (expected, list.items) |exp, actual| {
        try std.testing.expectEqual(exp, actual);
    }
}

// test
