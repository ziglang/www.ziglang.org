---
title: Build System
mobile_menu_title: "Build System"
toc: true
---

## When should you start using the Zig build system?

- non trivial logic that needs to execute to build your program
- you want to build many things at once
- you have dependencies on other projects
- you want a cross-platform alternative to cmake, make, shell, msvc, python, etc.
- you want to provide a package that can be easily consumed by third parties
- you want IDEs to understand your project (soon tm)

## Examples
### 1. Simple Executable
This build script creates an executable from a Zig file that contains a public main function definition.

{{< zigdoctest "assets/zig-code/build-system/1-simple-executable/build.zig" >}}
{{< zigdoctest "assets/zig-code/build-system/1-simple-executable/hello.zig" >}}

#### Installing Build Artifacts

The Zig build system, like most build systems, it's based on modeling your project as a directed acyclic graph (DAG) of steps, which are independently and concurrently run.

By default, the main step in the graph is to install the final build artifacts. However, the system is powerful and flexible, which means it does not assume all build artifacts are necessarily the final product, and one must explicitly add them to the install set.

**$ tree**
```
├── build.zig
├── hello.zig
├── zig-cache
└── zig-out
    └── bin
        └── hello
```

There are two generated directories in this output: `zig-cache` and `zig-out`. The first one contains files that will make subsequent builds faster, but these files are not intended to be checked into source-control and this directory can be completely deleted at any time with no consequences.

The second one, `zig-out`, is an "installation prefix". This maps to the standard file system hierarchy concept. This directory is not chosen by the project, but by the user of `zig build` with the `--prefix` flag (`-p` for short).

You, as the project maintainer, get to pick what gets put in this directory, but the user chooses where to install it in their system. The build script cannot hardcode output paths because this would break caching, concurrency, and composability, as well as annoy the final user.

# 


