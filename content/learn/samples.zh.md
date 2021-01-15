---
title: "代码范例"
mobile_menu_title: "代码范例"
toc: true
---

## 内存泄露检测
使用 `std.GeneralPurposeAllocator` 来检测双重释放和内存泄露。

{{< zigdoctest "assets/zig-code/samples/1-memory-leak.zig" >}}


## C 互操作性
导入 C 头文件并链接到 libc 和 raylib 的示例。

{{< zigdoctest "assets/zig-code/samples/2-c-interop.zig" >}}


## Zigg Zagg
Zig 已为代码面试做了*优化*（并没有）。

{{< zigdoctest "assets/zig-code/samples/3-ziggzagg.zig" >}}


## 泛型
在 Zig 中，类型是编译期的值，我们使用返回类型的函数来实现泛型算法和数据结构。
在此示例中，我们实现了一个简单的泛型队列并测试其行为。

{{< zigdoctest "assets/zig-code/samples/4-generic-type.zig" >}}


## 在 zig 中使用 cURL

{{< zigdoctest "assets/zig-code/samples/5-curl.zig" >}}
