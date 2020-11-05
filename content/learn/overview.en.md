---
title: "In-depth Overview"
toc: true
---
# Feature Highlights
## Small, simple language

Focus on debugging your application rather than debugging your programming language knowledge.

Zig's entire syntax is specified with a [500-line PEG grammar file](https://ziglang.org/documentation/master/#Grammar).

There is **no hidden control flow**, no hidden memory allocations, no preprocessor, and no macros. If Zig code doesn't look like it's jumping away to call a function, then it isn't. This means you can be sure that the following code calls only foo() and then bar(), and this is guaranteed without needing to know the types of anything:

```zig
var a = b + c.d;
foo();
bar();
```

Examples of hidden control flow:

- D has `@property` functions, which are methods that you call with what looks like field access, so in the above example, `c.d` might call a function.
- C++, D, and Rust have operator overloading, so the `+` operator might call a function.
- C++, D, and Go have throw/catch exceptions, so `foo()` might throw an exception, and prevent `bar()` from being called.

 Zig promotes code maintenance and readability by making all control flow managed exclusively with language keywords and function calls.

## Performance and Safety: Choose Two

Zig has four [build modes](https://ziglang.org/documentation/master/#Build-Mode), and they can all be mixed and matched all the way down to [scope granularity](https://ziglang.org/documentation/master/#setRuntimeSafety). 

| Parameter | [Debug](/documentation/master/#Debug) | [ReleaseSafe](/documentation/master/#ReleaseSafe) | [ReleaseFast](/documentation/master/#ReleaseFast) | [ReleaseSmall](/documentation/master/#ReleaseSmall) |
|-----------|-------|-------------|-------------|--------------|
Optimizations - improve speed, harm debugging, harm compile time | | -O3 | -O3| -Os |
Runtime Safety Checks - harm speed, harm size, crash instead of undefined behavior | On | On | | |

Here is what [Integer Overflow](https://ziglang.org/documentation/master/#Integer-Overflow) looks like at compile time, regardless of the build mode: 

{{< zigdocgen "docgen-samples/features/1-integer-overflow.md" >}}

Here is what it looks like at runtime, in safety-checked builds: 

{{< zigdocgen "docgen-samples/features/2-integer-overflow-runtime.md" >}}


Those [stack traces work on all targets](https://ziglang.org/#Stack-traces-on-all-targets), including [freestanding](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html).

With Zig one can rely on a safety-enabled build mode, and selectively disable safety at the performance bottlenecks. For example the previous example could be modified like this: 

{{< zigdocgen "docgen-samples/features/3-undefined-behavior.md" >}}

Zig uses [undefined behavior](https://ziglang.org/documentation/master/#Undefined-Behavior) as a razor sharp tool for both bug prevention and performance enhancement.

Speaking of performance, Zig is faster than C.

- The reference implementation uses LLVM as a backend for state of the art optimizations.
- What other projects call "Link Time Optimization" Zig does automatically.
- For native targets, advanced CPU features are enabled (-march=native), thanks to the fact that [Cross-compiling is a first-class use case](https://ziglang.org/#Cross-compiling-is-a-first-class-use-case).
- Carefully chosen undefined behavior. For example, in Zig both signed and unsigned integers have undefined behavior on overflow, contrasted to only signed integers in C. This [facilitates optimizations that are not available in C](https://godbolt.org/z/n_nLEU).
- Zig directly exposes a [SIMD vector type](https://ziglang.org/documentation/master/#Vectors), making it easy to write portable vectorized code.

Please note that Zig is not a fully safe language. For those interested in following Zig's safety story, subscribe to these issues:

- [enumerate all kinds of undefined behavior, even that which cannot be safety-checked](https://github.com/ziglang/zig/issues/1966)
- [make Debug and ReleaseSafe modes fully safe](https://github.com/ziglang/zig/issues/2301)

## Zig competes with C instead of depending on it

The Zig Standard Library integrates with libc, but does not depend on it. Here's Hello World:

{{< zigdocgen "docgen-samples/features/4-hello.md" >}}

When compiled with `-O ReleaseSmall`, debug symbols stripped, single-threaded mode, this produces a 9.8 KiB static executable for the x86_64-linux target:
```
$ zig build-exe hello.zig --release-small --strip --single-threaded
$ wc -c hello
9944 hello
$ ldd hello
  not a dynamic executable
```

A Windows build is even smaller, coming out to 4096 bytes:
```
$ zig build-exe hello.zig --release-small --strip --single-threaded -target x86_64-windows
$ wc -c hello.exe
4096 hello.exe
$ file hello.exe
hello.exe: PE32+ executable (console) x86-64, for MS Windows
```

## Order independent top level declarations

Top level declarations such as global variables are order-independent and lazily analyzed. The initialization value of global variables is [evaluated at compile-time](https://ziglang.org/#Compile-time-reflection-and-compile-time-code-execution). 

{{< zigdocgen "docgen-samples/features/5-global-variables.md" >}}

## Optional type instead of null pointers

In other programming languages, null references are the source of many runtime exceptions, and even stand accused of being [the worst mistake of computer science](https://www.lucidchart.com/techblog/2015/08/31/the-worst-mistake-of-computer-science/).

Unadorned Zig pointers cannot be null:

{{< zigdocgen "docgen-samples/features/6-null-to-ptr.md" >}}

However any type can be made into an [optional type](https://ziglang.org/documentation/master/#Optionals) by prefixing it with ?: 

{{< zigdocgen "docgen-samples/features/7-optional-syntax.md" >}}

To unwrap an optional value, one can use `orelse` to provide a default value:

{{< zigdocgen "docgen-samples/features/8-optional-orelse.md" >}}

Another option is to use if:

{{< zigdocgen "docgen-samples/features/9-optional-if.md" >}}

 The same syntax works with [while](https://ziglang.org/documentation/master/#while):

{{< zigdocgen "docgen-samples/features/10-optional-while.md" >}}

## Manual memory management

A library written in Zig is eligible to be used anywhere:

- [Desktop applications](https://github.com/TM35-Metronome/) & [games](https://github.com/dbandstra/oxid)
- Low latency servers
- [Operating System kernels](https://github.com/AndreaOrru/zen)
- [Embedded devices](https://github.com/skyfex/zig-nrf-demo/)
- Real-time software, e.g. live performances, airplanes, pacemakers
- [In web browsers or other plugins with WebAssembly](https://shritesh.github.io/zigfmt-web/)
- By other programming languages, using the C ABI

In order to accomplish this, Zig programmers must manage their own memory, and must handle memory allocation failure.

This is true of the Zig Standard Library as well. Any functions that need to allocate memory accept an allocator parameter. As a result, the Zig Standard Library can be used even for the freestanding target.

In addition to [A fresh take on error handling](https://ziglang.org/#A-fresh-take-on-error-handling), Zig provides [defer](https://ziglang.org/documentation/master/#defer) and [errdefer](https://ziglang.org/documentation/master/#errdefer) to make all resource management - not only memory - simple and easily verifiable.

For an example of `defer`, see [Integration with C libraries without FFI/bindings](https://ziglang.org/#Integration-with-C-libraries-without-FFIbindings). Here is an example of using `errdefer`:
{{< zigdocgen "docgen-samples/features/11-errdefer.md" >}}


## A fresh take on error handling

Errors are values, and may not be ignored:

{{< zigdocgen "docgen-samples/features/12-errors-as-values.md" >}}

Errors can be handled with [catch](https://ziglang.org/documentation/master/#catch): 

{{< zigdocgen "docgen-samples/features/13-errors-catch.md" >}}

The keyword [try](https://ziglang.org/documentation/master/#try) is a shortcut for `catch |err| return err`: 

{{< zigdocgen "docgen-samples/features/14-errors-try.md" >}}

Note that is an [Error Return Trace](https://ziglang.org/documentation/master/#Error-Return-Traces), not a [stack trace](https://ziglang.org/#Stack-traces-on-all-targets). The code did not pay the price of unwinding the stack to come up with that trace.

The [switch](https://ziglang.org/documentation/master/#switch) keyword used on an error ensures that all possible errors are handled: 

{{< zigdocgen "docgen-samples/features/15-errors-switch.md" >}}

The keyword [unreachable](https://ziglang.org/documentation/master/#unreachable) is used to assert that no errors will occur: 

{{< zigdocgen "docgen-samples/features/16-unreachable.md" >}}

This invokes [undefined behavior](https://ziglang.org/#Performance-and-Safety-Choose-Two) in the unsafe build modes, so be sure to use it only when success is guaranteed.

### Stack traces on all targets

The stack traces and [error return traces](https://ziglang.org/documentation/master/#Error-Return-Traces) shown on this page work on all [Tier 1 Support](https://ziglang.org/#Tier-1-Support) and some [Tier 2 Support](https://ziglang.org/#Tier-2-Support) targets. [Even freestanding](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html)!

In addition, the standard library has the ability to capture a stack trace at any point and then dump it to standard error later: 

{{< zigdocgen "docgen-samples/features/17-stack-traces.md" >}}

You can see this technique being used in the ongoing [GeneralPurposeDebugAllocator project](https://github.com/andrewrk/zig-general-purpose-allocator/#current-status).

## Generic data structures and functions

Types are values that must be known at compile-time:

{{< zigdocgen "docgen-samples/features/18-types.md" >}}

A generic data structure is simply a function that returns a `type`: 

{{< zigdocgen "docgen-samples/features/19-generics.md" >}}

## Compile-time reflection and compile-time code execution

The [@typeInfo](https://ziglang.org/documentation/master/#typeInfo) builtin function provides reflection:

{{< zigdocgen "docgen-samples/features/20-reflection.md" >}}

The Zig Standard Library uses this technique to implement formatted printing. Despite being a [Small, simple language](https://ziglang.org/#Small-simple-language), Zig's formatted printing is implemented entirely in Zig. Meanwhile, in C, compile errors for printf are hard-coded into the compiler. Similarly, in Rust, the formatted printing macro is hard-coded into the compiler.

Zig can also evaluate functions and blocks of code at compile-time. In some contexts, such as global variable initializations, the expression is implicitly evaluated at compile-time. Otherwise, one can explicitly evaluate code at compile-time with the [comptime](https://ziglang.org/documentation/master/#comptime) keyword. This can be especially powerful when combined with assertions: 

{{< zigdocgen "docgen-samples/features/21-comptime.md" >}}

## Integration with C libraries without FFI/bindings

[@cImport](https://ziglang.org/documentation/master/#cImport) directly imports types, variables, functions, and simple macros for use in Zig. It even translates inline functions from C into Zig.

Here is an example of emitting a sine wave using [libsoundio](http://libsound.io/): 

<pre>
{{< zigdocgen "docgen-samples/features/22-sine-wave.md" >}}
</pre>

[This Zig code is significantly simpler than the equivalent C code](https://gist.github.com/andrewrk/d285c8f912169329e5e28c3d0a63c1d8), as well as having more safety protections, and all this is accomplished by directly importing the C header file - no API bindings.

*Zig is better at using C libraries than C is at using C libraries.*

### Zig is also a C compiler

Here's an example of Zig building some C code:

<u>hello.c</u>
```c
#include <stdio.h>

int main(int argc, char **argv) {
    printf("Hello world\n");
    return 0;
}
```

```
$ zig build-exe --c-source hello.c --library c
$ ./hello
Hello world
```

You can use `--verbose-cc` to see what C compiler command this executed:
```
$ zig build-exe --c-source hello.c --library c --verbose-cc
zig cc -MD -MV -MF zig-cache/tmp/42zL6fBH8fSo-hello.o.d -nostdinc -fno-spell-checking -isystem /home/andy/dev/zig/build/lib/zig/include -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-gnu -isystem /home/andy/dev/zig/build/lib/zig/libc/include/generic-glibc -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-any -isystem /home/andy/dev/zig/build/lib/zig/libc/include/any-linux-any -march=native -g -fstack-protector-strong --param ssp-buffer-size=4 -fno-omit-frame-pointer -o zig-cache/tmp/42zL6fBH8fSo-hello.o -c hello.c -fPIC
```

Note that if I run the command again, there is no output, and it finishes instantly:
```
$ time zig build-exe --c-source hello.c --library c --verbose-cc

real	0m0.027s
user	0m0.018s
sys	0m0.009s
```

This is thanks to [Build Artifact Caching](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching). Zig automatically parses the .d file uses a robust caching system to avoid duplicating work.

Not only can Zig compile C code, but there is a very good reason to use Zig as a C compiler: [Zig ships with libc](https://ziglang.org/#Zig-ships-with-libc).

### Export functions, variables, and types for C code to depend on

One of the primary use cases for Zig is exporting a library with the C ABI for other programming languages to call into. The `export` keyword in front of functions, variables, and types causes them to be part of the library API: 

<u>mathtest.zig</u>
{{< zigdocgen "docgen-samples/features/23-math-test.md" >}}

To make a static library:
```
$ zig build-lib mathtest.zig
```

To make a shared library:
```
$ zig build-lib mathtest.zig -dynamic
```

Here is an example with the [Zig Build System](https://ziglang.org/#Zig-Build-System):

<u>file.c</u>
```c
#include "mathtest.h"
#include <stdio.h>

int main(int argc, char **argv) {
    int32_t result = add(42, 1337);
    printf("%d\n", result);
    return 0;
}
```

<u>build.zig</u>
{{< zigdocgen "docgen-samples/features/24-build.md" >}}

```shell
$ zig build test
1379
```

## Cross-compiling is a first-class use case

Zig can build for any of the targets from the [Support Table](https://ziglang.org/#Support-Table) with [Tier 3 Support](https://ziglang.org/#Tier-3-Support) or better. No "cross toolchain" needs to be installed or anything like that. Here's a native Hello World:

{{< zigdocgen "docgen-samples/features/4-hello.md" >}}

Now to build it for x86_64-windows, x86_64-macosx, and aarch64v8-linux:
```
$ zig build-exe hello.zig -target x86_64-windows
$ file hello.exe 
hello.exe: PE32+ executable (console) x86-64, for MS Windows
$ zig build-exe hello.zig -target x86_64-macosx
$ file hello
hello: Mach-O 64-bit x86_64 executable, flags:<NOUNDEFS|DYLDLINK|TWOLEVEL|PIE>
$ zig build-exe hello.zig -target aarch64v8-linux
$ file hello
hello: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), statically linked, with debug_info, not stripped
```

This works on any [Tier 3](https://ziglang.org/#Tier-3-Support)+ target, for any [Tier 3](https://ziglang.org/#Tier-3-Support)+ target. 

### Zig ships with libc

You can find the available libc targets with `zig targets`: 
```
...
 "libc": [
  "aarch64_be-linux-gnu",
  "aarch64_be-linux-musl",
  "aarch64_be-windows-gnu",
  "aarch64-linux-gnu",
  "aarch64-linux-musl",
  "aarch64-windows-gnu",
  "armeb-linux-gnueabi",
  "armeb-linux-gnueabihf",
  "armeb-linux-musleabi",
  "armeb-linux-musleabihf",
  "armeb-windows-gnu",
  "arm-linux-gnueabi",
  "arm-linux-gnueabihf",
  "arm-linux-musleabi",
  "arm-linux-musleabihf",
  "arm-windows-gnu",
  "i386-linux-gnu",
  "i386-linux-musl",
  "i386-windows-gnu",
  "mips64el-linux-gnuabi64",
  "mips64el-linux-gnuabin32",
  "mips64el-linux-musl",
  "mips64-linux-gnuabi64",
  "mips64-linux-gnuabin32",
  "mips64-linux-musl",
  "mipsel-linux-gnu",
  "mipsel-linux-musl",
  "mips-linux-gnu",
  "mips-linux-musl",
  "powerpc64le-linux-gnu",
  "powerpc64le-linux-musl",
  "powerpc64-linux-gnu",
  "powerpc64-linux-musl",
  "powerpc-linux-gnu",
  "powerpc-linux-musl",
  "riscv64-linux-gnu",
  "riscv64-linux-musl",
  "s390x-linux-gnu",
  "s390x-linux-musl",
  "sparc-linux-gnu",
  "sparcv9-linux-gnu",
  "wasm32-freestanding-musl",
  "x86_64-linux-gnu",
  "x86_64-linux-gnux32",
  "x86_64-linux-musl",
  "x86_64-windows-gnu"
 ],
 ```

What this means is that `--library c` for these targets *does not depend on any system files*!

Let's look at that [C hello world example](https://ziglang.org/#Zig-is-also-a-C-compiler) again: 
```
$ zig build-exe --c-source hello.c --library c
$ ./hello
Hello world
$ ldd ./hello
	linux-vdso.so.1 (0x00007ffd03dc9000)
	libc.so.6 => /lib/libc.so.6 (0x00007fc4b62be000)
	libm.so.6 => /lib/libm.so.6 (0x00007fc4b5f29000)
	libpthread.so.0 => /lib/libpthread.so.0 (0x00007fc4b5d0a000)
	libdl.so.2 => /lib/libdl.so.2 (0x00007fc4b5b06000)
	librt.so.1 => /lib/librt.so.1 (0x00007fc4b58fe000)
	/lib/ld-linux-x86-64.so.2 => /lib64/ld-linux-x86-64.so.2 (0x00007fc4b6672000)
```

[glibc](https://www.gnu.org/software/libc/) does not support building statically, but [musl](https://www.musl-libc.org/) does:
```
$ zig build-exe --c-source hello.c --library c -target x86_64-linux-musl
$ ./hello
Hello world
$ ldd hello
  not a dynamic executable
```

In this example, Zig built musl libc from source and then linked against it. The build of musl libc for x86_64-linux remains available thanks to the [caching system](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching), so any time this libc is needed again it will be available instantly.

This means that this functionality is available on any platform. Windows and macOS users can build Zig and C code, and link against libc, for any of the targets listed above. Similarly code can be cross compiled for other architectures:
```
$ zig build-exe --c-source hello.c --library c -target aarch64v8-linux-gnu
$ file hello
hello: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, for GNU/Linux 2.0.0, with debug_info, not stripped
```

In some ways, Zig is a better C compiler than C compilers! 

This functionality is more than bundling a cross-compilation toolchain along with Zig. For example, the total size of libc headers that Zig ships is 22 MiB uncompressed. Meanwhile, the headers for musl libc + linux headers on x86_64 alone are 8 MiB, and for glibc are 3.1 MiB (glibc is missing the linux headers), yet Zig currently ships with 40 libcs. With a naive bundling that would be 444 MiB. However, thanks to this [process_headers tool](https://github.com/ziglang/zig/blob/0.4.0/libc/process_headers.zig) that I made, and some [good old manual labor](https://github.com/ziglang/zig/wiki/Updating-libc), Zig binary tarballs remain roughly 30 MiB total, despite supporting libc for all these targets, as well as compiler-rt, libunwind, and libcxx, and despite being a clang-compatible C compiler. For comparison, the Windows binary build of clang 8.0.0 itself from llvm.org is 132 MiB.

Note that only the [Tier 1 Support](https://ziglang.org/#Tier-1-Support) targets have been thoroughly tested. It is planned to [add more libcs](https://github.com/ziglang/zig/issues/514) (including for Windows), and to [add test coverage for building against all the libcs](https://github.com/ziglang/zig/issues/2058).

It's [planned to have a Zig Package Manager](https://github.com/ziglang/zig/issues/943), but it's not done yet. One of the things that will be possible is to create a package for C libraries. This will make the [Zig Build System](https://ziglang.org/#Zig-Build-System) attractive for Zig programmers and C programmers alike.

## Zig Build System

Zig comes with a build system, so you don't need make, cmake, or anything like that.
```
$ zig init-exe
Created build.zig
Created src/main.zig

Next, try `zig build --help` or `zig build run`
```

<u>src/main.zig</u>
<pre>{{< zigdocgen "docgen-samples/features/25-all-bases.md" >}}</pre>


<u>build.zig</u>
<pre>{{< zigdocgen "docgen-samples/features/26-build.md" >}}</pre>


Let's have a look at that `--help` menu.
```
$ zig build --help
Usage: zig build [steps] [options]

Steps:
  install (default)      Copy build artifacts to prefix path
  uninstall              Remove build artifacts from prefix path
  run                    Run the app

General Options:
  --help                 Print this help and exit
  --verbose              Print commands before executing them
  --prefix [path]        Override default install prefix
  --search-prefix [path] Add a path to look for binaries, libraries, headers

Project-Specific Options:
  -Dtarget=[string]      The CPU architecture, OS, and ABI to build for.
  -Drelease-safe=[bool]  optimizations on and safety on
  -Drelease-fast=[bool]  optimizations on and safety off
  -Drelease-small=[bool] size optimizations on and safety off

Advanced Options:
  --build-file [file]         Override path to build.zig
  --cache-dir [path]          Override path to zig cache directory
  --override-lib-dir [arg]    Override path to Zig lib directory
  --verbose-tokenize          Enable compiler debug output for tokenization
  --verbose-ast               Enable compiler debug output for parsing into an AST
  --verbose-link              Enable compiler debug output for linking
  --verbose-ir                Enable compiler debug output for Zig IR
  --verbose-llvm-ir           Enable compiler debug output for LLVM IR
  --verbose-cimport           Enable compiler debug output for C imports
  --verbose-cc                Enable compiler debug output for C compilation
  --verbose-llvm-cpu-features Enable compiler debug output for LLVM CPU features
```

You can see that one of the available steps is run.
```
$ zig build run
All your base are belong to us.
```

Here are some example build scripts:

- [Build script of OpenGL Tetris game](https://github.com/andrewrk/tetris/blob/master/build.zig)
- [Build script of bare metal Raspberry Pi 3 arcade game](https://github.com/andrewrk/clashos/blob/master/build.zig)
- [Build script of self-hosted Zig compiler](https://github.com/ziglang/zig/blob/master/build.zig)

## Concurrency via Async Functions

Zig 0.5.0 [introduced async functions](https://ziglang.org/download/0.5.0/release-notes.html#Async-Functions). This feature has no dependency on a host operating system or even heap-allocated memory. That means async functions are available for the freestanding target.

Zig infers whether a function is async, and allows `async`/`await` on non-async functions, which means that **Zig libraries are agnostic of blocking vs async I/O**. [Zig avoids function colors](http://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/).



The Zig Standard Library implements an event loop that multiplexes async functions onto a thread pool for M:N concurrency. Multithreading safety and race detection are areas of active research.

## Wide range of targets supported

Zig uses a "support tier" system to communicate the level of support for different targets. Note that the bar for [Tier 1 Support](https://ziglang.org/#Tier-1-Support) is high - [Tier 2 Support](https://ziglang.org/#Tier-2-Support) is still quite useful.

### Support Table

| | free standing | Linux 3.16+ | macOS 10.13+ | Windows 8.1+ | FreeBSD 12.0+ | NetBSD 8.0+ | DragonFly​BSD 5.8+ | UEFI |
|-|---------------|-------------|--------------|--------------|---------------|-------------|-------------------|------|
| x86_64 | [Tier 1](https://ziglang.org/#Tier-1-Support) | [Tier 1](https://ziglang.org/#Tier-1-Support) | [Tier 2](https://ziglang.org/#Tier-2-Support) | [Tier 2](https://ziglang.org/#Tier-2-Support) | [Tier 2](https://ziglang.org/#Tier-2-Support) | [Tier 2](https://ziglang.org/#Tier-2-Support) | [Tier 2](https://ziglang.org/#Tier-2-Support) | [Tier 2](https://ziglang.org/#Tier-2-Support) |
| arm64 | [Tier 1](https://ziglang.org/#Tier-1-Support) | [Tier 2](https://ziglang.org/#Tier-2-Support) | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) |
| arm32 | [Tier 1](https://ziglang.org/#Tier-1-Support) | [Tier 2](https://ziglang.org/#Tier-2-Support) | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) |
| mips32 LE | [Tier 1](https://ziglang.org/#Tier-1-Support) | [Tier 2](https://ziglang.org/#Tier-2-Support) | N/A | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A |
| i386 | [Tier 1](https://ziglang.org/#Tier-1-Support) | [Tier 2](https://ziglang.org/#Tier-2-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 2](https://ziglang.org/#Tier-2-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | [Tier 2](https://ziglang.org/#Tier-2-Support) |
| riscv64 | [Tier 1](https://ziglang.org/#Tier-1-Support) | [Tier 2](https://ziglang.org/#Tier-2-Support) | N/A | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) |
| bpf | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A |
| hexagon | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A |
| mips32 BE | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A |
| mips64 | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A |
| amdgcn | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A |
| sparc | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A |
| s390x | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A |
| lanai | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A |
| powerpc32 | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A |
| powerpc64 | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A |
| avr | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| riscv32 | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) |
| xcore | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| nvptx | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| msp430 | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| r600 | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| arc | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| tce | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| le | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| amdil | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| hsail | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| spir | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| kalimba | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| shave | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| renderscript | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |


### WebAssembly Support Table

|        | free standing | emscripten | WASI   |
|--------|---------------|------------|--------|
| wasm32 | [Tier 1](https://ziglang.org/#Tier-1-Support)        | [Tier 3](https://ziglang.org/#Tier-3-Support)     | [Tier 1](https://ziglang.org/#Tier-1-Support) |
| wasm64 | [Tier 4](https://ziglang.org/#Tier-4-Support)        | [Tier 4](https://ziglang.org/#Tier-4-Support)     | [Tier 4](https://ziglang.org/#Tier-4-Support) |


### Tier System

#### Tier 1 Support
- Not only can Zig generate machine code for these targets, but the standard library cross-platform abstractions have implementations for these targets. Thus it is practical to write a pure Zig application with no dependency on libc.
- The CI server automatically tests these targets on every commit to master branch, and updates [the download page](https://ziglang.org/download) with links to pre-built binaries.
- These targets have debug info capabilities and therefore produce [stack traces](https://ziglang.org/#Stack-traces-on-all-targets) on failed assertions.
- [libc is available for this target even when cross compiling](https://ziglang.org/#Zig-ships-with-libc).
- All the behavior tests and applicable standard library tests pass for this target. All language features are known to work correctly.

#### Tier 2 Support
- The standard library supports this target, but it's possible that some APIs will give an "Unsupported OS" compile error. One can link with libc or other libraries to fill in the gaps in the standard library.
- These targets are known to work, but may not be automatically tested, so there are occasional regressions.
- Some tests may be disabled for these targets as we work toward [Tier 1 Support](https://ziglang.org/#Tier-1-Support).

#### Tier 3 Support

- The standard library has little to no knowledge of the existence of this target.
- Because Zig is based on LLVM, it has the capability to build for these targets, and LLVM has the target enabled by default.
- These targets are not frequently tested; one will likely need to contribute to Zig in order to build for these targets.
- The Zig compiler might need to be updated with a few things such as
  - what sizes are the C integer types
  - C ABI calling convention for this target
  - bootstrap code and default panic handler
- zig targets is guaranteed to include this target.

#### Tier 4 Support

- Support for these targets is entirely experimental.
- LLVM may have the target as an experimental target, which means that you need to use Zig-provided binaries for the target to be available, or build LLVM from source with special configure flags. zig targets will display the target if it is available.
- This target may be considered deprecated by an official party, such as [macosx/i386](https://support.apple.com/en-us/HT208436) in which case this target will remain forever stuck in Tier 4.
- This target may only support `--emit` asm and cannot emit object files.

## Friendly toward package maintainers

The reference Zig compiler is not completely self-hosted yet, but no matter what, [it will remain exactly 3 steps](https://github.com/ziglang/zig/issues/853) to go from having a system C++ compiler to having a fully self-hosted Zig compiler for any target. As Maya Rashish notes, [porting Zig to other platforms is fun and speedy](http://coypu.sdf.org/porting-zig.html).

Non-debug [build modes](https://ziglang.org/documentation/master/#Build-Mode) are reproducible/deterministic.

There is a [JSON version of the download page](https://ziglang.org/download/index.json).

Several members of the Zig team have experience maintaining packages.

- [Daurnimator](https://github.com/daurnimator) maintains the [Arch Linux package](https://www.archlinux.org/packages/community/x86_64/zig/)
- [Marc Tiehuis](https://tiehuis.github.io/) maintains the Visual Studio Code package.
- [Andrew Kelley](https://andrewkelley.me/) spent a year or so doing [Debian and Ubuntu packaging](https://qa.debian.org/developer.php?login=superjoe30%40gmail.com&comaint=yes), and casually contributes to [nixpkgs](https://github.com/NixOS/nixpkgs/).
- [Jeff Fowler](https://blog.jfo.click/) maintains the Homebrew package and started the [Sublime package](https://github.com/ziglang/sublime-zig-language) (now maintained by [emekoi](https://github.com/emekoi)).