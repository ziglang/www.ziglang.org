---
title: "بررسی عمیق"
mobile_menu_title: "بررسی"
toc: true
---
# قابلیت های برجسته
## زبانی کوچک و ساده

به جای اشکال زدایی دانش زبان برنامه نویسی، بر اشکال زدایی برنامه خود تمرکز کنید.

سینتکس Zig در یک [گرامر ۵۰۰ خطی PEG](https://ziglang.org/documentation/master/#Grammar) مشخص شده است.

**بدون جریان کنترل پنهان**، بدون تخصیص حافظه پنهان، بدون پیش پردازنده و بدون ماکرو. اگر کدی در زیگ به نظر نمی رسد که برای فراخوانی یک تابع به سرعت پرش می کند، پس اینطور نیست. این بدان معناست که می توانید مطمئن باشید که کد زیر فقط `foo()` و سپس `bar()` را فرا می خواند، و این بدون نیاز به دانستن هر چیزی تضمین می شود:

```zig
var a = b + c.d;
foo();
bar();
```

نمونه هایی از کنترل پنهان:

- D دارای توابع `@property` است، روش هایی که شما با دسترسی به فیلد تماس می گیرید، بنابراین در مثال بالا،` c.d` ممکن است یک تابع را فراخوانی کند.
- C++، D و Rust دارای دوباره نویسی اپراتور هستند، بنابراین عملگر `+` ممکن است یک تابع را فراخوانی کند.
- C++،D و Go دارای استثناء throw/catch هستند، بنابراین ممکن است `foo()` یک استثناء ایجاد کند و از فراخوانی` bar()` جلوگیری کند.

Zig با مدیریت کل جریان کنترل منحصراً با کلمات کلیدی زبان و فراخوانی تابع، نگهداری و خوانایی کد را ارتقا می بخشد.

## عملکرد و ایمنی: هر دو را انتخاب کنید

Zig دارای چهار [حالت ساخت](https://ziglang.org/documentation/master/#Build-Mode) است، و همه آنها را می توان مخلوط کرده و تا سطح [دانه بندی محدوده](https://ziglang.org/documentation/master/#setRuntimeSafety) مطابقت داد.

| پارامتر | [اشکال زدایی](/documentation/master/#Debug) | [انتشار امن](/documentation/master/#ReleaseSafe) | [انتشار سریع](/documentation/master/#ReleaseFast) | [انتشار کوچک](/documentation/master/#ReleaseSmall) |
|-----------|-------|-------------|-------------|--------------|
**بهینه سازی ها** : افزایش سرعت، صدمه به اشکال زدایی، صدمه به  compile time | | -O3 | -O3| -Os |
**بررسی ایمنی Runtime** : صدمه به سرعت، صدمه به اندازه، کرش به جای رفتار نامشخص | On | On | | |

این چیزی است که [عدد صحیح اضافی](https://ziglang.org/documentation/master/#Integer-Overflow) در Comptime به نظر میرسد، صرف نظر از حالت ساخت:

{{< zigdoctest "assets/zig-code/features/1-integer-overflow.zig" >}}

Runtime در build های دارای ایمنی:

{{< zigdoctest "assets/zig-code/features/2-integer-overflow-runtime.zig" >}}


این [آثار stack روی همه اهداف کار می کند](#stack-traces-on-all-targets)، شامل [freestanding](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html).

با Zig می توان به یک حالت ساخت مجهز به ایمنی اعتماد کرد و به طور انتخابی ایمنی را در تنگناهای عملکرد غیرفعال کرد.مثلا مثال قبلی می تواند به این شکل اصلاح شود:

{{< zigdoctest "assets/zig-code/features/3-undefined-behavior.zig" >}}

زیگ از [رفتار تعریف نشده](https://ziglang.org/documentation/master/#Undefined-Bhavior) به عنوان یک ابزار تیغ تیز برای پیشگیری از اشکال و افزایش عملکرد استفاده می کند.

در بحث از عملکرد،Zig سریعتر از C است.

- پیاده سازی مرجع از LLVM به عنوان پشتیبان برای بهینه سازی های پیشرفته استفاده می کند.
- آنچه پروژه های دیگر "بهینه سازی LinkTime" می نامند Zig به طور خودکار انجام می دهد.
- برای اهداف بومی، ویژگیهای پیشرفته CPU (-march = native) فعال است، به این دلیل که [Cross-compiling در اولویت است](#cross-compiling-در-اولویت-است).
- با دقت رفتارهای تعریف نشده را انتخاب کنید. به عنوان مثال، در Zig هر دو عدد صحیح امضا شده و بدون علامت دارای رفتار نامشخصی در سرریز هستند، در مقابل فقط اعداد صحیح امضا شده در C. این [بهینه سازی هایی را که در C موجود نیستند تسهیل می کند](https://godbolt.org/z/n_nLEU).
- زیگ مستقیماً [یک نوع بردار SIMD](https://ziglang.org/documentation/master/#Vectors) را نشان می دهد، که نوشتن کد بردار قابل حمل را آسان می کند.

لطفاً توجه داشته باشید که زیگ یک زبان کاملاً امن نیست. برای کسانی که علاقمندند داستان ایمنی زیگ را دنبال کنند، در این ایشو ها مشترک شوید:

- [enumerate all kinds of undefined behavior, even that which cannot be safety-checked](https://github.com/ziglang/zig/issues/1966)
- [make Debug and ReleaseSafe modes fully safe](https://github.com/ziglang/zig/issues/2301)

## Zig به جای وابستگی به C با آن رقابت میکند

کتابخانه استاندارد Zig با libc ادغام می شود، اما به آن وابسته نیست. این نمونه `Hello World` است:

{{< zigdoctest "assets/zig-code/features/4-hello.zig" >}}

هنگامی که با `-O ReleaseSmall` علامت های اشکال زدایی برداشته می شوند و حالت تک رشته ای ایجاد می شود، Zig فایل اجرایی 9.8 KiB برای هدف x86_64-linux تولید می کند:
```
$ zig build-exe hello.zig -O ReleaseSmall -fstrip -fsingle-threaded
$ wc -c hello
9944 hello
$ ldd hello
  not a dynamic executable
```

این build در ویندوز حتی کوچک تر است و به 4KB میرسد:
```
$ zig build-exe hello.zig -O ReleaseSmall -fstrip -fsingle-threaded -target x86_64-windows
$ wc -c hello.exe
4096 hello.exe
$ file hello.exe
hello.exe: PE32+ executable (console) x86-64, for MS Windows
```

## ترتیب مستقل اعلام (declaration) های سطح بالا

بیانیه های سطح بالا مانند متغیرهای جهانی مستقل از نظم هستند و با تنبلی تجزیه و تحلیل می شوند. مقادیر مقداردهی اولیه متغیرهای جهانی [در Comptime ارزیابی می شوند](#compile-time-reflection-and-compile-time-code-execution).

{{< zigdoctest "assets/zig-code/features/5-global-variables.zig" >}}

## تایپ اختیاری به جای اشاره گرهای تهی

در سایر زبانهای برنامه نویسی، مراجع تهی منبع بسیاری از استثنائات زمان اجرا هستند و حتی به عنوان [بدترین اشتباه علوم کامپیوتر](https://www.lucidchart.com/techblog/2015/08/31/the-worst-mistake-of-computer-science/) متهم می شوند.

اشاره گرهای Zig تزئین نشده نمی توانند خالی باشند:

{{< zigdoctest "assets/zig-code/features/6-null-to-ptr.zig" >}}

با این حال هر نوع را می توان با یک `?` تبدیل به [نوع اختیاری](https://ziglang.org/documentation/master/#Optionals) کرد:

{{< zigdoctest "assets/zig-code/features/7-optional-syntax.zig" >}}

برای باز کردن یک مقدار اختیاری، می توان از `orelse` برای ارائه مقدار پیش فرض استفاده کرد:

{{< zigdoctest "assets/zig-code/features/8-optional-orelse.zig" >}}

راه حل بعدی استفاده از `if` است:

{{< zigdoctest "assets/zig-code/features/9-optional-if.zig" >}}

همچنین این سینتکس با [while](https://ziglang.org/documentation/master/#while) هم قابل استفاده است:

{{< zigdoctest "assets/zig-code/features/10-optional-while.zig" >}}

## مدیریت دستی مموری

کتابخانه ای که به زبان زیگ نوشته شده است، می تواند در هر مکانی مورد استفاده قرار گیرد:

- [نرم افزار های دسکتاپ](https://github.com/TM35-Metronome/)
- سرورهای با تاخیر کم
- [کرنل سیستم هامل ها](https://github.com/AndreaOrru/zen)
- [دستگاه های Embedded](https://github.com/skyfex/zig-nrf-demo/)
- نرم افزارهای در لحظه (Real-time)، به عنوان مثال اجرای زنده، هواپیما، ضربان ساز
- [در مرورگرهای وب یا سایر افزونه ها با WebAssembly](https://shritesh.github.io/zigfmt-web/)
- با استفاده از سایر زبان های برنامه نویسی، از C ABI استفاده کنید

به منظور دستیابی به این هدف، برنامه نویسان Zig باید حافظه خود را مدیریت کنند و باید خرابی تخصیص حافظه را برطرف کنند.

این امر در مورد کتابخانه استاندارد زیگ نیز صادق است. هر عملکردی که نیاز به تخصیص حافظه دارد یک پارامتر اختصاص دهنده را می پذیرد. در نتیجه، کتابخانه استاندارد زیگ حتی می تواند برای اهداف مستقل مورد استفاده قرار گیرد.

علاوه بر [نگاهی تازه به مدیریت خطا](#a-fresh-take-on-error-handling)، Zig [defer](https://ziglang.org/documentation/master/#defer) و [errdefer](https://ziglang.org/documentation/master/#errdefer)  را ارائه میدهد. که برای مدیریت همه منابع ( نه تنها حافظه ) ساده و به راحتی قابل تأیید است.

برای یک مثال `defer`، [ادغام با کتابخانه های C بدون FFI/bindings](#integration-with-c-libraries-without-ffibindings) را ببینید.
اینجا یک مثال `errdefer` موجود است:
{{< zigdoctest "assets/zig-code/features/11-errdefer.zig" >}}


## نگاهی تازه به مدیریت خطا

خطاها یک مقدار هستند و نمی توان آنها را نادیده گرفت:

{{< zigdoctest "assets/zig-code/features/12-errors-as-values.zig" >}}

خطا ها با [catch](https://ziglang.org/documentation/master/#catch) قابل رسیدگی هستند:

{{< zigdoctest "assets/zig-code/features/13-errors-catch.zig" >}}

کلمه [try](https://ziglang.org/documentation/master/#try) یک شرتکات برای `catch |err| return err` است:

{{< zigdoctest "assets/zig-code/features/14-errors-try.zig" >}}

توجه داشته باشید که یک [خطای بازگشت](https://ziglang.org/documentation/master/#Error-Return-Traces) است، نه یک [رد در استک](#stack-traces-on-all-target). کد هزینه باز کردن استک را برای رسیدن به آن چیزی که میخواهد پرداخت نکرده است.

کلمه [switch](https://ziglang.org/documentation/master/#switch) مورد استفاده در خطا اطمینان می دهد که همه خطاهای احتمالی مدیریت می شوند:

{{< zigdoctest "assets/zig-code/features/15-errors-switch.zig" >}}

از کلمه [unreachable](https://ziglang.org/documentation/master/#unreachable) برای تأیید اینکه هیچ خطایی رخ نمی دهد استفاده می شود:

{{< zigdoctest "assets/zig-code/features/16-unreachable.zig" >}}

[رفتار نامشخص](#عملکرد-و-ایمنی:-هر-دو-را-انتخاب-کنید) را در حالت های build ناامن فرا خوانده میشود، بنابراین مطمئن شوید که فقط در مواقعی که موفقیت تضمین شده است از آن استفاده کنید.

### ردگیری استک روی همه اهداف

رد استک نشان داده شده در این صفحه [error return traces](https://ziglang.org/documentation/master/#Error-Return-Traces) روی همه [ردیف پشتیبانی 1](#ردیف-پشتیبانی-1) و برخی از اهداف [ردیف پشتیبانی 2](#ردیف-پشتیبانی-2) کار میکند. [حتی freestanding](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html)!

علاوه بر این، کتابخانه استاندارد این قابلیت را دارد که یک رد استک را در هر نقطه ضبط کرده و سپس بعداً آن را به خطای استاندارد منتقل کند.:

{{< zigdoctest "assets/zig-code/features/17-stack-traces.zig" >}}

میتوانید مشاهده کنید که این تکنیک در [پروژه GeneralPurposeDebugAllocator](https://github.com/andrewrk/zig-general-purpose-allocator/#current-status).

## ساختار های جنریک و فانکشن ها

تایپ ها مقادیری هستند که باید در زمان کامپایل شناخته شوند:

{{< zigdoctest "assets/zig-code/features/18-types.zig" >}}

یک ساختار داده عمومی فقط یک تابع است که یک را بر می گرداند`type` را برمیگرداند:

{{< zigdoctest "assets/zig-code/features/19-generics.zig" >}}

## بازتاب Comptime و اجرای کد Comptile

تابع توکار (builtin) [@typeInfo](https://ziglang.org/documentation/master/#typeInfo) از بازتاب پشتیبانی میکند:

{{< zigdoctest "assets/zig-code/features/20-reflection.zig" >}}

کتابخانه استاندارد Zig از این تکنیک برای اجرای چاپ فرمت استفاده می کند. با وجود اینکه یک زبان [کوچک و ساده](#زبانی-کوچک-و-ساده) است، چاپ فرمت شده به طور کامل در Zig اجرا می شود. در همین حال، در C، خطاهای کامپایل برای printf به سختی در کامپایلر کدگذاری می شوند. به طور مشابه، در Rust، ماکرو چاپ فرمت شده به سختی در کامپایلر کدگذاری می شود.

Zig همچنین می تواند توابع و بلوک های کد را در زمان کامپایل ارزیابی کند. در برخی زمینه ها، مانند مقداردهی اولیه متغیر جهانی، عبارت به طور ضمنی در زمان کامپایل ارزیابی می شود. در غیر این صورت، می توان صراحتاً کد را در زمان کامپایل با کلید واژه [comptime](https://ziglang.org/documentation/master/#comptime) ارزیابی کرد. این امر به ویژه هنگامی که با ادعاها ترکیب شود می تواند بسیار قدرتمند باشد:

{{< zigdoctest "assets/zig-code/features/21-comptime.zig" >}}

## ادغام با کتابخانه های C بدون FFI/bindings

[@cImport](https://ziglang.org/documentation/master/#cImport) به طور مستقیم انواع، متغیرها، توابع و ماکروهای ساده را برای استفاده در Zig وارد می کند. حتی توابع داخلی را از C به Zig ترجمه می کند.

در اینجا نمونه ای از انتشار موج سینوسی با استفاده از [libsoundio](http://libsound.io/) موجود است:

<u>sine.zig</u>
{{< zigdoctest "assets/zig-code/features/22-sine-wave.zig" >}}

```
$ zig build-exe sine.zig -lsoundio -lc
$ ./sine
Output device: Built-in Audio Analog Stereo
^C
```

[این کد زیگ به طور قابل توجهی ساده تر از کد C معادل است](https://gist.github.com/andrewrk/d285c8f912169329e5e28c3d0a63c1d8)، و همچنین دارای حفاظت ایمنی بیشتر، و همه اینها با وارد کردن مستقیم فایل هدر C - بدون اتصال API انجام می شود.

*Zig در استفاده از کتابخانه های C بهتر از C در استفاده از کتابخانه های C است.*

### Zig همچنین یک کامپایلر C است

در اینجا نمونه ای از Zig برای ایجاد کد C ذکر شده است:

<u>hello.c</u>
```c
#include <stdio.h>

int main(int argc, char **argv) {
    printf("سلام دنیا\n");
    return 0;
}
```

```
$ zig build-exe hello.c --library c
$ ./hello
سلام دنیا
```

شما می توانید از `--verbose-cc` برای دیدن دستور کامپایلر C که اجرا شده است استفاده کنید:
```
$ zig build-exe hello.c --library c --verbose-cc
zig cc -MD -MV -MF zig-cache/tmp/42zL6fBH8fSo-hello.o.d -nostdinc -fno-spell-checking -isystem /home/andy/dev/zig/build/lib/zig/include -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-gnu -isystem /home/andy/dev/zig/build/lib/zig/libc/include/generic-glibc -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-any -isystem /home/andy/dev/zig/build/lib/zig/libc/include/any-linux-any -march=native -g -fstack-protector-strong --param ssp-buffer-size=4 -fno-omit-frame-pointer -o zig-cache/tmp/42zL6fBH8fSo-hello.o -c hello.c -fPIC
```

توجه داشته باشید که اگر دوباره فرمان را اجرا کنم، خروجی وجود ندارد و فوراً به پایان می رسد:
```
$ time zig build-exe hello.c --library c --verbose-cc

real	0m0.027s
user	0m0.018s
sys	0m0.009s
```

این به لطف [کش (cache) مصنوعی](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching) است. Zig به طور خودکار فایل .d را برای جلوگیری از تکرار کار از یک سیستم کش قوی استفاده می کند.

Zig نه تنها می تواند کد C را کامپایل کند، بلکه دلیل بسیار خوبی برای استفاده از Zig به عنوان کامپایلر C وجود دارد: [Zig روی libc سوار میشود](#zig-روی-libc-سوار-میشود).

### صادر کردن توابع، متغیر ها و تایپ های C برای وابستگی به آن

یکی از موارد اصلی استفاده از Zig، صادر کردن کتابخانه با C ABI برای سایر زبان های برنامه نویسی است. کلمه کلیدی `export` در مقابل توابع، متغیرها و انواع باعث می شود که آنها بخشی از API کتابخانه باشند:

<u>mathtest.zig</u>
{{< zigdoctest "assets/zig-code/features/23-math-test.zig" >}}

برای ساخت کتابخانه ایستا:
```
$ zig build-lib mathtest.zig
```

و برای کتابخانه پویا:
```
$ zig build-lib mathtest.zig -dynamic
```

اینجا یک نمونه با [سیستم ساخت Zig](#سیستم-build-zig) وجود دارد:

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

## Cross-compiling در اولویت است

زیگ می تواند برای هر یک از اهداف از [جدول پشتیبانی](#جدول-پشتیبانی) با [ردیف پشتیبانی 3](#ردیف-پشتیبانی-3) یا بهتر. نیازی به نصب "cross toolchain" یا هر چیزی شبیه آن نیست. این یک `Hello World` بومی است:

{{< zigdoctest "assets/zig-code/features/4-hello.zig" >}}

اکنون آن را برای x86_64-windows، x86_64-macos و aarch64-linux بسازید.:
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

این بروی هر [۳ ردیف](#ردیف-پشتیبانی-3) + هدف و هر ۳ ردیف برای هدف کار میکند (میتوانید روی هر سه سیستم عامل برای هر سیستم عاملی خروجی بگیرید). 

### Zig روی libc سوار میشود

میتونی اهدافی که با libc ساخته میشوند را با `zig targets` ببینی:
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

این به این معنی که `--library c` برای این اهداف است *به هیچ فایلی در سیستم وابسته نیست*!

حالا یه نگاهی به [نمونه سلام دنیا در C](#Zig-همچنین-یک-کامپایلر-c-است) بندازیم:
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

[glibc](https://www.gnu.org/software/libc/) از ساخت ایستا پشتیبانی نمیکند، ولی [musl](https://www.musl-libc.org/) میکند:
```
$ zig build-exe hello.c --library c -target x86_64-linux-musl
$ ./hello
Hello world
$ ldd hello
  not a dynamic executable
```

در این مثال، musl Zig را از منبع ساخته و سپس در برابر آن را لینک کرده است. ساختار musl libc برای x86_64-linux به لطف [caching system](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching) موجود است، بنابراین هر زمان که به libc دوباره نیاز باشد فوراً در دسترس خواهد بود.

این بدان معناست که این قابلیت در هر پلتفرمی در دسترس است. کاربران ویندوز و macOS می توانند کد Zig و C را ایجاد کرده و در مقابل libc، برای هر یک از اهداف ذکر شده در بالا پیوند ایجاد کنند. به طور مشابه می توان کد را برای معماری های دیگر کامپایل کرد:
```
$ zig build-exe hello.c --library c -target aarch64-linux-gnu
$ file hello
hello: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, for GNU/Linux 2.0.0, with debug_info, not stripped
```

از جهاتی، Zig کامپایلر C بهتری نسبت به کامپایلرهای C است!

این قابلیت فراتر از یک cross-toolchain به همراه Zig است. به عنوان مثال، اندازه کل هدر های libc که Zig ارسال می کند 22 مگابایت غیر فشرده است. در همین حال، هدر های musl libc + headers در x86_64 به تنهایی 8 MiB و برای glibc 3.1 MiB است (glibc هدر های لینوکس را ندارد)، اما Zig در حال حاضر با 40 libc کار می کند. که با یک build ساده 444 MiB خواهد بود. به هر حال، به لطف [process_headers tool](https://github.com/ziglang/zig/blob/0.4.0/libc/process_headers.zig) که من ساختم، و چند [کار دستی خوب قدیمی](https://github.com/ziglang/zig/wiki/Updating-libc)، مجموع سایز باینری به 30 MiB میرسد. با وجود پشتیبانی از libc برای همه این اهداف و همچنین compiler-rt، libunwind و libcxx، با وجود اینکه یک کامپایلر C سازگار با clang است. ساختار باینری  clang 8.0 ویندوز در خود سایت llvm.org به 130 MB میرسد.

توجه داشته باشید که فقط اهداف [ردیف پشتیبانی 1](#ردیف-پشتیبانی-1) به طور کامل آزمایش شده است. برنامه ریزی شده است [اضافه کردن libcs بیشتر](https://github.com/ziglang/zig/issues/514) (از جمله برای Windows)، و [افزودن پوشش آزمایش برای ساخت در برابر همه libcs](https://github.com/ziglang/zig/issues/2058)

توجه داشته باشید که فقط اهداف [هدف ردیف 1](#اهداف-ردیف-1) به طور کامل آزمایش شده اند. [اضافه کردن libcs بیشتر](https://github.com/ziglang/zig/issues/514) برنامه ریزی شده است (از جمله برای Windows). [افزودن پوشش آزمایش برای ساخت در برابر همه libcs](https://github.com/ziglang/zig/issues/2058)

[برنامه ریزی شده است که یک Zig Package Manager داشته باشید](https://github.com/ziglang/zig/issues/943)، اما هنوز انجام نشده است. یکی از مواردی که امکان پذیر است ایجاد بسته برای کتابخانه های C است. این امر [Zig Build System](#سیستم-build-zig) را برای برنامه نویسان Zig و برنامه نویسان C جذاب می کند.

## سیستم ساخت Zig

Zig دارای یک سیستم ساخت است، پس به make، cmake و هر چیزی مشابه آن نیازی ندارید.
```
$ zig init-exe
Created build.zig
Created src/main.zig

then, try `zig build --help` or `zig build run`
```

<u>src/main.zig</u>
{{< zigdoctest "assets/zig-code/features/25-all-bases.zig" >}}


<u>build.zig</u>
{{< zigdoctest "assets/zig-code/features/26-build.zig" >}}


بیایید به آن منوی `--help` نگاهی بیندازیم.
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

می بینید که یکی از مراحل موجود اجرا شده است.
```
$ zig build run
All your base are belong to us.
```

در اینجا چند نمونه از اسکریپت های ساخت وجود دارد:

- [اسکریپت ساخت بازی OpenGL Tetris](https://github.com/andrewrk/tetris/blob/master/build.zig)
- [اسکریپت ساخت بازی metal Raspberry Pi 3](https://github.com/andrewrk/clashos/blob/master/build.zig)
- [ساخت اسکریپت کامپایلر Zig خود-میزبان](https://github.com/ziglang/zig/blob/master/build.zig)

## همزمانی از طریق توابع Async

Zig 0.5.0 [معرفی توابع async](https://ziglang.org/download/0.5.0/release-notes.html#Async-Functions). این ویژگی به سیستم عامل میزبان یا حتی حافظه اختصاص داده شده وابسته نیست. این بدان معناست که توابع async برای هدف مستقل در دسترس هستند.

Zig استنباط می کند که آیا یک تابع همگام است یا نه، و `async/await` را در توابع غیر همگام امکان پذیر می کند، به این معنی که **کتابخانه های Zig از مسدود کردن در مقابل async I/O** جلوگیری می کنند. [Zig avoids function colors](http://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/).



کتابخانه استاندارد Zig یک حلقه رویداد را اجرا می کند که عملکردهای همزمان را در یک مخزن thread برای همزمان M: N چند برابر می کند. ایمنی چند رشته ای و تشخیص مسابقه حوزه های تحقیقاتی فعال هستند.

## طیف گسترده ای از اهداف پشتیبانی می شود

زیگ از یک سیستم "ردیف پشتیبانی" برای ارتباط سطح پشتیبانی از اهداف مختلف استفاده می کند.

[[جدول پشتیبانی Zig 0.8.0]](/download/0.8.0/release-notes.html#Support-Table)

## با نگهدارندگان بسته دوستانه رفتار می کند

مرجع کامپایلر Zig هنوز کاملا خود میزبان نیست، اما فرقی ندارد چه باشد، فقط [3 مرحله](https://github.com/ziglang/zig/issues/853) برای داشتن یک کامپایلر C++ و داشتن یک کامپایلر Zig خود میزبان برای هر هدفی وجود دارد. همانطور که Maya Rashish گفت، [انتقال Zig به سایر سیستم عامل ها سرگرم کننده و سریع است](http://coypu.sdf.org/porting-zig.html).

اشکال زدایی [حالت های ساخت](https://ziglang.org/documentation/master/#Build-Mode) قابل تکرار/قطعی هستند.

اینجا یک نسخه [JSON از صفحه دانلود وجود دارد](/download/index.json).

چندین نفر از اعضای تیم زیگ تجربه نگهداری بسته ها را دارند.

- [Daurnimator](https://github.com/daurnimator) [بسته لینوکس Arch](https://www.archlinux.org/packages/community/x86_64/zig/) را نگهداری می کند
- [Marc Tiehuis](https://tiehuis.github.io/) از پکیج Visual Studio Code نگهداری میکند.
- [Andrew Kelley](https://andrewkelley.me/) یک سال یا بیشتر را صرف انجام [بسته بندی دبیان و اوبونتو](https://qa.debian.org/developer.php?login=superjoe30%40gmail.com&comaint=yes) کرد، و به گاها در [nixpkgs](https://github.com/NixOS/nixpkgs/) مشارکت میکند.
- [Jeff Fowler](https://blog.jfo.click/) بسته Homebrew را نگه می دارد و شروع به کار با [Sublime package](https://github.com/ziglang/sublime-zig-language) کرده است. (هم اکنون توسط [emekoi](https://github.com/emekoi) انجام میشود).
