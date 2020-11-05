{#code_begin|test_err#}
test "null @intToPtr" {
    const ptr = @intToPtr(*i32, 0x0);
}
{#code_end#}