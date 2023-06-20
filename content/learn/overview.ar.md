---
title: "نظرة عامة متعمقة"
mobile_menu_title: "نظرة عامة"
toc: true
---
# أهم المزايا
## لغة بسيطة وسهلة

تفرغ لتصحيح أخطاء برنامجك بدلًا من تصحيح معرفتك بلغة البرمجة.

صياغة Zig الكاملة تحددها [وثيقة قواعد لا تتعدى الـ500 سطر](https://ziglang.org/documentation/master/#Grammar).

لا **وجود لتحكمات مخفية في التدفّق**، أو تخصيصات مخفية للذاكرة، أو معالج تمهيدي، أو وحدات ماكرو. اذا كان الكود ظاهره أنه لا يستدعي وظيفة، فهذا ما يحدث بالفعل. هذا يعني أن بامكانك التأكد من أن الكود التالي يستدعي فقط `()foo` ثم `()bar`، وهذا مضمون دون أن تحتاج معرفة نوع أيًا من المتغيرات:

```zig
var a = b + c.d;
foo();
bar();
```

أمثلة للتحكم المخفي في التدفّق:

- D لديها وظائف `property@`، التي يمكنك استدعائها كما لو كانت حقل لا وظيفة، لذلك في المثال أعلاه يحتمل أن تستدعي `c.d` وظيفة.
- لدى ++C، وD، وRust خاصية إعادة تعريف المعاملات، لذا فيمكن للمعامل `+` أن يستدعي وظيفة.
- لدى ++C، وD، وRust خاصية الاستثناءات، لذا يمكن أن تقوم وظيفة `()foo` برمي استثناء مما يمنع استدعاء وظيفة `()bar`.

تشجع Zig على جعل صيانة وقراءة الكود سهلة بجعل كل آليات التحكم متاحة حصريًا عن طريق كلمات اللغة المفتاحية والوظائف.

## الأداء والأمان: اختر اثنان

لدى Zig أربع [أطوار بناء](https://ziglang.org/documentation/master/#Build-Mode)، ويمكن مزج أيًا منهم معًا وصولًا [لطبقة النطاق](https://ziglang.org/documentation/master/#setRuntimeSafety).

| المَعلم | [Debug](/documentation/master/#Debug) | [ReleaseSafe](/documentation/master/#ReleaseSafe) | [ReleaseFast](/documentation/master/#ReleaseFast) | [ReleaseSmall](/documentation/master/#ReleaseSmall) |
|-----------|-------|-------------|-------------|--------------|
التحسينات - تحسين للسرعة، ضرر للقدرة على تصحيح الأخطاء، ضرر لوقت الصرف | | O3- | O3- | Os- |
فحوصات الأمان في زمن التنفيذ - ضرر للسرعة، ضرر للحجم، تحطم بدلًا من سلوك غير محدد | On | On | | |

هذا مثال لشكل [طفح الأعداد الصحيحة](https://ziglang.org/documentation/master/#Integer-Overflow) في زمن التصريف، أيًا كان وضع البناء:

{{< zigdoctest "assets/zig-code/features/1-integer-overflow.zig" >}}

وهذا شكله في زمن التنفيذ، في الأطوار اللتي تتضمن فحوصات الأمان:

{{< zigdoctest "assets/zig-code/features/2-integer-overflow-runtime.zig" >}}

متفقدات الرص تلك [تعمل على كل المعماريات المستهدفة](#متفقدات-رص-لكل-المنصات)، بما في ذلك المنصات [القائمة بذاتها](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html).

مع Zig، يمكن الاعتماد على وضع يتضمن فحوصات الأمان، مع تعطيل هذه الفحوصات بشكل انتقائي في مختنقات الأداء. على سبيل المثال، يمكن تعديل المثال السابق هكذا:

{{< zigdoctest "assets/zig-code/features/3-undefined-behavior.zig" >}}

تستعمل Zig [السلوك غير المحدد](https://ziglang.org/documentation/master/#Undefined-Behavior) كأداة في غاية الدقة لمنع الأخطاء البرمجية وتحسين الأداء.

وبالحديث عن الأداء، فإن Zig أسرع من C.

- يستعمل التنفيذ المرجعي LLVM كواجهة خلفية لضمان الحصول على أفضل وأجدد التحسينات.
- تقوم Zig بتنفيذ ما يسميه الآخرون بتحسينات زمن الربط بشكلٍ آلي.
- بعض الخواص المتقدمة مفعلة للبرامج الأصيلة (-march=native)، ويعود الفضل في ذلك لأن [الترجمة المختلطة](#الترجمة-المختلطة-استخدام-من-الفئة-الأولى) هي أحد حالات الاستخدام المتوقعة من اللغة.
- السلوك غير المحدد منتق بعناية. على سبيل المثال، في Zig كلٌ من الأعداد الصحيحة ذات الإشارة أو من دونها لديها سلوك غير محدد عند الطفح، على عكس C التي تعرف ذلك للأعداد الصحيحة ذات الإشارة فقط. هذا [يسهل على القيام بتحسينات غير متاحة في C](https://godbolt.org/z/n_nLEU).
- تقدم Zig [صف نوعي بخاصية SIMD](https://ziglang.org/documentation/master/#Vectors)، مما يسهل عملية كتابة كود صفّي نقّال.

برجاء مراعاة أن Zig ليست لغة آمنة بالكامل. لمن يهمه تتبع قصة الأمان في Zig، يمكنكم متابعة هذه الموضوعات:

- [حصر كل أنواع السلوكيات غير المحددة، حتى تلك التي لا يمكن فحصها بشكل آمن](https://github.com/ziglang/zig/issues/1966)
- [جعل أطوار Debug وReleaseSafe آمنة بالكامل](https://github.com/ziglang/zig/issues/2301)

## تتنافس Zig مع C بدل من أن تعتمد عليها

مكتبة Zig الأساسية تستطيع الاندماج مع libc، ولكنها لا تعتمد عليها. هذا مثال مُبسّط:

{{< zigdoctest "assets/zig-code/features/4-hello.zig" >}}

حين يصرف هذا المثال بوضعية `O ReleaseSmall-` مع نزع رموز التشخيص، واستعمال وضعية سلسلة التعليمات الواحدة، نحصل على برنامج تنفيذي بحجم 9.8 KiB يستهدف x86_64-linux:
```
$ zig build-exe hello.zig -O ReleaseSmall --strip --single-threaded
$ wc -c hello
9944 hello
$ ldd hello
  not a dynamic executable
```

استهداف Windows يصغر حجم البرنامج التنفيذي ليصبح 4096 بايت.
```
$ zig build-exe hello.zig -O ReleaseSmall --strip --single-threaded -target x86_64-windows
$ wc -c hello.exe
4096 hello.exe
$ file hello.exe
hello.exe: PE32+ executable (console) x86-64, for MS Windows
```

## تعريفات علوية مستقلة

التعريفات العلوية مثل المتغيّرات العمومية مستقلة ولا تعتمد على الترتيب ويتم تحليلها بشكل كسول. القيم التهييئية للمتغيّرات العمومية [يتم تقييمها في زمن التصريف](#الاستبطان-والتنفيذ-في-زمن-التصريف).

{{< zigdoctest "assets/zig-code/features/5-global-variables.zig" >}}

## النوع الاختياري بدلًا من المؤشرات الفارغة

في لغات أخرى، الإشارات الفارغة مصدر للعديد من الاستثناءات في زمن التنفيذ، بل أن البعض يرى أنها [اسوأ غلطة في علم الكمبيوتر](https://www.lucidchart.com/techblog/2015/08/31/the-worst-mistake-of-computer-science/).

المؤشرات غير المزينة في Zig لا يمكنها أن تكون فارغة:

{{< zigdoctest "assets/zig-code/features/6-null-to-ptr.zig" >}}

ولكن أي نوع يمكن أن يُحَوّل [لنوع اختياري](https://ziglang.org/documentation/master/#Optionals) عن طريق استهلاله بـ?:

{{< zigdoctest "assets/zig-code/features/7-optional-syntax.zig" >}}

لفض قيمة اختيارية، يمكن استعمال `orelse` لنص قيمة افتراضية:

{{< zigdoctest "assets/zig-code/features/8-optional-orelse.zig" >}}

يمكن أيضًا استعمال if:

{{< zigdoctest "assets/zig-code/features/9-optional-if.zig" >}}

و نفس الصياغة مع [while](https://ziglang.org/documentation/master/#while):

{{< zigdoctest "assets/zig-code/features/10-optional-while.zig" >}}

## إدارة ذاكرة يدوية

أي مكتبة مكتوبة بلغة Zig صالحة للاستخدام في أي مكان:

- [برامج للأجهزة الشخصية](https://github.com/TM35-Metronome/)
- خوادم سريعة الاستجابة
- [أنوية أنظمة التشغيل](https://github.com/AndreaOrru/zen)
- [الأجهزة المدمجة](https://github.com/skyfex/zig-nrf-demo/)
- البرمجيات الفورية، مثل الحفلات المباشرة، والطائرات، ومنظمو ضربات القلب.
- [في متصفحي الانترنت أوالملحقات الأخرى باستعمال WebAssembly](https://shritesh.github.io/zigfmt-web/)
- من لغات برمجة أخرى، باستعمال واجهة C الثنائية للتطبيقات

من أجل تحقيق ذلك، فلابد على مبرمجي Zig من إدارة ذاكرتهم بأنفسهم، والتعامل مع فشل تخصيص الذاكرة.

هذا صحيح حتى بالنسبة لمكتبة Zig الأساسية أيضًا. أي وظائف تحتاج لتخصيص الذاكرة تقبل بمُخَصِص كمعَلم. نتيجة هذا هو أن مكتبة Zig الأساسية يمكن استخدامها حتى على المنصات القائمة بذاتها.

بالاضافة [لأسلوب جديد للتعامل مع الأخطاء](#أسلوب-جديد-للتعامل-مع-الأخطاء)، توفر Zig [defer](https://ziglang.org/documentation/master/#defer) و[errdefer](https://ziglang.org/documentation/master/#errdefer) لتبسيط كل عمليات إدارة الموارد، لا الذاكرة فحسب.

لمثال عن `defer`، تفقد [الدمج مع مكتبات C بدون FFI/تقييدات](#الدمج-مع-مكتبات-c-بدون-ffiتوصيلات). هذا مثال لاستخدام `errdefer`:
{{< zigdoctest "assets/zig-code/features/11-errdefer.zig" >}}


## أسلوب جديد للتعامل مع الأخطاء

الأخطاء قيم، ولا يمكن إهمالها:

{{< zigdoctest "assets/zig-code/features/12-errors-as-values.zig" >}}

يمكن التعامل مع الأخطاء باستخدام [catch](https://ziglang.org/documentation/master/#catch):

{{< zigdoctest "assets/zig-code/features/13-errors-catch.zig" >}}

الكلمة المفتاحية [try](https://ziglang.org/documentation/master/#try) هي اختصار لـ`catch |err| return err`:

{{< zigdoctest "assets/zig-code/features/14-errors-try.zig" >}}

لاحظ أن هذا [متفقد لتتبع الخطأ](https://ziglang.org/documentation/master/#Error-Return-Traces) وليس [متفقد للرص](#متفقدات-رص-لكل-المنصات). هذا الكود لم يدفع ثمن حل الرص لكي يعرض هذا المتفقد.

يمكن استخدام كلمة [switch](https://ziglang.org/documentation/master/#switch) المفتاحية مع الخطأ لضمان التعامل مع كل أنواع الأخطاء:

{{< zigdoctest "assets/zig-code/features/15-errors-switch.zig" >}}

تستخدم كلمة [unreachable](https://ziglang.org/documentation/master/#unreachable) المفتاحية للتأكيد على عدم إمكانية وقوع أخطاء:

{{< zigdoctest "assets/zig-code/features/16-unreachable.zig" >}}

هذا يستحضر [سلوك غير محدد](#الأداء-والأمان-اختر-اثنان) في أطور البناء غير الآمنة، لذا تأكد من استعماله فقط عندما يكون النجاح مضمونًا.

### متفقدات رص لكل المنصات

متفقدات الرص و[متفقدات تتبع الخطأ](https://ziglang.org/documentation/master/#Error-Return-Traces) المعروضة في هذه الصفحة تعمل على كل منصات [الفئة الأولى](#tier-1-support) وبعض منصات [الفئة الثانية](#tier-2-support). [هذا يشمل أيضًا المنصات القائمة بذاتها](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html)!

بالإضافة لذلك، يمكن لمكتبة Zig الأساسية أن تخزن متفقد لرص في أي وقت وتفريغه في وقت لاحق:

{{< zigdoctest "assets/zig-code/features/17-stack-traces.zig" >}}

يمكنك متابعة هذه التقنية في [مشروع GeneralPurposeDebugAllocator](https://github.com/andrewrk/zig-general-purpose-allocator/#current-status) الجاري.

## هياكل بيانات ووظائف عامة

الأنواع قيم يجب معرفتها في زمن التصريف:

{{< zigdoctest "assets/zig-code/features/18-types.zig" >}}

هيكل البيانات العام هو مجرد وظيفة ذات عائد نوعه `type`:

{{< zigdoctest "assets/zig-code/features/19-generics.zig" >}}

## الاستبطان والتنفيذ في زمن التصريف

وظيفة [@typeinfo](https://ziglang.org/documentation/master/#typeInfo) المضمنة توفر خاصية الاستبطان:

{{< zigdoctest "assets/zig-code/features/20-reflection.zig" >}}

تستخدم مكتبة Zig الأساسية هذه الطريقة في الطباعة المصاغة. على الرغم من كونها [لغة بسيطة وسهلة](#لغة-بسيطة-وسهلة)، فالطباعة المصوغة تم تنفيذها بالكامل بلغة Zig. بينما في C، فأخطاء وظائف مثل printf تم غرزها في المترجم. وكذلك في Rust، فوحدة ماكرو الطباعة المصوغة مغروز في المترجم.

تستطيع Zig أيضًا تقييم الوظائف وكتل الكود في وقت التصريف. في بعض الحالات، مثل تهيئة المتغيّرات العمومية، يتم تقييم المصطلح ضمنيًا في وقت الصرف. بخلاف ذلك، يمكن تقييم كود صراحًة في وقت التصريف باستخدام كلمة [comptime](https://ziglang.org/documentation/master/#comptime) المفتاحية. هذا يمكنه أن يكون فعالًا اذا تم جمعه مع التأكيدات:

{{< zigdoctest "assets/zig-code/features/21-comptime.zig" >}}

## الدمج مع مكتبات C بدون FFI/توصيلات

تستورد [@cImport](https://ziglang.org/documentation/master/#cImport) الأنواع والمتغيّرات والوظائف ووحدات الماكرو مباشرة لتصبح جاهزة للاستعمال في Zig. يمكنها أيضًا أن تترجم الوظائف المضمنة من C لـZig.

هذا مثال لإصدار موجة جيبية باستخدام [libsoundio](http://libsound.io/):

<u>sine.zig</u>
{{< zigdoctest "assets/zig-code/features/22-sine-wave.zig" >}}

```
$ zig build-exe sine.zig -lsoundio -lc
$ ./sine
Output device: Built-in Audio Analog Stereo
^C
```

[الكود بلغة Zig أبسط بكثير من نظيره بلغة C](https://gist.github.com/andrewrk/d285c8f912169329e5e28c3d0a63c1d8)، بالإضافة للمزيد من فحوصات الأمان، وكل هذا أمكن تحقيقه فقط باستيراد ملف C - بدون توصيلات مع الواجهة البرمجية.

*Zig أفضل في استعمال مكتبات C من C نفسها.*

### Zig أيضًا مترجم للغة C

هذا مثال لـZig وهي تقوم ببناء كود C:

<u>hello.c</u>
```c
#include <stdio.h>

int main(int argc, char **argv) {
    printf("Hello world\n");
    return 0;
}
```

```
$ zig build-exe hello.c --library c
$ ./hello
Hello world
```

يمكنك استخدام `--verbose-cc` لمعرفة تفاصيل مترجم لغة الـC الذي تم تنفيذه:
```
$ zig build-exe hello.c --library c --verbose-cc
zig cc -MD -MV -MF zig-cache/tmp/42zL6fBH8fSo-hello.o.d -nostdinc -fno-spell-checking -isystem /home/andy/dev/zig/build/lib/zig/include -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-gnu -isystem /home/andy/dev/zig/build/lib/zig/libc/include/generic-glibc -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-any -isystem /home/andy/dev/zig/build/lib/zig/libc/include/any-linux-any -march=native -g -fstack-protector-strong --param ssp-buffer-size=4 -fno-omit-frame-pointer -o zig-cache/tmp/42zL6fBH8fSo-hello.o -c hello.c -fPIC
```

لاحظ أن حين يُنفَذ الأمر مرة أخرى، لا يوجد ناتج، وينتهي فورًا:
```
$ time zig build-exe hello.c --library c --verbose-cc

real	0m0.027s
user	0m0.018s
sys	0m0.009s
```

هذا بفضل [التخزين المؤقت لنواتج البناء](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching). تحلل Zig ملف .d وتستعمل نظام تخزين مؤقت متين لتجنب تكرار العمل.

ليس بامكان Zig ترجمة كود C فحسب، بل أن هناك سبب جيد جدًا لاستعمال Zig كمترجم لـC: [تُشحن Zig ومعها libc](#تشحن-zig-ومعها-libc).

### صدّر وظائف ومتغيّرات وأنواع جاهزة للاستخدام من كود C

واحدة من الاستخدمات الأساسية لZig هي تصدير مكتبة تستخدم الواجهة الثنائية لC كي تستطيع اللغات الأخرى استخدامها. وضع كلمة `export` المفتاحية قبل أي وظيفة أو متغيّر أو نوع يضمهم إلى واجهة المكتبة البرمجية:

<u>mathtest.zig</u>
{{< zigdoctest "assets/zig-code/features/23-math-test.zig" >}}

لعمل مكتبة ساكنة:
```
$ zig build-lib mathtest.zig
```

لعمل مكتبة مشتركة:
```
$ zig build-lib mathtest.zig -dynamic
```

هذا مثال لـ[نظام Zig للبناء](#نظام-zig-للبناء):

<u>test.c</u>
```c
#include "mathtest.h"
#include <stdio.h>

int main(int argc, char **argv) {
    int32_t result = add(42, 1337);
    printf("%d\n", result);
    return 0;
}
```

<u>build.zig</u>
{{< zigdoctest "assets/zig-code/features/24-build.zig" >}}

```
$ zig build test
1379
```

## الترجمة المختلطة استخدام من الفئة الأولى

يمكن لـZig البناء لأي من المنصات في [جدول الدعم](#support-table) التي تصنف [كفئة ثالثة](#tier-3-support) أو أفضل. لا حاجة لتثبيت أي "سلسلة أدوات مختلطة" أو أي شيء من هذا القبيل. هذا مثال Hello World أصيل:

{{< zigdoctest "assets/zig-code/features/4-hello.zig" >}}

وهذا مثال لإختيار منصات x86_64-windows وx86_64-macos وaarch64-linux:
```
$ zig build-exe hello.zig -target x86_64-windows
$ file hello.exe
hello.exe: PE32+ executable (console) x86-64, for MS Windows
$ zig build-exe hello.zig -target x86_64-macos
$ file hello
hello: Mach-O 64-bit x86_64 executable, flags:<NOUNDEFS|DYLDLINK|TWOLEVEL|PIE>
$ zig build-exe hello.zig -target aarch64-linux
$ file hello
hello: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), statically linked, with debug_info, not stripped
```

هذا المثال يعمل على أي منصة من [الفئة الثالثة+](#tier-3-support)، لأي منصة مستهدفة من [الفئة الثالثة+](#tier-3-support).

### تُشحن Zig ومعها libc

يمكن تعديد أهداف libc المتاحة باستخدام `zig targets`:
```
...
 "libc": [
  "aarch64_be-linux-gnu",
  "aarch64_be-linux-musl",
  "aarch64_be-windows-gnu",
  "aarch64-linux-gnu",
  "aarch64-linux-musl",
  "aarch64-windows-gnu",
  "armeb-linux-gnueabi",
  "armeb-linux-gnueabihf",
  "armeb-linux-musleabi",
  "armeb-linux-musleabihf",
  "armeb-windows-gnu",
  "arm-linux-gnueabi",
  "arm-linux-gnueabihf",
  "arm-linux-musleabi",
  "arm-linux-musleabihf",
  "arm-windows-gnu",
  "i386-linux-gnu",
  "i386-linux-musl",
  "i386-windows-gnu",
  "mips64el-linux-gnuabi64",
  "mips64el-linux-gnuabin32",
  "mips64el-linux-musl",
  "mips64-linux-gnuabi64",
  "mips64-linux-gnuabin32",
  "mips64-linux-musl",
  "mipsel-linux-gnu",
  "mipsel-linux-musl",
  "mips-linux-gnu",
  "mips-linux-musl",
  "powerpc64le-linux-gnu",
  "powerpc64le-linux-musl",
  "powerpc64-linux-gnu",
  "powerpc64-linux-musl",
  "powerpc-linux-gnu",
  "powerpc-linux-musl",
  "riscv64-linux-gnu",
  "riscv64-linux-musl",
  "s390x-linux-gnu",
  "s390x-linux-musl",
  "sparc-linux-gnu",
  "sparcv9-linux-gnu",
  "wasm32-freestanding-musl",
  "x86_64-linux-gnu",
  "x86_64-linux-gnux32",
  "x86_64-linux-musl",
  "x86_64-windows-gnu"
 ],
 ```

وهذا يعني أن `library c--` لهذه المنصات *لا يعتمد على أي ملفات نظامية*!

لنفحص مثال [C hello world](#zig-أيضا-مترجم-للغة-c) مرة أخرى:
```
$ zig build-exe hello.c --library c
$ ./hello
Hello world
$ ldd ./hello
	linux-vdso.so.1 (0x00007ffd03dc9000)
	libc.so.6 => /lib/libc.so.6 (0x00007fc4b62be000)
	libm.so.6 => /lib/libm.so.6 (0x00007fc4b5f29000)
	libpthread.so.0 => /lib/libpthread.so.0 (0x00007fc4b5d0a000)
	libdl.so.2 => /lib/libdl.so.2 (0x00007fc4b5b06000)
	librt.so.1 => /lib/librt.so.1 (0x00007fc4b58fe000)
	/lib/ld-linux-x86-64.so.2 => /lib64/ld-linux-x86-64.so.2 (0x00007fc4b6672000)
```

لا تدعم [glibc](https://www.gnu.org/software/libc/) البناء بشكل ساكن، ولكن تدعم [musl](https://www.musl-libc.org/) ذلك:
```
$ zig build-exe hello.c --library c -target x86_64-linux-musl
$ ./hello
Hello world
$ ldd hello
  not a dynamic executable
```

في هذا المثال، بَنت Zig musl libc من كودها المصدري وربطت البرنامج بها. نسخة musl libc المبنية لـx86_64-linux ستبقى متاحة بفضل [نظام التخزين المؤقت](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching)، لذا فعندما نحتاج لهذه النسخة من libc مجددًا ستكون جاهزة للاستخدام في الحال.


مما يعني أن هذه الخاصية متاحة على كل المنصات. يستطيع مستخدمي Windows وmacOS بناء كود Zig وC، وربط برامجهم بlibc، لأي منصة مذكورة أعلاه. وبالمثل، يمكن ترجمة الكود بشكل مختلط لمعمارية أخرى:
```
$ zig build-exe hello.c --library c -target aarch64-linux-gnu
$ file hello
hello: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, for GNU/Linux 2.0.0, with debug_info, not stripped
```

من بعض النواحي، تعتبر Zig مترجم C أفضل من مترجمي C!

هذه الخاصية أكثر من مجرد شحن سلسلة أدوات للترجمة المختلطة مع Zig. مثلًا، المساحة الكُلّية دون ضغط لملفات libc التعريفية اللتي تُشحن مع Zig هي 22 MiB. بينما الملفات التعريفية الخاصة بmusl libc + Linux على x86_64 8 MiB و مساحة glibc 3.1 MiB (تفتقد glibc لملفات Linux التعريفية)، وZig تُشحن حاليًا ومعها 40 نسخة من libc. لو استخدمنا طريقة ساذجة لأصبح الحجم 444 MiB، ولكن بفضل [أداة process_headers](https://github.com/ziglang/zig/blob/0.4.0/libc/process_headers.zig) وبعض [المجهود اليدوي](https://github.com/ziglang/zig/wiki/Updating-libc)، فإن مساحة ملفات Zig الثنائية المضغوطة تبقى حوالي 30 MiB، على الرغم من دعمها لـlibc لكل هذه المنصات، بالإضافة لcompiler-rt وlibunwind وlibcxx وكونها مترجم للغة C متوافق مع Clang. للمقارنة فملف Clang 8.0.0 الثنائي من llvm.org حجمه 132 MiB.

لاحظ أن المنصات في [فئة الدعم الأولى](#tier-1-support) فقط هى التي تم اختبارها بعناية. من المخطط إضافة [المزيد من مكتبات libc](https://github.com/ziglang/zig/issues/514) (ويشمل هذا Windows)، و[إضافة اختبارات عند استعمال كل نسخ libc](https://github.com/ziglang/zig/issues/2058).

هنالك [خطة لإضافة مدير حزم Zig](https://github.com/ziglang/zig/issues/943)، ولكنها لم تكتمل بعد. إحدى الإمكانيات ستكون عمل حزمة لمكتبات C، مما سيجعل [نظان بناء Zig](#نظام-zig-للبناء) جذابًا لمبرجي Zig وC على السواء.

## نظام Zig للبناء

تأتي Zig بنظام بناء مدمج، فلا حاجة لmake أو cmake أو أيًا من تلك الأشياء.
```
$ zig init-exe
Created build.zig
Created src/main.zig

Next, try `zig build --help` or `zig build run`
```

<u>src/main.zig</u>
{{< zigdoctest "assets/zig-code/features/25-all-bases.zig" >}}


<u>build.zig</u>
{{< zigdoctest "assets/zig-code/features/26-build.zig" >}}

لنفحص قائمة `help--` لعرض المساعدة.
```
$ zig build --help
Usage: zig build [steps] [options]

Steps:
  install (default)      Copy build artifacts to prefix path
  uninstall              Remove build artifacts from prefix path
  run                    Run the app

General Options:
  --help                 Print this help and exit
  --verbose              Print commands before executing them
  --prefix [path]        Override default install prefix
  --search-prefix [path] Add a path to look for binaries, libraries, headers

Project-Specific Options:
  -Dtarget=[string]      The CPU architecture, OS, and ABI to build for.
  -Drelease-safe=[bool]  optimizations on and safety on
  -Drelease-fast=[bool]  optimizations on and safety off
  -Drelease-small=[bool] size optimizations on and safety off

Advanced Options:
  --build-file [file]         Override path to build.zig
  --cache-dir [path]          Override path to zig cache directory
  --override-lib-dir [arg]    Override path to Zig lib directory
  --verbose-tokenize          Enable compiler debug output for tokenization
  --verbose-ast               Enable compiler debug output for parsing into an AST
  --verbose-link              Enable compiler debug output for linking
  --verbose-ir                Enable compiler debug output for Zig IR
  --verbose-llvm-ir           Enable compiler debug output for LLVM IR
  --verbose-cimport           Enable compiler debug output for C imports
  --verbose-cc                Enable compiler debug output for C compilation
  --verbose-llvm-cpu-features Enable compiler debug output for LLVM CPU features
```

لاحظ أن أحد الخيارات الموجودة هو run الذي يقوم بإطلاق البرنامج.
```
$ zig build run
All your base are belong to us.
```

هذه بعض الأمثلة لنصوص بناء:

- [نص بناء لعبة Tetris تستخدم OpenGL](https://github.com/andrewrk/tetris/blob/master/build.zig)
- [نص بناء للعبة على Rasperrby Pi 3](https://github.com/andrewrk/clashos/blob/master/build.zig)
- [نص بناء مترجم Zig المستقل](https://github.com/ziglang/zig/blob/master/build.zig)

## التواقت عن طريق الوظائف غير المتزامنة

Zig 0.5.0 [قدمت الوظائف غير المتزامنة](https://ziglang.org/download/0.5.0/release-notes.html#Async-Functions). ليست لهذه الميزة أي اعتماديات على نظام التشغيل أو حتى ذاكرة مخصصة من الكومة، مما يعني أن الوظائف غير المتزامنة متاحة للمنصات القائمة بذاتها.

تستنبط Zig إذا ما كانت وظيفة ما غير متزامنة، وتسمح ب `async`/`await` مع الوظائف المتزامنة، ممع يعني أن مكتبات Zig **لا تعبأ بنظام المدخلات والمخرجات، سواء كان يستعمل الحظر أو عدم التزامن.** [تتجنب Zig ألوان الوظائف](http://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/).

تطبق مكتبة Zig الأساسية حلقة أحداث تداول بين الوظائف غير المتزامنة في مَجمع سلاسل لتحقيق تواقت من نوع M:N. تحقيق الأمان ومنع التسابق في حالة تعدد السلاسل موضع أبحاث جارية.

## العديد من المنصات المتوفرة للاستهداف

تعتمد Zig نظام "فئات الدعم" لتوضيح مستوى الدعم للمنصات المختلفة.

[جدول الدعم المعتمد لنسخة Zig 0.8.0](/download/0.8.0/release-notes.html#Support-Table)

## متعاونون مع القائمون على صيانة الحِزم

مترجم Zig القياسي ليس مستقل بالكامل بعد، ولكن مهما يكن، [فسيحتاج البناء بالضبط 3 خطوات](https://github.com/ziglang/zig/issues/853). كما ذكرت مايا راشيش، فإن [نقل Zig لمنصات أخرى أمر مسل وسريع](http://coypu.sdf.org/porting-zig.html).

[أطوار البناء](https://ziglang.org/documentation/master/#Build-Mode) غير ذات رموز التشخيص حتمية وقابلة للتكرار.

توجد [نسخة JSON من صفحة التحميل](/download/index.json).

لدى العديد من أعضاء فريق Zig خبرة في صيانة الحِزم.

- [Daurnimator](https://github.com/daurnimator) يصون [حزمة Arch Linux](https://www.archlinux.org/packages/community/x86_64/zig/)
- [Marc Tiehuis](https://tiehuis.github.io/) يصون حزمة Visual Studio Code.
- أمضى [Andrew Kelley](https://andrewkelley.me/) عامًا أو أكثر في [صيانة حزم Debian وUbuntu](https://qa.debian.org/developer.php?login=superjoe30%40gmail.com&comaint=yes), ويساهم بشكل غير دوري في [nixpkgs](https://github.com/NixOS/nixpkgs/).
- [Jeff Fowler](https://blog.jfo.click/) يصون حزمة Homebrew وبدأ [حزمة Sublime](https://github.com/ziglang/sublime-zig-language) (يصونها حاليًا [emekoi](https://github.com/emekoi)).
