---
title: ابدأ هنا
mobile_menu_title: "ابدأ هنا"
toc: true
---

## إصدار موسوم أم نسخة بناء ليلية؟
لم تصل Zig لنسخة 1.0 بعد ودورة الإصدارات الحالية مرتبطة بالإصدارات الجديدة من LLVM التي تصدر حوالي مرة كل 6 أشهر.
بصورة عملية، **فإصدارات Zig عادة ما تكون على فترات متباعدة وسرعان أن تصبح بائتة نظرًا لسرعة التطوير**.

لا بأس بتجربة Zig باستعمال نسخة موسومة، ولكن إذا أعجبتك وتريد أن تتعمق أكثر، فنحن **نشجعك أن ترتقي لنسخة البناء اليلية**، تحديدًا لأنها ستسهل عليك طلب المساعدة: معظم أعضاء المجتمع والمواقع مثل [ziglearn.org](https://ziglearn.org) تستعمل الفرع الرئيسي للأسباب المذكورة أعلاه.

لحسن الحظ فالتحويل بين نسخ Zig المختلفة سهل للغاية، بل أن بإمكانك أن تحتفظ بأكثر من نسخة على الجهاز الواحد في نفس الوقت: إصدارات Zig هي أرشيفات مكتفية بذاتها يمكنك تخزينها في أي مكان على جهازك.


## تثبيت Zig
### تحميل مباشر
هذه أبسط طريقة للحصول على Zig: انتق حزمة منصتك من صفحة [التحميل](/download)، واستخرج الملفات في دليل ما وقم بإضافته للـ`PATH` الخاص بك كي تستطيع أن تستدعي أمر `zig` من أي مكان.

#### إعداد PATH على Windows
لإعداد المسار على Windows قم بتنفيذ **واحدًا** من القصاصات التالية في Powershell.
اختر إذا كنت تريد تعميم هذا الإعداد على مستوى النظام (يتطلب هذا تشغيل Powershell بامتيازات مدير النظام) أو ضبطه للمستخدم الحالي، **وتأكد من تعديل القصاصة لتشير إلى مسار نسختك من Zig**.
الـ`;` قبل `C:` ليست خطأ مطبعيًا.

مستوى النظام (Powershell **مدير النظام**):
```
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "Machine") + ";C:\your-path\zig-windows-x86_64-your-version",
   "Machine"
)
```

مستوى المستخدم (Powershell):
```
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\your-path\zig-windows-x86_64-your-version",
   "User"
)
```
عندما تنتهي، قم بإعادة تشغيل Powershell.

#### إعداد PATH على Linux أو macOS أو BSD
أضف مسار Zig الخاص بك للمتغيّر البيئي PATH.

عادة ما يتم عمل ذلك بإضافة سطر تصدير لنص القشرة الإبتدائي (`.profile`، `.zshrc`، ...)
```bash
export PATH=$PATH:~/path/to/zig
```
بعد الإنتهاء، إما أن تنفذ أمر `source` على الملف أو أعد تشغيل القشرة.




### مديري الحزم
#### Windows
Zig متوفرة على [Chocolatey](https://chocolatey.org/packages/zig).
```
choco install zig
```

#### macOS

**Homebrew**
أحدث إصدار موسوم:
```
brew install zig
```

**MacPorts**
```
port install zig
```
#### Linux
Zig أيضًا موجودة عند العديد من مديري الحزم على Linux. [هنا](https://github.com/ziglang/zig/wiki/Install-Zig-from-a-Package-Manager) يمكنك العثور على قائمة محدثة ولكن كن حذرًا فبعض الحزم قد تتضمن نسخًا بالية من Zig.

### البناء من المصدر
[هنا](https://github.com/ziglang/zig/wiki/Building-Zig-From-Source) يمكنك الإطلاع على معلومات لبناء Zig من المصدر لLinux، وmacOS، وWindows.

## الأدوات الموصى بها
### مبرزي الصياغة وخواديم اللغة
كل محررات النصوص الأساسية تدعم إبراز صياغة Zig.
بعضهم يدمج الدعم بينما يحتاج البعض الاخر لتثبت ملحق.

إذا كنت مهتمًا بإندماج أعمق بين Zig ومحررك، تفقد [zigtools/zls](https://github.com/zigtools/zls).

إذا كنت مهتمًا بمعرفة بما هو متاح بالإضافة لما تم ذكره، قم بزيارة قسم [الأدوات](../tools/).

## نفذ Hello World
إذا أتممت عملية التثبت بشكل صحيص، يمكنك الآن أن تستدعي مترجم Zig من القشرة.
لنتأكد من ذلك عن طريق عمل أول برنامج Zig!

إذهب إلى مسار مشاريعك ونفذ:
```bash
mkdir hello-world
cd hello-world
zig init-exe
```

من المفترض أن يطبع ذلك:
```
info: Created build.zig
info: Created src/main.zig
info: Next, try `zig build --help` or `zig build run`
```

إستدعاء `zig build run` سوف يقوم بترجمة المصدر وبناء الملف التنفيذي وتنفيذه، مما سيطبع:
```
info: All your codebase are belong to us.
```

مبروك، أنت الآن تمتلك بيئة Zig مثبتة بشكل صحيح!

## الخطوات التالية
**تفقد الموارد الأخرى في قسم [التعلم](../)**، طالع الوثائق المطابقة لنسختك من Zig (ملحوظة: نسخ البناء الليلية تستعمل وثائق `master`) وفكر في أن تقرأ [ziglearn.org](https://ziglearn.org).

Zig مشروع حديث النشأة وللأسف ليس لدينا السعة اللازمة لعمل وثائق مُفصّلة وموارد لتعلم كل شيء، لذلك فكر في [الإنضمام لأحد مجتمعات Zig](https://github.com/ziglang/zig/wiki/Community) لتجد من يمد لك يد العون وقت الحاجة، وتفقد أيضًا المبادرات مثل [Zig SHOWTIME](https://zig.show).

وأخيرًا، إذا استمتعت بZig وتريد الإسراع من تطويرها، [فكر في التبرع لمؤسسة Zig للبرمجيات](../../zsf)
<img src="/heart.svg" style="vertical-align:middle; margin-inline-end: 5px">.
