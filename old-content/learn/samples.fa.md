---
title: "نمونه های کد"
mobile_menu_title: "نمونه کد"
toc: true
---

## تشخیص نشت حافظه
با استفاده از `std.heap.GeneralPurposeAllocator` میتوانید نشت هر دو `free` و `memory` را ردیابی کنید.

{{< zigdoctest "assets/zig-code/samples/1-memory-leak.zig" >}}


## همکاری با C
مثال وارد کردن یک فایل هدر C و پیوند دادن به libc و raylib.

{{< zigdoctest "assets/zig-code/samples/2-c-interop.zig" >}}


## زیگ زاگ
Zig برای مصاحبه های برنامه نویسی *بهینه* شده است (نه واقعا).

{{< zigdoctest "assets/zig-code/samples/3-ziggzagg.zig" >}}


## تایپ های Generic
در Zig انواع مقادیر comptime وجود دارد و ما از توابعی که یک نوع را برمی گردانند برای پیاده سازی الگوریتم های generic و ساختار داده ها استفاده می کنیم. در این مثال ما یک صف generic را پیاده سازی کرده و رفتار آن را آزمایش می کنیم.

{{< zigdoctest "assets/zig-code/samples/4-generic-type.zig" >}}


## استفاده از cURL در Zig

{{< zigdoctest "assets/zig-code/samples/5-curl.zig" >}}
