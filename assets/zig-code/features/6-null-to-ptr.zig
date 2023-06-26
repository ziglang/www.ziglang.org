// zig-doctest: test --fail zero
test "null @intToPtr" {
    const foo: *i32 = @ptrFromInt(0x0);
    _ = foo;
}
