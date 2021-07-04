// zig-doctest: test --fail zero
test "null @intToPtr" {
    _ = @intToPtr(*i32, 0x0);
}
