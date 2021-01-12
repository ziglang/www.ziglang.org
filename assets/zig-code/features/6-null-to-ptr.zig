// zig-doctest: test --fail zero
test "null @intToPtr" {
    const ptr = @intToPtr(*i32, 0x0);
}
