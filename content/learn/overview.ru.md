---
title: "Подробный обзор"
mobile_menu_title: "Обзор"
toc: true
---
# Основные возможности
## Маленький, простой язык

Сфокусируйтесь на отладке вашего приложения, а не на отладке вашего знания языка программирования.

Весь синтаксис Zig описывается [файлом PEG–грамматики в 500 строк](https://ziglang.org/documentation/master/#Grammar).

Здесь нет **скрытого потока управления**, нет скрытых выделений памяти, нет препроцессора и отсутствуют макросы. Если код на Zig не выглядит как вызов какой—то функции, тогда так оно и есть. Это значит, что вы можете быть уверены, что данный код вызывает только `foo()` и затем `bar()`, и это гарантировано независимо от типа:

```zig
var a = b + c.d;
foo();
bar();
```

Примеры скрытых потоков управления:

* D поддерживает `@property` функции, что есть методы, которые выглядят как доступ к полю, так что в примере выше `c.d` может вызывать функцию.
* C++, D и Rust позволяют перегружать операторы, так что оператор `+` может вызывать функцию.
* C++, D и Go поддерживают исключения, так что `foo()` может выбросить исключение и предотвратить вызов `bar()`.

Zig поощряет сопровождение кода и его читаемость, поэтому управление потоком управления осуществляется исключительно с помощью ключевых слов языка и вызовов функций.

## Производительность и безопасность: выберите оба

Zig имеет четыре [режима сборки](https://ziglang.org/documentation/master/#Build-Mode), и все их можно смешивать и сочетать вплоть до [области видимости функции](https://ziglang.org/documentation/master/#setRuntimeSafety).

| Параметр | [Debug](/documentation/master/#Debug) | [ReleaseSafe](/documentation/master/#ReleaseSafe) | [ReleaseFast](/documentation/master/#ReleaseFast) | [ReleaseSmall](/documentation/master/#ReleaseSmall) |
|-----------|-------|-------------|-------------|--------------|
Оптимизации - <br>улучшают производительность, <br>мешают отладке, замедляют компиляцию | -Og | -O3 | -O3 | -Os |
Проверки безопасности во время выполнения - <br>ухудшают производительность, увеличивают размер, <br>вызывают крах вместо неопределённого поведения | Да | Да | Нет | Нет |

Так выглядит [целочисленное переполнение](https://ziglang.org/documentation/master/#Integer-Overflow) во время компиляции, независимо от режима сборки:

{{< zigdoctest "assets/zig-code/features/1-integer-overflow.zig" >}}

Так переполнение выглядит во время выполнения, в сборках с проверками безопасности:

{{< zigdoctest "assets/zig-code/features/2-integer-overflow-runtime.zig" >}}


[Трассировка стека работает на всех архитектурах](#трассировка-стека-на-всех-архитектурах), включая ["голое железо" (freestanding)](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html).

В Zig можно полагаться на режим сборки с проверками безопасности и выборочно отключать безопасность в узких местах для производительности. Например, предыдущий пример может быть изменён следующим образом:

{{< zigdoctest "assets/zig-code/features/3-undefined-behavior.zig" >}}

Zig использует [неопределённое поведение](https://ziglang.org/documentation/master/#Undefined-Behavior) как "острый и опасный, как бритва" инструмент для предотвращения ошибок и повышения производительности.

Если говорить о производительности, Zig быстрее, чем C.

- Эталонная реализация использует LLVM в качестве бэкенда для современных оптимизаций.
- То, что другие проекты называют "оптимизацией во время связывания" (LTO), Zig делает автоматически.
- Для "нативных" платформ включены расширенные возможности процессора (-march=native), благодаря тому, что [кросс-компиляция является поддерживаемым вариантом использования](#cross-compiling-is-a-first-class-use-case).
- Тщательно выбранное неопределённое поведение. Например, в Zig как знаковые, так и беззнаковые целые числа имеют неопределённое поведение при переполнении, в отличие от C, где это применяется только к знаковым целым числам. Это [способствует оптимизациям, недоступным в C](https://godbolt.org/z/n_nLEU).
- Zig напрямую предоставляет [SIMD тип для векторов](https://ziglang.org/documentation/master/#Vectors), что упрощает написание переносимого векторизованного кода.

Обратите внимание, что Zig не является полностью безопасным языком. Для тех, кому интересно следить за развитием безопасности Zig, подпишитесь на эти задачи:

- [enumerate all kinds of undefined behavior, even that which cannot be safety-checked](https://github.com/ziglang/zig/issues/1966)
- [make Debug and ReleaseSafe modes fully safe](https://github.com/ziglang/zig/issues/2301)

## Zig соперничает с C, а не зависит от него

Стандартная библиотека Zig интегрируется с стандартной библиотекой C, но не зависит от нее. Вот пример Hello World:

{{< zigdoctest "assets/zig-code/features/4-hello.zig" >}}

При компиляции с параметром `-O ReleaseSmall` для однопоточного режиме с последующей очисткой от отладочных символов получается статический исполняемый файл размером 9.8 КиБ для целевой платформы x86_64-linux:

```
$ zig build-exe hello.zig -O ReleaseSmall -fstrip -fsingle-threaded
$ wc -c hello
9944 hello
$ ldd hello
  not a dynamic executable
```

Файл для Windows весит ещё меньше — 4096 байт:
```
$ zig build-exe hello.zig -O ReleaseSmall -fstrip -fsingle-threaded -target x86_64-windows
$ wc -c hello.exe
4096 hello.exe
$ file hello.exe
hello.exe: PE32+ executable (console) x86-64, for MS Windows
```

## Независящие от порядка объявления высшего уровня

Объявления верхнего уровня, такие как глобальные переменные, не зависят от порядка и "лениво" анализируются (их анализ откладывается). Начальные значения глобальных переменных [вычисляются во время компиляции](#рефлексия-во-время-компиляции-и-выполнение-кода-во-время-компиляции).

{{< zigdoctest "assets/zig-code/features/5-global-variables.zig" >}}

## Опциональные типы вместо нулевых указателей

В других языках программирования нулевые ссылки являются источником множества ошибок, возникающих во время выполнения программы, и даже считаются [самой страшной ошибкой в информатике](https://www.lucidchart.com/techblog/2015/08/31/the-worst-mistake-of-computer-science/).

Обычные указатели в Zig не могут быть нулевыми:

{{< zigdoctest "assets/zig-code/features/6-null-to-ptr.zig" >}}

Однако, любой тип может быть преобразован в [опциональный тип](https://ziglang.org/documentation/master/#Optionals), используя префикс ?:

{{< zigdoctest "assets/zig-code/features/7-optional-syntax.zig" >}}

Чтобы распаковать (извлечь) опциональное значение, вы можете использовать ключевое слово `orelse`, чтобы предоставить значение по умолчанию:

{{< zigdoctest "assets/zig-code/features/8-optional-orelse.zig" >}}

Так же вы можете использовать [if](https://ziglang.org/documentation/master/#if):

{{< zigdoctest "assets/zig-code/features/9-optional-if.zig" >}}

Похожий синтаксис работает и с [while](https://ziglang.org/documentation/master/#while):

{{< zigdoctest "assets/zig-code/features/10-optional-while.zig" >}}

## Ручное управление памятью

Библиотека, написанная на Zig, может быть использована где угодно:

- [Настольными приложениями](https://github.com/TM35-Metronome/)
- Серверами с низкой задержкой
- [Ядрами операционных систем](https://github.com/AndreaOrru/zen)
- [Встраиваемыми устройствами](https://github.com/skyfex/zig-nrf-demo/)
- ПО реального времени, например, живые концерты, самолеты, кардиостимуляторы
- [В веб–браузерах или других плагинах с WebAssembly](https://shritesh.github.io/zigfmt-web/)
- Другими языками программирования, используя C ABI

Чтобы достичь этого, программисты Zig должны сами управлять своей памятью и должны обрабатывать ошибки выделения памяти.

Это справедливо и для стандартной библиотеки Zig. Все функции, которым необходимо выделить память, принимают параметр с распределителем памяти. В результате, стандартную библиотеку Zig можно использовать даже для "голого железа".

В дополнение к [свежему подходу к обработке ошибок](#свежий-подход-к-обработке-ошибок), Zig предоставляет ключевые слова [defer](https://ziglang.org/documentation/master/#defer) и [errdefer](https://ziglang.org/documentation/master/#errdefer), чтобы сделать управление ресурсами (не только памятью) простым и легко контролируемым.

Пример использования ключевого слова `defer` приведен в подразделе [Интеграция с библиотеками на C без FFI и привязок](#интеграция-с-библиотеками-на-C-без-FFI-и-привязок). Здесь приведен пример использования `errdefer`:

{{< zigdoctest "assets/zig-code/features/11-errdefer.zig" >}}


## Свежий подход к обработке ошибок

Ошибки являются значениями и не могут быть проигнорированы:

{{< zigdoctest "assets/zig-code/features/12-errors-as-values.zig" >}}

Ошибки могут быть обработаны с помощью [catch](https://ziglang.org/documentation/master/#catch):

{{< zigdoctest "assets/zig-code/features/13-errors-catch.zig" >}}

Ключевое слово [try](https://ziglang.org/documentation/master/#try) является сокращением для `catch |err| return err`:

{{< zigdoctest "assets/zig-code/features/14-errors-try.zig" >}}

Обратите внимание, что это [трассировка возврата ошибки](https://ziglang.org/documentation/master/#Error-Return-Traces), а не [трассировка стека](#трассировка-стека-на-всех-архитектурах). Код не понёс расходов за разворачивание стека, чтобы получить эту трассировку.

Ключевое слово [switch](https://ziglang.org/documentation/master/#switch), при использовании на ошибках гарантирует, что все возможные ошибки будут обработаны:

{{< zigdoctest "assets/zig-code/features/15-errors-switch.zig" >}}

Ключевое слово [unreachable](https://ziglang.org/documentation/master/#unreachable) используется для допущения, что ошибок не возникнет:

{{< zigdoctest "assets/zig-code/features/16-unreachable.zig" >}}

Это вызывает [неопределённое поведение](#производительность-и-безопасность-выберите-оба) в небезопасных режимах сборки, поэтому используйте его только тогда, когда успех гарантирован.

### Трассировка стека на всех архитектурах

Трассировки стека и [трассировки возврата ошибок](https://ziglang.org/documentation/master/#Error-Return-Traces), показанные на этой странице, работают на всех архитектурах с [поддержкой 1 уровня](#tier-1-support) и некоторых архитектурах с [поддержкой 2 уровня](#tier-2-support). Даже на "[голом железе](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html)"!

Кроме того, стандартная библиотека содержит функцию для того, чтобы захватить трассировку стека в любой момент и затем превратить её в стандартную ошибку:

{{< zigdoctest "assets/zig-code/features/17-stack-traces.zig" >}}

Вы можете увидеть использование этой техники в текущем [проекте GeneralPurposeDebugAllocator](https://github.com/andrewrk/zig-general-purpose-allocator/#current-status).

## Обобщённые структуры данных и функции

Типы являются значениями, которые должны быть известны во время компиляции:

{{< zigdoctest "assets/zig-code/features/18-types.zig" >}}

Обобщённая структура данных — это просто функция, которая возвращает тип `type`:

{{< zigdoctest "assets/zig-code/features/19-generics.zig" >}}

## Рефлексия во время компиляции и выполнение кода во время компиляции

Встроенная функция [@typeInfo](https://ziglang.org/documentation/master/#typeInfo) предоставляет рефлексию:

{{< zigdoctest "assets/zig-code/features/20-reflection.zig" >}}

Стандартная библиотека Zig использует эту технику для реализации форматированного вывода. Несмотря на то, что Zig является [маленьким и простым языком](#маленький-простой-язык), форматированный вывод реализован полностью на Zig. Между тем, в языке C ошибки компиляции для printf заданы в самом компиляторе. Аналогично, в языке Rust макрос форматированной печати зафиксирован в самом компиляторе.

Zig также может использовать функции и блоки кода во время компиляции. В некоторых ситуациях, таких, как создание глобальных переменных, выражение неявно вычисляется во время компиляции. В противном случае, можно явно запустить код во время компиляции при помощи ключевого слова [comptime](https://ziglang.org/documentation/master/#comptime). Это может быть особенно мощным в сочетании с утверждениями ("assertions"):

{{< zigdoctest "assets/zig-code/features/21-comptime.zig" >}}

## Интеграция с библиотеками на C без FFI и привязок

Встроенная функция [@cImport](https://ziglang.org/documentation/master/#cImport) напрямую импортирует типы, переменные, функции и простые макросы для использования в Zig. Он даже переводит встроенные функции с C в Zig.

Вот пример испускания синусоидальной волны с помощью библиотеки [libsoundio](http://libsound.io/):

<u>sine.zig</u>
{{< zigdoctest "assets/zig-code/features/22-sine-wave.zig" >}}

```
$ zig build-exe sine.zig -lsoundio -lc
$ ./sine
Output device: Built-in Audio Analog Stereo
^C
```

[Этот код на Zig значительно проще, чем эквивалентный код на C](https://gist.github.com/andrewrk/d285c8f912169329e5e28c3d0a63c1d8), а также имеет больше механизмов защиты, и всё это достигается путем прямого импорта заголовочного файла C — без привязок к API.

*Zig использует библиотеки C лучше, чем сам C.*

### Zig также содержит компилятор C

Вот пример того, как Zig собирает код на языке C (используя встроенный Clang):

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

Вы можете использовать параметр `--verbose-cc`, чтобы увидеть, как вызывался компилятор C:

```
$ zig build-exe hello.c --library c --verbose-cc
zig cc -MD -MV -MF zig-cache/tmp/42zL6fBH8fSo-hello.o.d -nostdinc -fno-spell-checking -isystem /home/andy/dev/zig/build/lib/zig/include -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-gnu -isystem /home/andy/dev/zig/build/lib/zig/libc/include/generic-glibc -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-any -isystem /home/andy/dev/zig/build/lib/zig/libc/include/any-linux-any -march=native -g -fstack-protector-strong --param ssp-buffer-size=4 -fno-omit-frame-pointer -o zig-cache/tmp/42zL6fBH8fSo-hello.o -c hello.c -fPIC
```

Обратите внимание, что при повторном выполнении команды ничего не выводится на экран и она завершается мгновенно:

```
$ time zig build-exe hello.c --library c --verbose-cc

real	0m0.027s
user	0m0.018s
sys	0m0.009s
```

Это происходит благодаря [кэшированию артефактов сборки](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching). Zig автоматически разбирает .d файл, используя надёжную систему кэширования, чтобы избежать лишней работы.

Zig может компилировать код на C, но есть ещё одна очень хорошая причина использовать Zig в качестве компилятора C: [Zig поставляется вместе с стандартной библиотекой C](#zig-поставляется-вместе-с-стандартной-библиотекой-c)

### Экспорт функций, переменных и типов для использования в коде на C

Одним из основных вариантов использования Zig является экспорт библиотеки с C ABI для вызова этой библиотеки на других языках программирования. Ключевое слово `export` перед функциями, переменными и типами заставляет их стать частью API библиотеки:

<u>mathtest.zig</u>
{{< zigdoctest "assets/zig-code/features/23-math-test.zig" >}}

Чтобы создать статическую библиотеку:
```
$ zig build-lib mathtest.zig
```

Чтобы создать разделяемую библиотеку:
```
$ zig build-lib mathtest.zig -dynamic
```

Пример, использующий [сборочную систему Zig](#сборочная-система-zig):

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

## Первоклассная поддержка кросс–компиляции

Zig может собирать проекты для любой архитектуры из [таблицы поддержки архитектур](#поддерживается-большой-список-архитектур) с [поддержкой 3 уровня](#tier-3-support) и выше. Вам не нужно устанавливать дополнительный инструментарий или что-то подобное. Вот пример нативного Hello World:

{{< zigdoctest "assets/zig-code/features/4-hello.zig" >}}

Теперь, чтобы собрать его для архитектур x86_64-windows, x86_64-macos и aarch64-linux:

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

Это работает на любой архитектуре (и для любой архитектуры) с [поддержкой 3 уровня](#tier-3-support) и выше.

### Zig поставляется вместе с стандартной библиотекой C

Вы можете просмотреть список доступных стандартных библиотек C с помощью `zig targets`:

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

Это означает, что `--library c` для этих целей *не зависит ни от каких системных файлов*!

Давайте снова рассмотрим [пример Hello World на языке C](#zig-также-содержит-компилятор-c):

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

[glibc](https://www.gnu.org/software/libc/) не поддерживает статическую сборку, однако её поддерживает [musl](https://www.musl-libc.org/):
```
$ zig build-exe hello.c --library c -target x86_64-linux-musl
$ ./hello
Hello world
$ ldd hello
  not a dynamic executable
```

В этом примере, Zig собрал одну из реализаций стандартной библиотеки C — musl, из исходного кода, а затем статически связал её с программой. Сборка musl libc для x86_64-linux остаётся доступной благодаря [системе кэширования](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching), поэтому в любой момент, когда эта библиотека снова понадобится, она будет доступна мгновенно.

Это означает, что данная функциональность доступна на любой платформе. Пользователи Windows и macOS могут собирать код на Zig и C и связывать с стандартной библиотекой C для любой из перечисленных выше архитектур. Аналогично, код может быть кросс–компилирован для других архитектур:

```
$ zig build-exe hello.c --library c -target aarch64-linux-gnu
$ file hello
hello: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, for GNU/Linux 2.0.0, with debug_info, not stripped
```

В некотором смысле, Zig — это более продвинутый компилятор C, чем сами компиляторы C!

Эта не просто сборник инструментов для кросс–компиляции вместе с Zig. К примеру, общий размер заголовных файлов libc, поставляемых Zig, составляет 22 МиБ в распакованном виде. Между тем, размер заголовочных файлов musl libc и Linux только для архитектуры x86_64 составляет 8 МиБ, а для glibc — 3.1 МиБ (без учёта заголовочных файлов Linux), и всё же Zig в настоящее время поставляется с 40 libc. При обычной комплектации это составило бы 444 МиБ. Однако, благодаря инструменту [process_headers](https://github.com/ziglang/zig/blob/0.9.1/tools/process_headers.zig) и [небольшой ручной доработке](https://github.com/ziglang/zig/wiki/Updating-libc) архивы с бинарными файлами Zig весят примерно 30 МиБ, включая поддержку libc для всех этих архитектур, а также compiler-rt, libunwind и libcxx, и включая совместимый с Clang компилятор C. Для сравнения, архив с бинарными файлами самого Clang версии 8.0.0 для Windows с сайта llvm.org имеет размер 132 МиБ.

Обратите внимание, что только архитектуры с [поддержкой 1 уровня](#tier-1-support) были тщательно протестированы. Планируется добавить [больше стандартных библиотек C (libc)](https://github.com/ziglang/zig/issues/514) (в том числе для Windows), а также [покрыть тестами сборку вместе с каждой библиотекой](https://github.com/ziglang/zig/issues/2058).

Мы планируем [создать пакетный менеджер для Zig](https://github.com/ziglang/zig/issues/943), но это ещё не сделано. Одна из вещей, которые будут доступны — это создание пакета для библиотеки на C. Это сделает [сборочную систему Zig](#сборочная-система-zig) привлекательной как для программистов на Zig, так и для программистов на C.

## Сборочная система Zig

Zig поставляется с сборочной системой, поэтому вам не понадобится make, cmake или что-то подобное.
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

Давайте посмотрим на меню `--help`.

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

Вы можете видеть, что один из доступных шагов запущен.

```
$ zig build run
All your base are belong to us.
```

Вот несколько примеров сценариев сборки:

- [Сценарий сборки игры Tetris на OpenGL](https://github.com/andrewrk/tetris/blob/master/build.zig)
- [Сценарий сборки аркадной игры на "голом железе" Raspberry Pi 3](https://github.com/andrewrk/clashos/blob/master/build.zig)
- [Сценарий сборки для самодостаточного (написанного на самом себе) компилятора Zig](https://github.com/ziglang/zig/blob/master/build.zig)

## Параллелизм при помощи асинхронных функций

В Zig 0.5.0 [появились асинхронные функции](https://ziglang.org/download/0.5.0/release-notes.html#Async-Functions). Эти функции не зависят от операционной системы и даже от памяти кучи. Это означает, что асинхронные функции доступны для "голого железа".

Zig выясняет, является ли функция асинхронной, и разрешает использование `async`/`await` для неасинхронных функций, что означает, что **библиотеки на Zig не зависят от выбора между блокирующим и асинхронным вводом/выводом**. [Zig избегает цветные функций](http://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/).

Стандартная библиотека Zig реализует цикл событий, который мультиплексирует асинхронные функции в пул потоков для параллелизма M:N типа. Безопасность многопоточности и обнаружение гонок являются областями активных исследований.

## Поддерживается большой список архитектур

Zig использует систему "уровней поддержки", чтобы сообщать об уровне поддержки для различных архитектур.

[Таблица поддержки для Zig версии 0.8.0](/download/0.9.1/release-notes.html#Support-Table)

## Приятен для сопроводителей пакетных менеджеров

Эталонный компилятор Zig ещё не полностью самодостаточен, но, несмотря ни на что, с помощью системного компилятора C++ до полностью самодостаточного компилятора Zig для любой платформы [всегда будет требоваться ровно 3 шага](https://github.com/ziglang/zig/issues/853). Как отмечает Maya Rashish, [портирование Zig на другие платформы — весёлый и быстрый процесс](http://coypu.sdf.org/porting-zig.html).

[Режимы сборки](https://ziglang.org/documentation/master/#Build-Mode) без поддержки отладки воспроизводимы/детерминистичны.

Существует [JSON версия страницы с загрузками](/download/index.json).

Несколько членов команды Zig имеют опыт сопровождения пакетов.

- [Daurnimator](https://github.com/daurnimator) сопровождает [пакет в Arch Linux](https://www.archlinux.org/packages/community/x86_64/zig/)
- [Marc Tiehuis](https://tiehuis.github.io/) сопровождает пакет для Visual Studio Code.
- [Andrew Kelley](https://andrewkelley.me/) занимался около года [созданием пакета для Debian и Ubuntu](https://qa.debian.org/developer.php?login=superjoe30%40gmail.com&comaint=yes), а также иногда вносит вклад в [nixpkgs](https://github.com/NixOS/nixpkgs/).
- [Jeff Fowler](https://blog.jfo.click/) сопровождает пакет для Homebrew и создал [пакет для Sublime](https://github.com/ziglang/sublime-zig-language) (теперь его сопровождает [emekoi](https://github.com/emekoi)).
