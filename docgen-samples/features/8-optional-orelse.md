{#code_begin|syntax#}
// malloc prototype included for reference
extern fn malloc(size: size_t) ?*u8;

fn doAThing() ?*Foo {
    const ptr = malloc(1234) orelse return null;
    // ...
}
{#code_end#}