test "integer overflow at runtime" {
    var x: u8 = 255;
    x += 1;
}

// test_safety=overflow
