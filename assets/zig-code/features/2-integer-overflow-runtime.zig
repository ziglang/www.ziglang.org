// zig-doctest: test --fail overflow
test "integer overflow at runtime" {
    var x: u8 = 255;
    x += 1;
}
