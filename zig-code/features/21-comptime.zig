const std = @import("std");
const assert = std.debug.assert;

fn fibonacci(x: u32) u32 {
    if (x <= 1) return x;
    return fibonacci(x - 1) + fibonacci(x - 2);
}

test "compile-time evaluation" {
    var array: [fibonacci(6)]i32 = undefined;

    @memset(&array, 42);

    comptime {
        assert(array.len == 12345);
    }
}

// test_safety=unreachable
