const std = @import("std");
const expect = std.testing.expect;

const Node = struct {
    next: *const Node,
};

const a: Node = .{ .next = &b };
const b: Node = .{ .next = &a };

test "example" {
    try expect(a.next == &b);
    try expect(b.next == &a);
}

// test
