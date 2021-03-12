// zig-doctest: test --fail overflow --name test
test "integer overflow at runtime" {
    var x: u8 = 255;
    x += 1;
}
