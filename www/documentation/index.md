# Zig Documentation {#introduction}

Zig is an open-source programming language designed for **robustness**, **optimality**, and
**clarity**.

Often the most efficient way to learn something new is to see examples, so this documentation shows
how to use each of Zig’s features. It is all on one page so you can search with your browser’s
search tool.

If you search for something specific in this documentation and do not find it, please [file an issue](https://github.com/zig-lang/www.ziglang.org/issues/new?title=I%20searched%20for%20___%20in%20the%20docs%20and%20didn%27t%20find%20it)
or [say something on IRC](https://webchat.freenode.net/?channels=%23zig).

## Hello World

```{.zig}
const io = @import("std").io;

pub fn main() -> %void {
    %%io.stdout.printf("Hello, world!\n");
}
```

```
$ zig build-exe hello.zig
$ ./hello
Hello, world!
```

See also:

-   [Values](#values)
-   [@import](#builtin-import)
-   [Errors](#errors)
-   [Root Source File](#root-source-file)

## Values

```{.zig}
const io = @import("std").io;
const os = @import("std").os;

// error declaration, makes `error.ArgNotFound` available
error ArgNotFound;

pub fn main() -> %void {
    // integers
    const one_plus_one: i32 = 1 + 1;
    %%io.stdout.printf("1 + 1 = {}\n", one_plus_one);

    // floats
    const seven_div_three: f32 = 7.0 / 3.0;
    %%io.stdout.printf("7.0 / 3.0 = {}\n", seven_div_three);

    // boolean
    %%io.stdout.printf("{}\n{}\n{}\n",
        true and false,
        true or false,
        !true);

    // nullable
    const nullable_value = if (os.args.count() >= 2) os.args.at(1) else null;
    %%io.stdout.printf("\nnullable\ntype: {}\nvalue: {}\n",
        @typeName(@typeOf(nullable_value)), nullable_value);

    // error union
    const number_or_error = if (os.args.count() >= 3) os.args.at(2) else error.ArgNotFound;
    %%io.stdout.printf("\nerror union\ntype: {}\nvalue: {}\n",
        @typeName(@typeOf(number_or_error)), number_or_error);
}
```

```
$ zig build-exe values.zig
$ ./values 
1 + 1 = 2
7.0 / 3.0 = 2.333333
false
true
false

nullable
type: ?[]const u8
value: null

error union
type: %[]const u8
value: error.ArgNotFound
```

### Primitive Types

| Name           | C Equivalent         | Description                                                                             |
|----------------|----------------------|-----------------------------------------------------------------------------------------|
| `i2`           | `(none)`             | signed 2-bit integer                                                                    |
| `u2`           | `(none)`             | unsigned 2-bit integer                                                                  |
| `i3`           | `(none)`             | signed 3-bit integer                                                                    |
| `u3`           | `(none)`             | unsigned 3-bit integer                                                                  |
| `i4`           | `(none)`             | signed 4-bit integer                                                                    |
| `u4`           | `(none)`             | unsigned 4-bit integer                                                                  |
| `i5`           | `(none)`             | signed 5-bit integer                                                                    |
| `u5`           | `(none)`             | unsigned 5-bit integer                                                                  |
| `i6`           | `(none)`             | signed 6-bit integer                                                                    |
| `u6`           | `(none)`             | unsigned 6-bit integer                                                                  |
| `i7`           | `(none)`             | signed 7-bit integer                                                                    |
| `u7`           | `(none)`             | unsigned 7-bit integer                                                                  |
| `i8`           | `int8_t`             | signed 8-bit integer                                                                    |
| `u8`           | `uint8_t`            | unsigned 8-bit integer                                                                  |
| `i16`          | `int16_t`            | signed 16-bit integer                                                                   |
| `u16`          | `uint16_t`           | unsigned 16-bit integer                                                                 |
| `i32`          | `int32_t`            | signed 32-bit integer                                                                   |
| `u32`          | `uint32_t`           | unsigned 32-bit integer                                                                 |
| `i64`          | `int64_t`            | signed 64-bit integer                                                                   |
| `u64`          | `uint64_t`           | unsigned 64-bit integer                                                                 |
| `i128`         | `__int128`           | signed 128-bit integer                                                                  |
| `u128`         | `unsigned __int128`  | unsigned 128-bit integer                                                                |
| `isize`        | `intptr_t`           | signed pointer sized integer                                                            |
| `usize`        | `uintptr_t`          | unsigned pointer sized integer                                                          |
| `c_short`      | `short`              | for ABI compatibility with C                                                            |
| `c_ushort`     | `unsigned short`     | for ABI compatibility with C                                                            |
| `c_int`        | `int`                | for ABI compatibility with C                                                            |
| `c_uint`       | `unsigned int`       | for ABI compatibility with C                                                            |
| `c_long`       | `long`               | for ABI compatibility with C                                                            |
| `c_ulong`      | `unsigned long`      | for ABI compatibility with C                                                            |
| `c_longlong`   | `long long`          | for ABI compatibility with C                                                            |
| `c_ulonglong`  | `unsigned long long` | for ABI compatibility with C                                                            |
| `c_longdouble` | `long double`        | for ABI compatibility with C                                                            |
| `c_void`       | `void`               | for ABI compatibility with C                                                            |
| `f32`          | `float`              | 32-bit floating point (23-bit mantissa)                                                 |
| `f64`          | `double`             | 64-bit floating point (52-bit mantissa)                                                 |
| `f128`         | (none)               | 128-bit floating point (112-bit mantissa)                                               |
| `bool`         | `bool`               | `true` or `false`                                                                       |
| `void`         | (none)               | 0 bit type                                                                              |
| `noreturn`     | (none)               | the type of `break`, `continue`, `goto`, `return`, `unreachable`, and `while (true) {}` |
| `type`         | (none)               | the type of types                                                                       |
| `error`        | (none)               | an error code                                                                           |

See also:

-   [Integers](#integers)
-   [Floats](#floats)
-   [void](#void)
-   [Errors](#errors)

### Primitive Values

| Name               | Description                            |
|--------------------|----------------------------------------|
| `true` and `false` | `bool` values                          |
| `null`             | used to set a nullable type to `null`  |
| `undefined`        | used to leave a value unspecified      |
| `this`             | refers to the thing in immediate scope |

See also:

-   [Nullables](#nullables)
-   [this](#this)

### String Literals

```{.zig}
const assert = @import("std").debug.assert;
const mem = @import("std").mem;

test "string literals" {
    // In Zig a string literal is an array of bytes.
    const normal_bytes = "hello";
    assert(@typeOf(normal_bytes) == [5]u8);
    assert(normal_bytes.len == 5);
    assert(normal_bytes[1] == 'e');
    assert('e' == '\x65');
    assert(mem.eql(u8, "hello", "h\x65llo"));

    // A C string literal is a null terminated pointer.
    const null_terminated_bytes = c"hello";
    assert(@typeOf(null_terminated_bytes) == &const u8);
    assert(null_terminated_bytes[5] == 0);
}
```

```
$ zig test string_literals.zig 
Test 1/1 string literals...OK
```

See also:

-   [Arrays](#arrays)
-   [Zig Test](#zig-test)

#### Escape Sequences {#string-literal-escapes}

| Escape Sequence | Name                                                               |
|-----------------|--------------------------------------------------------------------|
| `\n`            | Newline                                                            |
| `\r`            | Carriage Return                                                    |
| `\t`            | Tab                                                                |
| `\\`            | Backslash                                                          |
| `\'`            | Single Quote                                                       |
| `\"`            | Double Quote                                                       |
| `\xNN`          | hexadecimal 8-bit character code (2 digits)                        |
| `\uNNNN`        | hexadecimal 16-bit Unicode character code UTF-8 encoded (4 digits) |
| `\UNNNNNN`      | hexadecimal 24-bit Unicode character code UTF-8 encoded (6 digits) |

Note that the maximum valid Unicode point is `0x10ffff`.

#### Multiline String Literals

Multiline string literals have no escapes and can span across multiple lines. To start a multiline
string literal, use the `\\` token. Just like a comment, the string literal goes until the end of
the line. The end of the line is not included in the string literal. However, if the next line
begins with `\\` then a newline is appended and the string literal continues.

```{.zig}
const hello_world_in_c =
    \\#include <stdio.h>
    \\
    \\int main(int argc, char **argv) {
    \\    printf("hello world\n");
    \\    return 0;
    \\}
;
```

For a multiline C string literal, prepend `c` to each `\\`:

```{.zig}
const c_string_literal =
    c\\#include <stdio.h>
    c\\
    c\\int main(int argc, char **argv) {
    c\\    printf("hello world\n");
    c\\    return 0;
    c\\}
;
```

In this example the variable `c_string_literal` has type `&const char` and has a terminating null
byte.

See also:

-   [@embedFile](#builtin-embedFile)

### Assignment {#values-assignment}

Use `const` to assign a value to an identifier:

```{.zig}
const x = 1234;

fn foo() {
    // It works at global scope as well as inside functions.
    const y = 5678;

    // Once assigned, an identifier cannot be changed.
    y += 1;
}

test "assignment" {
    foo();
}
```

```
$ zig test test.zig 
test.zig:8:7: error: cannot assign to constant
    y += 1;
      ^
```

If you need a variable that you can modify, use `var`:

```{.zig}
const assert = @import("std").debug.assert;

test "var" {
    var y: i32 = 5678;

    y += 1;

    assert(y == 5679);
}
```

```
$ zig test test.zig 
Test 1/1 assignment...OK
```

Variables must be initialized:

```{.zig}
test "initialization" {
    var x: i32;

    x = 1;
}
```

```
$ zig test test.zig 
test.zig:3:5: error: variables must be initialized
    var x: i32;
    ^
```

Use `undefined` to leave variables uninitialized:

```{.zig}
const assert = @import("std").debug.assert;

test "init with undefined" {
    var x: i32 = undefined;
    x = 1;
    assert(x == 1);
}
```

```
$ zig test test.zig 
Test 1/1 init with undefined...OK
```

## Integers

### Integer Literals

```{.zig}
const decimal_int = 98222;
const hex_int = 0xff;
const another_hex_int = 0xFF;
const octal_int = 0o755;
const binary_int = 0b11110000;
```

### Runtime Integer Values

Integer literals have no size limitation, and if any undefined behavior occurs, the compiler catches
it.

However, once an integer value is no longer known at compile-time, it must have a known size, and is
vulnerable to undefined behavior.

```{.zig}
fn divide(a: i32, b: i32) -> i32 {
    return a / b;
}
```

In this function, values `a` and `b` are known only at runtime, and thus this division operation is
vulnerable to both integer overflow and division by zero.

Operators such as `+` and `-` cause undefined behavior on integer overflow. Also available are
operations such as `+%` and `-%` which are defined to have wrapping arithmetic on all targets.

See also:

-   [Integer Overflow](#undef-integer-overflow)
-   [Division By Zero](#undef-division-by-zero)
-   [Wrapping Operations](#undef-int-overflow-wrap)

## Floats

### Float Literals

```{.zig}
const floating_point = 123.0E+77;
const another_float = 123.0;
const yet_another = 123.0e+77;

const hex_floating_point = 0x103.70p-5;
const another_hex_float = 0x103.70;
const yet_another_hex_float = 0x103.70P-5;
```

### Floating Point Operations {#float-operations}

By default floating point operations use `Optimized` mode, but you can switch to `Strict` mode on a
per-block basis:

foo.zig

```{.zig}
const builtin = @import("builtin");
const big = f64(1 << 40);

export fn foo_strict(x: f64) -> f64 {
    @setFloatMode(this, builtin.FloatMode.Strict);
    return x + big - big;
}

export fn foo_optimized(x: f64) -> f64 {
    return x + big - big;
}
```

test.zig

```{.zig}
const io = @import("std").io;

extern fn foo_strict(x: f64) -> f64;
extern fn foo_optimized(x: f64) -> f64;

pub fn main() -> %void {
    const x = 0.001;
    %%io.stdout.printf("optimized = {}\n", foo_optimized(x));
    %%io.stdout.printf("strict = {}\n", foo_strict(x));
}
```

For this test we have to separate code into two object files - otherwise the optimizer figures out
all the values at compile-time, which operates in strict mode.

```
$ zig build-obj foo.zig --release-fast
$ zig build-exe test.zig --object foo.o
$ ./test
optimized = 1.0e-2
strict = 9.765625e-3
```

See also:

-   [@setFloatMode](#builtin-setFloatMode)
-   [Division By Zero](#undef-division-by-zero)

## Operators

### Table of Operators {#operators-table}

<table>
<tr>
  <th>
    Syntax
  </th>
  <th>
    Relevant Types
  </th>
  <th>
    Description
  </th>
  <th>
    Example
  </th>
</tr>
<tr>
  <td><pre><code class="zig">a + b
a += b</code></pre></td>
  <td>
    <ul>
      <li><a href="#integers">Integers</a></li>
      <li><a href="#floats">Floats</a></li>
    </ul>
  </td>
  <td>Addition.
    <ul>
      <li>Can cause <a href="#undef-integer-overflow">overflow</a> for integers.</li>
    </ul>
  </td>
  <td>
    <pre><code class="zig">2 + 5 == 7</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">a +% b
a +%= b</code></pre></td>
  <td>
    <ul>
      <li><a href="#integers">Integers</a></li>
    </ul>
  </td>
  <td>Wrapping Addition.
    <ul>
      <li>Guaranteed to have twos-complement wrapping behavior.</li>
    </ul>
  </td>
  <td>
    <pre><code class="zig">u32(@maxValue(u32)) +% 1 == 0</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">a - b
a -= b</code></pre></td>
  <td>
    <ul>
      <li><a href="#integers">Integers</a></li>
      <li><a href="#floats">Floats</a></li>
    </ul>
  </td>
  <td>Subtraction.
    <ul>
      <li>Can cause <a href="#undef-integer-overflow">overflow</a> for integers.</li>
    </ul>
  </td>
  <td>
    <pre><code class="zig">2 - 5 == -3</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">a -% b
a -%= b</code></pre></td>
  <td>
    <ul>
      <li><a href="#integers">Integers</a></li>
    </ul>
  </td>
  <td>Wrapping Subtraction.
    <ul>
      <li>Guaranteed to have twos-complement wrapping behavior.</li>
    </ul>
  </td>
  <td>
    <pre><code class="zig">u32(0) -% 1 == @maxValue(u32)</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">-a<code></pre></td>
  <td>
    <ul>
      <li><a href="#integers">Integers</a></li>
      <li><a href="#floats">Floats</a></li>
    </ul>
  </td>
  <td>
    Negation.
    <ul>
      <li>Can cause <a href="#undef-integer-overflow">overflow</a> for integers.</li>
    </ul>
  </td>
  <td>
    <pre><code class="zig">-1 == 0 - 1</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">-%a<code></pre></td>
  <td>
    <ul>
      <li><a href="#integers">Integers</a></li>
    </ul>
  </td>
  <td>
    Wrapping Negation.
    <ul>
      <li>Guaranteed to have twos-complement wrapping behavior.</li>
    </ul>
  </td>
  <td>
    <pre><code class="zig">-%i32(@minValue(i32)) == @minValue(i32)</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">a * b
a *= b</code></pre></td>
  <td>
    <ul>
      <li><a href="#integers">Integers</a></li>
      <li><a href="#floats">Floats</a></li>
    </ul>
  </td>
  <td>Multiplication.
    <ul>
      <li>Can cause <a href="#undef-integer-overflow">overflow</a> for integers.</li>
    </ul>
  </td>
  <td>
    <pre><code class="zig">2 * 5 == 10</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">a *% b
a *%= b</code></pre></td>
  <td>
    <ul>
      <li><a href="#integers">Integers</a></li>
    </ul>
  </td>
  <td>Wrapping Multiplication.
    <ul>
      <li>Guaranteed to have twos-complement wrapping behavior.</li>
    </ul>
  </td>
  <td>
    <pre><code class="zig">u8(200) *% 2 == 144</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">a / b
a /= b</code></pre></td>
  <td>
    <ul>
      <li><a href="#integers">Integers</a></li>
      <li><a href="#floats">Floats</a></li>
    </ul>
  </td>
  <td>Divison.
    <ul>
      <li>Can cause <a href="#undef-integer-overflow">overflow</a> for integers.</li>
      <li>Can cause <a href="#undef-division-by-zero">division by zero</a> for integers.</li>
      <li>Can cause <a href="#undef-division-by-zero">division by zero</a> for floats in <a href="#float-operations">FloatMode.Optimized Mode</a>.</li>
      <li>For non-compile-time-known signed integers, must use
        <a href="#builtin-divTrunc">@divTrunc</a>,
        <a href="#builtin-divFloor">@divFloor</a>, or
        <a href="#builtin-divExact">@divExact</a> instead of <code>/</code>.
      </li>
    </ul>
  </td>
  <td>
    <pre><code class="zig">10 / 5 == 2</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">a % b
a %= b</code></pre></td>
  <td>
    <ul>
      <li><a href="#integers">Integers</a></li>
      <li><a href="#floats">Floats</a></li>
    </ul>
  </td>
  <td>Remainder Division.
    <ul>
      <li>Can cause <a href="#undef-division-by-zero">division by zero</a> for integers.</li>
      <li>Can cause <a href="#undef-division-by-zero">division by zero</a> for floats in <a href="#float-operations">FloatMode.Optimized Mode</a>.</li>
      <li>For non-compile-time-known signed integers, must use
        <a href="#builtin-rem">@rem</a> or
        <a href="#builtin-mod">@mod</a> instead of <code>%</code>.
      </li>
    </ul>
  </td>
  <td>
    <pre><code class="zig">10 % 3 == 1</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">a &lt;&lt; b
a &lt;&lt;= b</code></pre></td>
  <td>
    <ul>
      <li><a href="#integers">Integers</a></li>
    </ul>
  </td>
  <td>Bit Shift Left.
    <ul>
      <li>See also <a href="#builtin-shlExact">@shlExact</a>.</li>
      <li>See also <a href="#builtin-shlWithOverflow">@shlWithOverflow</a>.</li>
    </ul>
  </td>
  <td>
    <pre><code class="zig">1 &lt;&lt; 8 == 256</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">a &gt;&gt; b
a &gt;&gt;= b</code></pre></td>
  <td>
    <ul>
      <li><a href="#integers">Integers</a></li>
    </ul>
  </td>
  <td>Bit Shift Right.
    <ul>
      <li>See also <a href="#builtin-shrExact">@shrExact</a>.</li>
    </ul>
  </td>
  <td>
    <pre><code class="zig">10 &gt;&gt; 1 == 5</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">a &amp; b
a &amp;= b</code></pre></td>
  <td>
    <ul>
      <li><a href="#integers">Integers</a></li>
    </ul>
  </td>
  <td>Bitwise AND.
  </td>
  <td>
    <pre><code class="zig">0b011 &amp; 0b101 == 0b001</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">a | b
a |= b</code></pre></td>
  <td>
    <ul>
      <li><a href="#integers">Integers</a></li>
    </ul>
  </td>
  <td>Bitwise OR.
  </td>
  <td>
    <pre><code class="zig">0b010 | 0b100 == 0b110</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">a ^ b
a ^= b</code></pre></td>
  <td>
    <ul>
      <li><a href="#integers">Integers</a></li>
    </ul>
  </td>
  <td>Bitwise XOR.
  </td>
  <td>
    <pre><code class="zig">0b011 ^ 0b101 == 0b110</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">~a<code></pre></td>
  <td>
    <ul>
      <li><a href="#integers">Integers</a></li>
    </ul>
  </td>
  <td>
    Bitwise NOT.
  </td>
  <td>
    <pre><code class="zig">~u8(0b0101111) == 0b1010000</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">a ?? b</code></pre></td>
  <td>
    <ul>
      <li><a href="#nullables">Nullables</a></li>
    </ul>
  </td>
  <td>If <code>a</code> is <code>null</code>,
    returns <code>b</code> ("default value"),
    otherwise returns the unwrapped value of <code>a</code>.
    Note that <code>b</code> may be a value of type <a href="#noreturn">noreturn</a>.
  </td>
  <td>
    <pre><code class="zig">const value: ?u32 = null;
const unwrapped = value ?? 1234;
unwrapped == 1234</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">??a</code></pre></td>
  <td>
    <ul>
      <li><a href="#nullables">Nullables</a></li>
    </ul>
  </td>
  <td>
    Equivalent to:
    <pre><code class="zig">a ?? unreachable</code></pre>
  </td>
  <td>
    <pre><code class="zig">const value: ?u32 = 5678;
??value == 5678</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">a %% b
a %% |err| b</code></pre></td>
  <td>
    <ul>
      <li><a href="#errors">Error Unions</a></li>
    </ul>
  </td>
  <td>If <code>a</code> is an <code>error</code>,
    returns <code>b</code> ("default value"),
    otherwise returns the unwrapped value of <code>a</code>.
    Note that <code>b</code> may be a value of type <a href="#noreturn">noreturn</a>.
    <code>err</code> is the <code>error</code> and is in scope of the expression <code>b</code>.
  </td>
  <td>
    <pre><code class="zig">const value: %u32 = null;
const unwrapped = value %% 1234;
unwrapped == 1234</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">%%a</code></pre></td>
  <td>
    <ul>
      <li><a href="#errors">Error Unions</a></li>
    </ul>
  </td>
  <td>Equivalent to:
    <pre><code class="zig">a %% unreachable</code></pre>
  </td>
  <td>
    <pre><code class="zig">const value: %u32 = 5678;
%%value == 5678</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">a and b<code></pre></td>
  <td>
    <ul>
      <li><a href="#primitive-types">bool</a></li>
    </ul>
  </td>
  <td>
    If <code>a</code> is <code>false</code>, returns <code>false</code>
    without evaluating <code>b</code>. Otherwise, retuns <code>b</code>.
  </td>
  <td>
    <pre><code class="zig">false and true == false</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">a or b<code></pre></td>
  <td>
    <ul>
      <li><a href="#primitive-types">bool</a></li>
    </ul>
  </td>
  <td>
    If <code>a</code> is <code>true</code>, returns <code>true</code>
    without evaluating <code>b</code>. Otherwise, retuns <code>b</code>.
  </td>
  <td>
    <pre><code class="zig">false or true == true</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">!a<code></pre></td>
  <td>
    <ul>
      <li><a href="#primitive-types">bool</a></li>
    </ul>
  </td>
  <td>
    Boolean NOT.
  </td>
  <td>
    <pre><code class="zig">!false == true</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">a == b<code></pre></td>
  <td>
    <ul>
      <li><a href="#integers">Integers</a></li>
      <li><a href="#floats">Floats</a></li>
      <li><a href="#primitive-types">bool</a></li>
      <li><a href="#primitive-types">type</a></li>
    </ul>
  </td>
  <td>
    Returns <code>true</code> if a and b are equal, otherwise returns <code>false</code>.
  </td>
  <td>
    <pre><code class="zig">(1 == 1) == true</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">a == null<code></pre></td>
  <td>
    <ul>
      <li><a href="#nullables">Nullables</a></li>
    </ul>
  </td>
  <td>
    Returns <code>true</code> if a is <code>null</code>, otherwise returns <code>false</code>.
  </td>
  <td>
    <pre><code class="zig">const value: ?u32 = null;
value == null</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">a != b<code></pre></td>
  <td>
    <ul>
      <li><a href="#integers">Integers</a></li>
      <li><a href="#floats">Floats</a></li>
      <li><a href="#primitive-types">bool</a></li>
      <li><a href="#primitive-types">type</a></li>
    </ul>
  </td>
  <td>
    Returns <code>false</code> if a and b are equal, otherwise returns <code>true</code>.
  </td>
  <td>
    <pre><code class="zig">(1 != 1) == false</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">a &gt; b<code></pre></td>
  <td>
    <ul>
      <li><a href="#integers">Integers</a></li>
      <li><a href="#floats">Floats</a></li>
    </ul>
  </td>
  <td>
    Returns <code>true</code> if a is greater than b, otherwise returns <code>false</code>.
  </td>
  <td>
    <pre><code class="zig">(2 &gt; 1) == true</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">a &gt;= b<code></pre></td>
  <td>
    <ul>
      <li><a href="#integers">Integers</a></li>
      <li><a href="#floats">Floats</a></li>
    </ul>
  </td>
  <td>
    Returns <code>true</code> if a is greater than or equal to b, otherwise returns <code>false</code>.
  </td>
  <td>
    <pre><code class="zig">(2 &gt;= 1) == true</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">a &lt; b<code></pre></td>
  <td>
    <ul>
      <li><a href="#integers">Integers</a></li>
      <li><a href="#floats">Floats</a></li>
    </ul>
  </td>
  <td>
    Returns <code>true</code> if a is less than b, otherwise returns <code>false</code>.
  </td>
  <td>
    <pre><code class="zig">(1 &lt; 2) == true</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">a &lt;= b<code></pre></td>
  <td>
    <ul>
      <li><a href="#integers">Integers</a></li>
      <li><a href="#floats">Floats</a></li>
    </ul>
  </td>
  <td>
    Returns <code>true</code> if a is less than or equal to b, otherwise returns <code>false</code>.
  </td>
  <td>
    <pre><code class="zig">(1 &lt;= 2) == true</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">a ++ b<code></pre></td>
  <td>
    <ul>
      <li><a href="#arrays">Arrays</a></li>
    </ul>
  </td>
  <td>
    Array concatenation.
    <ul>
      <li>Only available when <code>a</code> and <code>b</code> are <a href="#comptime">compile-time known</a>.
    </ul>
  </td>
  <td>
    <pre><code class="zig">const mem = @import("std").mem;
const array1 = []u32{1,2};
const array2 = []u32{3,4};
const together = array1 ++ array2;
mem.eql(u32, together, []u32{1,2,3,4})</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">a ** b<code></pre></td>
  <td>
    <ul>
      <li><a href="#arrays">Arrays</a></li>
    </ul>
  </td>
  <td>
    Array multiplication.
    <ul>
      <li>Only available when <code>a</code> and <code>b</code> are <a href="#comptime">compile-time known</a>.
    </ul>
  </td>
  <td>
    <pre><code class="zig">const mem = @import("std").mem;
const pattern = "ab" ** 3;
mem.eql(u8, pattern, "ababab")</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">*a<code></pre></td>
  <td>
    <ul>
      <li><a href="#pointers">Pointers</a></li>
    </ul>
  </td>
  <td>
    Pointer dereference.
  </td>
  <td>
    <pre><code class="zig">const x: u32 = 1234;
const ptr = &amp;x;
*x == 1234</code></pre>
  </td>
</tr>
<tr>
  <td><pre><code class="zig">&amp;a<code></pre></td>
  <td>
    All types
  </td>
  <td>
    Address of.
  </td>
  <td>
    <pre><code class="zig">const x: u32 = 1234;
const ptr = &amp;x;
*x == 1234</code></pre>
  </td>
</tr>
</table>

### Precedence {#operators-precedence}

```{.zig}
x() x[] x.y
!x -x -%x ~x *x &x ?x %x %%x ??x
x{}
* / % ** *%
+ - ++ +% -%
<< >>
&
^
|
== != < > <= >=
and
or
?? %%
= *= /= %= += -= <<= >>= &= ^= |=
```

## Arrays

```{.zig}
const assert = @import("std").debug.assert;
const mem = @import("std").mem;

// array literal
const message = []u8{'h', 'e', 'l', 'l', 'o'};

// get the size of an array
comptime {
    assert(message.len == 5);
}

// a string literal is an array literal
const same_message = "hello";

comptime {
    assert(mem.eql(u8, message, same_message));
    assert(@typeOf(message) == @typeOf(same_message));
}

test "iterate over an array" {
    var sum: usize = 0;
    for (message) |byte| {
        sum += byte;
    }
    assert(sum == usize('h') + usize('e') + usize('l') * 2 + usize('o'));
}

// modifiable array
var some_integers: [100]i32 = undefined;

test "modify an array" {
    for (some_integers) |*item, i| {
        *item = i32(i);
    }
    assert(some_integers[10] == 10);
    assert(some_integers[99] == 99);
}

// array concatenation works if the values are known
// at compile time
const part_one = []i32{1, 2, 3, 4};
const part_two = []i32{5, 6, 7, 8};
const all_of_it = part_one ++ part_two;
comptime {
    assert(mem.eql(i32, all_of_it, []i32{1,2,3,4,5,6,7,8}));
}

// remember that string literals are arrays
const hello = "hello";
const world = "world";
const hello_world = hello ++ " " ++ world;
comptime {
    assert(mem.eql(u8, hello_world, "hello world"));
}

// ** does repeating patterns
const pattern = "ab" ** 3;
comptime {
    assert(mem.eql(u8, pattern, "ababab"));
}

// initialize an array to zero
const all_zero = []u16{0} ** 10;

comptime {
    assert(all_zero.len == 10);
    assert(all_zero[5] == 0);
}

// use compile-time code to initialize an array
var fancy_array = {
    var initial_value: [10]Point = undefined;
    for (initial_value) |*pt, i| {
        *pt = Point {
            .x = i32(i),
            .y = i32(i) * 2,
        };
    }
    initial_value
};
const Point = struct {
    x: i32,
    y: i32,
};

test "compile-time array initalization" {
    assert(fancy_array[4].x == 4);
    assert(fancy_array[4].y == 8);
}

// call a function to initialize an array
var more_points = []Point{makePoint(3)} ** 10;
fn makePoint(x: i32) -> Point {
    Point {
        .x = x,
        .y = x * 2,
    }
}
test "array initialization with function calls" {
    assert(more_points[4].x == 3);
    assert(more_points[4].y == 6);
    assert(more_points.len == 10);
}
```

```
$ zig test arrays.zig 
Test 1/4 iterate over an array...OK
Test 2/4 modify an array...OK
Test 3/4 compile-time array initalization...OK
Test 4/4 array initialization with function calls...OK
```

See also:

-   [for](#for)
-   [Slices](#slices)

## Pointers

```{.zig}
const assert = @import("std").debug.assert;

test "address of syntax" {
    // Get the address of a variable:
    const x: i32 = 1234;
    const x_ptr = &x;

    // Deference a pointer:
    assert(*x_ptr == 1234);

    // When you get the address of a const variable, you get a const pointer.
    assert(@typeOf(x_ptr) == &const i32);

    // If you want to mutate the value, you'd need an address of a mutable variable:
    var y: i32 = 5678;
    const y_ptr = &y;
    assert(@typeOf(y_ptr) == &i32);
    *y_ptr += 1;
    assert(*y_ptr == 5679);
}

test "pointer array access" {
    // Pointers do not support pointer arithmetic. If you
    // need such a thing, use array index syntax:

    var array = []u8{1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    const ptr = &array[1];

    assert(array[2] == 3);
    ptr[1] += 1;
    assert(array[2] == 4);
}

test "pointer slicing" {
    // In Zig, we prefer using slices over null-terminated pointers.
    // You can turn a pointer into a slice using slice syntax:
    var array = []u8{1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    const ptr = &array[1];
    const slice = ptr[1..3];

    assert(slice.ptr == &ptr[1]);
    assert(slice.len == 2);

    // Slices have bounds checking and are therefore protected
    // against this kind of undefined behavior. This is one reason
    // we prefer slices to pointers.
    assert(array[3] == 4);
    slice[1] += 1;
    assert(array[3] == 5);
}

comptime {
    // Pointers work at compile-time too, as long as you don't use
    // @ptrCast.
    var x: i32 = 1;
    const ptr = &x;
    *ptr += 1;
    x += 1;
    assert(*ptr == 3);
}

test "@ptrToInt and @intToPtr" {
    // To convert an integer address into a pointer, use @intToPtr:
    const ptr = @intToPtr(&i32, 0xdeadbeef);

    // To convert a pointer to an integer, use @ptrToInt:
    const addr = @ptrToInt(ptr);

    assert(@typeOf(addr) == usize);
    assert(addr == 0xdeadbeef);
}

comptime {
    // Zig is able to do this at compile-time, as long as
    // ptr is never dereferenced.
    const ptr = @intToPtr(&i32, 0xdeadbeef);
    const addr = @ptrToInt(ptr);
    assert(@typeOf(addr) == usize);
    assert(addr == 0xdeadbeef);
}

test "volatile" {
    // In Zig, loads and stores are assumed to not have side effects.
    // If a given load or store should have side effects, such as
    // Memory Mapped Input/Output (MMIO), use `volatile`:
    const mmio_ptr = @intToPtr(&volatile u8, 0x12345678);

    // Now loads and stores with mmio_ptr are guaranteed to all happen
    // and in the same order as in source code.
    assert(@typeOf(mmio_ptr) == &volatile u8);
}

test "nullable pointers" {
    // Pointers cannot be null. If you want a null pointer, use the nullable
    // prefix `?` to make the pointer type nullable.
    var ptr: ?&i32 = null;

    var x: i32 = 1;
    ptr = &x;

    assert(*??ptr == 1);

    // Nullable pointers are the same size as normal pointers, because pointer
    // value 0 is used as the null value.
    assert(@sizeOf(?&i32) == @sizeOf(&i32));
}

test "pointer casting" {
    // To convert one pointer type to another, use @ptrCast. This is an unsafe
    // operation that Zig cannot protect you against. Use @ptrCast only when other
    // conversions are not possible.
    const bytes = []u8{0x12, 0x12, 0x12, 0x12};
    const u32_ptr = @ptrCast(&const u32, &bytes[0]);
    assert(*u32_ptr == 0x12121212);

    // Even this example is contrived - there are better ways to do the above than
    // pointer casting. For example, using a slice narrowing cast:
    const u32_value = ([]const u32)(bytes[0..])[0];
    assert(u32_value == 0x12121212);

    // And even another way, the most straightforward way to do it:
    assert(@bitCast(u32, bytes) == 0x12121212);
}
      
test "pointer child type" {
    // pointer types have a `child` field which tells you the type they point to.
    assert((&u32).child == u32);
}
```

```
$ zig test test.zig 
Test 1/8 address of syntax...OK
Test 2/8 pointer array access...OK
Test 3/8 pointer slicing...OK
Test 4/8 @ptrToInt and @intToPtr...OK
Test 5/8 volatile...OK
Test 6/8 nullable pointers...OK
Test 7/8 pointer casting...OK
Test 8/8 pointer child type...OK
```

### Alignment

Each type has an **alignment** - a number of bytes such that, when a value of the type is loaded
from or stored to memory, the memory address must be evenly divisible by this number. You can use
[@alignOf](#builtin-alignOf) to find out this value for any type.

Alignment depends on the CPU architecture, but is always a power of two, and less than `1 << 29`.

In Zig, a pointer type has an alignment value. If the value is equal to the alignment of the
underlying type, it can be omitted from the type:

```{.zig}
const assert = @import("std").debug.assert;
const builtin = @import("builtin");

test "variable alignment" {
    var x: i32 = 1234;
    const align_of_i32 = @alignOf(@typeOf(x));
    assert(@typeOf(&x) == &i32);
    assert(&i32 == &align(align_of_i32) i32);
    if (builtin.arch == builtin.Arch.x86_64) {
        assert((&i32).alignment == 4);
    }
}
```

In the same way that a `&i32` can be implicitly cast to a `&const i32`, a pointer with a larger
alignment can be implicitly cast to a pointer with a smaller alignment, but not vice versa.

You can specify alignment on variables and functions. If you do this, then pointers to them get the
specified alignment:

```{.zig}
const assert = @import("std").debug.assert;

var foo: u8 align(4) = 100;

test "global variable alignment" {
    assert(@typeOf(&foo).alignment == 4);
    assert(@typeOf(&foo) == &align(4) u8);
    const slice = (&foo)[0..1];
    assert(@typeOf(slice) == []align(4) u8);
}

fn derp() align(@sizeOf(usize) * 2) -> i32 { 1234 }
fn noop1() align(1) {}
fn noop4() align(4) {}

test "function alignment" {
    assert(derp() == 1234);
    assert(@typeOf(noop1) == fn() align(1));
    assert(@typeOf(noop4) == fn() align(4));
    noop1();
    noop4();
}
```

If you have a pointer or a slice that has a small alignment, but you know that it actually has a
bigger alignment, use [@alignCast](#builtin-alignCast) to change the pointer into a more aligned
pointer. This is a no-op at runtime, but inserts a [safety check](#undef-incorrect-pointer-alignment):

```{.zig}
const assert = @import("std").debug.assert;

test "pointer alignment safety" {
    var array align(4) = []u32{0x11111111, 0x11111111};
    const bytes = ([]u8)(array[0..]);
    assert(foo(bytes) == 0x11111111);
}
fn foo(bytes: []u8) -> u32 {
    const slice4 = bytes[1..5];
    const int_slice = ([]u32)(@alignCast(4, slice4));
    return int_slice[0];
}
```

```{.zig}
$ zig test test.zig
Test 1/1 pointer alignment safety...incorrect alignment
/home/andy/dev/zig/build/lib/zig/std/special/zigrt.zig:16:35: 0x0000000000203525 in ??? (test)
        @import("std").debug.panic("{}", message_ptr[0..message_len]);
                                  ^
/home/andy/dev/zig/build/test.zig:10:45: 0x00000000002035ec in ??? (test)
    const int_slice = ([]u32)(@alignCast(4, slice4));
                                            ^
/home/andy/dev/zig/build/test.zig:6:15: 0x0000000000203439 in ??? (test)
    assert(foo(bytes) == 0x11111111);
              ^
/home/andy/dev/zig/build/lib/zig/std/special/test_runner.zig:9:21: 0x00000000002162d8 in ??? (test)
        test_fn.func();
                    ^
/home/andy/dev/zig/build/lib/zig/std/special/bootstrap.zig:60:21: 0x0000000000216197 in ??? (test)
    return root.main();
                    ^
/home/andy/dev/zig/build/lib/zig/std/special/bootstrap.zig:47:13: 0x0000000000216050 in ??? (test)
    callMain(argc, argv, envp) %% std.os.posix.exit(1);
            ^
/home/andy/dev/zig/build/lib/zig/std/special/bootstrap.zig:34:25: 0x0000000000215fa0 in ??? (test)
    posixCallMainAndExit()
                        ^

Tests failed. Use the following command to reproduce the failure:
./test
```

### Type Based Alias Analysis

Zig uses Type Based Alias Analysis (also known as Strict Aliasing) to perform some optimizations.
This means that pointers of different types must not alias the same memory, with the exception of
`u8`. Pointers to `u8` can alias any memory.

As an example, this code produces undefined behavior:

```{.zig}
*@ptrCast(&u32, f32(12.34))
```

Instead, use [@bitCast](#builtin-bitCast):

```{.zig}
@bitCast(u32, f32(12.34))
```

As an added benefit, the `@bitcast` version works at compile-time.

See also:

-   [Slices](#slices)
-   [Memory](#memory)

## Slices

```{.zig}
const assert = @import("std").debug.assert;

test "basic slices" {
    var array = []i32{1, 2, 3, 4};
    // A slice is a pointer and a length. The difference between an array and
    // a slice is that the array's length is part of the type and known at
    // compile-time, whereas the slice's length is known at runtime.
    // Both can be accessed with the `len` field.
    const slice = array[0..array.len];
    assert(slice.ptr == &array[0]);
    assert(slice.len == array.len);

    // Slices have array bounds checking. If you try to access something out
    // of bounds, you'll get a safety check failure:
    slice[10] += 1;
}
```

```
$ zig test test.zig 
Test 1/1 basic slices...index out of bounds
lib/zig/std/special/zigrt.zig:16:35: 0x0000000000203455 in ??? (test)
        @import("std").debug.panic("{}", message_ptr[0..message_len]);
                                  ^
test.zig:15:10: 0x0000000000203334 in ??? (test)
    slice[10] += 1;
         ^
lib/zig/std/special/test_runner.zig:9:21: 0x0000000000214b1a in ??? (test)
        test_fn.func();
                    ^
lib/zig/std/special/bootstrap.zig:60:21: 0x00000000002149e7 in ??? (test)
    return root.main();
                    ^
lib/zig/std/special/bootstrap.zig:47:13: 0x00000000002148a0 in ??? (test)
    callMain(argc, argv, envp) %% std.os.posix.exit(1);
            ^
lib/zig/std/special/bootstrap.zig:34:25: 0x00000000002147f0 in ??? (test)
    posixCallMainAndExit()
                        ^

Tests failed. Use the following command to reproduce the failure:
./test
```

This is one reason we prefer slices to pointers.

```{.zig}
const assert = @import("std").debug.assert;
const mem = @import("std").mem;
const fmt = @import("std").fmt;

test "using slices for strings" {
    // Zig has no concept of strings. String literals are arrays of u8, and
    // in general the string type is []u8 (slice of u8).
    // Here we implicitly cast [5]u8 to []const u8
    const hello: []const u8 = "hello";
    const world: []const u8 = "世界";

    var all_together: [100]u8 = undefined;
    // You can use slice syntax on an array to convert an array into a slice.
    const all_together_slice = all_together[0..];
    // String concatenation example:
    const hello_world = fmt.bufPrint(all_together_slice, "{} {}", hello, world);

    // Generally, you can use UTF-8 and not worry about whether something is a
    // string. If you don't need to deal with individual characters, no need
    // to decode.
    assert(mem.eql(u8, hello_world, "hello 世界"));
}

test "slice pointer" {
    var array: [10]u8 = undefined;
    const ptr = &array[0];

    // You can use slicing syntax to convert a pointer into a slice:
    const slice = ptr[0..5];
    slice[2] = 3;
    assert(slice[2] == 3);
    // The slice is mutable because we sliced a mutable pointer.
    assert(@typeOf(slice) == []u8);

    // You can also slice a slice:
    const slice2 = slice[2..3];
    assert(slice2.len == 1);
    assert(slice2[0] == 3);
}

test "slice widening" {
    // Zig supports slice widening and slice narrowing. Cast a slice of u8
    // to a slice of anything else, and Zig will perform the length conversion.
    const array = []u8{0x12, 0x12, 0x12, 0x12, 0x13, 0x13, 0x13, 0x13};
    const slice = ([]const u32)(array[0..]);
    assert(slice.len == 2);
    assert(slice[0] == 0x12121212);
    assert(slice[1] == 0x13131313);
}
```

```
$ zig test test.zig 
Test 1/3 using slices for strings...OK
Test 2/3 slice pointer...OK
Test 3/3 slice widening...OK
```

See also:

-   [Pointers](#pointers)
-   [for](#for)
-   [Arrays](#arrays)

## struct

```{.zig}
// Declare a struct.
// Zig gives no guarantees about the order of fields and whether or
// not there will be padding.
const Point = struct {
    x: f32,
    y: f32,
};

// Maybe we want to pass it to OpenGL so we want to be particular about
// how the bytes are arranged.
const Point2 = packed struct {
    x: f32,
    y: f32,
};


// Declare an instance of a struct.
const p = Point {
    .x = 0.12,
    .y = 0.34,
};

// Maybe we're not ready to fill out some of the fields.
var p2 = Point {
    .x = 0.12,
    .y = undefined,
};

// Structs can have methods
// Struct methods are not special, they are only namespaced
// functions that you can call with dot syntax.
const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn init(x: f32, y: f32, z: f32) -> Vec3 {
        return Vec3 {
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub fn dot(self: &const Vec3, other: &const Vec3) -> f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }
};

const assert = @import("std").debug.assert;
test "dot product" {
    const v1 = Vec3.init(1.0, 0.0, 0.0);
    const v2 = Vec3.init(0.0, 1.0, 0.0);
    assert(v1.dot(v2) == 0.0);

    // Other than being available to call with dot syntax, struct methods are
    // not special. You can reference them as any other declaration inside
    // the struct:
    assert(Vec3.dot(v1, v2) == 0.0);
}

// Structs can have global declarations.
// Structs can have 0 fields.
const Empty = struct {
    pub const PI = 3.14;
};
test "struct namespaced variable" {
    assert(Empty.PI == 3.14);
    assert(@sizeOf(Empty) == 0);

    // you can still instantiate an empty struct
    const does_nothing = Empty {};
}

// struct field order is determined by the compiler for optimal performance.
// however, you can still calculate a struct base pointer given a field pointer:
fn setYBasedOnX(x: &f32, y: f32) {
    const point = @fieldParentPtr(Point, "x", x);
    point.y = y;
}
test "field parent pointer" {
    var point = Point {
        .x = 0.1234,
        .y = 0.5678,
    };
    setYBasedOnX(&point.x, 0.9);
    assert(point.y == 0.9);
}

// You can return a struct from a function. This is how we do generics
// in Zig:
fn LinkedList(comptime T: type) -> type {
    return struct {
        pub const Node = struct {
            prev: ?&Node,
            next: ?&Node,
            data: T,
        };

        first: ?&Node,
        last:  ?&Node,
        len:   usize,
    };
}

test "linked list" {
    // Functions called at compile-time are memoized. This means you can
    // do this:
    assert(LinkedList(i32) == LinkedList(i32));

    var list = LinkedList(i32) {
        .first = null,
        .last = null,
        .len = 0,
    };
    assert(list.len == 0);

    // Since types are first class values you can instantiate the type
    // by assigning it to a variable:
    const ListOfInts = LinkedList(i32);
    assert(ListOfInts == LinkedList(i32));

    var node = ListOfInts.Node {
        .prev = null,
        .next = null,
        .data = 1234,
    };
    var list2 = LinkedList(i32) {
        .first = &node,
        .last = &node,
        .len = 1,
    };
    assert((??list2.first).data == 1234);
}
```

```
$ zig test structs.zig 
Test 1/4 dot product...OK
Test 2/4 struct namespaced variable...OK
Test 3/4 field parent pointer...OK
Test 4/4 linked list...OK
```

See also:

-   [comptime](#comptime)
-   [@fieldParentPtr](#builtin-fieldParentPtr)

## enum

```{.zig}
const assert = @import("std").debug.assert;
const mem = @import("std").mem;

// Declare an enum.
const Type = enum {
    Ok,
    NotOk,
};

// Enums are sum types, and can hold more complex data of different types.
const ComplexType = enum {
    Ok: u8,
    NotOk: void,
};

// Declare a specific instance of the enum variant.
const c = ComplexType.Ok { 0 };

// The ordinal value of a simple enum with no data members can be
// retrieved by a simple cast.
// The value starts from 0, counting up for each member.
const Value = enum {
    Zero,
    One,
    Two,
};
test "enum ordinal value" {
    assert(usize(Value.Zero) == 0);
    assert(usize(Value.One) == 1);
    assert(usize(Value.Two) == 2);
}

// Enums can have methods, the same as structs.
// Enum methods are not special, they are only namespaced
// functions that you can call with dot syntax.
const Suit = enum {
    Clubs,
    Spades,
    Diamonds,
    Hearts,

    pub fn ordinal(self: &const Suit) -> u8 {
        u8(*self)
    }
};
test "enum method" {
    const p = Suit.Spades;
    assert(p.ordinal() == 1);
}

// An enum variant of different types can be switched upon.
// The associated data can be retrieved using `|...|` syntax.
//
// A void type is not required on a tag-only member.
const Foo = enum {
    String: []const u8,
    Number: u64,
    None,
};
test "enum variant switch" {
    const p = Foo.Number { 54 };
    const what_is_it = switch (p) {
        // Capture by reference
        Foo.String => |*x| {
            "this is a string"
        },

        // Capture by value
        Foo.Number => |x| {
            "this is a number"
        },

        Foo.None => {
            "this is a none"
        }
    };
}

// The @enumTagName and @memberCount builtin functions can be used to
// the string representation and number of members respectively.
const BuiltinType = enum {
    A: f32,
    B: u32,
    C,
};

test "enum builtins" {
    assert(mem.eql(u8, @enumTagName(BuiltinType.A { 0 }), "A"));
    assert(mem.eql(u8, @enumTagName(BuiltinType.C), "C"));
    assert(@memberCount(BuiltinType) == 3);
}
```

```
$ zig test enum.zig
Test 1/4 enum ordinal value...OK
Test 2/4 enum method...OK
Test 3/4 enum variant switch...OK
Test 4/4 enum builtins...OK
```

Enums are generated as a struct with a tag field and union field. Zig sorts the order of the tag and
union field by the largest alignment.

See also:

-   [@enumTagName](#builtin-enumTagName)
-   [@memberCount](#builtin-memberCount)

## switch

```{.zig}
const assert = @import("std").debug.assert;
const builtin = @import("builtin");

test "switch simple" {
    const a: u64 = 10;
    const zz: u64 = 103;

    // All branches of a switch expression must be able to be coerced to a
    // common type.
    //
    // Branches cannot fallthrough. If fallthrough behavior is desired, combine
    // the cases and use an if.
    const b = switch (a) {
        // Multiple cases can be combined via a ','
        1, 2, 3 => 0,

        // Ranges can be specified using the ... syntax. These are inclusive
        // both ends.
        5 ... 100 => 1,

        // Branches can be arbitrarily complex.
        101 => {
            const c: u64 = 5;
            c * 2 + 1
        },

        // Switching on arbitrary expressions is allowed as long as the
        // expression is known at compile-time.
        zz => zz,
        comptime {
            const d: u32 = 5;
            const e: u32 = 100;
            d + e
        } => 107,

        // The else branch catches everything not already captured.
        // Else branches are mandatory unless the entire range of values
        // is handled.
        else => 9,
    };

    assert(b == 1);
}

test "switch enum" {
    const Item = enum {
        A: u32,
        C: struct { x: u8, y: u8 },
        D,
    };

    var a = Item.A { 3 };

    // Switching on more complex enums is allowed.
    const b = switch (a) {
        // A capture group is allowed on a match, and will return the enum
        // value matched.
        Item.A => |item| item,

        // A reference to the matched value can be obtained using `*` syntax.
        Item.C => |*item| {
            (*item).x += 1;
            6
        },

        // No else is required if the types cases was exhaustively handled
        Item.D => 8,
    };

    assert(b == 3);
}

// Switch expressions can be used outside a function:
const os_msg = switch (builtin.os) {
    builtin.Os.linux => "we found a linux user",
    else => "not a linux user",
};

// Inside a function, switch statements implicitly are compile-time
// evaluated if the target expression is compile-time known.
test "switch inside function" {
    switch (builtin.os) {
        builtin.Os.windows => {
            // On an OS other than windows, block is not even analyzed,
            // so this compile error is not triggered.
            // On windows this compile error would be triggered.
            @compileError("windows not supported");
        },
        else => {},
    };
}
```

```
$ zig test switch.zig
Test 1/2 switch simple...OK
Test 2/2 switch enum...OK
Test 3/3 switch inside function...OK
```

See also:

-   [comptime](#comptime)
-   [enum](#enum)
-   [@compileError](#builtin-compileError)
-   [Compile Variables](#compile-variables)

## while

```{.zig}
const assert = @import("std").debug.assert;

test "while basic" {
    // A while loop is used to repeatedly execute an expression until
    // some condition is no longer true.
    var i: usize = 0;
    while (i < 10) {
        i += 1;
    }
    assert(i == 10);
}

test "while break" {
    // You can use break to exit a while loop early.
    var i: usize = 0;
    while (true) {
        if (i == 10)
            break;
        i += 1;
    }
    assert(i == 10);
}

test "while continue" {
    // You can use continue to jump back to the beginning of the loop.
    var i: usize = 0;
    while (true) {
        i += 1;
        if (i < 10)
            continue;
        break;
    }
    assert(i == 10);
}

test "while loop continuation expression" {
    // You can give an expression to the while loop to execute when
    // the loop is continued. This is respected by the continue control flow.
    var i: usize = 0;
    while (i < 10) : (i += 1) {}
    assert(i == 10);
}

test "while loop continuation expression, more complicated" {
    // More complex blocks can be used as an expression in the loop continue
    // expression.
    var i1: usize = 1;
    var j1: usize = 1;
    while (i1 * j1 < 2000) : ({ i1 *= 2; j1 *= 3; }) {
        const my_ij1 = i1 * j1;
        assert(my_ij1 < 2000);
    }
}

test "while else" {
    assert(rangeHasNumber(0, 10, 5));
    assert(!rangeHasNumber(0, 10, 15));
}

fn rangeHasNumber(begin: usize, end: usize, number: usize) -> bool {
    var i = begin;
    // While loops are expressions. The result of the expression is the
    // result of the else clause of a while loop, which is executed when
    // the condition of the while loop is tested as false.
    return while (i < end) : (i += 1) {
        if (i == number) {
            // break expressions, like return expressions, accept a value
            // parameter. This is the result of the while expression.
            // When you break from a while loop, the else branch is not
            // evaluated.
            break true;
        }
    } else {
        false
    }
}

test "while null capture" {
    // Just like if expressions, while loops can take a nullable as the
    // condition and capture the payload. When null is encountered the loop
    // exits.
    var sum1: u32 = 0;
    numbers_left = 3;
    while (eventuallyNullSequence()) |value| {
        sum1 += value;
    }
    assert(sum1 == 3);

    // The else branch is allowed on nullable iteration. In this case, it will
    // be executed on the first null value encountered.
    var sum2: u32 = 0;
    numbers_left = 3;
    while (eventuallyNullSequence()) |value| {
        sum2 += value;
    } else {
        assert(sum1 == 3);
    }

    // Just like if expressions, while loops can also take an error union as
    // the condition and capture the payload or the error code. When the
    // condition results in an error code the else branch is evaluated and
    // the loop is finished.
    var sum3: u32 = 0;
    numbers_left = 3;
    while (eventuallyErrorSequence()) |value| {
        sum3 += value;
    } else |err| {
        assert(err == error.ReachedZero);
    }
}

var numbers_left: u32 = undefined;
fn eventuallyNullSequence() -> ?u32 {
    return if (numbers_left == 0) {
        null
    } else {
        numbers_left -= 1;
        numbers_left
    }
}
error ReachedZero;
fn eventuallyErrorSequence() -> %u32 {
    return if (numbers_left == 0) {
        error.ReachedZero
    } else {
        numbers_left -= 1;
        numbers_left
    }
}

test "inline while loop" {
    // While loops can be inlined. This causes the loop to be unrolled, which
    // allows the code to do some things which only work at compile time,
    // such as use types as first class values.
    comptime var i = 0;
    var sum: usize = 0;
    inline while (i < 3) : (i += 1) {
        const T = switch (i) {
            0 => f32,
            1 => i8,
            2 => bool,
            else => unreachable,
        };
        sum += typeNameLength(T);
    }
    assert(sum == 9);
}

fn typeNameLength(comptime T: type) -> usize {
    return @typeName(T).len;
}
```

```
$ zig while.zig
Test 1/8 while basic...OK
Test 2/8 while break...OK
Test 3/8 while continue...OK
Test 4/8 while loop continuation expression...OK
Test 5/8 while loop continuation expression, more complicated...OK
Test 6/8 while else...OK
Test 7/8 while null capture...OK
Test 8/8 inline while loop...OK
```

See also:

-   [if](#if)
-   [Nullables](#nullables)
-   [Errors](#errors)
-   [comptime](#comptime)
-   [unreachable](#unreachable)

## for

```{.zig}
const assert = @import("std").debug.assert;

test "for basics" {
    const items = []i32 { 4, 5, 3, 4, 0 };
    var sum: i32 = 0;

    // For loops iterate over slices and arrays.
    for (items) |value| {
        // Break and continue are supported.
        if (value == 0) {
            continue;
        }
        sum += value;
    }
    assert(sum == 16);

    // To iterate over a portion of a slice, reslice.
    for (items[0..1]) |value| {
        sum += value;
    }
    assert(sum == 20);

    // To access the index of iteration, specify a second capture value.
    // This is zero-indexed.
    var sum2: i32 = 0;
    for (items) |value, i| {
        assert(@typeOf(i) == usize);
        sum2 += i32(i);
    }
    assert(sum2 == 10);
}

test "for reference" {
    var items = []i32 { 3, 4, 2 };

    // Iterate over the slice by reference by
    // specifying that the capture value is a pointer.
    for (items) |*value| {
        *value += 1;
    }

    assert(items[0] == 4);
    assert(items[1] == 5);
    assert(items[2] == 3);
}

test "for else" {
    // For allows an else attached to it, the same as a while loop.
    var items = []?i32 { 3, 4, null, 5 };

    // For loops can also be used as expressions.
    var sum: i32 = 0;
    const result = for (items) |value| {
        if (value == null) {
            break 9;
        } else {
            sum += ??value;
        }
    } else {
        assert(sum == 7);
        sum
    };
}


test "inline for loop" {
    const nums = []i32{2, 4, 6};
    // For loops can be inlined. This causes the loop to be unrolled, which
    // allows the code to do some things which only work at compile time,
    // such as use types as first class values.
    // The capture value and iterator value of inlined for loops are
    // compile-time known.
    var sum: usize = 0;
    inline for (nums) |i| {
        const T = switch (i) {
            2 => f32,
            4 => i8,
            6 => bool,
            else => unreachable,
        };
        sum += typeNameLength(T);
    }
    assert(sum == 9);
}

fn typeNameLength(comptime T: type) -> usize {
    return @typeName(T).len;
}
```

```
$ zig test for.zig
Test 1/4 for basics...OK
Test 2/4 for reference...OK
Test 3/4 for else...OK
Test 4/4 inline for loop...OK
```

See also:

-   [while](#while)
-   [comptime](#comptime)
-   [Arrays](#arrays)
-   [Slices](#slices)

## if

```{.zig}
// If expressions have three uses, corresponding to the three types:
// * bool
// * ?T
// * %T

const assert = @import("std").debug.assert;

test "if boolean" {
    // If expressions test boolean conditions.
    const a: u32 = 5;
    const b: u32 = 4;
    if (a != b) {
        assert(true);
    } else if (a == 9) {
        unreachable
    } else {
        unreachable
    }

    // If expressions are used instead of a ternary expression.
    const result = if (a != b) 47 else 3089;
    assert(result == 47);
}

test "if nullable" {
    // If expressions test for null.

    const a: ?u32 = 0;
    if (a) |value| {
        assert(value == 0);
    } else {
        unreachable;
    }

    const b: ?u32 = null;
    if (b) |value| {
        unreachable;
    } else {
        assert(true);
    }

    // The else is not required.
    if (a) |value| {
        assert(value == 0);
    }

    // To test against null only, use the binary equality operator.
    if (b == null) {
        assert(true);
    }

    // Access the value by reference using a pointer capture.
    var c: ?u32 = 3;
    if (c) |*value| {
        *value = 2;
    }

    if (c) |value| {
        assert(value == 2);
    } else {
        unreachable;
    }
}

error BadValue;
error LessBadValue;
test "if error union" {
    // If expressions test for errors.
    // Note the |err| capture on the else.

    const a: %u32 = 0;
    if (a) |value| {
        assert(value == 0);
    } else |err| {
        unreachable
    }

    const b: %u32 = error.BadValue;
    if (b) |value| {
        unreachable
    } else |err| {
        assert(err == error.BadValue);
    }

    // The else and |err| capture is strictly required.
    if (a) |value| {
        assert(value == 0);
    } else |_| {}

    // To check only the error value, use an empty block expression.
    if (b) |_| {} else |err| {
        assert(err == error.BadValue);
    }

    // Access the value by reference using a pointer capture.
    var c: %u32 = 3;
    if (c) |*value| {
        *value = 9;
    } else |err| {
        unreachable
    }

    if (c) |value| {
        assert(value == 9);
    } else |err| {
        unreachable
    }
}
```

```
$ zig test if.zig
Test 1/3 if boolean...OK
Test 2/3 if nullable...OK
Test 3/3 if error union...OK
```

See also:

-   [Nullables](#nullables)
-   [Errors](#errors)

## goto

```{.zig}
const assert = @import("std").debug.assert;

test "goto" {
    var value = false;
    goto label;
    value = true;

label:
    assert(value == false);
}
```

```
$ zig test goto.zig
Test 1/1 goto...OK
```

Note that there are [plans to remove goto](https://github.com/zig-lang/zig/issues/346)

## defer

```{.zig}
const assert = @import("std").debug.assert;
const printf = @import("std").io.stdout.printf;

// defer will execute an expression at the end of the current scope.
fn deferExample() -> usize {
    var a: usize = 1;

    {
        defer a = 2;
        a = 1;
    }
    assert(a == 2);

    a = 5;
    a
}

test "defer basics" {
    assert(deferExample() == 5);
}

// If multiple defer statements are specified, they will be executed in
// the reverse order they were run.
fn deferUnwindExample() {
    %%printf("\n");

    defer {
        %%printf("1 ");
    }
    defer {
        %%printf("2 ");
    }
    if (false) {
        // defers are not run if they are never executed.
        defer {
            %%printf("3 ");
        }
    }
}

test "defer unwinding" {
    deferUnwindExample()
}

// The %defer keyword is similar to defer, but will only execute if the
// scope returns with an error.
//
// This is especially useful in allowing a function to clean up properly
// on error, and replaces goto error handling tactics as seen in c.
error DeferError;
fn deferErrorExample(is_error: bool) -> %void {
    %%printf("\nstart of function\n");

    // This will always be executed on exit
    defer {
        %%printf("end of function\n");
    }

    %defer {
        %%printf("encountered an error!\n");
    }

    if (is_error) {
        return error.DeferError;
    }
}

test "%defer unwinding" {
    _ = deferErrorExample(false);
    _ = deferErrorExample(true);
}
```

```
$ zig test defer.zig
Test 1/3 defer basics...OK
Test 2/3 defer unwinding...
2 1 OK
Test 3/3 %defer unwinding...
start of function
end of function

start of function
encountered an error!
end of function
OK
```

See also:

-   [Errors](#errors)

## unreachable

In `Debug` and `ReleaseSafe` mode, and when using `zig test`, `unreachable` emits a call to `panic`
with the message `reached unreachable code`.

In `ReleaseFast` mode, the optimizer uses the assumption that `unreachable` code will never be hit
to perform optimizations. However, `zig test` even in `ReleaseFast` mode still emits `unreachable`
as calls to `panic`.

### Basics {#unreachable-basics}

```{.zig}
// unreachable is used to assert that control flow will never happen upon a
// particular location:
test "basic math" {
    const x = 1;
    const y = 2;
    if (x + y != 3) {
        unreachable;
    }
}

// in fact, this is how assert is implemented:
fn assert(ok: bool) {
    if (!ok) unreachable; // assertion failure
}

// This test will fail because we hit unreachable.
test "this will fail" {
    assert(false);
}
```

```
$ zig test test.zig 
Test 1/2 basic math...OK
Test 2/2 this will fail...reached unreachable code
test.zig:13:14: 0x00000000002033ac in ??? (test)
    if (!ok) unreachable; // assertion failure
             ^
test.zig:18:11: 0x000000000020329b in ??? (test)
    assert(false);
          ^
lib/zig/std/special/test_runner.zig:9:21: 0x0000000000214a7a in ??? (test)
        test_fn.func();
                    ^
lib/zig/std/special/bootstrap.zig:60:21: 0x0000000000214947 in ??? (test)
    return root.main();
                    ^
lib/zig/std/special/bootstrap.zig:47:13: 0x0000000000214800 in ??? (test)
    callMain(argc, argv, envp) %% std.os.posix.exit(1);
            ^
lib/zig/std/special/bootstrap.zig:34:25: 0x0000000000214750 in ??? (test)
    posixCallMainAndExit()
                        ^

Tests failed. Use the following command to reproduce the failure:
./test
```

### At Compile-Time {#unreachable-comptime}

```{.zig}
const assert = @import("std").debug.assert;

comptime {
    // The type of unreachable is noreturn.

    // However this assertion will still fail because
    // evaluating unreachable at compile-time is a compile error.

    assert(@typeOf(unreachable) == noreturn);
}
```

```
$ zig build-obj test.zig 
test.zig:9:12: error: unreachable code
    assert(@typeOf(unreachable) == noreturn);
           ^
```

See also:

-   [Zig Test](#zig-test)
-   [Build Mode](#build-mode)
-   [comptime](#comptime)

## noreturn

`noreturn` is the type of:

-   `break`
-   `continue`
-   `goto`
-   `return`
-   `unreachable`
-   `while (true) {}`

When resolving types together, such as `if` clauses or `switch` prongs, the `noreturn` type is
compatible with every other type. Consider:

```{.zig}
fn foo(condition: bool, b: u32) {
    const a = if (condition) b else return;
    bar(a);
}

extern fn bar(value: u32);
```

Another use case for `noreturn` is the `exit` function:

```{.zig}
pub extern "kernel32" stdcallcc fn ExitProcess(exit_code: c_uint) -> noreturn;

fn foo() {
    const value = bar() %% ExitProcess(1);
    assert(value == 1234);
}

fn bar() -> %u32 {
    return 1234;
}

const assert = @import("std").debug.assert;
```

## Functions

```{.zig}
const assert = @import("std").debug.assert;

// Functions are declared like this
// The last expression in the function can be used as the return value.
fn add(a: i8, b: i8) -> i8 {
    if (a == 0) {
        // You can still return manually if needed.
        return b;
    }

    a + b
}

// The export specifier makes a function externally visible in the generated
// object file, and makes it use the C ABI.
export fn sub(a: i8, b: i8) -> i8 { a - b }

// The extern specifier is used to declare a function that will be resolved
// at link time, when linking statically, or at runtime, when linking
// dynamically.
// The stdcallcc specifier changes the calling convention of the function.
extern "kernel32" stdcallcc fn ExitProcess(exit_code: u32) -> noreturn;
extern "c" fn atan2(a: f64, b: f64) -> f64;

// coldcc makes a function use the cold calling convention.
coldcc fn abort() -> noreturn {
    while (true) {}
}

// nakedcc makes a function not have any function prologue or epilogue.
// This can be useful when integrating with assembly.
nakedcc fn _start() -> noreturn {
    abort();
}

// The pub specifier allows the function to be visible when importing.
// Another file can use @import and call sub2
pub fn sub2(a: i8, b: i8) -> i8 { a - b }

// Functions can be used as values and are equivalent to pointers.
const call2_op = fn (a: i8, b: i8) -> i8;
fn do_op(fn_call: call2_op, op1: i8, op2: i8) -> i8 {
    fn_call(op1, op2)
}

test "function" {
    assert(do_op(add, 5, 6) == 11);
    assert(do_op(sub2, 5, 6) == -1);
}
```

```
$ zig test function.zig
Test 1/1 function...OK
```

Function values are like pointers:

```{.zig}
const assert = @import("std").debug.assert;

comptime {
    assert(@typeOf(foo) == fn());
    assert(@sizeOf(fn()) == @sizeOf(?fn()));
}

fn foo() { }
```

```
$ zig build-obj test.zig
```

TODO: byval not allowed except for C ABI

TODO: implicit cast from T to &const T

## Errors

One of the distinguishing features of Zig is its exception handling strategy.

Among the top level declarations available is the error value declaration:

```{.zig}
error FileNotFound;
error OutOfMemory;
error UnexpectedToken;
```

These error values are assigned an unsigned integer value greater than 0 at compile time. You are
allowed to declare the same error value more than once, and if you do, it gets the same error value.

You can refer to these error values with the error namespace such as `error.FileNotFound`.

Each error value across the entire compilation unit gets a unique integer, and this determines the
size of the pure error type.

The pure error type is one of the error values, and in the same way that pointers cannot be null, a
pure error is always an error.

```{.zig}
const pure_error = error.FileNotFound;
```

Most of the time you will not find yourself using a pure error type. Instead, likely you will be
using the error union type. This is when you take a normal type, and prefix it with the `%`
operator.

Here is a function to parse a string into a 64-bit integer:

```{.zig}
error InvalidChar;
error Overflow;

pub fn parseU64(buf: []const u8, radix: u8) -> %u64 {
    var x: u64 = 0;

    for (buf) |c| {
        const digit = charToDigit(c);

        if (digit >= radix) {
            return error.InvalidChar;
        }

        // x *= radix
        if (@mulWithOverflow(u64, x, radix, &x)) {
            return error.Overflow;
        }

        // x += digit
        if (@addWithOverflow(u64, x, digit, &x)) {
            return error.Overflow;
        }
    }

    return x;
}
```

Notice the return type is `%u64`. This means that the function either returns an unsigned 64 bit
integer, or an error.

Within the function definition, you can see some return statements that return a pure error, and at
the bottom a return statement that returns a `u64`. Both types implicitly cast to `%u64`.

What it looks like to use this function varies depending on what you’re trying to do. One of the
following:

-   You want to provide a default value if it returned an error.
-   If it returned an error then you want to return the same error.
-   You know with complete certainty it will not return an error, so want to unconditionally unwrap it.
-   You want to take a different action for each possible error.

If you want to provide a default value, you can use the `%%` binary operator:

```{.zig}
fn doAThing(str: []u8) {
    const number = parseU64(str, 10) %% 13;
    // ...
}
```

In this code, `number` will be equal to the successfully parsed string, or a default value of 13.
The type of the right hand side of the binary `%%` operator must match the unwrapped error union
type, or be of type `noreturn`.

Let’s say you wanted to return the error if you got one, otherwise continue with the function logic:

```{.zig}
fn doAThing(str: []u8) -> %void {
    const number = parseU64(str, 10) %% |err| return err;
    // ...
}
```

There is a shortcut for this. The `%return` expression:

```{.zig}
fn doAThing(str: []u8) -> %void {
    const number = %return parseU64(str, 10);
    // ...
}
```

`%return` evaluates an error union expression. If it is an error, it returns from the current
function with the same error. Otherwise, the expression results in the unwrapped value.

Maybe you know with complete certainty that an expression will never be an error. In this case you
can do this:

```{.zig}
const number = parseU64("1234", 10) %% unreachable;
```

Here we know for sure that “1234” will parse successfully. So we put the `unreachable` value on the
right hand side. `unreachable` generates a panic in Debug and ReleaseSafe modes and undefined
behavior in ReleaseFast mode. So, while we’re debugging the application, if there *was* a surprise
error here, the application would crash appropriately.

Again there is a syntactic shortcut for this:

```{.zig}
const number = %%parseU64("1234", 10);
```

The `%%` *prefix* operator is equivalent to `expression %% |err| return err`. It unwraps an error
union type, and panics in debug mode if the value was an error.

Finally, you may want to take a different action for every situation. For that, we combine the `if`
and `switch` expression:

```{.zig}
fn doAThing(str: []u8) {
    if (parseU64(str, 10)) |number| {
        doSomethingWithNumber(number);
    } else |err| switch (err) {
        error.Overflow => {
            // handle overflow...
        },
        // we promise that InvalidChar won't happen (or crash in debug mode if it does)
        error.InvalidChar => unreachable,
    }
}
```

The other component to error handling is defer statements. In addition to an unconditional `defer`,
Zig has `%defer`, which evaluates the deferred expression on block exit path if and only if the
function returned with an error from the block.

Example:

```{.zig}
fn createFoo(param: i32) -> %Foo {
    const foo = %return tryToAllocateFoo();
    // now we have allocated foo. we need to free it if the function fails.
    // but we want to return it if the function succeeds.
    %defer deallocateFoo(foo);

    const tmp_buf = allocateTmpBuffer() ?? return error.OutOfMemory;
    // tmp_buf is truly a temporary resource, and we for sure want to clean it up
    // before this block leaves scope
    defer deallocateTmpBuffer(tmp_buf);

    if (param > 1337) return error.InvalidParam;

    // here the %defer will not run since we're returning success from the function.
    // but the defer will run!
    return foo;
}
```

The neat thing about this is that you get robust error handling without the verbosity and cognitive
overhead of trying to make sure every exit path is covered. The deallocation code is always directly
following the allocation code.

A couple of other tidbits about error handling:

-   These primitives give enough expressiveness that it’s completely practical to have failing to
    check for an error be a compile error. If you really want to ignore the error, you can use the
    `%%` prefix operator and get the added benefit of crashing in debug mode if your assumption was
    wrong.
-   Since Zig understands error types, it can pre-weight branches in favor of errors not occuring.
    Just a small optimization benefit that is not available in other languages.

See also:

-   [defer](#defer)
-   [if](#if)
-   [switch](#switch)

## Nullables

One area that Zig provides safety without compromising efficiency or readability is with the
nullable type.

The question mark symbolizes the nullable type. You can convert a type to a nullable type by putting
a question mark in front of it, like this:

```{.zig}
// normal integer
const normal_int: i32 = 1234;

// nullable integer
const nullable_int: ?i32 = 5678;
```

Now the variable `nullable_int` could be an `i32`, or `null`.

Instead of integers, let’s talk about pointers. Null references are the source of many runtime
exceptions, and even stand accused of being [the worst mistake of computer
science](https://www.lucidchart.com/techblog/2015/08/31/the-worst-mistake-of-computer-science/).

Zig does not have them.

Instead, you can use a nullable pointer. This secretly compiles down to a normal pointer, since we
know we can use 0 as the null value for the nullable type. But the compiler can check your work and
make sure you don’t assign null to something that can’t be null.

Typically the downside of not having null is that it makes the code more verbose to write. But,
let’s compare some equivalent C code and Zig code.

Task: call malloc, if the result is null, return null.

C code

```{.c}
// malloc prototype included for reference
void *malloc(size_t size);

struct Foo *do_a_thing(void) {
    char *ptr = malloc(1234);
    if (!ptr) return NULL;
    // ...
}
```

Zig code

```{.zig}
// malloc prototype included for reference
extern fn malloc(size: size_t) -> ?&u8;

fn doAThing() -> ?&Foo {
    const ptr = malloc(1234) ?? return null;
    // ...
}
```

Here, Zig is at least as convenient, if not more, than C. And, the type of “ptr” is `&u8` *not*
`?&u8`. The `??` operator unwrapped the nullable type and therefore `ptr` is guaranteed to be
non-null everywhere it is used in the function.

The other form of checking against NULL you might see looks like this:

```{.zig}
void do_a_thing(struct Foo *foo) {
    // do some stuff

    if (foo) {
        do_something_with_foo(foo);
    }

    // do some stuff
}
```

In Zig you can accomplish the same thing:

```{.zig}
fn doAThing(nullable_foo: ?&Foo) {
    // do some stuff

    if (const foo ?= nullable_foo) {
      doSomethingWithFoo(foo);
    }

    // do some stuff
}
```

Once again, the notable thing here is that inside the if block, `foo` is no longer a nullable
pointer, it is a pointer, which cannot be null.

One benefit to this is that functions which take pointers as arguments can be annotated with the
“nonnull” attribute - `__attribute__((nonnull))` in
[GCC](https://gcc.gnu.org/onlinedocs/gcc-4.0.0/gcc/Function-Attributes.html). The optimizer can
sometimes make better decisions knowing that pointer arguments cannot be null.

## Casting

TODO: explain implicit vs explicit casting

TODO: resolve peer types builtin

TODO: truncate builtin

TODO: bitcast builtin

TODO: int to ptr builtin

TODO: ptr to int builtin

TODO: ptrcast builtin

TODO: explain number literals vs concrete types

## void

TODO: assigning void has no codegen

TODO: hashmap with void becomes a set

TODO: difference between c\_void and void

TODO: void is the default return value of functions

TODO: functions require assigning the return value

## this

TODO: example of this referring to Self struct

TODO: example of this referring to recursion function

TODO: example of this referring to basic block for @setDebugSafety

## comptime

Zig places importance on the concept of whether an expression is known at compile-time. There are a
few different places this concept is used, and these building blocks are used to keep the language
small, readable, and powerful.

### Introducing the Compile-Time Concept {#introducing-compile-time-concept}

#### Compile-Time Parameters

Compile-time parameters is how Zig implements generics. It is compile-time duck typing.

```{.zig}
fn max(comptime T: type, a: T, b: T) -> T {
    if (a > b) a else b
}
fn gimmeTheBiggerFloat(a: f32, b: f32) -> f32 {
    max(f32, a, b)
}
fn gimmeTheBiggerInteger(a: u64, b: u64) -> u64 {
    max(u64, a, b)
}
```

In Zig, types are first-class citizens. They can be assigned to variables, passed as parameters to
functions, and returned from functions. However, they can only be used in expressions which are
known at *compile-time*, which is why the parameter `T` in the above snippet must be marked with
`comptime`.

A `comptime` parameter means that:

-   At the callsite, the value must be known at compile-time, or it is a compile error.
-   In the function definition, the value is known at compile-time.

For example, if we were to introduce another function to the above snippet:

```{.zig}
fn max(comptime T: type, a: T, b: T) -> T {
    if (a > b) a else b
}
fn letsTryToPassARuntimeType(condition: bool) {
    const result = max(
        if (condition) f32 else u64,
        1234,
        5678);
}
```

Then we get this result from the compiler:

```
./test.zig:6:9: error: unable to evaluate constant expression
        if (condition) f32 else u64,
        ^
```

This is an error because the programmer attempted to pass a value only known at run-time to a
function which expects a value known at compile-time.

Another way to get an error is if we pass a type that violates the type checker when the function is
analyzed. This is what it means to have *compile-time duck typing*.

For example:

```{.zig}
fn max(comptime T: type, a: T, b: T) -> T {
    if (a > b) a else b
}
fn letsTryToCompareBools(a: bool, b: bool) -> bool {
    max(bool, a, b)
}
```

The code produces this error message:

```{.zig}
./test.zig:2:11: error: operator not allowed for type 'bool'
    if (a > b) a else b
          ^
./test.zig:5:8: note: called from here
    max(bool, a, b)
      ^
```

On the flip side, inside the function definition with the `comptime` parameter, the value is known
at compile-time. This means that we actually could make this work for the bool type if we wanted to:

```{.zig}
fn max(comptime T: type, a: T, b: T) -> T {
    if (T == bool) {
        return a or b;
    } else if (a > b) {
        return a;
    } else {
        return b;
    }
}
fn letsTryToCompareBools(a: bool, b: bool) -> bool {
    max(bool, a, b)
}
```

This works because Zig implicitly inlines `if` expressions when the condition is known at
compile-time, and the compiler guarantees that it will skip analysis of the branch not taken.

This means that the actual function generated for `max` in this situation looks like this:

```{.zig}
fn max(a: bool, b: bool) -> bool {
    return a or b;
}
```

All the code that dealt with compile-time known values is eliminated and we are left with only the
necessary run-time code to accomplish the task.

This works the same way for `switch` expressions - they are implicitly inlined when the target
expression is compile-time known.

#### Compile-Time Variables

In Zig, the programmer can label variables as `comptime`. This guarantees to the compiler that every
load and store of the variable is performed at compile-time. Any violation of this results in a
compile error.

This combined with the fact that we can `inline` loops allows us to write a function which is
partially evaluated at compile-time and partially at run-time.

For example:

```{.zig}
const assert = @import("std").debug.assert;

const CmdFn = struct {
    name: []const u8,
    func: fn(i32) -> i32,
};

const cmd_fns = []CmdFn{
    CmdFn {.name = "one", .func = one},
    CmdFn {.name = "two", .func = two},
    CmdFn {.name = "three", .func = three},
};
fn one(value: i32) -> i32 { value + 1 }
fn two(value: i32) -> i32 { value + 2 }
fn three(value: i32) -> i32 { value + 3 }

fn performFn(comptime prefix_char: u8, start_value: i32) -> i32 {
    var result: i32 = start_value;
    comptime var i = 0;
    inline while (i < cmd_fns.len) : (i += 1) {
        if (cmd_fns[i].name[0] == prefix_char) {
            result = cmd_fns[i].func(result);
        }
    }
    return result;
}

test "perform fn" {
    assert(performFn('t', 1) == 6);
    assert(performFn('o', 0) == 1);
    assert(performFn('w', 99) == 99);
}
```

This example is a bit contrived, because the compile-time evaluation component is unnecessary; this
code would work fine if it was all done at run-time. But it does end up generating different code.
In this example, the function `performFn` is generated three different times, for the different
values of `prefix_char` provided:

```{.zig}
// From the line:
// assert(performFn('t', 1) == 6);
fn performFn(start_value: i32) -> i32 {
    var result: i32 = start_value;
    result = two(result);
    result = three(result);
    return result;
}

// From the line:
// assert(performFn('o', 0) == 1);
fn performFn(start_value: i32) -> i32 {
    var result: i32 = start_value;
    result = one(result);
    return result;
}

// From the line:
// assert(performFn('w', 99) == 99);
fn performFn(start_value: i32) -> i32 {
    var result: i32 = start_value;
    return result;
}
```

Note that this happens even in a debug build; in a release build these generated functions still
pass through rigorous LLVM optimizations. The important thing to note, however, is not that this is
a way to write more optimized code, but that it is a way to make sure that what *should* happen at
compile-time, *does* happen at compile-time. This catches more errors and as demonstrated later in
this article, allows expressiveness that in other languages requires using macros, generated code,
or a preprocessor to accomplish.

#### Compile-Time Expressions

In Zig, it matters whether a given expression is known at compile-time or run-time. A programmer can
use a `comptime` expression to guarantee that the expression will be evaluated at compile-time. If
this cannot be accomplished, the compiler will emit an error. For example:

```{.zig}
extern fn exit() -> unreachable;

fn foo() {
    comptime {
        exit();
    }
}

./test.zig:5:9: error: unable to evaluate constant expression
        exit();
        ^
```

It doesn’t make sense that a program could call `exit()` (or any other external function) at
compile-time, so this is a compile error. However, a `comptime` expression does much more than
sometimes cause a compile error.

Within a `comptime` expression:

-   All variables are `comptime` variables.
-   All `if`, `while`, `for`, `switch`, and `goto` expressions are evaluated at compile-time, or
    emit a compile error if this is not possible.
-   All function calls cause the compiler to interpret the function at compile-time, emitting a
    compile error if the function tries to do something that has global run-time side effects.

This means that a programmer can create a function which is called both at compile-time and
run-time, with no modification to the function required.

Let’s look at an example:

```{.zig}
const assert = @import("std").debug.assert;
      
fn fibonacci(index: u32) -> u32 {
    if (index < 2) return index;
    return fibonacci(index - 1) + fibonacci(index - 2);
}

test "fibonacci" {
    // test fibonacci at run-time
    assert(fibonacci(7) == 13);

    // test fibonacci at compile-time
    comptime {
        assert(fibonacci(7) == 13);
    }
}
```

```
$ zig test test.zig
Test 1/1 testFibonacci...OK
```

Imagine if we had forgotten the base case of the recursive function and tried to run the tests:

```{.zig}
const assert = @import("std").debug.assert;

fn fibonacci(index: u32) -> u32 {
    //if (index < 2) return index;
    return fibonacci(index - 1) + fibonacci(index - 2);
}

test "fibonacci" {
    comptime {
        assert(fibonacci(7) == 13);
    }
}
```

```
$ zig test test.zig
./test.zig:3:28: error: operation caused overflow
    return fibonacci(index - 1) + fibonacci(index - 2);
                          ^
./test.zig:3:21: note: called from here
    return fibonacci(index - 1) + fibonacci(index - 2);
                    ^
./test.zig:3:21: note: called from here
    return fibonacci(index - 1) + fibonacci(index - 2);
                    ^
./test.zig:3:21: note: called from here
    return fibonacci(index - 1) + fibonacci(index - 2);
                    ^
./test.zig:3:21: note: called from here
    return fibonacci(index - 1) + fibonacci(index - 2);
                    ^
./test.zig:3:21: note: called from here
    return fibonacci(index - 1) + fibonacci(index - 2);
                    ^
./test.zig:3:21: note: called from here
    return fibonacci(index - 1) + fibonacci(index - 2);
                    ^
./test.zig:3:21: note: called from here
    return fibonacci(index - 1) + fibonacci(index - 2);
                    ^
./test.zig:14:25: note: called from here
        assert(fibonacci(7) == 13);
                        ^
```

The compiler produces an error which is a stack trace from trying to evaluate the function at
compile-time.

Luckily, we used an unsigned integer, and so when we tried to subtract 1 from 0, it triggered
undefined behavior, which is always a compile error if the compiler knows it happened. But what
would have happened if we used a signed integer?

```{.zig}
const assert = @import("std").debug.assert;
      
fn fibonacci(index: i32) -> i32 {
    //if (index < 2) return index;
    return fibonacci(index - 1) + fibonacci(index - 2);
}

test "fibonacci" {
    comptime {
        assert(fibonacci(7) == 13);
    }
}
```

```
./test.zig:3:21: error: evaluation exceeded 1000 backwards branches
    return fibonacci(index - 1) + fibonacci(index - 2);
                    ^
./test.zig:3:21: note: called from here
    return fibonacci(index - 1) + fibonacci(index - 2);
                    ^
./test.zig:3:21: note: called from here
    return fibonacci(index - 1) + fibonacci(index - 2);
                    ^
./test.zig:3:21: note: called from here
    return fibonacci(index - 1) + fibonacci(index - 2);
                    ^
./test.zig:3:21: note: called from here
    return fibonacci(index - 1) + fibonacci(index - 2);
                    ^
./test.zig:3:21: note: called from here
    return fibonacci(index - 1) + fibonacci(index - 2);
                    ^
./test.zig:3:21: note: called from here
    return fibonacci(index - 1) + fibonacci(index - 2);
                    ^
./test.zig:3:21: note: called from here
    return fibonacci(index - 1) + fibonacci(index - 2);
                    ^
./test.zig:3:21: note: called from here
    return fibonacci(index - 1) + fibonacci(index - 2);
                    ^
./test.zig:3:21: note: called from here
    return fibonacci(index - 1) + fibonacci(index - 2);
                    ^
./test.zig:3:21: note: called from here
    return fibonacci(index - 1) + fibonacci(index - 2);
                    ^
./test.zig:3:21: note: called from here
    return fibonacci(index - 1) + fibonacci(index - 2);
                    ^
```

The compiler noticed that evaluating this function at compile-time took a long time, and thus
emitted a compile error and gave up. If the programmer wants to increase the budget for compile-time
computation, they can use a built-in function called
[@setEvalBranchQuota](#builtin-setEvalBranchQuota) to change the default number 1000 to something
else.

What if we fix the base case, but put the wrong value in the `assert` line?

```{.zig}
comptime {
    assert(fibonacci(7) == 99999);
}
```

```
./test.zig:15:14: error: unable to evaluate constant expression
    if (!ok) unreachable;
            ^
./test.zig:10:15: note: called from here
        assert(fibonacci(7) == 99999);
              ^
```

What happened is Zig started interpreting the `assert` function with the parameter `ok` set to
`false`. When the interpreter hit `unreachable` it emitted a compile error, because reaching
unreachable code is undefined behavior, and undefined behavior causes a compile error if it is
detected at compile-time.

In the global scope (outside of any function), all expressions are implicitly `comptime`
expressions. This means that we can use functions to initialize complex static data. For example:

```{.zig}
const first_25_primes = firstNPrimes(25);
const sum_of_first_25_primes = sum(first_25_primes);

fn firstNPrimes(comptime n: usize) -> [n]i32 {
    var prime_list: [n]i32 = undefined;
    var next_index: usize = 0;
    var test_number: i32 = 2;
    while (next_index < prime_list.len) : (test_number += 1) {
        var test_prime_index: usize = 0;
        var is_prime = true;
        while (test_prime_index < next_index) : (test_prime_index += 1) {
            if (test_number % prime_list[test_prime_index] == 0) {
                is_prime = false;
                break;
            }
        }
        if (is_prime) {
            prime_list[next_index] = test_number;
            next_index += 1;
        }
    }
    return prime_list;
}

fn sum(numbers: []i32) -> i32 {
    var result: i32 = 0;
    for (numbers) |x| {
        result += x;
    }
    return result;
}
```

When we compile this program, Zig generates the constants with the answer pre-computed. Here are the
lines from the generated LLVM IR:

```{.llvm}
@0 = internal unnamed_addr constant [25 x i32] [i32 2, i32 3, i32 5, i32 7, i32 11, i32 13, i32 17, i32 19, i32 23, i32 29, i32 31, i32 37, i32 41, i32 43, i32 47, i32 53, i32 59, i32 61, i32 67, i32 71, i32 73, i32 79, i32 83, i32 89, i32 97]
      @1 = internal unnamed_addr constant i32 1060
```

Note that we did not have to do anything special with the syntax of these functions. For example, we
could call the `sum` function as is with a slice of numbers whose length and values were only known
at run-time.

### Generic Data Structures

Zig uses these capabilities to implement generic data structures without introducing any
special-case syntax. If you followed along so far, you may already know how to create a generic data
structure.

Here is an example of a generic `List` data structure, that we will instantiate with the type `i32`.
In Zig we refer to the type as `List(i32)`.

```{.zig}
fn List(comptime T: type) -> type {
    struct {
        items: []T,
        len: usize,
    }
}
```

That’s it. It’s a function that returns an anonymous `struct`. For the purposes of error messages
and debugging, Zig infers the name `"List(i32)"` from the function name and parameters invoked when
creating the anonymous struct.

To keep the language small and uniform, all aggregate types in Zig are anonymous. To give a type a
name, we assign it to a constant:

```{.zig}
const Node = struct {
    next: &Node,
    name: []u8,
};
```

This works because all top level declarations are order-independent, and as long as there isn’t an
actual infinite regression, values can refer to themselves, directly or indirectly. In this case,
`Node` refers to itself as a pointer, which is not actually an infinite regression, so it works
fine.

### Case Study: printf in Zig {#case-study-printf}

Putting all of this together, let’s see how `printf` works in Zig.

```{.zig}
const io = @import("std").io;

const a_number: i32 = 1234;
const a_string = "foobar";

pub fn main(args: [][]u8) -> %void {
    %%io.stderr.printf("here is a string: '{}' here is a number: {}\n", a_string, a_number);
}

here is a string: 'foobar' here is a number: 1234
```

Let’s crack open the implementation of this and see how it works:

```{.zig}
/// Calls print and then flushes the buffer.
pub fn printf(self: &OutStream, comptime format: []const u8, args: ...) -> %void {
    const State = enum {
        Start,
        OpenBrace,
        CloseBrace,
    };

    comptime var start_index: usize = 0;
    comptime var state = State.Start;
    comptime var next_arg: usize = 0;

    inline for (format) |c, i| {
        switch (state) {
            State.Start => switch (c) {
                '{' => {
                    if (start_index < i) %return self.write(format[start_index...i]);
                    state = State.OpenBrace;
                },
                '}' => {
                    if (start_index < i) %return self.write(format[start_index...i]);
                    state = State.CloseBrace;
                },
                else => {},
            },
            State.OpenBrace => switch (c) {
                '{' => {
                    state = State.Start;
                    start_index = i;
                },
                '}' => {
                    %return self.printValue(args[next_arg]);
                    next_arg += 1;
                    state = State.Start;
                    start_index = i + 1;
                },
                else => @compileError("Unknown format character: " ++ c),
            },
            State.CloseBrace => switch (c) {
                '}' => {
                    state = State.Start;
                    start_index = i;
                },
                else => @compileError("Single '}' encountered in format string"),
            },
        }
    }
    comptime {
        if (args.len != next_arg) {
            @compileError("Unused arguments");
        }
        if (state != State.Start) {
            @compileError("Incomplete format string: " ++ format);
        }
    }
    if (start_index < format.len) {
        %return self.write(format[start_index...format.len]);
    }
    %return self.flush();
}
```

This is a proof of concept implementation; the actual function in the standard library has more
formatting capabilities.

Note that this is not hard-coded into the Zig compiler; this is userland code in the standard
library.

When this function is analyzed from our example code above, Zig partially evaluates the function and
emits a function that actually looks like this:

```{.zig}
pub fn printf(self: &OutStream, arg0: i32, arg1: []const u8) -> %void {
    %return self.write("here is a string: '");
    %return self.printValue(arg0);
    %return self.write("' here is a number: ");
    %return self.printValue(arg1);
    %return self.write("\n");
    %return self.flush();
}
```

`printValue` is a function that takes a parameter of any type, and does different things depending
on the type:

```{.zig}
pub fn printValue(self: &OutStream, value: var) -> %void {
    const T = @typeOf(value);
    if (@isInteger(T)) {
        return self.printInt(T, value);
    } else if (@isFloat(T)) {
        return self.printFloat(T, value);
    } else if (@canImplicitCast([]const u8, value)) {
        const casted_value = ([]const u8)(value);
        return self.write(casted_value);
    } else {
        @compileError("Unable to print type '" ++ @typeName(T) ++ "'");
    }
}
```

And now, what happens if we give too many arguments to `printf`?

```
%%io.stdout.printf("here is a string: '{}' here is a number: {}\n",
        a_string, a_number, a_number);

.../std/io.zig:147:17: error: Unused arguments
                @compileError("Unused arguments");
                ^
./test.zig:7:23: note: called from here
    %%io.stdout.printf("here is a number: {} and here is a string: {}\n",
                      ^
```

Zig gives programmers the tools needed to protect themselves against their own mistakes.

Zig doesn’t care whether the format argument is a string literal, only that it is a compile-time
known value that is implicitly castable to a `[]const u8`:

```{.zig}
const io = @import("std").io;

const a_number: i32 = 1234;
const a_string = "foobar";
const fmt = "here is a string: '{}' here is a number: {}\n";

pub fn main(args: [][]u8) -> %void {
    %%io.stderr.printf(fmt, a_string, a_number);
}
```

This works fine.

Zig does not special case string formatting in the compiler and instead exposes enough power to
accomplish this task in userland. It does so without introducing another language on top of Zig,
such as a macro language or a preprocessor language. It’s Zig all the way down.

TODO: suggestion to not use inline unless necessary

## inline

TODO: inline while

TODO: inline for

TODO: suggestion to not use inline unless necessary

## Assembly

TODO: example of inline assembly

TODO: example of module level assembly

TODO: example of using inline assembly return value

TODO: example of using inline assembly assigning values to variables

## Atomics

TODO: @fence()

TODO: @atomic rmw

TODO: builtin atomic memory ordering enum

## Builtin Functions

Builtin functions are provided by the compiler and are prefixed with `@`. The `comptime` keyword on
a parameter means that the parameter must be known at compile time.

### @addWithOverflow {#builtin-addWithOverflow}

```{.zig}
@addWithOverflow(comptime T: type, a: T, b: T, result: &T) -> bool
```

Performs `*result = a + b`. If overflow or underflow occurs, stores the overflowed bits in `result`
and returns `true`. If no overflow or underflow occurs, returns `false`.

### @bitCast {#builtin-bitCast}

```{.zig}
@bitCast(comptime DestType: type, value: var) -> DestType
```

Converts a value of one type to another type.

Asserts that `@sizeOf(@typeOf(value)) == @sizeOf(DestType)`.

Asserts that `@typeId(DestType) != @import("builtin").TypeId.Pointer`. Use `@ptrCast` or `@intToPtr`
if you need this.

Can be used for these things for example:

-   Convert `f32` to `u32` bits
-   Convert `i32` to `u32` preserving twos complement

Works at compile-time if `value` is known at compile time. It’s a compile error to bitcast a struct
to a scalar type of the same size since structs have undefined layout. However if the struct is
packed then it works.

### @breakpoint {#builtin-breakpoint}

```{.zig}
@breakpoint()
```

This function inserts a platform-specific debug trap instruction which causes debuggers to break
there.

This function is only valid within function scope.

### @alignCast {#builtin-alignCast}

```{.zig}
@alignCast(comptime alignment: u29, ptr: var) -> var
```

`ptr` can be `&T`, `fn()`, `?&T`, `?fn()`, or `[]T`. It returns the same type as `ptr` except with
the alignment adjusted to the new value.

A [pointer alignment safety check](#undef-incorrect-pointer-alignment) is added to the generated
code to make sure the pointer is aligned as promised.

### @alignOf {#builtin-alignOf}

```{.zig}
@alignOf(comptime T: type) -> (number literal)
```

This function returns the number of bytes that this type should be aligned to for the current target
to match the C ABI. When the child type of a pointer has this alignment, the alignment can be
omitted from the type.

```{.zig}
const assert = @import("std").debug.assert;
comptime {
    assert(&u32 == &align(@alignOf(u32)) u32);
}
```

The result is a target-specific compile time constant. It is guaranteed to be less than or equal to
[@sizeOf(T)](#builtin-sizeOf).

See also:

-   [Alignment](#alignment)

### @cDefine {#builtin-cDefine}

```{.zig}
@cDefine(comptime name: []u8, value)
```

This function can only occur inside `@cImport`.

This appends `#define $name $value` to the `@cImport` temporary buffer.

To define without a value, like this:

```{.c}
#define _GNU_SOURCE
```

Use the void value, like this:

```{.zig}
@cDefine("_GNU_SOURCE", {})
```

See also:

-   [Import from C Header File](#c-import)
-   [@cInclude](#builtin-cInclude)
-   [@cImport](#builtin-cImport)
-   [@cUndef](#builtin-cUndef)
-   [void](#void)

### @cImport {#builtin-cImport}

```{.zig}
@cImport(expression) -> (namespace)
```

This function parses C code and imports the functions, types, variables, and compatible macro
definitions into the result namespace.

`expression` is interpreted at compile time. The builtin functions `@cInclude`, `@cDefine`, and
`@cUndef` work within this expression, appending to a temporary buffer which is then parsed as C
code.

See also:

-   [Import from C Header File](#c-import)
-   [@cInclude](#builtin-cInclude)
-   [@cDefine](#builtin-cDefine)
-   [@cUndef](#builtin-cUndef)

### @cInclude {#builtin-cInclude}

```{.zig}
@cInclude(comptime path: []u8)
```

This function can only occur inside `@cImport`.

This appends `#include <$path>\n` to the `c_import` temporary buffer.

See also:

-   [Import from C Header File](#c-import)
-   [@cImport](#builtin-cImport)
-   [@cDefine](#builtin-cDefine)
-   [@cUndef](#builtin-cUndef)

### @cUndef {#builtin-cUndef}

```{.zig}
@cUndef(comptime name: []u8)
```

This function can only occur inside `@cImport`.

This appends `#undef $name` to the `@cImport` temporary buffer.

See also:

-   [Import from C Header File](#c-import)
-   [@cImport](#builtin-cImport)
-   [@cDefine](#builtin-cDefine)
-   [@cInclude](#builtin-cInclude)

### @canImplicitCast {#builtin-canImplicitCast}

```{.zig}
@canImplicitCast(comptime T: type, value) -> bool
```

Returns whether a value can be implicitly casted to a given type.

### @clz {#builtin-clz}

```{.zig}
@clz(x: T) -> U
```

This function counts the number of leading zeroes in `x` which is an integer type `T`.

The return type `U` is an unsigned integer with the minimum number of bits that can represent the
value `T.bit_count`.

If `x` is zero, `@clz` returns `T.bit_count`.

### @cmpxchg {#builtin-cmpxchg}

```{.zig}
@cmpxchg(ptr: &T, cmp: T, new: T, success_order: AtomicOrder, fail_order: AtomicOrder) -> bool
```

This function performs an atomic compare exchange operation.

`AtomicOrder` can be found with `@import("builtin").AtomicOrder`.

`@typeOf(ptr).alignment` must be `>= @sizeOf(T).`

See also:

-   [Compile Variables](#compile-variables)

### @compileError {#builtin-compileError}

```{.zig}
@compileError(comptime msg: []u8)
```

This function, when semantically analyzed, causes a compile error with the message `msg`.

There are several ways that code avoids being semantically checked, such as using `if` or `switch`
with compile time constants, and `comptime` functions.

### @compileLog {#builtin-compileLog}

```{.zig}
@compileLog(args: ...)
```

This function, when semantically analyzed, causes a compile error, but it does not prevent
compile-time code from continuing to run, and it otherwise does not interfere with analysis.

Each of the arguments will be serialized to a printable debug value and output to stderr, and then a
newline at the end.

This function can be used to do “printf debugging” on compile-time executing code.

### @ctz {#builtin-ctz}

```{.zig}
@ctz(x: T) -> U
```

This function counts the number of trailing zeroes in `x` which is an integer type `T`.

The return type `U` is an unsigned integer with the minimum number of bits that can represent the
value `T.bit_count`.

If `x` is zero, `@ctz` returns `T.bit_count`.

### @divExact {#builtin-divExact}

```{.zig}
@divExact(numerator: T, denominator: T) -> T
```

Exact division. Caller guarantees `denominator != 0` and `@divTrunc(numerator, denominator) *
denominator == numerator`.

-   `@divExact(6, 3) == 2`
-   `@divExact(a, b) * b == a`

See also:

-   [@divTrunc](#builtin-divTrunc)
-   [@divFloor](#builtin-divFloor)
-   `@import("std").math.divExact`

### @divFloor {#builtin-divFloor}

```{.zig}
@divFloor(numerator: T, denominator: T) -> T
```

Floored division. Rounds toward negative infinity. For unsigned integers it is the same as
`numerator / denominator`. Caller guarantees `denominator != 0` and `!(@typeId(T) ==
builtin.TypeId.Int and T.is_signed and numerator == @minValue(T) and denominator == -1)`.

-   `@divFloor(-5, 3) == -2`
-   `@divFloor(a, b) + @mod(a, b) == a`

See also:

-   [@divTrunc](#builtin-divTrunc)
-   [@divExact](#builtin-divExact)
-   `@import("std").math.divFloor`

### @divTrunc {#builtin-divTrunc}

```{.zig}
@divTrunc(numerator: T, denominator: T) -> T
```

Truncated division. Rounds toward zero. For unsigned integers it is the same as `numerator /
denominator`. Caller guarantees `denominator != 0` and `!(@typeId(T) == builtin.TypeId.Int and
T.is_signed and numerator == @minValue(T) and denominator == -1)`.

-   `@divTrunc(-5, 3) == -1`
-   `@divTrunc(a, b) + @rem(a, b) == a`

See also:

-   [@divFloor](#builtin-divFloor)
-   [@divExact](#builtin-divExact)
-   `@import("std").math.divTrunc`

### @embedFile {#builtin-embedFile}

```{.zig}
@embedFile(comptime path: []const u8) -> [X]u8
```

This function returns a compile time constant fixed-size array with length equal to the byte count
of the file given by `path`. The contents of the array are the contents of the file.

`path` is absolute or relative to the current file, just like `@import`.

See also:

-   [@import](#builtin-import)

### @enumTagName {#builtin-enumTagName}

```{.zig}
@enumTagName(value: var) -> []const u8
```

Converts an enum tag name to a slice of bytes.

### @errorName {#builtin-errorName}

```{.zig}
@errorName(err: error) -> []u8
```

This function returns the string representation of an error. If an error declaration is:

```{.zig}
error OutOfMem
```

Then the string representation is `"OutOfMem"`.

If there are no calls to `@errorName` in an entire application, or all calls have a compile-time
known value for `err`, then no error name table will be generated.

### @fence {#builtin-fence}

```{.zig}
@fence(order: AtomicOrder)
```

The `fence` function is used to introduce happens-before edges between operations.

`AtomicOrder` can be found with `@import("builtin").AtomicOrder`.

See also:

-   [Compile Variables](#compile-variables)

### @fieldParentPtr {#builtin-fieldParentPtr}

```{.zig}
@fieldParentPtr(comptime ParentType: type, comptime field_name: []const u8,
        field_ptr: &T) -> &ParentType
```

Given a pointer to a field, returns the base pointer of a struct.

### @frameAddress {#builtin-frameAddress}

```{.zig}
@frameAddress()
```

This function returns the base pointer of the current stack frame.

The implications of this are target specific and not consistent across all platforms. The frame
address may not be available in release mode due to aggressive optimizations.

This function is only valid within function scope.

### @import {#builtin-import}

```{.zig}
@import(comptime path: []u8) -> (namespace)
```

This function finds a zig file corresponding to `path` and imports all the public top level
declarations into the resulting namespace.

`path` can be a relative or absolute path, or it can be the name of a package. If it is a relative
path, it is relative to the file that contains the `@import` function call.

The following packages are always available:

-   `@import("std")` - Zig Standard Library
-   `@import("builtin")` - Compiler-provided types and variables

See also:

-   [Compile Variables](#compile-variables)
-   [@embedFile](#builtin-embedFile)

### @inlineCall {#builtin-inlineCall}

```{.zig}
@inlineCall(function: X, args: ...) -> Y
```

This calls a function, in the same way that invoking an expression with parentheses does:

```{.zig}
const assert = @import("std").debug.assert;
test "inline function call" {
    assert(@inlineCall(add, 3, 9) == 12);
}

fn add(a: i32, b: i32) -> i32 { a + b }
```

Unlike a normal function call, however, `@inlineCall` guarantees that the call will be inlined. If
the call cannot be inlined, a compile error is emitted.

### @intToPtr {#builtin-intToPtr}

```{.zig}
@intToPtr(comptime DestType: type, int: usize) -> DestType
```

Converts an integer to a pointer. To convert the other way, use [@ptrToInt](#builtin-ptrToInt).

### @IntType {#builtin-IntType}

```{.zig}
@IntType(comptime is_signed: bool, comptime bit_count: u8) -> type
```

This function returns an integer type with the given signness and bit count.

### @maxValue {#builtin-maxValue}

```{.zig}
@maxValue(comptime T: type) -> (number literal)
```

This function returns the maximum value of the integer type `T`.

The result is a compile time constant.

### @memberCount {#builtin-memberCount}

```{.zig}
@memberCount(comptime T: type) -> (number literal)
```

This function returns the number of enum values in an enum type.

The result is a compile time constant.

### @memcpy {#builtin-memcpy}

```{.zig}
@memcpy(noalias dest: &u8, noalias source: &const u8, byte_count: usize)
```

This function copies bytes from one region of memory to another. `dest` and `source` are both
pointers and must not overlap.

This function is a low level intrinsic with no safety mechanisms. Most code should not use this
function, instead using something like this:

```{.zig}
for (source[0...byte_count]) |b, i| dest[i] = b;
```

The optimizer is intelligent enough to turn the above snippet into a memcpy.

There is also a standard library function for this:

```{.zig}
const mem = @import("std").mem;
mem.copy(u8, dest[0...byte_count], source[0...byte_count]);
```

### @memset {#builtin-memset}

```{.zig}
@memset(dest: &u8, c: u8, byte_count: usize)
```

This function sets a region of memory to `c`. `dest` is a pointer.

This function is a low level intrinsic with no safety mechanisms. Most code should not use this
function, instead using something like this:

```{.zig}
for (dest[0...byte_count]) |*b| *b = c;
```

The optimizer is intelligent enough to turn the above snippet into a memset.

There is also a standard library function for this:

```{.zig}
const mem = @import("std").mem;
mem.set(u8, dest, c);
```

### @minValue {#builtin-minValue}

```{.zig}
@minValue(comptime T: type) -> (number literal)
```

This function returns the minimum value of the integer type T.

The result is a compile time constant.

### @mod {#builtin-mod}

```{.zig}
@mod(numerator: T, denominator: T) -> T
```

Modulus division. For unsigned integers this is the same as `numerator % denominator`. Caller
guarantees `denominator > 0`.

-   `@mod(-5, 3) == 1`
-   `@divFloor(a, b) + @mod(a, b) == a`

See also:

-   [@rem](#builtin-rem)
-   `@import("std").math.mod`

### @mulWithOverflow {#builtin-mulWithOverflow}

```{.zig}
@mulWithOverflow(comptime T: type, a: T, b: T, result: &T) -> bool
```

Performs `*result = a * b`. If overflow or underflow occurs, stores the overflowed bits in `result`
and returns `true`. If no overflow or underflow occurs, returns `false`.

### @offsetOf {#builtin-offsetOf}

```{.zig}
@offsetOf(comptime T: type, comptime field_name: [] const u8) -> (number literal)
```

This function returns the byte offset of a field relative to its containing struct.

### @OpaqueType {#builtin-OpaqueType}

```{.zig}
@OpaqueType() -> type
```

Creates a new type with an unknown size and alignment.

This is typically used for type safety when interacting with C code that does not expose struct
details. Example:

```{.zig}
const Derp = @OpaqueType();
const Wat = @OpaqueType();

extern fn bar(d: &Derp);
export fn foo(w: &Wat) {
    bar(w);
}
```

```
$ ./zig build-obj test.zig
test.zig:5:9: error: expected type '&Derp', found '&Wat'
    bar(w);
        ^
```

### @panic {#builtin-panic}

```{.zig}
@panic(message: []const u8) -> noreturn
```

Invokes the panic handler function. By default the panic handler function calls the public `panic`
function exposed in the root source file, or if there is not one specified, invokes the one provided
in `std/special/panic.zig`.

Generally it is better to use `@import("std").debug.panic`. However, `@panic` can be useful for 2
scenarios:

-   From library code, calling the programmer’s panic function if they exposed one in the root
    source file.
-   When mixing C and Zig code, calling the canonical panic implementation across multiple .o files.

See also:

-   [Root Source File](#root-source-file)

### @ptrCast {#builtin-ptrCast}

```{.zig}
@ptrCast(comptime DestType: type, value: var) -> DestType
```

Converts a pointer of one type to a pointer of another type.

### @ptrToInt {#builtin-ptrToInt}

    @ptrToInt(value: var) -> usize

Converts `value` to a `usize` which is the address of the pointer. `value` can be one of these types:

-   `&T`
-   `?&T`
-   `fn()`
-   `?fn()`

To convert the other way, use [@intToPtr](#builtin-intToPtr)

### @rem {#builtin-rem}

```{.zig}
@rem(numerator: T, denominator: T) -> T
```

Remainder division. For unsigned integers this is the same as `numerator % denominator`. Caller
guarantees `denominator > 0`.

-   `@rem(-5, 3) == -2`
-   `@divTrunc(a, b) + @rem(a, b) == a`

See also:

-   [@mod](#builtin-mod)
-   `@import("std").math.rem`

### @returnAddress {#builtin-returnAddress}

```{.zig}
@returnAddress()
```

This function returns a pointer to the return address of the current stack frame.

The implications of this are target specific and not consistent across all platforms.

This function is only valid within function scope.

### @setDebugSafety {#builtin-setDebugSafety}

```{.zig}
@setDebugSafety(scope, safety_on: bool)
```

Sets whether debug safety checks are on for a given scope.

### @setEvalBranchQuota {#builtin-setEvalBranchQuota}

```{.zig}
@setEvalBranchQuota(new_quota: usize)
```

Changes the maximum number of backwards branches that compile-time code execution can use before
giving up and making a compile error.

If the `new_quota` is smaller than the default quota (`1000`) or a previously explicitly set quota,
it is ignored.

Example:

```{.zig}
comptime {
    var i = 0;
    while (i < 1001) : (i += 1) {}
}
```

```
$ ./zig build-obj test.zig 
/home/andy/dev/zig/build/test.zig:3:5: error: evaluation exceeded 1000 backwards branches
    while (i < 1001) : (i += 1) {}
    ^
```

Now we use `@setEvalBranchQuota`:

```{.zig}
comptime {
    @setEvalBranchQuota(1001);
    var i = 0;
    while (i < 1001) : (i += 1) {}
}
```

```
$ zig build-obj test.zig
```

(no output because it worked fine)

See also:

-   [comptime](#comptime)

### @setFloatMode {#builtin-setFloatMode}

```{.zig}
@setFloatMode(scope, mode: @import("builtin").FloatMode)
```

Sets the floating point mode for a given scope. Possible values are:

```{.zig}
pub const FloatMode = enum {
    Optimized,
    Strict,
};
```

-   `Optimized` (default) - Floating point operations may do all of the following:
    -   Assume the arguments and result are not NaN. Optimizations are required to retain defined
        behavior over NaNs, but the value of the result is undefined.
    -   Assume the arguments and result are not +/-Inf. Optimizations are required to retain defined
        behavior over +/-Inf, but the value of the result is undefined.
    -   Treat the sign of a zero argument or result as insignificant.
    -   Use the reciprocal of an argument rather than perform division.
    -   Perform floating-point contraction (e.g. fusing a multiply followed by an addition into a
        fused multiply-and-add).
    -   Perform algebraically equivalent transformations that may change results in floating point
        (e.g. reassociate).

    This is equivalent to `-ffast-math` in GCC.
-   `Strict` - Floating point operations follow strict IEEE compliance.

See also:

-   [Floating Point Operations](#float-operations)

### @setGlobalLinkage {#builtin-setGlobalLinkage}

```{.zig}
@setGlobalLinkage(global_variable_name, comptime linkage: GlobalLinkage)
```

`GlobalLinkage` can be found with `@import("builtin").GlobalLinkage`.

See also:

-   [Compile Variables](#compile-variables)

### @setGlobalSection {#builtin-setGlobalSection}

```{.zig}
@setGlobalSection(global_variable_name, comptime section_name: []const u8) -> bool
```

Puts the global variable in the specified section.

### @shlExact {#builtin-shlExact}

```{.zig}
@shlExact(value: T, shift_amt: Log2T) -> T
```

Performs the left shift operation (`<<`). Caller guarantees that the shift will not shift any 1 bits
out.

The type of `shift_amt` is an unsigned integer with `log2(T.bit_count)` bits. This is because
`shift_amt >= T.bit_count` is undefined behavior.

See also:

-   [@shrExact](#builtin-shrExact)
-   [@shlWithOverflow](#builtin-shlWithOverflow)

### @shlWithOverflow {#builtin-shlWithOverflow}

```{.zig}
@shlWithOverflow(comptime T: type, a: T, shift_amt: Log2T, result: &T) -> bool
```

Performs `*result = a << b`. If overflow or underflow occurs, stores the overflowed bits in `result`
and returns `true`. If no overflow or underflow occurs, returns `false`.

The type of `shift_amt` is an unsigned integer with `log2(T.bit_count)` bits. This is because
`shift_amt >= T.bit_count` is undefined behavior.

See also:

-   [@shlExact](#builtin-shlExact)
-   [@shrExact](#builtin-shrExact)

### @shrExact {#builtin-shrExact}

```{.zig}
@shrExact(value: T, shift_amt: Log2T) -> T
```

Performs the right shift operation (`>>`). Caller guarantees that the shift will not shift any 1
bits out.

The type of `shift_amt` is an unsigned integer with `log2(T.bit_count)` bits. This is because
`shift_amt >= T.bit_count` is undefined behavior.

See also:

-   [@shlExact](#builtin-shlExact)

### @sizeOf {#builtin-sizeOf}

```{.zig}
@sizeOf(comptime T: type) -> (number literal)
```

This function returns the number of bytes it takes to store `T` in memory.

The result is a target-specific compile time constant.

### @subWithOverflow {#builtin-subWithOverflow}

```{.zig}
@subWithOverflow(comptime T: type, a: T, b: T, result: &T) -> bool
```

Performs `*result = a - b`. If overflow or underflow occurs, stores the overflowed bits in `result`
and returns `true`. If no overflow or underflow occurs, returns `false`.

### @truncate {#builtin-truncate}

```{.zig}
@truncate(comptime T: type, integer) -> T
```

This function truncates bits from an integer type, resulting in a smaller integer type.

The following produces a crash in debug mode and undefined behavior in release mode:

```{.zig}
const a: u16 = 0xabcd;
const b: u8 = u8(a);
```

However this is well defined and working code:

```{.zig}
const a: u16 = 0xabcd;
const b: u8 = @truncate(u8, a);
// b is now 0xcd
```

This function always truncates the significant bits of the integer, regardless of endianness on the
target platform.

### @typeId {#builtin-typeId}

```{.zig}
@typeId(comptime T: type) -> @import("builtin").TypeId
```

Returns which kind of type something is. Possible values:

```{.zig}
pub const TypeId = enum {
    Type,
    Void,
    Bool,
    NoReturn,
    Int,
    Float,
    Pointer,
    Array,
    Struct,
    FloatLiteral,
    IntLiteral,
    UndefinedLiteral,
    NullLiteral,
    Nullable,
    ErrorUnion,
    Error,
    Enum,
    EnumTag,
    Union,
    Fn,
    Namespace,
    Block,
    BoundFn,
    ArgTuple,
    Opaque,
};
```

### @typeName {#builtin-typeName}

```{.zig}
@typeName(T: type) -> []u8
```

This function returns the string representation of a type.

### @typeOf {#builtin-typeOf}

```{.zig}
@typeOf(expression) -> type
```

This function returns a compile-time constant, which is the type of the expression passed as an
argument. The expression is evaluated.

## Build Mode

Zig has three build modes:

-   [Debug](#build-mode-debug) (default)
-   [ReleaseFast](#build-mode-release-fast)
-   [ReleaseSafe](#build-mode-release-safe)

To add standard build options to a `build.zig` file:

```{.zig}
const Builder = @import("std").build.Builder;

pub fn build(b: &Builder) {
    const exe = b.addExecutable("example", "example.zig");
    exe.setBuildMode(b.standardReleaseOptions());
    b.default_step.dependOn(&exe.step);
}
```

This causes these options to be available:

```
  -Drelease-safe=(bool)  optimizations on and safety on
  -Drelease-fast=(bool)  optimizations on and safety off
```

### Debug {#build-mode-debug}

```
$ zig build-exe example.zig
```

-   Fast compilation speed
-   Safety checks enabled
-   Slow runtime performance

### ReleaseFast {#build-mode-release-fast}

```
$ zig build-exe example.zig --release-fast
```

-   Fast runtime performance
-   Safety checks disabled
-   Slow compilation speed

### ReleaseSafe {#build-mode-release-safe}

```
$ zig build-exe example.zig --release-safe
```

-   Medium runtime performance
-   Safety checks enabled
-   Slow compilation speed

See also:

-   [Compile Variables](#compile-variables)
-   [Zig Build System](#zig-build-system)
-   [Undefined Behavior](#undefined-behavior)

## Undefined Behavior

Zig has many instances of undefined behavior. If undefined behavior is detected at compile-time, Zig
emits an error. Most undefined behavior that cannot be detected at compile-time can be detected at
runtime. In these cases, Zig has safety checks. Safety checks can be disabled on a per-block basis
with `@setDebugSafety`. The [ReleaseFast](#build-mode-release-fast) build mode disables all safety
checks in order to facilitate optimizations.

When a safety check fails, Zig crashes with a stack trace, like this:

```{.zig}
test "safety check" {
    unreachable;
}
```

```
$ zig test test.zig 
Test 1/1 safety check...reached unreachable code
/home/andy/dev/zig/build/lib/zig/std/special/zigrt.zig:16:35: 0x000000000020331c in ??? (test)
        @import("std").debug.panic("{}", message_ptr[0...message_len]);
                                  ^
/home/andy/dev/zig/build/test.zig:2:5: 0x0000000000203297 in ??? (test)
    unreachable;
    ^
/home/andy/dev/zig/build/lib/zig/std/special/test_runner.zig:9:21: 0x0000000000214b0a in ??? (test)
        test_fn.func();
                    ^
/home/andy/dev/zig/build/lib/zig/std/special/bootstrap.zig:50:21: 0x0000000000214a17 in ??? (test)
    return root.main();
                    ^
/home/andy/dev/zig/build/lib/zig/std/special/bootstrap.zig:37:13: 0x00000000002148d0 in ??? (test)
    callMain(argc, argv, envp) %% exit(1);
            ^
/home/andy/dev/zig/build/lib/zig/std/special/bootstrap.zig:30:20: 0x0000000000214820 in ??? (test)
    callMainAndExit()
                   ^

Tests failed. Use the following command to reproduce the failure:
./test
```

### Reaching Unreachable Code {#undef-unreachable}

At compile-time:

```{.zig}
comptime {
    assert(false);
}
fn assert(ok: bool) {
    if (!ok) unreachable; // assertion failure
}
```

```
$ zig build-obj test.zig 
/home/andy/dev/zig/build/test.zig:5:14: error: unable to evaluate constant expression
    if (!ok) unreachable; // assertion failure
             ^
/home/andy/dev/zig/build/test.zig:2:11: note: called from here
    assert(false);
          ^
/home/andy/dev/zig/build/test.zig:1:10: note: called from here
comptime {
         ^
```

At runtime crashes with the message `reached unreachable code` and a stack trace.

### Index out of Bounds {#undef-index-out-of-bounds}

At compile-time:

```{.zig}
comptime {
    const array = "hello";
    const garbage = array[5];
}
```

```
$ zig build-obj test.zig 
/home/andy/dev/zig/build/test.zig:3:26: error: index 5 outside array of size 5
    const garbage = array[5];
                         ^
```

At runtime crashes with the message `index out of bounds` and a stack trace.

### Cast Negative Number to Unsigned Integer {#undef-cast-negative-unsigned}

At compile-time:

```{.zig}
comptime {
    const value: i32 = -1;
    const unsigned = u32(value);
}

$ zig build-obj test.zig test.zig:3:25: error: attempt to cast negative value to unsigned integer
    const unsigned = u32(value);
                        ^
```

At runtime crashes with the message `attempt to cast negative value to unsigned integer` and a stack
trace.

If you are trying to obtain the maximum value of an unsigned integer, use `@maxValue(T)`, where `T`
is the integer type, such as `u32`.

### Cast Truncates Data {#undef-cast-truncates-data}

At compile-time:

```{.zig}
comptime {
    const spartan_count: u16 = 300;
    const byte = u8(spartan_count);
}
```

```
$ zig build-obj test.zig
test.zig:3:20: error: cast from 'u16' to 'u8' truncates bits
    const byte = u8(spartan_count);
                   ^
```

At runtime crashes with the message `integer cast truncated bits` and a stack trace.

If you are trying to truncate bits, use `@truncate(T, value)`, where `T` is the integer type, such
as `u32`, and `value` is the value you want to truncate.

### Integer Overflow {#undef-integer-overflow}

#### Default Operations {#undef-int-overflow-default}

The following operators can cause integer overflow:

-   `+` (addition)
-   `-` (subtraction)
-   `-` (negation)
-   `*` (multiplication)
-   `/` (division)
-   `@divTrunc` (division)
-   `@divFloor` (division)
-   `@divExact` (division)

Example with addition at compile-time:

```{.zig}
comptime {
    var byte: u8 = 255;
    byte += 1;
}
```

```
$ zig build-obj test.zig 
/home/andy/dev/zig/build/test.zig:3:10: error: operation caused overflow
    byte += 1;
         ^
```

At runtime crashes with the message `integer overflow` and a stack trace.

#### Standard Library Math Functions {#undef-int-overflow-std}

These functions provided by the standard library return possible errors.

-   `@import("std").math.add`
-   `@import("std").math.sub`
-   `@import("std").math.mul`
-   `@import("std").math.divTrunc`
-   `@import("std").math.divFloor`
-   `@import("std").math.divExact`
-   `@import("std").math.shl`

Example of catching an overflow for addition:

```{.zig}
const math = @import("std").math;
const io = @import("std").io;
pub fn main() -> %void {
    var byte: u8 = 255;

    byte = if (math.add(u8, byte, 1)) |result| {
        result
    } else |err| {
        %%io.stderr.printf("unable to add one: {}\n", @errorName(err));
        return err;
    };

    %%io.stderr.printf("result: {}\n", byte);
}
```

```
$ zig build-exe test.zig 
$ ./test 
unable to add one: Overflow
```

#### Builtin Overflow Functions {#undef-int-overflow-builtin}

These builtins return a `bool` of whether or not overflow occurred, as well as returning the
overflowed bits:

-   `@addWithOverflow`
-   `@subWithOverflow`
-   `@mulWithOverflow`
-   `@shlWithOverflow`

Example of `@addWithOverflow`:

```{.zig}
const io = @import("std").io;
pub fn main() -> %void {
    var byte: u8 = 255;

    var result: u8 = undefined;
    if (@addWithOverflow(u8, byte, 10, &result)) {
        %%io.stderr.printf("overflowed result: {}\n", result);
    } else {
        %%io.stderr.printf("result: {}\n", result);
    }
}
```

```
$ zig build-exe test.zig 
$ ./test 
overflowed result: 9
```

#### Wrapping Operations {#undef-int-overflow-wrap}

These operations have guaranteed wraparound semantics.

-   `+%` (wraparound addition)
-   `-%` (wraparound subtraction)
-   `-%` (wraparound negation)
-   `*%` (wraparound multiplication)


```{.zig}
const assert = @import("std").debug.assert;

test "wraparound addition and subtraction" {
    const x: i32 = @maxValue(i32);
    const min_val = x +% 1;
    assert(min_val == @minValue(i32));
    const max_val = min_val -% 1;
    assert(max_val == @maxValue(i32));
}
```

### Exact Left Shift Overflow {#undef-shl-overflow}

At compile-time:

```{.zig}
comptime {
    const x = @shlExact(u8(0b01010101), 2);
}

$ zig build-obj test.zig 
/home/andy/dev/zig/build/test.zig:2:15: error: operation caused overflow
    const x = @shlExact(u8(0b01010101), 2);
              ^
```

At runtime crashes with the message `left shift overflowed bits` and a stack trace.

### Exact Right Shift Overflow {#undef-shr-overflow}

At compile-time:

```{.zig}
comptime {
    const x = @shrExact(u8(0b10101010), 2);
}

$ zig build-obj test.zig 
/home/andy/dev/zig/build/test.zig:2:15: error: exact shift shifted out 1 bits
    const x = @shrExact(u8(0b10101010), 2);
              ^
```

At runtime crashes with the message `right shift overflowed bits` and a stack trace.

### Division by Zero {#undef-division-by-zero}

At compile-time:

```{.zig}
comptime {
    const a: i32 = 1;
    const b: i32 = 0;
    const c = a / b;
}

$ zig build-obj test.zig 
/home/andy/dev/zig/build/test.zig:4:17: error: division by zero is undefined
    const c = a / b;
                ^
```

At runtime crashes with the message `division by zero` and a stack trace.

### Remainder Division by Zero {#undef-remainder-division-by-zero}

At compile-time:

```{.zig}
comptime {
    const a: i32 = 10;
    const b: i32 = 0;
    const c = a % b;
}

$ zig build-obj test.zig 
/home/andy/dev/zig/build/test.zig:4:17: error: division by zero is undefined
    const c = a % b;
                ^
```

At runtime crashes with the message `remainder division by zero` and a stack trace.

### Exact Division Remainder {#undef-exact-division-remainder}

TODO

### Slice Widen Remainder {#undef-slice-widen-remainder}

TODO

### Attempt to Unwrap Null {#undef-attempt-unwrap-null}

At compile-time:

```{.zig}
comptime {
    const nullable_number: ?i32 = null;
    const number = ??nullable_number;
}

$ zig build-obj test.zig 
/home/andy/dev/zig/build/test.zig:3:20: error: unable to unwrap null
    const number = ??nullable_number;
                   ^
```

At runtime crashes with the message `attempt to unwrap null` and a stack trace.

One way to avoid this crash is to test for null instead of assuming non-null, with the `if`
expression:

```{.zig}
const io = @import("std").io;
pub fn main() -> %void {
    const nullable_number: ?i32 = null;

    if (nullable_number) |number| {
        %%io.stderr.printf("got number: {}\n", number);
    } else {
        %%io.stderr.printf("it's null\n");
    }
}
```

```
% zig build-exe test.zig
$ ./test 
it's null
```

### Attempt to Unwrap Error {#undef-attempt-unwrap-error}

At compile-time:

```{.zig}
comptime {
    const number = %%getNumberOrFail();
}

error UnableToReturnNumber;

fn getNumberOrFail() -> %i32 {
    return error.UnableToReturnNumber;
}
```

```
$ zig build-obj test.zig 
/home/andy/dev/zig/build/test.zig:2:20: error: unable to unwrap error 'UnableToReturnNumber'
    const number = %%getNumberOrFail();
                         ^
```

At runtime crashes with the message `attempt to unwrap error: ErrorCode` and a stack trace.

One way to avoid this crash is to test for an error instead of assuming a successful result, with
the `if` expression:

```{.zig}
const io = @import("std").io;

pub fn main() -> %void {
    const result = getNumberOrFail();

    if (result) |number| {
        %%io.stderr.printf("got number: {}\n", number);
    } else |err| {
        %%io.stderr.printf("got error: {}\n", @errorName(err));
    }
}

error UnableToReturnNumber;

fn getNumberOrFail() -> %i32 {
    return error.UnableToReturnNumber;
}
```

```
$ zig build-exe test.zig 
$ ./test 
got error: UnableToReturnNumber
```

### Invalid Error Code {#undef-invalid-error-code}

At compile-time:

```{.zig}
error AnError;
comptime {
    const err = error.AnError;
    const number = u32(err) + 10;
    const invalid_err = error(number);
}

$ zig build-obj test.zig 
/home/andy/dev/zig/build/test.zig:5:30: error: integer value 11 represents no error
    const invalid_err = error(number);
                             ^
```

At runtime crashes with the message `invalid error code` and a stack trace.

### Invalid Enum Cast {#undef-invalid-enum-cast}

TODO

### Incorrect Pointer Alignment {#undef-incorrect-pointer-alignment}

TODO

## Memory

TODO: explain no default allocator in zig

TODO: show how to use the allocator interface

TODO: mention debug allocator

TODO: importance of checking for allocation failure

TODO: mention overcommit and the OOM Killer

TODO: mention recursion

See also:

-   [Pointers](#pointers)

## Compile Variables

Compile variables are accessible by importing the `"builtin"` package, which the compiler makes
available to every Zig source file. It contains compile-time constants such as the current target,
endianness, and release mode.

```{.zig}
const builtin = @import("builtin");
const separator = if (builtin.os == builtin.Os.windows) '\\' else '/';
```

Example of what is imported with `@import("builtin")`:

```{.zig}
pub const Os = enum {
    freestanding,
    cloudabi,
    darwin,
    dragonfly,
    freebsd,
    ios,
    kfreebsd,
    linux,
    lv2,
    macosx,
    netbsd,
    openbsd,
    solaris,
    windows,
    haiku,
    minix,
    rtems,
    nacl,
    cnk,
    bitrig,
    aix,
    cuda,
    nvcl,
    amdhsa,
    ps4,
    elfiamcu,
    tvos,
    watchos,
    mesa3d,
};

pub const Arch = enum {
    armv8_2a,
    armv8_1a,
    armv8,
    armv8m_baseline,
    armv8m_mainline,
    armv7,
    armv7em,
    armv7m,
    armv7s,
    armv7k,
    armv6,
    armv6m,
    armv6k,
    armv6t2,
    armv5,
    armv5te,
    armv4t,
    armeb,
    aarch64,
    aarch64_be,
    avr,
    bpfel,
    bpfeb,
    hexagon,
    mips,
    mipsel,
    mips64,
    mips64el,
    msp430,
    powerpc,
    powerpc64,
    powerpc64le,
    r600,
    amdgcn,
    sparc,
    sparcv9,
    sparcel,
    s390x,
    tce,
    thumb,
    thumbeb,
    i386,
    x86_64,
    xcore,
    nvptx,
    nvptx64,
    le32,
    le64,
    amdil,
    amdil64,
    hsail,
    hsail64,
    spir,
    spir64,
    kalimbav3,
    kalimbav4,
    kalimbav5,
    shave,
    lanai,
    wasm32,
    wasm64,
    renderscript32,
    renderscript64,
};
pub const Environ = enum {
    gnu,
    gnuabi64,
    gnueabi,
    gnueabihf,
    gnux32,
    code16,
    eabi,
    eabihf,
    android,
    musl,
    musleabi,
    musleabihf,
    msvc,
    itanium,
    cygnus,
    amdopencl,
    coreclr,
};

pub const ObjectFormat = enum {
    unknown,
    coff,
    elf,
    macho,
};

pub const GlobalLinkage = enum {
    Internal,
    Strong,
    Weak,
    LinkOnce,
};

pub const AtomicOrder = enum {
    Unordered,
    Monotonic,
    Acquire,
    Release,
    AcqRel,
    SeqCst,
};

pub const Mode = enum {
    Debug,
    ReleaseSafe,
    ReleaseFast,
};

pub const is_big_endian = false;
pub const is_test = false;
pub const os = Os.linux;
pub const arch = Arch.x86_64;
pub const environ = Environ.gnu;
pub const object_format = ObjectFormat.elf;
pub const mode = Mode.ReleaseFast;
pub const link_libs = [][]const u8 {
};
```

See also:

-   [Build Mode](#build-mode)

## Root Source File

TODO: explain how root source file finds other files

TODO: pub fn main

TODO: pub fn panic

TODO: if linking with libc you can use export fn main

TODO: order independent top level declarations

TODO: lazy analysis

TODO: using comptime { \_ = @import() }

## Zig Test

TODO: basic usage

TODO: lazy analysis

TODO: –test-filter

TODO: –test-name-prefix

TODO: testing in releasefast and releasesafe mode. assert still works

## Zig Build System

TODO: explain purpose, it’s supposed to replace make/cmake

TODO: example of building a zig executable

TODO: example of building a C library

## C

Although Zig is independent of C, and, unlike most other languages, does not depend on libc, Zig
acknowledges the importance of interacting with existing C code.

There are a few ways that Zig facilitates C interop.

### C Type Primitives

These have guaranteed C ABI compatibility and can be used like any other type.

-   `c_short`
-   `c_ushort`
-   `c_int`
-   `c_uint`
-   `c_long`
-   `c_ulong`
-   `c_longlong`
-   `c_ulonglong`
-   `c_longdouble`
-   `c_void`

See also:

-   [Primitive Types](#primitive-types)

### C String Literals

```{.zig}
extern fn puts(&const u8);

pub fn main() -> %void {
    puts(c"this has a null terminator");
    puts(
        c\\and so
        c\\does this
        c\\multiline C string literal
    );
}
```

See also:

-   [String Literals](#string-literals)

### Import from C Header File {#c-import}

The `@cImport` builtin function can be used to directly import symbols from .h files:

```{.zig}
const c = @cImport(@cInclude("stdio.h"));
pub fn main() -> %void {
    c.printf("hello\n");
}
```

The `@cImport` function takes an expression as a parameter. This expression is evaluated at
compile-time and is used to control preprocessor directives and include multiple .h files:

```{.zig}
const builtin = @import("builtin");

const c = @cImport({
    @cDefine("NDEBUG", builtin.mode == builtin.Mode.ReleaseFast);
    if (something) {
        @cDefine("_GNU_SOURCE", {});
    }
    @cInclude("stdlib.h")
    if (something) {
        @cUndef("_GNU_SOURCE");
    }
    @cInclude("soundio.h");
});
```

See also:

-   [@cImport](#builtin-cImport)
-   [@cInclude](#builtin-cInclude)
-   [@cDefine](#builtin-cDefine)
-   [@cUndef](#builtin-cUndef)
-   [@import](#builtin-import)

### Mixing Object Files

You can mix Zig object files with any other object files that respect the C ABI. Example:

##### base64.zig

```{.zig}
const base64 = @import("std").base64;

export fn decode_base_64(dest_ptr: &u8, dest_len: usize,
    source_ptr: &const u8, source_len: usize) -> usize
{
    const src = source_ptr[0...source_len];
    const dest = dest_ptr[0...dest_len];
    return base64.decode(dest, src).len;
}
```

##### test.c

```{.c}
// This header is generated by zig from base64.zig
#include "base64.h"

#include <string.h>
#include <stdio.h>

int main(int argc, char **argv) {
    const char *encoded = "YWxsIHlvdXIgYmFzZSBhcmUgYmVsb25nIHRvIHVz";
    char buf[200];

    size_t len = decode_base_64(buf, 200, encoded, strlen(encoded));
    buf[len] = 0;
    puts(buf);

    return 0;
}
```

##### build.zig

```{.zig}
const Builder = @import("std").build.Builder;

pub fn build(b: &Builder) {
    const obj = b.addObject("base64", "base64.zig");

    const exe = b.addCExecutable("test");
    exe.addCompileFlags([][]const u8 {
        "-std=c99",
    });
    exe.addSourceFile("test.c");
    exe.addObject(obj);
    exe.setOutputPath(".");

    b.default_step.dependOn(&exe.step);
}
```

##### Terminal

```
$ zig build
$ ./test
all your base are belong to us
```

See also:

-   [Targets](#targets)
-   [Zig Build System](#zig-build-system)

## Targets

Zig supports generating code for all targets that LLVM supports. Here is what it looks like to
execute `zig targets` on a Linux x86\_64 computer:

```
$ zig targets
Architectures:
  armv8_2a
  armv8_1a
  armv8
  armv8m_baseline
  armv8m_mainline
  armv7
  armv7em
  armv7m
  armv7s
  armv7k
  armv6
  armv6m
  armv6k
  armv6t2
  armv5
  armv5te
  armv4t
  armeb
  aarch64
  aarch64_be
  avr
  bpfel
  bpfeb
  hexagon
  mips
  mipsel
  mips64
  mips64el
  msp430
  powerpc
  powerpc64
  powerpc64le
  r600
  amdgcn
  sparc
  sparcv9
  sparcel
  s390x
  tce
  thumb
  thumbeb
  i386
  x86_64 (native)
  xcore
  nvptx
  nvptx64
  le32
  le64
  amdil
  amdil64
  hsail
  hsail64
  spir64
  kalimbav3
  kalimbav4
  kalimbav5
  shave
  lanai
  wasm32
  wasm64
  renderscript32
  renderscript64

Operating Systems:
  freestanding
  cloudabi
  darwin
  dragonfly
  freebsd
  ios
  kfreebsd
  linux (native)
  lv2
  macosx
  netbsd
  openbsd
  solaris
  windows
  haiku
  minix
  rtems
  nacl
  cnk
  bitrig
  aix
  cuda
  nvcl
  amdhsa
  ps4
  elfiamcu
  tvos
  watchos
  mesa3d

Environments:
  gnu (native)
  gnuabi64
  gnueabi
  gnueabihf
  gnux32
  code16
  eabi
  eabihf
  android
  musl
  musleabi
  musleabihf
  msvc
  itanium
  cygnus
  amdopencl
  coreclr
```

The Zig Standard Library (`@import("std")`) has architecture, environment, and operating sytsem
abstractions, and thus takes additional work to support more platforms. It currently supports Linux
x86\_64. Not all standard library code requires operating system abstractions, however, so things
such as generic data structures work an all above platforms.

## Style Guide

These coding conventions are not enforced by the compiler, but they are shipped in this
documentation along with the compiler in order to provide a point of reference, should anyone wish
to point to an authority on agreed upon Zig coding style.

### Whitespace {#style-guide-whitespace}

-   4 space indentation
-   Open braces on same line, unless you need to wrap.
-   If a list of things is longer than 2, put each item on its own line and exercise the abilty to
    put an extra comma at the end.
-   Line length: aim for 100; use common sense.

### Names {#style-guide-names}

Roughly speaking: `camelCaseFunctionName`, `TitleCaseTypeName`, `snake_case_variable_name`. More precisely:

-   If `x` is a `struct` (or an alias of a `struct`), then `x` should be `TitleCase`.
-   If `x` otherwise identifies a type, `x` should have `snake_case`.
-   If `x` is callable, and `x`’s return type is `type`, then `x` should be `TitleCase`.
-   If `x` is otherwise callable, then `x` should be `camelCase`.
-   Otherwise, `x` should be `snake_case`.

Acronyms, initialisms, proper nouns, or any other word that has capitalization rules in written
English are subject to naming conventions just like any other word. Even acronyms that are only 2
letters long are subject to these conventions.

These are general rules of thumb; if it makes sense to do something different, do what makes sense.
For example, if there is an established convention such as `ENOENT`, follow the established
convention.

### Examples {#style-guide-examples}

```{.zig}
const namespace_name = @import("dir_name/file_name.zig");
var global_var: i32 = undefined;
const const_name = 42;
const primitive_type_alias = f32;
const string_alias = []u8;

const StructName = struct {};
const StructAlias = StructName;

fn functionName(param_name: TypeName) {
    var functionPointer = functionName;
    functionPointer();
    functionPointer = otherFunction;
    functionPointer();
}
const functionAlias = functionName;

fn ListTemplateFunction(comptime ChildType: type, comptime fixed_size: usize) -> type {
    return List(ChildType, fixed_size);
}

fn ShortList(comptime T: type, comptime n: usize) -> type {
    struct {
        field_name: [n]T,
        fn methodName() {}
    }
}

// The word XML loses its casing when used in Zig identifiers.
const xml_document =
    \\<?xml version="1.0" encoding="UTF-8"?>
    \\<document>
    \\</document>
;
const XmlParser = struct {};

// The initials BE (Big Endian) are just another word in Zig identifier names.
fn readU32Be() -> u32 {}
```

See the Zig Standard Library for more examples.

## Grammar

```
Root = many(TopLevelItem) EOF

TopLevelItem = ErrorValueDecl | CompTimeExpression(Block) | TopLevelDecl | TestDecl

TestDecl = "test" String Block

TopLevelDecl = option(VisibleMod) (FnDef | ExternDecl | GlobalVarDecl | UseDecl)

ErrorValueDecl = "error" Symbol ";"

GlobalVarDecl = VariableDeclaration ";"

VariableDeclaration = option("comptime") ("var" | "const") Symbol option(":" TypeExpr) option("align" "(" Expression ")") "=" Expression

ContainerMember = (ContainerField | FnDef | GlobalVarDecl)

ContainerField = Symbol option(":" Expression) ","

UseDecl = "use" Expression ";"

ExternDecl = "extern" option(String) (FnProto | VariableDeclaration) ";"

FnProto = option("coldcc" | "nakedcc" | "stdcallcc") "fn" option(Symbol) ParamDeclList option("align" "(" Expression ")") option("->" TypeExpr)

VisibleMod = "pub" | "export"

FnDef = option("inline" | "extern") FnProto Block

ParamDeclList = "(" list(ParamDecl, ",") ")"

ParamDecl = option("noalias" | "comptime") option(Symbol ":") (TypeExpr | "...")

Block = "{" many(Statement) option(Expression) "}"

Statement = Label | VariableDeclaration ";" | Defer(Block) | Defer(Expression) ";" | BlockExpression(Block) | Expression ";" | ";"

Label = Symbol ":"

TypeExpr = PrefixOpExpression | "var"

BlockOrExpression = Block | Expression

Expression = ReturnExpression | BreakExpression | AssignmentExpression

AsmExpression = "asm" option("volatile") "(" String option(AsmOutput) ")"

AsmOutput = ":" list(AsmOutputItem, ",") option(AsmInput)

AsmInput = ":" list(AsmInputItem, ",") option(AsmClobbers)

AsmOutputItem = "[" Symbol "]" String "(" (Symbol | "->" TypeExpr) ")"

AsmInputItem = "[" Symbol "]" String "(" Expression ")"

AsmClobbers= ":" list(String, ",")

UnwrapExpression = BoolOrExpression (UnwrapNullable | UnwrapError) | BoolOrExpression

UnwrapNullable = "??" Expression

UnwrapError = "%%" option("|" Symbol "|") Expression

AssignmentExpression = UnwrapExpression AssignmentOperator UnwrapExpression | UnwrapExpression

AssignmentOperator = "=" | "*=" | "/=" | "%=" | "+=" | "-=" | "<<=" | ">>=" | "&=" | "^=" | "|=" | "*%=" | "+%=" | "-%="

BlockExpression(body) = Block | IfExpression(body) | TryExpression(body) | TestExpression(body) | WhileExpression(body) | ForExpression(body) | SwitchExpression | CompTimeExpression(body)

CompTimeExpression(body) = "comptime" body

SwitchExpression = "switch" "(" Expression ")" "{" many(SwitchProng) "}"

SwitchProng = (list(SwitchItem, ",") | "else") "=>" option("|" option("*") Symbol "|") Expression ","

SwitchItem = Expression | (Expression "..." Expression)

ForExpression(body) = option("inline") "for" "(" Expression ")" option("|" option("*") Symbol option("," Symbol) "|") body option("else" BlockExpression(body))

BoolOrExpression = BoolAndExpression "or" BoolOrExpression | BoolAndExpression

ReturnExpression = option("%") "return" option(Expression)

BreakExpression = "break" option(Expression)

Defer(body) = option("%") "defer" body

IfExpression(body) = "if" "(" Expression ")" body option("else" BlockExpression(body))

TryExpression(body) = "if" "(" Expression ")" option("|" option("*") Symbol "|") body "else" "|" Symbol "|" BlockExpression(body)

TestExpression(body) = "if" "(" Expression ")" option("|" option("*") Symbol "|") body option("else" BlockExpression(body))

WhileExpression(body) = option("inline") "while" "(" Expression ")" option("|" option("*") Symbol "|") option(":" "(" Expression ")") body option("else" option("|" Symbol "|") BlockExpression(body))

BoolAndExpression = ComparisonExpression "and" BoolAndExpression | ComparisonExpression

ComparisonExpression = BinaryOrExpression ComparisonOperator BinaryOrExpression | BinaryOrExpression

ComparisonOperator = "==" | "!=" | "<" | ">" | "<=" | ">="

BinaryOrExpression = BinaryXorExpression "|" BinaryOrExpression | BinaryXorExpression

BinaryXorExpression = BinaryAndExpression "^" BinaryXorExpression | BinaryAndExpression

BinaryAndExpression = BitShiftExpression "&" BinaryAndExpression | BitShiftExpression

BitShiftExpression = AdditionExpression BitShiftOperator BitShiftExpression | AdditionExpression

BitShiftOperator = "<<" | ">>" | "<<"

AdditionExpression = MultiplyExpression AdditionOperator AdditionExpression | MultiplyExpression

AdditionOperator = "+" | "-" | "++" | "+%" | "-%"

MultiplyExpression = CurlySuffixExpression MultiplyOperator MultiplyExpression | CurlySuffixExpression

CurlySuffixExpression = TypeExpr option(ContainerInitExpression)

MultiplyOperator = "*" | "/" | "%" | "**" | "*%"

PrefixOpExpression = PrefixOp PrefixOpExpression | SuffixOpExpression

SuffixOpExpression = PrimaryExpression option(FnCallExpression | ArrayAccessExpression | FieldAccessExpression | SliceExpression)

FieldAccessExpression = "." Symbol

FnCallExpression = "(" list(Expression, ",") ")"

ArrayAccessExpression = "[" Expression "]"

SliceExpression = "[" Expression ".." option(Expression) "]"

ContainerInitExpression = "{" ContainerInitBody "}"

ContainerInitBody = list(StructLiteralField, ",") | list(Expression, ",")

StructLiteralField = "." Symbol "=" Expression

PrefixOp = "!" | "-" | "~" | "*" | ("&" option("align" "(" Expression option(":" Integer ":" Integer) ")" ) option("const") option("volatile")) | "?" | "%" | "%%" | "??" | "-%"

PrimaryExpression = Integer | Float | String | CharLiteral | KeywordLiteral | GroupedExpression | GotoExpression | BlockExpression(BlockOrExpression) | Symbol | ("@" Symbol FnCallExpression) | ArrayType | (option("extern") FnProto) | AsmExpression | ("error" "." Symbol) | ContainerDecl

ArrayType : "[" option(Expression) "]" option("align" "(" Expression option(":" Integer ":" Integer) ")")) option("const") option("volatile") TypeExpr

GotoExpression = "goto" Symbol

GroupedExpression = "(" Expression ")"

KeywordLiteral = "true" | "false" | "null" | "continue" | "undefined" | "error" | "this" | "unreachable"

ContainerDecl = option("extern" | "packed") ("struct" | "enum" | "union") "{" many(ContainerMember) "}"
```

## Zen

-   Communicate intent precisely.
-   Edge cases matter.
-   Favor reading code over writing code.
-   Only one obvious way to do things.
-   Runtime crashes are better than bugs.
-   Compile errors are better than runtime crashes.
-   Incremental improvements.
-   Avoid local maximums.
-   Reduce the amount one must remember.
-   Minimize energy spent on coding style.
-   Together we serve end users.

<script src="../highlight/highlight.pack.js"></script>
<script>hljs.initHighlightingOnLoad();</script>
