// zig-doctest: test --fail zero
test "null @intToPtr" {
    _ = @ptrFromInt(*i32, 0x0);
}
