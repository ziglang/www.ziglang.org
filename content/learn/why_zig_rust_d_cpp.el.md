---
title: "Γιατί Zig όταν υπάρχει ήδη C++, D, και Rust;"
mobile_menu_title: "Γιατί Zig όταν..."
toc: true
---


## Χωρίς κρυφές ροές ελέγχου

Εάν ο κώδικας Zig δεν φαίνεται ότι καλεί μια συνάρτηση, τότε δεν το κάνει. Αυτό σημαίνει ότι μπορείτε να είστε βέβαιοι ότι ο παρακάτω κώδικας καλεί μόνο το `foo()` και μετά το `bar()`, και αυτό είναι εγγυημένο χωρίς να χρειάζεται να γνωρίζετε οποιουδήποτε τύπους:

```zig
var a = b + c.d;
foo();
bar();
```

Παραδείγματα κρυφής ροής ελέγχου:

* Η D έχει συναρτήσεις `@property`, οι οποίες είναι μέθοδοι που καλείτε με κάτι που μοιάζει με πρόσβαση πεδίου, επομένως στο παραπάνω παράδειγμα, το `c.d` μπορεί να καλέσει μια συνάρτηση.
* Οι C++, D και Rust έχουν υπερφόρτωση τελεστή, επομένως ο τελεστής `+` μπορεί να καλέσει μια συνάρτηση.
* Οι C++, D και Go έχουν εξαιρέσεις (exceptions), επομένως το `foo()` μπορεί να δημιουργήσει μια εξαίρεση και να αποτρέψει την κλήση του `bar()`. (Φυσικά, ακόμη και στη Zig το `foo()` θα μπορούσε να είναι αδιέξοδο (deadlock) και να αποτρέψει την κλήση του `bar()`, αλλά αυτό μπορεί να συμβεί σε οποιαδήποτε γλώσσα που είναι πλήρης κατά Turing.)

Σκοπός αυτής της σχεδίασης είναι η βελτίωση της αναγνωσιμότητας.

## Χωρίς κρυφές δεσμεύσεις μνήμης

Zig has a hands-off approach when it comes to heap allocation. There is no `new` keyword
or any other language feature that uses a heap allocator (e.g. string concatenation operator[1]).
The entire concept of the heap is managed by library and application code, not by the language.

Examples of hidden allocations:

* Go's `defer` allocates memory to a function-local stack. In addition to being an unintuitive
  way for this control flow to work, it can cause out-of-memory failures if you use
  `defer` inside a loop.
* C++ coroutines allocate heap memory in order to call a coroutine.
* In Go, a function call can cause heap allocation because goroutines allocate small stacks
  that get resized when the call stack gets deep enough.
* The main Rust standard library APIs panic on out of memory conditions, and the alternate
  APIs that accept allocator parameters are an afterthought
  (see [rust-lang/rust#29802](https://github.com/rust-lang/rust/issues/29802)).

Nearly all garbage collected languages have hidden allocations strewn about, since the
garbage collector hides the evidence on the cleanup side.

The main problem with hidden allocations is that it prevents the *reusability* of a
piece of code, unnecessarily limiting the number of environments that code would be
appropriate to be deployed to. Simply put, there are use cases where one must be able
to rely on control flow and function calls not to have the side-effect of memory allocation,
therefore a programming language can only serve these use cases if it can realistically
provide this guarantee.

In Zig, there are standard library features that provide and work with heap allocators,
but those are optional standard library features, not built into the language itself.
If you never initialize a heap allocator, you can be confident your program will not heap allocate.

Every standard library feature that needs to allocate heap memory accepts an `Allocator` parameter
in order to do it. This means that the Zig standard library supports freestanding targets. For
example `std.ArrayList` and `std.AutoHashMap` can be used for bare metal programming!

Custom allocators make manual memory management a breeze. Zig has a debug allocator that
maintains memory safety in the face of use-after-free and double-free. It automatically
detects and prints stack traces of memory leaks. There is an arena allocator so that you can
bundle any number of allocations into one and free them all at once rather than manage
each allocation independently. Special-purpose allocators can be used to improve performance
or memory usage for any particular application's needs.

\[1]: Actually there is a string concatenation operator (generally an array concatenation operator), but it only works at compile time, so it still doesn't do any runtime heap allocation.

## Πλήρη υποστήριξη απουσίας πρότυπης βιβλιοθήκης

As hinted above, Zig has an entirely optional standard library. Each std lib API only gets compiled
into your program if you use it. Zig has equal support for either linking against libc or
not linking against it. Zig is friendly to bare-metal and high-performance development.

It's the best of both worlds; for example in Zig, WebAssembly programs can both use
the normal features of the standard library, and still result in the tiniest binaries when
compared to other programming languages that support compiling to WebAssembly.

## Μια φορητή γλώσσα για βιβλιοθήκες

One of the holy grails of programming is code reuse. Sadly, in practice, we find ourselves re-inventing the wheel many times over again. Often it's justified.

 * If an application has real-time requirements, then any library that uses garbage collection or any other non-deterministic behavior is disqualified as a dependency.
 * If a language makes it too easy to ignore errors, and thus hard to verify that a library correctly handles and bubbles up errors, it can be tempting to ignore the library and re-implement it, knowing that one handled all the relevant errors correctly. Zig is designed such that the laziest thing a programmer can do is handle errors correctly, and thus one can be reasonably confident that a library will properly bubble errors up.
 * Currently it is pragmatically true that C is the most versatile and portable language. Any language that does not have the ability to interact with C code risks obscurity. Zig is attempting to become the new portable language for libraries by simultaneously making it straightforward to conform to the C ABI for external functions, and introducing safety and language design that prevents common bugs within the implementations.

## Διαχείριση πακέτων και σύστημα κατασκευής προγραμμάτων για υπάρχοντα έργα

Zig is a toolchain in addition to a programming language. It comes with a
[build system and package manager](/learn/build-system/) that are useful even
in the context of a traditional C/C++ project.

Not only can you write Zig code instead of C or C++ code, but you can use Zig
as a replacement for autotools, cmake, make, scons, ninja, etc. And on top of
this, it provides a package manager for native dependencies. This build system
is appropriate even if the entirety of a project's codebase is in C or C++.
For example, by
[porting ffmpeg to the zig build system](https://github.com/andrewrk/ffmpeg),
it becomes possible to compile ffmpeg on any supported system for any supported
system using only a [50 MiB download of zig](/download/). For open source
projects, this streamlined ability to build from source - and even
cross-compile - can be the difference between gaining or losing valuable
contributors.

System package managers such as apt-get, pacman, homebrew, and others are
instrumental for end user experience, but they can be insufficient for the
needs of developers. A language-specific package manager can be the difference
between having no contributors and having many. For open source projects, the
difficulty of getting the project to build at all is a huge hurdle for
potential contributors. For C/C++ projects, having dependencies can be fatal,
especially on Windows, where there is no package manager. Even when just
building Zig itself, most potential contributors have a difficult time with the
LLVM dependency. Zig offers a way for projects to depend on native libraries
directly - without depending on the users' system package manager to have the
correct version available, and in a way that is practically guaranteed to
successfully build projects on the first try regardless of what system is being
used and independent of what platform is being targeted.

**Other languages have package managers but they do not eliminate pesky system
dependencies like Zig does.**

Zig can replace a project's build system with a reasonable language using
a declarative API for building projects, that also provides package management,
and thus the ability to actually depend on other C libraries. The ability to
have dependencies enables higher level abstractions, and thus the proliferation
of reusable high-level code.

## Απλότητα

C++, Rust, and D have such a large number of features that they can be distracting from the actual meaning of the application you are working on. One finds oneself debugging one's knowledge of the programming language instead of debugging the application itself.

Zig has no macros yet is still powerful enough to express complex programs in a
clear, non-repetitive way. Even Rust has macros with special cases like
`format!`, which is implemented in the compiler itself. Meanwhile in Zig, the
equivalent function is implemented in the standard library with no special case
code in the compiler.

## Εργαλεία

Zig can be downloaded from [the downloads section](/download/).  Zig provides
binary archives for Linux, Windows, and macOS. The following describes what you
get with one of these archives:

* installed by downloading and extracting a single archive, no system configuration needed
* statically compiled so there are no runtime dependencies
* supports using LLVM for optimized release builds while using Zig's custom backends for faster compilation performance
* additionally supports a backend for outputting C code
* out of the box cross-compilation to most major platforms
* ships with source code for libc that will be dynamically compiled when needed for any supported platform
* includes build system with concurrency and caching
* compiles C and C++ code with libc support
* drop-in GCC/Clang command line compatibility with `zig cc`
* Windows resource compiler
