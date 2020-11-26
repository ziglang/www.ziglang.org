---
title: "Code Examples"
toc: true
---

## Memory leak detection
Using `std.GeneralPurposeAllocator` you can easily track double frees and memory leaks.

{{< zigdoctest "assets/zig-code/samples/1-memory-leak.zig" >}}


## C interoperability
Example of importing a C header file and linking to both libc and raylib.

{{< zigdoctest "assets/zig-code/samples/2-c-interop.zig" >}}


## Zigg Zagg
Zig is *optimized* for coding interviews (not really).

{{< zigdoctest "assets/zig-code/samples/3-ziggzagg.zig" >}}


## Generic Type
In Zig types are comptime values and we use functions that return a type to implement generic algorithms and data structures. In this example we implement a simple generic queue and test its behaviour.

{{< zigdoctest "assets/zig-code/samples/4-generic-type.zig" >}}


## Using cURL from Zig

{{< zigdoctest "assets/zig-code/samples/5-curl.zig" >}}
