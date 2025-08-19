test "big float literal" {
    const val: f32 = 123_456_789;
    _ = val;
}

// test_error=type 'f32' cannot represent integer value '123456789'
