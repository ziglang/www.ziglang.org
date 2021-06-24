---
title: "أمثلة"
mobile_menu_title: "أمثلة"
toc: true
---

## كشف تسرب الذاكرة
باستخدام `std.heap.GeneralPurposeAllocator` يمكنك تتبُع التحريرات المزدوجة وتسريبات الذاكرة.

{{< zigdoctest "assets/zig-code/samples/1-memory-leak.zig" >}}


## التوافق مع C
مثال لتوريد ملف تعريفي بلغة الـC وربط مكتبات libc وraylib.

{{< zigdoctest "assets/zig-code/samples/2-c-interop.zig" >}}


## Zigg Zagg
*صممت* Zig لأسئلة اختبارات البرمجة (غير صحيح).

{{< zigdoctest "assets/zig-code/samples/3-ziggzagg.zig" >}}


## الأنواع العامة
الأنواع في Zig هي قيم معروفة في زمن التصريف ويمكننا استخدام وظائف ترجع أنواع لتنفيذ خوارزميات عامة وهيكلة البيانات. في هذا المثال سنقوم بتنفيذ صف (queue) عام مٌبسّط وسنختبره.

{{< zigdoctest "assets/zig-code/samples/4-generic-type.zig" >}}


## استخدام cURL من Zig

{{< zigdoctest "assets/zig-code/samples/5-curl.zig" >}}
