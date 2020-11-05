{#code_begin|syntax#}
test "actually undefined behavior" {
    @setRuntimeSafety(false);
    var x: u8 = 255;
    x += 1; // XXX undefined behavior!
}
{#code_end#}