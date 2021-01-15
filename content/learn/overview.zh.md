---
title: "深入了解"
mobile_menu_title: "深入了解"
toc: true
---
# 功能特色
## 小巧而简洁的语言

专注于调试你的应用程序，而不是调试你的编程语言知识。

Zig 的完整语法可以被 [500 行的 PEG 语法的文件](https://ziglang.org/documentation/master/#Grammar)所描述。

没有**隐式控制流**，没有隐式内存分配，没有预处理器，也没有宏。如果 Zig 代码看起来不像是在调用一个函数，那么它就不是。这意味着你可以确定下面的代码只会先调用 `foo()`，然后调用 `bar()`，不需要知道任何元素的类型，这一点也是可以保证的：

```zig
var a = b + c.d;
foo();
bar();
```

隐式控制流的例子：

- D 有 `@property` 函数，可以让你的方法调用看起来像是成员访问，因此在上面的例子中，`c.d` 可能会调用一个函数。
- C++，D 和 Rust 有运算符重载，因此 `+` 可能会调用一个函数。
- C++，D 和 Go 可以抛出和捕获异常，因此 `foo()` 可能会抛出一个异常，并且将会阻止 `bar()` 被调用。

Zig 将所有的控制流完全用语言关键字和函数调用来表达，以此促进代码的维护性和可读性。

## 性能和安全：全都要

Zig 有 4 种[构建模式](https://ziglang.org/documentation/master/#Build-Mode)，它们可以从全局到[代码作用域的粒度](https://ziglang.org/documentation/master/#setRuntimeSafety)下被任意混合以匹配需求。

| 参数 | [Debug](/documentation/master/#Debug) | [ReleaseSafe](/documentation/master/#ReleaseSafe) | [ReleaseFast](/documentation/master/#ReleaseFast) | [ReleaseSmall](/documentation/master/#ReleaseSmall) |
|-----------|-------|-------------|-------------|--------------|
优化 - 提升运行速度，降低可调试能力，减慢编译期间 | | -O3 | -O3| -Os |
运行时安全检查 - 降低运行速度，增大体积，用崩溃代替未定义行为 | On | On | | |

以下是编译期[整数溢出](https://ziglang.org/documentation/master/#Integer-Overflow)的例子，无关编译模式选择：

{{< zigdoctest "assets/zig-code/features/1-integer-overflow.zig" >}}

这是运行时的场景，在启用了安全检查的构建中。

{{< zigdoctest "assets/zig-code/features/2-integer-overflow-runtime.zig" >}}


这些[堆栈跟踪在所有目标上都可用](#在所有目标上启用堆栈跟踪)，包括[裸金属（freestanding）](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html)。

有了 Zig，人们可以依赖启用安全检查的构建模式，并在性能瓶颈处选择性地禁用安全检查。例如前面的例子可以这样修改：

{{< zigdoctest "assets/zig-code/features/3-undefined-behavior.zig" >}}

Zig 将[未定义行为](https://ziglang.org/documentation/master/#Undefined-Behavior)作为一个利器，既可以预防 bug，又可以提升性能。

说到性能，Zig 比 C 快：

- 参考实现使用 LLVM 作为后端进行最先进的优化。
- 其他项目所谓的“链接时优化”，在 Zig 是自动达成的。
- 多亏了[对交叉编译的一流支持](#交叉编译的一流支持)，对于原生构建目标，高级 CPU 特性可以被启用（相当于 `-march=native`）。
- 精心选择的未定义行为。例如，在 Zig 中，有符号和无符号整数在溢出时都属于未定义的行为，而在 C 中仅有有符号整数的溢出属于未定义行为，这有助于[实现 C 语言里没有的优化](https://godbolt.org/z/n_nLEU)。
- Zig 直接暴露了[SIMD 向量类型](https://ziglang.org/documentation/master/#Vectors)，使得编写跨平台的向量化代码更容易。

请注意，Zig 不是一个完全安全的语言。有兴趣关注 Zig 安全故事的用户，可以订阅下面这些链接：

- [列举各种未定义的行为，甚至是无法进行安全检查的行为（英文）](https://github.com/ziglang/zig/issues/1966)
- [使 Debug 和 ReleaseSafe 模式完全安全（英文）](https://github.com/ziglang/zig/issues/2301)

## Zig 与 C 竞争，而不是依赖于它

Zig 标准库里集成了 libc，但是不依赖于它：

{{< zigdoctest "assets/zig-code/features/4-hello.zig" >}}

当使用 `-O ReleaseSmall` 并移除调试符号，单线程模式构建，可以产生一个以 x86_64-linux 为目标的 9.8 KiB 的静态可执行文件：
```
$ zig build-exe hello.zig --release-small --strip --single-threaded
$ wc -c hello
9944 hello
$ ldd hello
  not a dynamic executable
```

Windows 的构建就更小了，仅仅 4096 字节：
```
$ zig build-exe hello.zig --release-small --strip --single-threaded -target x86_64-windows
$ wc -c hello.exe
4096 hello.exe
$ file hello.exe
hello.exe: PE32+ executable (console) x86-64, for MS Windows
```

## 顺序无关的顶层声明

全局变量等顶层声明与顺序无关，并进行惰性分析。全局变量的初始值[在编译时进行求值](#编译期反射和编译期代码执行)。

{{< zigdoctest "assets/zig-code/features/5-global-variables.zig" >}}

## 可选类型代替空指针

在其他编程语言中，空引用是许多运行时异常的来源，甚至被指责为[计算机科学中最严重的错误](https://www.lucidchart.com/techblog/2015/08/31/the-worst-mistake-of-computer-science/)。

不加修饰的 Zig 指针不可为空：

{{< zigdoctest "assets/zig-code/features/6-null-to-ptr.zig" >}}
当然，任何类型都可以通过在前面加上 `?` 来变成一个[可选类型](https://ziglang.org/documentation/master/#Optionals)：

{{< zigdoctest "assets/zig-code/features/7-optional-syntax.zig" >}}

要解开一个可选的值，可以使用 `orelse` 来提供一个默认值：

{{< zigdoctest "assets/zig-code/features/8-optional-orelse.zig" >}}

另一种选择是使用 if：

{{< zigdoctest "assets/zig-code/features/9-optional-if.zig" >}}

 相同的语法也可以在 [while](https://ziglang.org/documentation/master/#while) 种使用：

{{< zigdoctest "assets/zig-code/features/10-optional-while.zig" >}}

## 手动内存管理

用 Zig 编写的库可以在任何地方使用：

- [桌面程序](https://github.com/TM35-Metronome/)和[游戏](https://github.com/dbandstra/oxid)
- 低延迟服务器
- [操作系统内核](https://github.com/AndreaOrru/zen)
- [嵌入式设备](https://github.com/skyfex/zig-nrf-demo/)
- 实时软件，例如现场表演，飞机，心脏起搏器
- [在浏览器或者其他使用 WebAssembly 作为插件的程序](https://shritesh.github.io/zigfmt-web/)
- 通过 C ABI 给其他语言调用

为了达到这个目的，Zig 程序员必须管理自己的内存，必须处理内存分配失败。

Zig 标准库也是如此。任何需要分配内存的函数都会接受一个分配器参数。因此，Zig 标准库甚至可以用于裸金属（freestanding）的目标。

除了对[错误处理的全新诠释](#错误处理的全新诠释)，Zig 还提供了[defer](https://ziglang.org/documentation/master/#defer)和[errdefer](https://ziglang.org/documentation/master/#errdefer)，使所有的资源管理——不仅仅是内存——变得简单且易于验证。

关于 `defer` 的例子，请看[无需 FFI/bindings 的 C 库集成](#无需-ffibindings-的-c-库集成)。下面是一个使用errdefer的例子：
{{< zigdoctest "assets/zig-code/features/11-errdefer.zig" >}}


## 错误处理的全新诠释

错误是值，不可忽略：

{{< zigdoctest "assets/zig-code/features/12-errors-as-values.zig" >}}

错误可以被 [catch](https://ziglang.org/documentation/master/#catch) 所处理：

{{< zigdoctest "assets/zig-code/features/13-errors-catch.zig" >}}

关键词 [try](https://ziglang.org/documentation/master/#try) 是 `catch |err| return err` 的简写：

{{< zigdoctest "assets/zig-code/features/14-errors-try.zig" >}}

请注意这是一个[错误返回跟踪](https://ziglang.org/documentation/master/#Error-Return-Traces)，而不是[堆栈跟踪](#在所有目标上启用堆栈跟踪)。代码没有付出解开堆栈的代价来获得该跟踪。

在错误值上使用 [switch](https://ziglang.org/documentation/master/#switch) 关键词可以用于确保所有可能的错误都被处理：

{{< zigdoctest "assets/zig-code/features/15-errors-switch.zig" >}}

而关键词 [unreachable](https://ziglang.org/documentation/master/#unreachable) 用于断言不会发生错误：

{{< zigdoctest "assets/zig-code/features/16-unreachable.zig" >}}

这将会在不安全构建中出现[未定义行为](#性能和安全全都要)，因此请确保只在一定会成功的地方使用。

### 在所有目标上启用堆栈跟踪

本页所展示的堆栈跟踪和[错误返回跟踪](https://ziglang.org/documentation/master/#Error-Return-Traces)适用于所有[一级支持](#一级支持)和部分[二级支持](#二级支持)目标，[甚至裸金属（freestanding）目标](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html)！

此外，标准库能在任何一点捕获堆栈跟踪，然后将其转储为标准错误：

{{< zigdoctest "assets/zig-code/features/17-stack-traces.zig" >}}

你可以在正在进行的 [GeneralPurposeDebugAllocator](https://github.com/andrewrk/zig-general-purpose-allocator/#current-status) 项目中看到这种技术的应用。

## 泛型数据结构和函数

类型和值必须在编译期已知：

{{< zigdoctest "assets/zig-code/features/18-types.zig" >}}

泛型数据结构简单来说就是一个函数返回一个类型：

{{< zigdoctest "assets/zig-code/features/19-generics.zig" >}}

## 编译期反射和编译期代码执行

[@typeInfo](https://ziglang.org/documentation/master/#typeInfo) 内置函数可以用于提供编译期反射：

{{< zigdoctest "assets/zig-code/features/20-reflection.zig" >}}

Zig 标准库使用这种技术来实现格式化打印。尽管是一种[小巧而简洁的语言](#小巧而简洁的语言)，但 Zig 的格式化打印完全是在 Zig 中实现的。同时，在 C 语言中，printf 的编译错误是硬编码到编译器中的。同样，在 Rust 中，格式化打印的宏也是硬编码到编译器中的。

Zig 还可以在编译期对函数和代码块求值。在某些情况下，比如全局变量初始化，表达式会在编译期隐式地进行求值。除此之外我们还可以使用 [comptime](https://ziglang.org/documentation/master/#comptime) 关键字显式地在编译期求值。把它与断言相结合就可以变得尤为强大了：

{{< zigdoctest "assets/zig-code/features/21-comptime.zig" >}}

## 无需 FFI/bindings 的 C 库集成

[@cImport](https://ziglang.org/documentation/master/#cImport) 可以为 Zig 直接导入类型，变量，函数和简单的宏。它甚至能将 C 内联函数翻译成 Zig 函数。

这是一个利用 [libsoundio](http://libsound.io/) 库发出正弦波的例子：

<u>sine.zig</u>
{{< zigdoctest "assets/zig-code/features/22-sine-wave.zig" >}}

```
$ zig build-exe sine.zig -lsoundio -lc
$ ./sine
Output device: Built-in Audio Analog Stereo
^C
```

[这里的 Zig 代码比等效的 C 代码要简单得多](https://gist.github.com/andrewrk/d285c8f912169329e5e28c3d0a63c1d8)，同时也有更多的安全保护措施，所有这些都是通过直接导入 C 头文件来实现的——无需 API 绑定。

*Zig 比 C 更擅长使用 C 库。*

### Zig 也是 C 编译器

这有一个简单的使用 Zig 编译 C 代码的例子：

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

你可以使用 `--verbose-cc` 选项来查看编译时使用了哪些 C 编译器选项：
```
$ zig build-exe --c-source hello.c --library c --verbose-cc
zig cc -MD -MV -MF zig-cache/tmp/42zL6fBH8fSo-hello.o.d -nostdinc -fno-spell-checking -isystem /home/andy/dev/zig/build/lib/zig/include -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-gnu -isystem /home/andy/dev/zig/build/lib/zig/libc/include/generic-glibc -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-any -isystem /home/andy/dev/zig/build/lib/zig/libc/include/any-linux-any -march=native -g -fstack-protector-strong --param ssp-buffer-size=4 -fno-omit-frame-pointer -o zig-cache/tmp/42zL6fBH8fSo-hello.o -c hello.c -fPIC
```

注意当我再次运行这个命令时，没有看到输出，它立刻完成了：
```
$ time zig build-exe --c-source hello.c --library c --verbose-cc

real	0m0.027s
user	0m0.018s
sys	0m0.009s
```

这要归功于[构建产物缓存](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching)。Zig 会自动解析 .d 文件，使用强大的缓存系统来避免重复工作。

Zig 不只是可以用来编译 C 代码，同时还有很好的理由使用 Zig 作为 C 编译器：[zig 与 libc 一起发布](#zig-与-libc-一起发布)。

### 导出函数、变量和类型供 C 代码使用

Zig 的一个主要用例是用 C ABI 导出一个库，供其他编程语言调用。在函数、变量和类型前面的 `export` 关键字会使它们成为库 API 的一部分：

<u>mathtest.zig</u>
{{< zigdoctest "assets/zig-code/features/23-math-test.zig" >}}

生成静态库：
```
$ zig build-lib mathtest.zig
```

生成动态库：
```
$ zig build-lib mathtest.zig -dynamic
```

这有一个使用 [Zig 构建系统](#zig-构建系统)的例子:

<u>test.c</u>
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
{{< zigdoctest "assets/zig-code/features/24-build.zig" >}}

```
$ zig build test
1379
```

## 交叉编译的一流支持

Zig 可以为[支持表](#支持表)中的任何[三级支持](#三级支持)或更高的目标构建。不需要安装“交叉编译工具链”之类的东西。这是一个原生的 Hello World。

{{< zigdoctest "assets/zig-code/features/4-hello.zig" >}}

现在为 x86_64-windows, x86_64-macosx 和 aarch64v8-linux 构建：
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

在任意[三级](#三级支持)以上的目标平台都可以构建任何[三级](#三级支持)以上的目标。

### Zig 与 libc 一起发布

你可以通过 `zig targets` 命令获得可用的 libc 目标：
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

这意味着在这些目标上使用 `--library c` 将*不依赖任何系统文件*！

让我们再看看 [C 语言 hello world 例子](#zig-也是-c-编译器)：
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

[glibc](https://www.gnu.org/software/libc/) 不支持静态链接，但是 [musl](https://www.musl-libc.org/) 支持：
```
$ zig build-exe --c-source hello.c --library c -target x86_64-linux-musl
$ ./hello
Hello world
$ ldd hello
  not a dynamic executable
```

在这个例子中，Zig 从源码构建 musl libc 然后将其链接到输出文件中。由于[缓存系统](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching)，musl libc 的缓存仍然有效，所以当再次需要这个 libc 的时候，它就会被立即使用。

这意味着这个功能可以在任何平台上使用。Windows 和 macOS 用户可以为上面列出的任何目标构建 Zig 和 C 代码，并与 libc 链接。同样的代码也可以为其他架构交叉编译：
```
$ zig build-exe --c-source hello.c --library c -target aarch64v8-linux-gnu
$ file hello
hello: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, for GNU/Linux 2.0.0, with debug_info, not stripped
```

在某些方面，Zig 是比 C 编译器更好的 C 编译器！

这个功能不仅仅是将交叉编译工具链与 Zig 捆绑在一起。例如，Zig 提供的 libc 头文件总大小为 22 MiB，未压缩。同时，仅 x86_64 上的musl libc+linux 头文件就有 8 MiB，glibc 有 3.1 MiB（glibc 不包括 linux 头文件），然而 Zig 目前附带的 libc 有 40 个。如果是天真的捆绑发布，那就是 444 MiB。然而，多亏了我做的这个 [process_headers](https://github.com/ziglang/zig/blob/0.4.0/libc/process_headers.zig) 工具，以及一些[老式的手工劳动](https://github.com/ziglang/zig/wiki/Updating-libc)，Zig 二进制压缩包的总容量仍然只有 30 MiB，尽管它支持所有这些目标的 libc，以及 compiler-rt、libunwind 和 libcxx，尽管它是一个 clang 兼容的 C 编译器。作为比较，来自 llvm.org 的 clang 8.0.0 本身的 Windows 二进制构建有 132 MiB 这么大。

请注意，只有[一级支持](#一级支持)目标得到了彻底测试。我们有计划增加[更多的 libc](https://github.com/ziglang/zig/issues/514)（包括 Windows 平台），并提高[对所有 libc 的测试覆盖率](https://github.com/ziglang/zig/issues/2058)。

我们还计划有一个 [Zig 包管理器](https://github.com/ziglang/zig/issues/943)，但还没有完成。其中一个功能是可以为 C 库创建一个包，这将使 [Zig 构建系统](#Zig-构建系统)对 Zig 程序员和 C 程序员都有吸引力。

## Zig 构建系统

Zig 自带构建系统，所以你不需要 make、cmake 之类的东西。
```
$ zig init-exe
Created build.zig
Created src/main.zig

Next, try `zig build --help` or `zig build run`
```

<u>src/main.zig</u>
{{< zigdoctest "assets/zig-code/features/25-all-bases.zig" >}}


<u>build.zig</u>
{{< zigdoctest "assets/zig-code/features/26-build.zig" >}}


我们来看看那个 `--help` 菜单。
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

你可以看到，其中一个可用的步骤（step）被运行。
```
$ zig build run
All your base are belong to us.
```

以下是一些构建脚本的例子:

- [OpenGL 俄罗斯方块游戏](https://github.com/andrewrk/tetris/blob/master/build.zig)
- [裸金属树莓派 3 街机游戏](https://github.com/andrewrk/clashos/blob/master/build.zig)
- [自托管 Zig 编译器](https://github.com/ziglang/zig/blob/master/build.zig)

## 使用异步函数进行并发

Zig 0.5.0 [引入了异步函数（英文）](https://ziglang.org/download/0.5.0/release-notes.html#Async-Functions)。该功能不依赖于宿主操作系统，甚至不依赖于堆分配的内存。这意味着异步函数可以用于裸金属（freestanding）目标。

Zig 自动推导函数是否为异步，并允许在非异步函数上进行 `async`/`await`，这意味着 **Zig 库对阻塞与异步 I/O 是不可知的**。[Zig 避免了函数染色（英文）](http://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/)。



Zig 标准库实现了一个事件循环，将异步函数复用到线程池上，实现 M:N 并发。多线程安全和竞争检测是尚在积极研究的领域。

## 支持广泛的目标

Zig 使用“支持等级”系统来描述不同目标的支持程度。需要注意的是，[一级支持](#一级支持)的门槛很高——[二级支持](#二级支持)还是相当有用的。

### 支持表

| | free standing | Linux 3.16+ | macOS 10.13+ | Windows 8.1+ | FreeBSD 12.0+ | NetBSD 8.0+ | DragonFly​BSD 5.8+ | UEFI |
|-|---------------|-------------|--------------|--------------|---------------|-------------|-------------------|------|
| x86_64 | [一级支持](#一级支持) | [一级支持](#一级支持) | [一级支持](#一级支持) | [二级支持](#二级支持) | [二级支持](#二级支持) | [二级支持](#二级支持) | [二级支持](#二级支持) | [二级支持](#二级支持) |
| arm64 | [一级支持](#一级支持) | [二级支持](#二级支持) | [二级支持](#二级支持) | [三级支持](#三级支持) | [三级支持](#三级支持) | [三级支持](#三级支持) | 未知 | [三级支持](#三级支持) |
| arm32 | [一级支持](#一级支持) | [二级支持](#二级支持) | 未知 | [三级支持](#三级支持) | [三级支持](#三级支持) | [三级支持](#三级支持) | 未知 | [三级支持](#三级支持) |
| mips32 LE | [一级支持](#一级支持) | [二级支持](#二级支持) | 未知 | 未知 | [三级支持](#三级支持) | [三级支持](#三级支持) | 未知 | 未知 |
| i386 | [一级支持](#一级支持) | [二级支持](#二级支持) | [四级支持](#四级支持) | [二级支持](#二级支持) | [三级支持](#三级支持) | [三级支持](#三级支持) | 未知 | [二级支持](#二级支持) |
| riscv64 | [一级支持](#一级支持) | [二级支持](#二级支持) | 未知 | 未知 | [三级支持](#三级支持) | [三级支持](#三级支持) | 未知 | [三级支持](#三级支持) |
| bpf | [三级支持](#三级支持) | [三级支持](#三级支持) | 未知 | 未知 | [三级支持](#三级支持) | [三级支持](#三级支持) | 未知 | 未知 |
| hexagon | [三级支持](#三级支持) | [三级支持](#三级支持) | 未知 | 未知 | [三级支持](#三级支持) | [三级支持](#三级支持) | 未知 | 未知 |
| mips32 BE | [三级支持](#三级支持) | [三级支持](#三级支持) | 未知 | 未知 | [三级支持](#三级支持) | [三级支持](#三级支持) | 未知 | 未知 |
| mips64 | [三级支持](#三级支持) | [三级支持](#三级支持) | 未知 | 未知 | [三级支持](#三级支持) | [三级支持](#三级支持) | 未知 | 未知 |
| amdgcn | [三级支持](#三级支持) | [三级支持](#三级支持) | 未知 | 未知 | [三级支持](#三级支持) | [三级支持](#三级支持) | 未知 | 未知 |
| sparc | [三级支持](#三级支持) | [三级支持](#三级支持) | 未知 | 未知 | [三级支持](#三级支持) | [三级支持](#三级支持) | 未知 | 未知 |
| s390x | [三级支持](#三级支持) | [三级支持](#三级支持) | 未知 | 未知 | [三级支持](#三级支持) | [三级支持](#三级支持) | 未知 | 未知 |
| lanai | [三级支持](#三级支持) | [三级支持](#三级支持) | 未知 | 未知 | [三级支持](#三级支持) | [三级支持](#三级支持) | 未知 | 未知 |
| powerpc32 | [三级支持](#三级支持) | [三级支持](#三级支持) | [四级支持](#四级支持) | 未知 | [三级支持](#三级支持) | [三级支持](#三级支持) | 未知 | 未知 |
| powerpc64 | [三级支持](#三级支持) | [三级支持](#三级支持) | [四级支持](#四级支持) | 未知 | [三级支持](#三级支持) | [三级支持](#三级支持) | 未知 | 未知 |
| avr | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 |
| riscv32 | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | [四级支持](#四级支持) |
| xcore | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 |
| nvptx | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 |
| msp430 | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 |
| r600 | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 |
| arc | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 |
| tce | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 |
| le | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 |
| amdil | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 |
| hsail | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 |
| spir | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 |
| kalimba | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 |
| shave | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 |
| renderscript | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 | [四级支持](#四级支持) | [四级支持](#四级支持) | 未知 | 未知 |


### WebAssembly 支持表

|        | free standing | emscripten | WASI   |
|--------|---------------|------------|--------|
| wasm32 | [一级支持](#一级支持)        | [三级支持](#三级支持)     | [一级支持](#一级支持) |
| wasm64 | [四级支持](#四级支持)        | [四级支持](#四级支持)     | [四级支持](#四级支持) |


### 支持等级

#### 一级支持
- Zig 不仅可以为这些目标生成机器代码，而且标准库的跨平台抽象也有这些目标的实现。因此，写一个不依赖 libc 的纯 Zig 应用是可行的。
- CI 服务器在每次提交到主分支时都会自动测试这些目标，并在[下载页面](../../download/)更新预建二进制文件的链接。
- 这些目标具有调试信息功能，因此在失败的断言时产生[堆栈跟踪](#在所有目标上启用堆栈跟踪)。
- [即使在交叉编译时，libc 也可以用于这些目标。](#zig-与-libc-一起发布)
- 所有的行为测试和适用的标准库测试都在这些目标上通过，所有的语言功能都能正常工作。

#### 二级支持
- 标准库支持这个目标，但有可能一些 API 会给出“Unsupported OS”的编译错误。可以用 libc 或其他库链接来填补标准库的空白。
- 这些目标都是已知的，但可能不会自动测试，所以偶尔会有倒退。
- 随着我们对[一级支持](#一级支持)的努力，这些目标的一些测试可能会被禁用。

#### 三级支持

- 标准库对这个目标的存在几乎一无所知。
- 因为 Zig 是基于 LLVM 的，所以它有能力为这些目标构建，而 LLVM 默认启用了目标。
- 这些目标并不经常被测试：人们可能需要为 Zig 做出贡献，以便为这些目标构建。
- Zig 编译器可能需要更新一些东西，如
  - C 整数类型的大小是多少
  - 这个目标的 C ABI 调用约定是什么
  - bootstrap 代码和默认 panic 处理函数
- zig targets 保证包含这个目标。

#### 四级支持

- 对这些目标的支持完全是试验性的。
- LLVM可能会将目标作为实验性目标，这意味着你需要使用 Zig 提供的二进制文件来使目标可用，或者使用特殊的配置标志从源码构建 LLVM ，如果目标可用，`zig targets` 将显示目标。
- 这个目标可能会被官方认为是废弃的，比如 [macosx/i386](https://support.apple.com/en-us/HT208436)，在这种情况下，这个目标将永远停留在四级。
- 这个目标可能只支持输出汇编（`--emit asm`），而不支持输出对象文件。

## 对包维护者友好

虽然 Zig 编译器还没有完全自托管，但无论如何，从拥有一个系统 C++ 编译器到拥有一个适用于任何目标的完全自托管的 Zig 编译器，将[保持正好 3 步](https://github.com/ziglang/zig/issues/853)。正如 Maya Rashish 所指出的那样，[将 Zig 移植到其他平台是有趣且快速的](http://coypu.sdf.org/porting-zig.html)。

非[调试模式](https://ziglang.org/documentation/master/#Build-Mode)的构建是可重现/确定的。

这是[JSON格式的下载页面](https://ziglang.org/download/index.json)。

Zig 团队的几位成员都有维护软件包的经验。

- [Daurnimator](https://github.com/daurnimator) 维护 [Arch Linux 包](https://www.archlinux.org/packages/community/x86_64/zig/)。
- [Marc Tiehuis](https://tiehuis.github.io/) 维护 Visual Studio Code 扩展。
- [Andrew Kelley](https://andrewkelley.me/) 花了一年左右的时间来做 [Debian 和 Ubuntu 的打包工作](https://qa.debian.org/developer.php?login=superjoe30%40gmail.com&comaint=yes)，并随手贡献给 [nixpkgs](https://github.com/NixOS/nixpkgs/)。
- [Jeff Fowler](https://blog.jfo.click/) 维护者 Homebrew 包并发起了 [Sublime 扩展](https://github.com/ziglang/sublime-zig-language) （现在由 [emekoi](https://github.com/emekoi) 维护）。
