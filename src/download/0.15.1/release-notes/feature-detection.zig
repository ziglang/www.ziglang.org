const something = struct {
    // In this example, `foo` is supported but `bar` is not.
    const have_foo = true;
    const have_bar = false;
    pub const foo = if (have_foo) 123 else {};
    pub const bar = if (have_bar) undefined else {};
};

test "use foo if supported" {
    if (@TypeOf(something.foo) == void) return error.SkipZigTest; // unsupported
    try expect(something.foo == 123);
}

test "use bar if supported" {
    if (@TypeOf(something.bar) == void) return error.SkipZigTest; // unsupported
    try expect(something.bar == 456);
}

const expect = @import("std").testing.expect;

// test
