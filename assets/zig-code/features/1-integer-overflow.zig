test "integer overflow at compile time" {
    const x: u8 = 255;
    _ = x + 1;
}

// test_safety=overflow
