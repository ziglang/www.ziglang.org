// zig-doctest: test --fail overflow
test "integer overflow at compile time" {
    const x: u8 = 255;
    const y = x + 1;
}
