{#code_begin|test_err|overflow#}
test "integer overflow at compile time" {
    const x: u8 = 255;
    const y = x + 1;
}
{#code_end#}