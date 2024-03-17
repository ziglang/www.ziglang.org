---
title: "Code Examples"
mobile_menu_title: "Code Samples"
toc: true
---

## Calling external library functions
All system API functions can be invoked this way, you do not need library bindings to interface them.

{{< zigdoctest "assets/zig-code/samples/0-windows-msgbox.zig" >}}

## Memory leak detection
Using `std.heap.GeneralPurposeAllocator` you can track double frees and memory leaks.

{{< zigdoctest "assets/zig-code/samples/1-memory-leak.zig" >}}


## C interoperability
Example of importing a C header file and linking to both libc and raylib.

{{< zigdoctest "assets/zig-code/samples/2-c-interop.zig" >}}


## Zigg Zagg
Zig is *optimized* for coding interviews (not really).

{{< zigdoctest "assets/zig-code/samples/3-ziggzagg.zig" >}}


## Generic Types
In Zig types are comptime values and we use functions that return a type to implement generic algorithms and data structures. In this example we implement a simple generic queue and test its behaviour.

{{< zigdoctest "assets/zig-code/samples/4-generic-type.zig" >}}


## Using cURL from Zig

{{< zigdoctest "assets/zig-code/samples/5-curl.zig" >}}
