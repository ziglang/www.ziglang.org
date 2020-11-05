{#code_begin|syntax#}
fn doAThing(optional_foo: ?*Foo) void {
    // do some stuff

    if (optional_foo) |foo| {
      doSomethingWithFoo(foo);
    }

    // do some stuff
}
{#code_end#}