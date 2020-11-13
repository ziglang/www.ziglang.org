---
title: "Why Zig When There is Already C++, D, and Rust?"
toc: true
---


## No hidden control flow

If Zig code doesn't look like it's jumping away to call a function, then it isn't. This means you can be sure that the following code calls only `foo()` and then `bar()`, and this is guaranteed without needing to know the types of anything:

```zig
var a = b + c.d;
foo();
bar();
```

D has `@property` functions, which are methods that you call with what looks like field access, so in the above example, `c.d` might call a function. Rust has operator overloading, so the `+` operator might call a function. D has throw/catch exceptions, so `foo()` might throw an exception, and prevent `bar()` from being called. (Of course, even in Zig `foo()` could deadlock and prevent `bar()` from being called, but that can happen in any Turing-complete language.)

The purpose of this design decision is to improve readability.

## No hidden allocations

More generally, have a hands-off approach when it comes to heap allocation. There is no `new` keyword or any other language feature that uses a heap allocator (e.g. string concatenation operator[1]). The entire concept of the heap is strictly in userspace. There are some standard library features that provide and work with heap allocators, but those are optional standard library features, not built into the language itself. If you never initialize a heap allocator, then you can be sure your program is never going to cause heap allocations.

Zig's standard library is still very young, but the goal is for every feature that uses an allocator to accept an allocator at runtime, or possibly at either compile time or runtime.

The motivation for this design philosophy is to enable users to write any manner of custom allocator strategy they find necessary, instead of forcing them or even encouraging them into a particular strategy that may not be suitable for their needs. For example, Rust seems to encourage a single global allocator strategy, which is not suitable for many usecases such as OS development and high-performance game development. Zig is taking cues from [Jai](https://www.youtube.com/watch?v=ciGQCP6HgqI)'s stance on allocators, since that language is being developed by a high-performance game designer for the usecase of high-performance games.

As stated before, this topic is still a bit fuzzy, and will become more concrete as the Zig standard library matures. The important thing is that heap allocation be a userspace concept, and not built into the language.

Needless to say, there is no builtin garbage collector like Go has.

[Rust standard library panics on Out Of Memory](https://github.com/rust-lang/rust/issues/29802)

[1]: Actually there is a string concatenation operator (generally an array concatenation operator), but it only works at compile time, so there's still no runtime heap allocation with that.

## First-class support for no standard library

Zig has an entirely optional standard library that only gets compiled into your program if you use it. Zig has equal support for either linking against libc or not linking against it. Zig is friendly to bare-metal and high-performance development.


## A Portable Language for Libraries

One of the holy grails of programming is code reuse. Sadly, in practice, we find ourselves re-inventing the wheel many times over again. Often it's justified.

 * If an application has real-time requirements, then any library that uses garbage collection or any other non-deterministic behavior is disqualified as a dependency.
 * If a language makes it too easy to ignore errors, and thus to verify that a library correctly handles and bubbles up errors, it can be tempting to ignore the library and re-implement it, knowing that one handled all the relevant errors correctly. Zig is designed such that the laziest thing a programmer can do is handle errors correctly, and thus one can be reasonably confident that a library will properly bubble errors up.
 * Currently it is pragmatically true that C is the most versatile and portable language. Any language that does not have the ability to interact with C code risks obscurity. Zig is attempting to become the new portable language for libraries by simultaneously making it straightforward to conform to the C ABI for external functions, and introducing safety and language design that prevents common bugs within the implementations.

## A Package Manager and Build System for Existing Projects

Zig is a programming language, but it also ships with a build system and package manager that are intended to be useful even in the context of a traditional C/C++ project.

Not only can you write Zig code instead of C or C++ code, but you can use Zig as a replacement for autotools, cmake, make, scons, ninja, etc. And on top of this, it (will) provide a package manager for native dependencies. This build system is intended to be appropriate even if the entirety of a project's codebase is in C or C++.

System package managers such as apt-get, pacman, homebrew, and others are instrumental for end user experience, but they can be insufficient for the needs of developers. A language-specific package manager can be the difference between having no contributors and having dozens. For open source projects, the difficulty of getting the project to build at all is a huge hurdle for potential contributors. For C/C++ projects, having dependencies can be fatal, especially on Windows, where there is no package manager. Even when just building Zig itself, most potential contributors have a difficult time with the LLVM dependency. Zig is (will be) offering a way for projects to depend on native libraries directly - without depending on the users' system package manager to have the correct version available, and in a way that is practically guaranteed to successfully build projects on the first try regardless of what system is being used and independent of what platform is being targeted.

Zig is offering to replace a project's build system with a reasonable language using a declarative API for building projects, that also provides package management, and thus the ability to actually depend on other C libraries. The ability to have dependencies enables higher level abstractions, and thus the proliferation of reusable high-level code.

## Simplicity

C++, Rust, and D have a large number of features and it can be distracting from the actual meaning of the application you are working on. One finds themselves debugging their knowledge of the programming language instead of debugging the application itself.

Zig has no macros and no metaprogramming, yet still is powerful enough to express complex programs in a clear, non-repetitive way. Even Rust which has macros special cases `format!`, implementing it in the compiler itself. Meanwhile in Zig, the equivalent function is implemented in the standard library with no special case code in the compiler.

When you look at Zig code, everything is a simple expression or a function call. There is no operator overloading, property methods, runtime dispatch, macros, or hidden control flow. Zig is going for all the beautiful simplicity of C, minus the pitfalls.

 * [Struggles With Rust](https://compileandrun.com/stuggles-with-rust.html)
 * [Way Cooler gives up on Rust due to complexity](http://way-cooler.org/blog/2019/04/29/rewriting-way-cooler-in-c.html)
 * [Moving to Zig for ARM Development](https://www.jishuwen.com/d/2Ap9)

## Tooling

Zig can be downloaded from [the downloads section](/downloads/).  Zig provides binary archives for linux, windows, macos and freebsd. The following describes what you get with this archive:

* installed by downloading and extracting a single archive, no system configuration needed
* statically compiled so there are no runtime dependencies
* uses the mature well-supported LLVM infrastructure which enables deep optimization and support for most major platforms
* out of the box cross-compilation to most major platforms
* ships with source code for libc that will be dynamically compiled when needed for any supported platform
* includes build system with caching
* compiles C code with libc support
