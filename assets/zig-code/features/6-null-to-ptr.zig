test "null @intToPtr" {
    const foo: *i32 = @ptrFromInt(0x0);
    _ = foo;
}

// test_safety=zero
