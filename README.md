# ziglang.org

Website for [zig](https://github.com/andrewrk/zig)

To upload:

```
./push
```

## How to update documentation

The docs here are actually generated using a
tool written in zig. Here's where the source files are:
 * [docs](https://github.com/zig-lang/zig/blob/master/doc/langref.html.in)

## How to update release notes

Edit files in src/.

```
export ZIG_DOCGEN=/home/andy/dev/zig/zig-cache/docgen
./build
```

Both the source and the output are committed to this repo because docgen is
likely to change in the future. The `build` script will only build the
release notes for the latest release.
