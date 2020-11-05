{#code_begin|test_err|overflow#}
test "integer overflow at runtime" {
    var x: u8 = 255;
    x += 1;
}
{#code_end#}