---
title: خانه
mobile_menu_title: "خانه"
---

{{< slogan get_started="شروع" docs="مستندات" notes="تغییرات" lang="fa" >}}
Zig یک زبان همه منظوره و ابزاری برای نگهداری نرم افزار های قدرتمند، بهینه و قابل استفاده مجدد است.
{{< /slogan >}}

{{< flexrow class="container" style="padding: 20px 0; justify-content: space-between;" >}}
{{% div class="features" %}}

# ⚡ یک زبان ساده

به جای اشکال زدایی زبان برنامه نویسی، بر اشکال زدایی برنامه خود تمرکز کنید.

-   بدون جریان کنترل پنهان.
-   بدون تخصیص حافظه مخفی.
-   بدون پیش پردازنده، بدون ماکرو.

# ⚡ زمان اجرا

یک رویکرد تازه برای برنامه نویسی متا (Meta Prgoramming) بر اساس اجرای کد Comptime و ارزیابی تنبل.

-   هر فانکشنی را در Comptime فرابخوانید.
-   تایپ ها را به عنوان مقادیر بدون runtime اضافی تغییر دهید.
-   Comptime معماری هدف را شبیه سازی می کند.

# ⚡ سرعت و امنیت

کد سریع و واضحی بنویسید که بتواند همه شرایط خطا را مدیریت کند.

-   Zig با ظرافت منطق مدیریت خطای شما را هدایت میکند.
-   بررسی های runtime قابل تنظیم به شما کمک می کند تا بین سرعت و ایمنی تعادل برقرار کنید.
-   برای بیان دستورالعمل های SIMD به صورت قابل حمل از انواع بردار استفاده کنید.
-   از بردار ها (vector) برای دستورالعمل های SIMD قابل حمل بهره ببرید.

{{% flexrow style="justify-content:center;" %}}
{{% div %}}

<h1>
    <a href="learn/overview/" class="button" style="display: inline;">مرور عمیق</a>
</h1>
{{% /div %}}
{{% div  style="margin-left: 5px;" %}}
<h1>
    <a href="learn/samples/" class="button" style="display: inline;">نمونه کد های بیشتر</a>
</h1>
{{% /div %}}
{{% /flexrow %}}
{{% /div %}}
{{< div class="codesample" >}}

{{% zigdoctest "assets/zig-code/index.zig" %}}

{{< /div >}}
{{< /flexrow >}}

{{% div class="alt-background" %}}
{{% div class="container"  style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="انجمن" %}}

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div style="width:25%" %}}
<img src="/ziggy.svg" style="max-height: 200px">
{{% /div %}}

{{% div class="community-message" %}}

# انجمن Zig غیر متمرکز است

هرکسی آزاد است تا فضای شخصی خود را برای انجمن ایجاد و حفظ کند.
هیچ مفهومی از "رسمی" یا "غیر رسمی" وجود ندارد، با این حال، هر مکان مدیر ها و قوانین خاص خود را دارد.

<div style="">
<h1>
	<a href="https://github.com/ziglang/zig/wiki/Community" class="button" style="display: inline;">همه انجمن ها را ببینید</a>
</h1>
</div>
{{% /div %}}
{{< /flexrow >}}
<div style="height: 50px;"></div>

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div class="main-development-message" %}}

# توسعه اصلی

میتوانید مخزن Zig را در [https://github.com/ziglang/zig](https://github.com/ziglang/zig) پیدا کنید, جایی که ما ایشو ها را دنبال میکنیم و در مورد پیشنهادات بحث میکنیم.
ما انتظار داریم مشارکت کننده ها [قانون کد](https://github.com/ziglang/zig/blob/master/.github/CODE_OF_CONDUCT.md) را بخوانند.
{{% /div %}}
{{% div style="width:40%" %}}
<img src="/zero.svg" style="max-height: 200px">
{{% /div %}}
{{< /flexrow >}}
{{% /div %}}
{{% /div %}}

{{% div class="container" style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="بنیاد نرم افزار Zig" %}}

## ZSF یک کمپانی غیر انتفاعی بر اساس 501(c)(3) است.

بنیاد نرم افزاری Zig یک شرکت غیرانتفاعی است که در سال 2020 توسط اندرو کلی، خالق Zig، با هدف حمایت از توسعه زبان تأسیس شد. در حال حاضر، ZSF قادر است کارهای پولی را با نرخ رقابتی به تعداد کمی از مشارکت کنندگان اصلی ارائه دهد. امیدواریم بتوانیم این پیشنهاد را در آینده به مشارکت کنندگان اصلی تر نیز بسط دهیم.

بنیاد نرم افزاری Zig با کمکهای مالی حمایت می شود.

<h1>
	<a href="zsf/" class="button" style="display:inline;">بیشتر بدانید</a>
</h1>
{{% /div %}}

{{< div class="alt-background" style="padding: 20px 0;">}}
{{% div class="container" title="Sponsors" %}}

# حامیان مالی شرکت ها

شرکتهای زیر مستقیماً از بنیاد نرم افزار Zig پشتیبانی مالی می کنند.

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

# اسپانسر های گیت هاب

ممنونیم از کسانی که [اسپانسر Zig](zsf/) بودند، پروژه به جای سهامداران شرکت، به جامعه منبع باز پاسخگو است. به طور خاص، این افراد خوب با 200 دلار در ماه یا بیشتر از Zig حمایت می کنند:

{{< ghsponsors >}}

این قسمت هر ماه بروزرسانی میشود.
{{% /div %}}
{{< /div >}}
