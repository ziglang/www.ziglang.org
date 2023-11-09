---
title: Build System
mobile_menu_title: "Build System"
toc: true
---

## When should you start using the Zig Build System?

The fundamental commands `zig build-exe`, `zig build-lib`, `zig build-obj`, and
`zig test` are often sufficient. However, sometimes a project needs another
layer of abstraction to manage the complexity of building from source.

For example, perhaps one of these situations applies:

- The command line becomes too long and unwieldly, and you want some place to
  write it down.
- You want to build many things, or the build process contains many steps.
- You want to take advantage of concurrency and caching to reduce build time.
- You want to expose configuration options for your project.
- The build process is different depending on the target system and other options.
- You have dependencies on other projects.
- You want to avoid an unnecessary dependency on cmake, make, shell, msvc,
  python, etc., making your project accessible to more contributors.
- You want to provide a package to be consumed by third parties.
- You want to provide a standardized way for tools such as IDEs to semantically understand
  how to build your project.

If any of these apply, your project will benefit from using the Zig Build System.

## Examples
### Simple Executable
This build script creates an executable from a Zig file that contains a public main function definition.

{{< zigdoctest "assets/zig-code/build-system/1-simple-executable/hello.zig" >}}
{{< zigdoctest "assets/zig-code/build-system/1-simple-executable/build.zig" >}}

#### Installing Build Artifacts

The Zig build system, like most build systems, it's based on modeling your project as a directed acyclic graph (DAG) of steps, which are independently and concurrently run.

By default, the main step in the graph is to install the final build artifacts. However, the system is powerful and flexible, which means it does not assume all build artifacts are necessarily the final product, and one must explicitly add them to the install set.

**Output**
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

You, as the project maintainer, pick what gets put in this directory, but the user chooses where to install it in their system. The build script cannot hardcode output paths because this would break caching, concurrency, and composability, as well as annoy the final user.

### User-Provided Options

Use `b.option` to make your build script configurable to end users as well as
other projects that depend on your project as a package.

{{< zigdoctest "assets/zig-code/build-system/2-user-provided-options/build.zig" >}}
{{< zigdoctest "assets/zig-code/build-system/2-user-provided-options/example.zig" >}}

Please direct your attention to these lines:

```
Project-Specific Options:
  -Dwindows=[bool]             Target Microsoft Windows
```

This part of the help menu is auto-generated based on running the `build.zig` logic. Users
can discover configuration options of your build script this way.

### Standard Configuration Options

Previously, we used a boolean flag to indicate building for Windows. However, we can do
better.

Most projects want to provide the ability to change the target and optimization settings.
In order to encourage standard naming conventions for these options, Zig provides the
helper functions, `standardTargetOptions` and `standardOptimizeOption`.

Standard target options allows the person running `zig build` to choose what
target to build for. By default, any target is allowed, and no choice means to
target the host system. Other options for restricting supported target set are
available.

Standard optimization options allow the person running `zig build` to select
between `Debug`, `ReleaseSafe`, `ReleaseFast`, and `ReleaseSmall`. By default
none of the release options are considered the preferable choice by the build
script, and the user must make a decision in order to create a release build.

{{< zigdoctest "assets/zig-code/build-system/3-standard-config-options/hello.zig" >}}
{{< zigdoctest "assets/zig-code/build-system/3-standard-config-options/build.zig" >}}

Now, our `--help` menu contains more items:

```
Project-Specific Options:
  -Dtarget=[string]            The CPU architecture, OS, and ABI to build for
  -Dcpu=[string]               Target CPU features to add or subtract
  -Doptimize=[enum]            Prioritize performance, safety, or binary size (-O flag)
                                 Supported Values:
                                   Debug
                                   ReleaseSafe
                                   ReleaseFast
                                   ReleaseSmall
```

It is entirely possible to create these options via `b.option` directly, but this
API provides a commonly used naming convention for these frequently used settings.

In our terminal output, observe that we passed `-Dtarget=x86_64-windows -Doptimize=ReleaseSmall`.
Compared to the first example, now we see different files in the installation prefix:

```
zig-out/
└── bin
    └── hello.exe
```

### Build for multiple targets to make a release

In this example we're going to change some defaults when creating an `InstallArtifact` step in order to put the build for each target into a separate subdirectory inside the install path. 

{{< zigdoctest "assets/zig-code/build-system/10-release/build.zig" >}}
{{< zigdoctest "assets/zig-code/build-system/10-release/hello.zig" >}}

**Output**

```
zig-out
├── aarch64-linux
│   └── hello
├── aarch64-macos
│   └── hello
├── x86_64-linux-gnu
│   └── hello
├── x86_64-linux-musl
│   └── hello
└── x86_64-windows
    ├── hello.exe
    └── hello.pdb
```
