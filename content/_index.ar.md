---
title: الرئيسية
mobile_menu_title: "الرئيسية"
---
{{< slogan get_started="ابدأ" docs="الوثائق" notes="التغييرات" lang="ar" >}}
Zig هي لغة برمجة متعددة الأغراض وسلسلة أدوات لصنع برمجيات **قوية**، و**مثالية** ويمكن **إعادة استخدمها**.
{{< /slogan >}}

{{< flexrow class="container" style="padding: 20px 0; justify-content: space-between;" >}}
{{% div class="features" %}}

# ⚡ لغة بسيطة
تفرغ لتصحيح أخطاء برنامجك بدلًا من تصحيح معرفتك بلغة البرمجة.

- لا تحكمات مخفية في التدفّق.
- لا تخصيصات مخفية للذاكرة.
- لا معالج تمهيدي، ولا وحدات ماكرو.

# ⚡ Comptime
طريقة مبتكرة للبرمجة الوصفية معتمدة على تنفيذ التعليمات في زمن التصريف والتقييم الكسول.

- قم باستدعاء أي وظيفة في زمن التصريف.
- تعامل مع الأنواع كقيم بدون تكاليف غير مباشرة في زمن التنفيذ.
- Comptime تحاكي المعمارية المختارة.

# ⚡ أداء وسرعة
اكتب كود سريع، وواضح وقادر على التعامل مع جميع أنواع الأخطاء.

- ترشدك اللغة للتعامل الأمثل مع الأخطاء.
- تساعدك فحوصات زمن التشغيل القالبة للإعداد على الموازنة بين الأداء وضمانات الأمان.
- استفد من الصفوف النوعية لتعبر عن تعليمات SIMD بشكل نقال.

{{% flexrow style="justify-content:center;" %}}
{{% div %}}
<h1>
    <a href="learn/overview/" class="button" style="display: inline;">نظرة عامة متعمقة</a>
</h1>
{{% /div %}}
{{% div  style="margin-left: 5px;" %}}
<h1>
    <a href="learn/samples/" class="button" style="display: inline;">أمثلة كود أخرى</a>
</h1>
{{% /div %}}
{{% /flexrow %}}
{{% /div %}}
{{< div class="codesample" >}}

{{% zigdoctest "assets/zig-code/index.zig" %}}

{{< /div >}}
{{< /flexrow >}}


{{% div class="alt-background" %}}
{{% div class="container"  style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="المجتمع" %}}

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div style="width:25%" %}}
<img src="/ziggy.svg" style="max-height: 200px; transform: scaleX(-1)">
{{% /div %}}

{{% div class="community-message" %}}
# مجتمع Zig غير مركزي
يمكن لأي شخص أن يبدأ مساحة تواصل خاصة به.
لا وجود لمجتمعات "رسمية" و"غير رسمية"، ولكن لكل تجمع مشرفينه وقوانينه الخاصة به.

<div style="">
<h1>
	<a href="https://github.com/ziglang/zig/wiki/Community" class="button" style="display: inline;">عرض كل المجتمعات</a>
</h1>
</div>
{{% /div %}}
{{< /flexrow >}}
<div style="height: 50px;"></div>

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div class="main-development-message" %}}
# التطوير الرئيسي
مصدر Zig الأصلي موجود في [https://github.com/ziglang/zig](https://github.com/ziglang/zig) حيث نقوم ايضًا بمتابعة المشاكل ومناقشة الاقترحات.
يتوقع من المشاركين أن يتبعوا [قواعد سلوك Zig](https://github.com/ziglang/zig/blob/master/.github/CODE_OF_CONDUCT.md).
{{% /div %}}
{{% div style="width:40%" %}}
<img src="/zero.svg" style="max-height: 200px; transform: scaleX(-1)">
{{% /div %}}
{{< /flexrow >}}
{{% /div %}}
{{% /div %}}


{{% div class="container" style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="مؤسسة Zig للبرمجيات" %}}
## مؤسسة Zig للبرمجيات (ZSF) هي مؤسسة (3)(c)501 غير ربحية

مؤسسة Zig للبرمجيات مؤسسة غير هادفة للربح، أسسها أندرو كيلي، مؤلف لغة Zig في 2020، بهدف دعم تطوير اللغة. حاليًا، المؤسسة قادرة على توفير عمل مدفوع الأجر لعدد محدود من المساهمين الأساسيين. نأمل أن نستطيع التوسع في توفير المزيد من هذه الفرص لمساهمين أكثر في المستقبل.

مؤسسة Zig للبرمجيات قائمة على التبرعات.

<h1>
	<a href="zsf/" class="button" style="display:inline;">المزيد</a>
</h1>
{{% /div %}}


{{< div class="alt-background" style="padding: 20px 0;">}}
{{% div class="container" title="الرعاة" %}}
# الجهات الراعية
الشركات التالية توفر دعم مادي مباشر لمؤسسة Zig للبرمجيات (ZSF).

{{% sponsor-logos "monetary" %}}
 <a href="https://pex.com" rel="noopener nofollow" target="_blank"><picture>
   <picture>
     <source srcset="/pex-white.svg" media="(prefers-color-scheme: dark)">
     <img src="/pex-dark.svg">
   </picture>
 </a> 
 <a href="https://coil.com" rel="noopener nofollow" target="_blank"><picture>
   <picture>
     <source srcset="/coil-logo-white.svg" media="(prefers-color-scheme: dark)">
     <img src="/coil-logo-black.svg">
   </picture>
 </a>
{{% /sponsor-logos %}}

# رعاة GitHub
 بفضل كل من [يدعم Zig](zsf/)، فالمشروع ملك لمجتمع البرمجيات مفتوحة المصدر وليس للشركات الراعية. تحديدًا، هذه القائمة هي لأفراد يدعمون Zig بـ200$ شهريًا أو أكثر:

{{< ghsponsors >}}

يتم تحديث هذا القسم مع بداية كل شهر.
{{% /div %}}
{{< /div >}}
