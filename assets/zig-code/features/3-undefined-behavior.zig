// zig-doctest: syntax
test "actually undefined behavior" {
    @setRuntimeSafety(false);
    var x: u8 = 255;
    x += 1; // XXX undefined behavior!
}
