---
title: "Code Examples"
toc: true
---

## Memory leak detection
Using `std.GeneralPurposeAllocator` you can easily track double frees and memory leaks.

{{< zigdocgen "docgen-samples/samples/1-memory-leak.md" >}}


## C interoperability
Example of importing a C header file and linking to both libc and raylib.

<pre>
{{< zigdocgen "docgen-samples/samples/2-c-interop.md" >}}
</pre>


## Zigg Zagg
Zig is *optimized* for coding interviews.

{{< zigdocgen "docgen-samples/samples/3-ziggzagg.md" >}}


## Generic Type
In Zig types are comptime values and we use functions that return a type to implement generic algorithms and data structures. In this example we implement a simple generic queue and test its behaviour.

{{< zigdocgen "docgen-samples/samples/4-generic-type.md" >}}
