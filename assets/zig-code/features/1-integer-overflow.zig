// zig-doctest: test --fail overflow --name test
test "integer overflow at compile time" {
    const x: u8 = 255;
    _ = x + 1;
}
