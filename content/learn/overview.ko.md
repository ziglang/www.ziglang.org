---
title: "심층 개요"
mobile_menu_title: "개요"
toc: true
---
# 주요 기능
## 작고 단순한 언어

프로그래밍 언어 지식을 디버깅할게 아니라 여러분의 애플리케이션을 디버깅하는데 집중하십시오.

Zig의 전체 문법은 [500줄 PEG 문법 파일](https://ziglang.org/documentation/master/#Grammar)로 표현됩니다.

**숨겨진 제어 흐름**이 없으며, 숨겨진 메모리 할당도 없고, 전처리기와 매크로도 없습니다. 만약 Zig 코드가 멀리 점프해서 함수를 호출하려는걸로 보이지 않다면, 실제로 그런겁니다. 이는 다음의 코드가 그저 `foo()`를 호출한 뒤 `bar()`를 호출하는 것을 확신해도 된다는 것이며, 어떤 것의 타입도 알 필요가 없음을 보장합니다:

```zig
var a = b + c.d;
foo();
bar();
```

숨겨진 제어 흐름의 예:

* D에는 필드에 대한 접근처럼 보이지만 실제는 메소드인 `@property` 함수가 있어, 위 예제에서는 `c.d`가 함수를 호출할 수도 있습니다.
* C++, D, Rust에는 연산자 오버로딩이 가능하여, `+` 연산자가 함수를 호출할 수도 있습니다.
* C++, D, Go에는 throw/catch 예외가 있어, `foo()` 함수가 예외를 발생시키고 `bar()` 함수가 불리는 것을 막을 수도 있습니다. (물론, Zig에서도 `foo()` 함수에 deadlock이 발생해 `bar()`가 불리는 것을 막을 수 있지만, 이는 어떠한 튜링-완전 언어에서도 발생할 수 있습니다.)

Zig는 모든 제어 흐름을 언어의 키워드와 함수 호출로 명시적으로 관리함으로써 유지보수를 용이하게 하고 가독성을 향상시켜 줍니다.

## 퍼포먼스와 안정성: 둘 다 고르세요

Zig에는 네 가지의 [빌드 모드](https://ziglang.org/documentation/master/#Build-Mode)가 있으며, [세분화된 범위](https://ziglang.org/documentation/master/#setRuntimeSafety)에 따라 조합하고 섞어서 사용할 수 있습니다.

| 파라미터 | [Debug](/documentation/master/#Debug) | [ReleaseSafe](/documentation/master/#ReleaseSafe) | [ReleaseFast](/documentation/master/#ReleaseFast) | [ReleaseSmall](/documentation/master/#ReleaseSmall) |
|-----------|-------|-------------|-------------|--------------|
최적화 - 속도 향상, 디버깅 어려움, 컴파일 시간 김 | | -O3 | -O3| -Os |
런타임 안전성 확인 - 속도 느림, 용량 큼, 정의되지 않은 동작 대신 크래시 발생 | On | On | | |

빌드 모드에 상관 없이 컴파일 타임의 [정수 오버플로우](https://ziglang.org/documentation/master/#Integer-Overflow)는 다음과 같습니다:

{{< zigdoctest "assets/zig-code/features/1-integer-overflow.zig" >}}

안전성 확인 빌드의 런타임에서 발생하는 결과는 다음과 같습니다:

{{< zigdoctest "assets/zig-code/features/2-integer-overflow-runtime.zig" >}}


스택트레이스는 [프리스탠딩](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html)을 포함한 [모든 타겟에서 작동](#모든-타겟에서-스택트레이스-지원)합니다.

Zig에서는 안전성 확인이 켜진 빌드모드에 의존해도 되고, 성능 병목이 있는 곳에서만 선택적으로 안전성 확인을 꺼도 됩니다. 예를 들어 이전 예제는 다음과 같이 수정될 수 있습니다:

{{< zigdoctest "assets/zig-code/features/3-undefined-behavior.zig" >}}

Zig는 [정의되지 않은 동작](https://ziglang.org/documentation/master/#Undefined-Behavior)을 통해 날카롭게 버그 방지와 성능 향상을 꾀합니다.

성능에 대해 얘기하자면, Zig는 C보다 빠릅니다.

- 표준 구현체는 LLVM을 백엔드로 사용하여 최고의 최적화 기술을 활용합니다.
- 다른 프로젝트에서 "링크 타임의 최적화"라고 부르는 것을 Zig는 자동으로 수행합니다.
- [크로스 컴파일이 기본 제공](#크로스-컴파일-기본-제공) 되는 덕분에, 네이티브 타겟에서 고급 CPU 기능을 쓸 수 있습니다.
- 정의되지 않은 동작을 조심스럽게 선정했습니다. 예를 들어 Zig에서는 부호가 있거나 없는 정수 모두 오버플로우 시에 정의되지 않은 동작이 있는데, 이는 C에는 부호 있는 정수에만 있는 것과 대조됩니다. 이는 [C에서는 불가능한 최적화가 가능하게 해줍니다](https://godbolt.org/z/n_nLEU).
- Zig는 [SIMD 벡터 타입](https://ziglang.org/documentation/master/#Vectors)을 직접 노출하여, 이식 가능한 벡터화된 코드를 작성하기 쉽게 해줍니다.

Zig가 완전히 안전한 언어는 아니니 주의하십시오. Zig의 안전성과 관련된 이야기에 관심있으신 분은 다음 이슈를 구독하세요:

- [enumerate all kinds of undefined behavior, even that which cannot be safety-checked](https://github.com/ziglang/zig/issues/1966)
- [make Debug and ReleaseSafe modes fully safe](https://github.com/ziglang/zig/issues/2301)

## ZIG는 C에 의존하는게 아니라 경쟁한다

Zig 표준 라이브러리는 libc와 연동하지만, 의존하지는 않습니다. 여기 Hello World가 있습니다:

{{< zigdoctest "assets/zig-code/features/4-hello.zig" >}}

x86_64-linux 타겟으로 `-O ReleaseSmall`에 디버그 심볼을 제거하고 단일 쓰레드 모드로 컴파일 하면, 정적으로 컴파일된 9.9 KiB의 실행파일이 만들어집니다:
```
$ zig build-exe hello.zig -O ReleaseSmall --strip --single-threaded
$ wc -c hello
9944 hello
$ ldd hello
  not a dynamic executable
```

Windows용 빌드는 더 작아서, 4096 byte입니다:
```
$ zig build-exe hello.zig -O ReleaseSmall --strip --single-threaded -target x86_64-windows
$ wc -c hello.exe
4096 hello.exe
$ file hello.exe
hello.exe: PE32+ executable (console) x86-64, for MS Windows
```

## 순서와 무관한 최상위 선언

전역 변수 같은 최상위 선언은 순서와 무관하며 게으르게 분석됩니다. 초기화 값과 전역 변수는 [컴파일 타임에 평가됩니다](#컴파일-타임-리플렉션과-컴파일-타입-코드-실행).

{{< zigdoctest "assets/zig-code/features/5-global-variables.zig" >}}

## 널 포인터 대신 선택적 타입 사용

다른 프로그래밍 언어에서 null 참조는 많은 런타임 예외의 원인이며 [컴퓨터 과학에서의 최악의 실수](https://www.lucidchart.com/techblog/2015/08/31/the-worst-mistake-of-computer-science/)라고까지 일컬어집니다.

평범한 Zig 포인터는 null이 될 수 없습니다:

{{< zigdoctest "assets/zig-code/features/6-null-to-ptr.zig" >}}

하지만 어떤 타입이든 앞에 ?를 붙여 [선택적 타입](https://ziglang.org/documentation/master/#Optionals)으로 만들 수 있습니다:

{{< zigdoctest "assets/zig-code/features/7-optional-syntax.zig" >}}

선택적 값을 풀어서 쓰고 싶은 경우, `orelse`를 사용하여 기본값을 가져올 수 있습니다:

{{< zigdoctest "assets/zig-code/features/8-optional-orelse.zig" >}}

다른 방법은 if를 사용하는겁니다:

{{< zigdoctest "assets/zig-code/features/9-optional-if.zig" >}}

[while](https://ziglang.org/documentation/master/#while)도 같은 문법이 적용됩니다:

{{< zigdoctest "assets/zig-code/features/10-optional-while.zig" >}}

## 수동 메모리 관리

Zig로 작성한 라이브러리는 어디에나 쓸 수 있습니다:

- [데스크탑 애플리케이션](https://github.com/TM35-Metronome/)
- 지연시간이 짧은 서버
- [운영체제 커널](https://github.com/AndreaOrru/zen)
- [임베디드 장치](https://github.com/skyfex/zig-nrf-demo/)
- 실시간 소프트웨어 (예: 공연 실황, 항공기, 심장박동기)
- [웹브라우저 또는 WebAssembly로 된 다른 플러그인](https://shritesh.github.io/zigfmt-web/)
- C ABI를 사용하는 다른 프로그래밍 언어

이를 달성하기 위해 Zig 개발자는 반드시 메모리를 직접 관리해야 하며, 메모리 할당 실패를 처리해야 합니다.

이는 Zig 표준 라이브러리에서도 마찬가지입니다. 메모리 할당이 필요한 모든 함수는 할당자 파라미터를 필요로 합니다. 결과적으로 Zig 표준 라이브러리는 프리스탠딩 타겟에서도 사용할 수 있습니다.

[오류 처리에 대한 새로운 접근 방식](#오류-처리에-대한-새로운-접근)에 더해, Zig는 모든 리소스 관리(메모리 뿐 아니라)를 간단하고 쉽게 검증할 수 있도록 해주는 [defer](https://ziglang.org/documentation/master/#defer)와 [errdefer](https://ziglang.org/documentation/master/#errdefer)를 제공합니다.

`defer`의 예제는 [FFI/바인딩 없이 C 라이브러리와 연동](#ffi나-바인딩-없이-c-라이브러리와-연동)을 확인하세요. `errdefer`의 예제는 다음과 같습니다:
{{< zigdoctest "assets/zig-code/features/11-errdefer.zig" >}}


## 오류 처리에 대한 새로운 접근

오류도 값이며, 무시되면 안됩니다:

{{< zigdoctest "assets/zig-code/features/12-errors-as-values.zig" >}}

오류는 [catch](https://ziglang.org/documentation/master/#catch)로 처리할 수 있습니다:

{{< zigdoctest "assets/zig-code/features/13-errors-catch.zig" >}}

[try](https://ziglang.org/documentation/master/#try) 키워드는 `catch |err| return err`를 줄인 것입니다:

{{< zigdoctest "assets/zig-code/features/14-errors-try.zig" >}}

[스택트레이스](#모든-타겟에서-스택트레이스-지원)가 아니라 [오류 리턴 트레이스](https://ziglang.org/documentation/master/#Error-Return-Traces)임을 주의하세요. 저 코드는 스택을 풀어 트레이스를 만드는 비용이 없습니다.

오류에 [switch](https://ziglang.org/documentation/master/#switch) 키워드를 사용하면 발생 가능한 모든 오류가 처리되도록 할 수 있습니다:

{{< zigdoctest "assets/zig-code/features/15-errors-switch.zig" >}}

[unreachable](https://ziglang.org/documentation/master/#unreachable) 키워드는 오류가 발생하지 않을 것을 assert 하는데 사용합니다:

{{< zigdoctest "assets/zig-code/features/16-unreachable.zig" >}}

이는 안전하지 않은 빌드 모드에서 [undefined behavior](#퍼포먼스와-안정성-둘-다-고르세요)를 발생시키므로, 반드시 성공이 보장되는 때에만 사용하십시오.

### 모든 타겟에서 스택트레이스 지원

이 페이지에 있는 스택트레이스와 [오류 리턴 트레이스](https://ziglang.org/documentation/master/#Error-Return-Traces)는 모든 [티어 1 Support](#티어-1-지원)와 일부 [티어 2 지원](#티어-2-지원) 타겟에서 작동합니다. [프리스탠딩에서도요](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html)!

더하여, 표준 라이브러리는 아무 지점에서나 스택트레이스를 저장했다가 나중에 표준 오류로 출력할 수 있는 기능이 있습니다.

{{< zigdoctest "assets/zig-code/features/17-stack-traces.zig" >}}

이 기술은 현재 진행 중인 [GeneralPurposeDebugAllocator 프로젝트](https://github.com/andrewrk/zig-general-purpose-allocator/#current-status)에서 사용되고 있는 것을 볼 수 있습니다.

## Generic한 데이터구조와 함수

타입은 컴파일 타임에 반드시 알고 있어야 하는 값입니다:

{{< zigdoctest "assets/zig-code/features/18-types.zig" >}}

Generic 데이터 구조는 단순히 `type`을 리턴하는 함수입니다:

{{< zigdoctest "assets/zig-code/features/19-generics.zig" >}}

## 컴파일 타임 리플렉션과 컴파일 타입 코드 실행

빌트인 함수인 [@typeInfo](https://ziglang.org/documentation/master/#typeInfo)는 리플렉션을 제공합니다:

{{< zigdoctest "assets/zig-code/features/20-reflection.zig" >}}

Zig 표준 라이브러리는 이 기술을 이용하여 포맷 출력을 구현합니다. [작고 단순한 언어](#작고-단순한-언어)이지만, Zig의 포맷 출력은 모두 Zig 안에 구현되어 있습니다. 반면 C에서는 printf를 위한 컴파일 오류가 컴파일러에 하드코딩 되어 있습니다. 비슷하게 Rust에서는 포맷 출력 매크로는 컴파일러에 하드코딩 되어 있습니다.

Zig는 또한 함수와 코드 블록을 컴파일 타임에 평가할 수 있습니다. 어떤 경우 전역 변수 초기화 같은 표현은 암시적으로 컴파일 타임에 평가됩니다. 다른 방법으로는 [comptime](https://ziglang.org/documentation/master/#comptime) 키워드를 이용하여 명시적으로 컴파일 타임에 코드를 평가할 수 있습니다. 이는 특히 assertion과 함께 사용하면 강력합니다:

{{< zigdoctest "assets/zig-code/features/21-comptime.zig" >}}

## FFI나 바인딩 없이 C 라이브러리와 연동

[@cImport](https://ziglang.org/documentation/master/#cImport)는 Zig에서 타입, 변수, 함수, 그리고 단순한 매크로를 직접적으로 가져와 사용하는 데 쓰입니다. 심지어 C의 인라인 함수도 변환하여 Zig로 가져옵니다.

[libsoundio](http://libsound.io/)를 사용하여 사인파를 만들어내는 예제입니다:

<u>sine.zig</u>
{{< zigdoctest "assets/zig-code/features/22-sine-wave.zig" >}}

```
$ zig build-exe sine.zig -lsoundio -lc
$ ./sine
Output device: Built-in Audio Analog Stereo
^C
```

[이 Zig 코드는 동일한 C 코드에 비해 월등히 단순할 뿐 아니라](https://gist.github.com/andrewrk/d285c8f912169329e5e28c3d0a63c1d8), 더 많은 안전성 보호를 해주며, API 바인딩도 없이 C 헤더 파일을 직접 가져와 이 모든 일을 해냅니다.

*Zig는 C가 C 라이브러리를 사용하는 것보다도 더 C 라이브러리를 사용하는 데에 좋습니다.*

### Zig도 하나의 C 컴파일러

Zig로 C 코드를 빌드하는 예입니다:

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

`--verbose-cc`를 사용하면 무슨 C 컴파일러 명령어를 사용했는지 확인할 수 있습니다:
```
$ zig build-exe hello.c --library c --verbose-cc
zig cc -MD -MV -MF zig-cache/tmp/42zL6fBH8fSo-hello.o.d -nostdinc -fno-spell-checking -isystem /home/andy/dev/zig/build/lib/zig/include -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-gnu -isystem /home/andy/dev/zig/build/lib/zig/libc/include/generic-glibc -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-any -isystem /home/andy/dev/zig/build/lib/zig/libc/include/any-linux-any -march=native -g -fstack-protector-strong --param ssp-buffer-size=4 -fno-omit-frame-pointer -o zig-cache/tmp/42zL6fBH8fSo-hello.o -c hello.c -fPIC
```

명령어를 다시 실행하면 출력되는 것 없이 바로 종료됩니다:
```
$ time zig build-exe hello.c --library c --verbose-cc

real	0m0.027s
user	0m0.018s
sys	0m0.009s
```

이는 [빌드 결과 캐싱](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching) 덕분입니다. Zig는 .d 파일을 자동으로 파싱하여 중복된 작업을 하지 않도록 해주는 강력한 캐싱 시스템을 사용합니다.

Zig는 C 코드를 컴파일할 수 있을 뿐 아니라 Zig를 C 컴파일러로 쓸 좋은 이유가 있습니다: [Zig에는 libc가 포함됩니다](#zig에는-libc가-포함됩니다).

### C 코드가 의존할 수 있도록 함수, 변수, 타입을 export

Zig의 주된 용도 중 하나는 다른 프로그래밍 언어에서 쓸 수 있도록 C ABI로 라이브러리를 export하는 것입니다. `export` 키워드를 함수, 변수, 타입 앞에 쓰면 라이브러리 API의 일부가 됩니다.

<u>mathtest.zig</u>
{{< zigdoctest "assets/zig-code/features/23-math-test.zig" >}}

정적인 라이브러리를 만들려면:
```
$ zig build-lib mathtest.zig
```

동적 라이브러리를 만들려면:
```
$ zig build-lib mathtest.zig -dynamic
```

[Zig 빌드 시스템](#zig-빌드-시스템)의 예제입니다:

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

## 크로스 컴파일 기본 제공

Zig는 [지원 목록](#지원-목록)에 있는 타겟 중 [티어 3 지원](#티어-3-지원) 이상이면 모두 빌드할 수 있습니다. "크로스 툴체인" 같은 것은 설치할 필요도 없습니다. 네이티브 Hello World입니다:

{{< zigdoctest "assets/zig-code/features/4-hello.zig" >}}

이제 x86_64-windows, x86_64-macosx, aarch64v8-linux로 빌드하려면:
```
$ zig build-exe hello.zig -target x86_64-windows
$ file hello.exe
hello.exe: PE32+ executable (console) x86-64, for MS Windows
$ zig build-exe hello.zig -target x86_64-macosx
$ file hello
hello: Mach-O 64-bit x86_64 executable, flags:<NOUNDEFS|DYLDLINK|TWOLEVEL|PIE>
$ zig build-exe hello.zig -target aarch64v8-linux
$ file hello
hello: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), statically linked, with debug_info, not stripped
```

[티어 3](#티어-3-지원) 이상의 모든 타겟에서 동작하며, [티어 3](#티어-3-지원) 이상의 모든 타겟을 대상으로 사용 가능합니다.

### Zig에는 libc가 포함됩니다

`zig targets`로 사용 가능한 libc 타겟을 확인할 수 있습니다:
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

이 타겟들에 대해 `--library c`를 사용하면 *어떠한 시스템 파일에도 의존하지 않는다*는 것입니다!

[C hello world 예제](#zig도-하나의-c-compiler)를 다시 보겠습니다:
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

[glibc](https://www.gnu.org/software/libc/)는 정적인 빌드를 지원하지 않지만, [musl](https://www.musl-libc.org/)은 지원합니다:
```
$ zig build-exe hello.c --library c -target x86_64-linux-musl
$ ./hello
Hello world
$ ldd hello
  not a dynamic executable
```

이 예제에서는 Zig가 musl libc를 소스코드로 빌드한 뒤 링크했습니다. [캐싱 시스템](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching) 덕분에 x86_64-linux용 musl libc의 빌드가 계속 사용 가능하여, 다시 libc가 필요하게 되더라도 즉각 사용할 수 있습니다.

이 기능은 어떤 플랫폼에서도 사용 가능합니다. Windows와 macOS 사용자는 위에 나열된 어떤 타겟으로도 C 코드를 빌드하고 libc에 링크할 수 있습니다. 비슷하게 다른 아키텍쳐로의 크로스 컴파일도 가능합니다:
```
$ zig build-exe hello.c --library c -target aarch64v8-linux-gnu
$ file hello
hello: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, for GNU/Linux 2.0.0, with debug_info, not stripped
```

어떤 면에서 Zig는 C 컴파일러보다도 나은 C 컴파일러입니다!

이 기능은 Zig에 크로스 컴파일 툴체인을 포함하는 것 이상입니다. 예를 들어 Zig에 포함되는 libc 헤더의 전체 크기는 압축 없이 22 MiB입니다. 한편, musl libc + Linux는 x86_64 헤더만 8 MiB이며, glibc 용은 3.1 MiB 인데(glibc에는 Linux 헤더 미포함), Zig는 현재 40종의 libc를 포함합니다. 네이티브 번들링을 포함하면 444 MiB가 될겁니다. 하지만, 제가 만든 [process_headers 툴](https://github.com/ziglang/zig/blob/0.4.0/libc/process_headers.zig)과 [수작업](https://github.com/ziglang/zig/wiki/Updating-libc) 덕분에 이 모든 타겟에 libc를 비롯 compiler-rt, libunwind, libcx를 지원하며 clang 호환 C 컴파일러임에도 불구하고 Zig 바이너리 압축파일들은 대략 30 MiB를 유지할 수 있었습니다. 비교하자면, llvm.org에서 받은 Windows용 clang 8.0.0 바이너리 빌드는 그 자체만으로 132 MiB 입니다.

[티어 1 지원](#티어-1-지원) 타겟만 완전히 테스트 되었음을 주의해 주세요. [더 많은 libc들을 추가](https://github.com/ziglang/zig/issues/514)할 계획이며 (Windows 포함), [모든 libc의 빌드에 대한 테스트 커버리지도 추가](https://github.com/ziglang/zig/issues/2058)할 계획입니다.

[Zig 패키지 매니저](https://github.com/ziglang/zig/issues/943)도 계획되어 있으나, 아직 완성되지 않았습니다. 가능해질 일 중 하나는 C 라이브러리용 패키지를 만드는 것입니다. [Zig 빌드 시스템](#zig-빌드-시스템)은 Zig 개발자와 C 개발자 모두에게 매력있게 다가올 것입니다.

## Zig 빌드 시스템

Zig는 빌드 시스템이 포함 되어 있으므로 make, cmake 같은 것은 사용하실 필요 없습니다.
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


`--help` 메뉴를 살펴보겠습니다.
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

사용 가능한 스텝 중 하나가 실행되는걸 보실 수 있습니다.
```
$ zig build run
All your base are belong to us.
```

빌드 스크립트 예제입니다:

- [OpenGL 테트리스 게임 빌드 스크립트](https://github.com/andrewrk/tetris/blob/master/build.zig)
- [베어메탈 라즈베리파이3 아케이드게임 빌드 스크립트](https://github.com/andrewrk/clashos/blob/master/build.zig)
- [자체 호스팅 Zig 컴파일러 빌드 스크립트](https://github.com/ziglang/zig/blob/master/build.zig)

## 비동기 함수를 통한 동시성

Zig 0.5.0 버전에서 [비동기 함수가 도입 되었습니다](https://ziglang.org/download/0.5.0/release-notes.html#Async-Functions). 이 기능은 운영체제나 힙에 할당된 메모리에도 의존하지 않습니다. 이는 프리스탠딩 타겟에도 비동기 함수를 쓸 수 있다는걸 의미합니다.

Zig는 함수가 비동기인지 유추하며, `async`/`await`을 비동기가 아닌 함수에도 허용하는데, 이는 **Zig 라이브러리가 I/O의 블로킹이나 비동기 여부와 상관 없다**는 것을 의미합니다. [Zig는 함수의 색깔을 지양합니다](http://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/).



Zig 표준 라이브러리는 M:N 동시성을 위해 비동기 함수를 쓰레드 풀에 다중화 하는 이벤트 루프를 구현합니다. 멀티쓰레드 안전성과 경쟁상태 감지는 현재 활발히 진행 중인 연구 분야입니다.

## 다양한 타겟 지원

Zig는 "지원 티어" 체계를 이용해 다른 타겟에 대한 지원 수준을 소통합니다. [1 티어 지원](#티어-1-지원)은 기준이 높지만, [2 티어 지원](#티어-2-지원)도 꽤 괜찮으니 참고하세요.

### 지원 목록

| | free standing | Linux 3.16+ | macOS 10.13+ | Windows 8.1+ | FreeBSD 12.0+ | NetBSD 8.0+ | DragonFly​BSD 5.8+ | UEFI |
|-|---------------|-------------|--------------|--------------|---------------|-------------|-------------------|------|
| x86_64 | [티어 1](#티어-1-지원) | [티어 1](#티어-1-지원) | [티어 1](#티어-1-지원) | [티어 2](#티어-2-지원) | [티어 2](#티어-2-지원) | [티어 2](#티어-2-지원) | [티어 2](#티어-2-지원) | [티어 2](#티어-2-지원) |
| arm64 | [티어 1](#티어-1-지원) | [티어 2](#티어-2-지원) | [티어 2](#티어-2-지원) | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | N/A | [티어 3](#티어-3-지원) |
| arm32 | [티어 1](#티어-1-지원) | [티어 2](#티어-2-지원) | N/A | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | N/A | [티어 3](#티어-3-지원) |
| mips32 LE | [티어 1](#티어-1-지원) | [티어 2](#티어-2-지원) | N/A | N/A | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | N/A | N/A |
| i386 | [티어 1](#티어-1-지원) | [티어 2](#티어-2-지원) | [티어 4](#티어-4-지원) | [티어 2](#티어-2-지원) | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | N/A | [티어 2](#티어-2-지원) |
| riscv64 | [티어 1](#티어-1-지원) | [티어 2](#티어-2-지원) | N/A | N/A | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | N/A | [티어 3](#티어-3-지원) |
| bpf | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | N/A | N/A | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | N/A | N/A |
| hexagon | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | N/A | N/A | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | N/A | N/A |
| mips32 BE | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | N/A | N/A | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | N/A | N/A |
| mips64 | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | N/A | N/A | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | N/A | N/A |
| amdgcn | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | N/A | N/A | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | N/A | N/A |
| sparc | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | N/A | N/A | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | N/A | N/A |
| s390x | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | N/A | N/A | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | N/A | N/A |
| lanai | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | N/A | N/A | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | N/A | N/A |
| powerpc32 | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | [티어 4](#티어-4-지원) | N/A | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | N/A | N/A |
| powerpc64 | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | [티어 4](#티어-4-지원) | N/A | [티어 3](#티어-3-지원) | [티어 3](#티어-3-지원) | N/A | N/A |
| avr | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A |
| riscv32 | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | [티어 4](#티어-4-지원) |
| xcore | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A |
| nvptx | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A |
| msp430 | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A |
| r600 | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A |
| arc | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A |
| tce | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A |
| le | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A |
| amdil | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A |
| hsail | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A |
| spir | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A |
| kalimba | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A |
| shave | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A |
| renderscript | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A | [티어 4](#티어-4-지원) | [티어 4](#티어-4-지원) | N/A | N/A |


### WebAssembly 지원 목록

|        | free standing | emscripten | WASI   |
|--------|---------------|------------|--------|
| wasm32 | [티어 1](#티어-1-지원)        | [티어 3](#티어-3-지원)     | [티어 1](#티어-1-지원) |
| wasm64 | [티어 4](#티어-4-지원)        | [티어 4](#티어-4-지원)     | [티어 4](#티어-4-지원) |


### 티어 시스템

#### 티어 1 지원
- Zig가 이 타겟들의 머신 코드를 생성할 수 있을 뿐 아니라 표준 라이브러리의 크로스 플랫폼 추상화 역시 구현되어 있습니다.
- CI 서버가 master 브랜치에 대한 모든 commit에 대해 이 타겟들을 자동으로 테스트 하며, [다운로드 페이지]({{< ref "/download/" >}})의 링크를 빌드된 바이너리로 업데이트 합니다.
- 이 타겟들은 디버그 정보가 포함되어 있어 실패한 assertion에 대해 [스택트레이스](#모든-타겟에서-스택트레이스-지원)를 생성합니다.
- [이 타겟으로 크로스 컴파일할 때도 libc가 사용 가능합니다](#zig에는-libc가-포함됩니다).
- 모든 동작 테스트와 적용 가능한 표준 라이브러리 테스트를 통과합니다. 모든 언어 기능이 정상적으로 작동하는 것으로 알려져 있습니다.

#### 티어 2 지원
- 표준 라이브러리가 이 타겟을 지원하지만, 일부 API는 "Unsupported OS" 컴파일 오류를 발생시킵니다. libc나 다른 라이브러리를 링크하여 표준 라이브러리 내의 간극을 메울 수 있습니다.
- 이 타겟들은 작동하는 것으로 알려져 있지만, 자동으로 테스트 되지 않을 수 있어 때때로 수정한 문제가 되살아나기도 합니다.
- 일부 테스트는 [티어 1 지원](#티어-1-지원)으로의 작업을 위해 비활성화 되었을 수 있습니다.

#### 티어 3 지원

- 표준 라이브러리에는 이 타겟에 대한 정보가 거의 없습니다.
- Zig가 LLVM 기반이기 때문에 이 타겟들에 대한 빌드가 가능하며 LLVM에 해당 타겟의 사용이 기본으로 활성화 되어 있습니다.
- 자주 테스트 되지 않기 때문에 이 타겟들로 빌드하고자 한다면 Zig에 기여하게 되기 쉽습니다.
- Zig 컴파일러는 다음의 몇 가지를 업데이트 해야할 수 있습니다:
  - C 정수 타입의 크기가 얼마나 되나
  - 이 타겟에 대한 C ABI 호출 컨벤션
  - 부트스트랩 코드 및 기본 패닉 핸들러
- zig targets에 이 타겟이 포함되는 것이 보장됩니다.

#### 티어 4 지원

- 이 타겟들의 지원은 완전히 실험적입니다.
- LLVM에서도 타겟이 실험적일 수 있는데, 그 경우에는 Zig에서 해당 타겟용 바이너리가 나왔을 때 사용하거나, 특별한 설정 플래그와 함께 LLVM을 소스로 빌드해야 합니다.
- [macosx/i386](https://support.apple.com/en-us/HT208436)의 경우처럼 타겟에 대한 지원이 공식적으로 중단될 수 있는데, 이 경우 타겟은 영원히 티어 4로 남아있게 됩니다.
- 이 타겟은 `--emit` asm만 지원할 수도 있으며 이 경우 오브젝트 파일은 생성되지 않습니다.

## 패키지 관리자에게 친숙

표준 Zig 컴파일러는 아직 완전히 자체 호스팅 되지 않지만, 어쨌든 [정확히 3 단계만 거치면](https://github.com/ziglang/zig/issues/853) 시스템 C++ 컴파일러로부터 어떤 타겟에도 자체 호스팅 되는 완전한 Zig 컴파일러를 얻을 수 있습니다. Maya Rashish가 얘기한 것처럼, [Zig를 다른 플랫폼으로 포팅하는 것은 재밌고 빠릅니다](http://coypu.sdf.org/porting-zig.html).

디버그 외의 [빌드 모드](https://ziglang.org/documentation/master/#Build-Mode)들은 재현 가능하며 결정적입니다.

[다운로드 페이지의 JSON 버전](/download/index.json)도 있습니다.

Zig 팀의 몇몇 멤버는 패키지 관리 경험이 있습니다.

- [Daurnimator](https://github.com/daurnimator)는 [Arch Linux 패키지](https://www.archlinux.org/packages/community/x86_64/zig/)를 관리합니다.
- [Marc Tiehuis](https://tiehuis.github.io/)는 Visual Studio Code 패키지를 관리하고 있습니다.
- [Andrew Kelley](https://andrewkelley.me/)는 1년 이상 걸려 [Debian 및 Ubuntu 패키지](https://qa.debian.org/developer.php?login=superjoe30%40gmail.com&comaint=yes)를 만들었고, [nixpkgs](https://github.com/NixOS/nixpkgs/)에 기여 중입니다.
- [Jeff Fowler](https://blog.jfo.click/)는 Homebrew 패키지를 관리하며 [Sublime 패키지](https://github.com/ziglang/sublime-zig-language)의 개발을 시작했습니다 (현재는 [emekoi](https://github.com/emekoi)가 관리합니다).
