const std = @import("std");
const expect = std.testing.expect;

test "packed struct atomics" {
    const S = packed struct {
        a: u4,
        b: u4,
    };
    var x: S = .{ .a = 1, .b = 2 };
    const y: S = .{ .a = 3, .b = 4 };
    const prev = @atomicRmw(S, &x, .Xchg, y, .seq_cst);
    try expect(prev.b == 2);
    try expect(x.b == 4);
}

// test
