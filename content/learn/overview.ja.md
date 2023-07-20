---
title: "詳細な概要"
mobile_menu_title: "概要"
toc: true
---
# 機能ハイライト
## 小さく、シンプルな言語

プログラミング言語の知識をデバッグするよりも、アプリケーションのデバッグに重点を置いてください。

Zigの全文法は、[500行のPEG文法ファイル](https://ziglang.org/documentation/master/#Grammar)で指定されています。

**隠された制御フロー**も、隠されたメモリ確保も、プリプロセッサも、マクロも存在しないのです。もしZigのコードが関数を呼び出すために飛び出しているように見えないなら、それは違います。つまり、次のコードは`foo()`と`bar()`のみを呼び出し、何も型を知らなくてもこれが保証されることを意味します：

```zig
var a = b + c.d;
foo();
bar();
```

隠された制御フローの例：

- Dには`@property`関数があります。これは、フィールドアクセスのように見えるメソッドで、上記の例では`c.d`が関数を呼び出すかもしれません。
- C++、D、Rustには演算子のオーバーローディングがあるので、`+`演算子は関数を呼び出すかもしれません。
- C++、D、Goにはthrow/catch 例外機能があるので、`foo()`は例外をスローして`bar()`が呼ばれないようにするかもしれません。

 Zigは、すべての制御フローを言語キーワードと関数呼び出しのみで管理することで、コードの保守性と可読性を高めています。

## 性能と安全性：2つの選択

Zigには4つの[ビルドモード](https://ziglang.org/documentation/master/#Build-Mode)があり、これらはすべて[スコープ粒度](https://ziglang.org/documentation/master/#setRuntimeSafety)に至るまで混在させることが可能です。

| パラメータ | [Debug](/documentation/master/#Debug) | [ReleaseSafe](/documentation/master/#ReleaseSafe) | [ReleaseFast](/documentation/master/#ReleaseFast) | [ReleaseSmall](/documentation/master/#ReleaseSmall) |
|-----------|-------|-------------|-------------|--------------|
最適化 - 速度の向上、デバッグの悪影響、コンパイル時の悪影響 | | -O3 | -O3| -Os |
ランタイムセーフティチェック - 危険速度、危険サイズ、未定義動作の代わりのクラッシュ | On | On | | |

以下は、ビルドモードに関係なく、コンパイル時の[整数オーバーフロー](https://ziglang.org/documentation/master/#Integer-Overflow)の様子です：

{{< zigdoctest "assets/zig-code/features/1-integer-overflow.zig" >}}

以下は、安全性を確認したビルドにおける、実行時の様子です：

{{< zigdoctest "assets/zig-code/features/2-integer-overflow-runtime.zig" >}}


これらは、[freestanding](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html)を含む[すべてのターゲットでスタックトレースが動作します](#stack-traces-on-all-targets)。

Zigでは、安全性を有効にしたビルドモードに依存し、パフォーマンスのボトルネックとなる部分の安全性を選択的に無効化することができます。例えば、前の例はこのように修正することができます：

{{< zigdoctest "assets/zig-code/features/3-undefined-behavior.zig" >}}

Zigは、[未定義の動作](https://ziglang.org/documentation/master/#Undefined-Behavior)を、バグ対策とパフォーマンス向上の両面で、剃刀のように鋭い道具として使っています。

パフォーマンスについて言えば、ZigはCよりも速いです。

- リファレンス実装では、最先端の最適化のためのバックエンドとしてLLVMを使用しています。
- 他のプロジェクトが「リンクタイム最適化」と呼ぶものを、Zigは自動的に行うのです。
- ネイティブターゲットでは、[クロスコンパイルは第一級の使用例](#cross-compiling-is-a-first-class-use-case)のおかげで、高度なCPU機能が有効になります(-march=native)。
- 未定義の挙動を慎重に選択する。例えば、Zigでは符号付き整数も符号なし整数もオーバーフロー時の挙動が未定義であるのに対し、C言語では符号付き整数だけです。これにより、[C言語ではできない最適化が容易になります](https://godbolt.org/z/n_nLEU)。
- Zigは[SIMDベクトル型](https://ziglang.org/documentation/master/#Vectors)を直接公開しており、移植性の高いベクトル化コードを簡単に記述することができます。

Zigは完全な安全言語ではありませんのでご注意ください。Zigの安全性に関するストーリーを追いたい方は、これらの号をご購読ください：

- [安全確認ができないものも含め、あらゆる種類の未定義の動作を列挙する](https://github.com/ziglang/zig/issues/1966)
- [Debug および ReleaseSafe モードを完全に安全なものにする](https://github.com/ziglang/zig/issues/2301)

## ZigはC言語に依存するのではなく、C言語と競争する

Zig標準ライブラリはlibcと統合されていますが、libcに依存しているわけではありません。以下はHello Worldです：

{{< zigdoctest "assets/zig-code/features/4-hello.zig" >}}

`-O ReleaseSmall`、デバッグシンボル除去、シングルスレッドでコンパイルすると、x86_64-linuxターゲットで9.8 KiBの静的実行ファイルが作成されます：
```
$ zig build-exe hello.zig -O ReleaseSmall -fstrip -fsingle-threaded
$ wc -c hello
9944 hello
$ ldd hello
  not a dynamic executable
```

Windowsでのビルドはさらに小さく、4096バイトになります：
```
$ zig build-exe hello.zig -O ReleaseSmall -fstrip -fsingle-threaded -target x86_64-windows
$ wc -c hello.exe
4096 hello.exe
$ file hello.exe
hello.exe: PE32+ executable (console) x86-64, for MS Windows
```

## 順序に依存しないトップレベル宣言

グローバル変数のようなトップレベルの宣言は、順序に依存せず、遅延的に解析される。グローバル変数の初期化値は[コンパイル時に評価](#compile-time-reflection-and-compile-time-code-execution)されます。

{{< zigdoctest "assets/zig-code/features/5-global-variables.zig" >}}

## nullポインタの代わりにオプショナル型

他のプログラミング言語では、null参照は多くの実行時例外の原因となり、[コンピュータサイエンスの最悪の過ち](https://www.lucidchart.com/techblog/2015/08/31/the-worst-mistake-of-computer-science/)とまで非難されています。

飾り気のないZigポインタはnullにできません：

{{< zigdoctest "assets/zig-code/features/6-null-to-ptr.zig" >}}

しかし、どのような型でもその前に?を付けることによって[オプショナル型](https://ziglang.org/documentation/master/#Optionals)にすることができます：

{{< zigdoctest "assets/zig-code/features/7-optional-syntax.zig" >}}

オプションの値をアンラップするには、`orelse`を使ってデフォルト値を指定することができます：

{{< zigdoctest "assets/zig-code/features/8-optional-orelse.zig" >}}

また、ifを使うという選択肢もあります：

{{< zigdoctest "assets/zig-code/features/9-optional-if.zig" >}}

 [while](https://ziglang.org/documentation/master/#while)でも同じ構文が使えます：

{{< zigdoctest "assets/zig-code/features/10-optional-while.zig" >}}

## 手動のメモリ管理

Zigで書かれたライブラリは、どこでも使用することができます：

- [デスクトップアプリケーション](https://github.com/TM35-Metronome/)
- 低レイテンシーサーバ
- [OSカーネル](https://github.com/AndreaOrru/zen)
- [組込み機器](https://github.com/skyfex/zig-nrf-demo/)
- リアルタイムソフトウェア（例：ライブ、飛行機、ペースメーカーなど）
- [WebAssemblyを搭載したWebブラウザやその他プラグイン](https://shritesh.github.io/zigfmt-web/)
- CのABIを使用するその他プログラミング言語呼び出し

これらを実現するために、Zigのプログラマは自分自身のメモリを管理しなければならず、メモリ割り当ての失敗を処理しなければなりません。

これは、Zig標準ライブラリにも当てはまります。メモリを確保する必要がある関数はすべてアロケータパラメータを受け取ります。その結果、Zig標準ライブラリは、独立したターゲットに対しても使用することができます。

Zigでは[エラー処理を見直す](#a-fresh-take-on-error-handling)に加えて、[defer](https://ziglang.org/documentation/master/#defer) と[errdefer](https://ziglang.org/documentation/master/#errdefer)を提供して、メモリに限らずあらゆるリソース管理をシンプルかつ容易に検証できるようにしています。

`defer`の例については、[FFI/バインディングを使わないCライブラリとの統合](#integration-with-c-libraries-without-ffibindings)を参照してください。ここでは、`errdefer`を使用した例を示します：
{{< zigdoctest "assets/zig-code/features/11-errdefer.zig" >}}


## エラー処理を見直す

エラーは値であり、無視できない場合があります：

{{< zigdoctest "assets/zig-code/features/12-errors-as-values.zig" >}}

エラーは[catch](https://ziglang.org/documentation/master/#catch)で処理することができます：

{{< zigdoctest "assets/zig-code/features/13-errors-catch.zig" >}}

キーワード[try](https://ziglang.org/documentation/master/#try)は`catch |err| return err`のショートカットです：

{{< zigdoctest "assets/zig-code/features/14-errors-try.zig" >}}

これは[スタックトレース](#stack-traces-on-all-targets)ではなく[エラーリターントレース](https://ziglang.org/documentation/master/#Error-Return-Traces)であることに注意しましょう。コードはそのトレースを得るためにスタックを巻き戻すという代償を支払わなかったのです。

エラー時に使用される[switch](https://ziglang.org/documentation/master/#switch)キーワードは、起こりうるすべてのエラーを確実に処理するものです：

{{< zigdoctest "assets/zig-code/features/15-errors-switch.zig" >}}

キーワード[unreachable](https://ziglang.org/documentation/master/#unreachable)は、エラーが発生しないことを表明するために使用されます：

{{< zigdoctest "assets/zig-code/features/16-unreachable.zig" >}}

安全でないビルドモードでは[undefined behavior](#performance-and-safety-choose-two)を呼び出すので、成功が保証されている場合にのみ使用するようにしてください。

### すべてのターゲットのスタックトレース

このページで紹介するスタックトレースと[エラーリターントレース](https://ziglang.org/documentation/master/#Error-Return-Traces)は、すべての[Tier 1サポート](#tier-1-support)及びいくつかの[Tier 2サポート](#tier-2-support)ターゲットで機能します。[自立型も](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html)！

さらに、標準ライブラリには、任意の時点でスタックトレースをキャプチャし、後で標準エラーにダンプする機能があります：

{{< zigdoctest "assets/zig-code/features/17-stack-traces.zig" >}}

この手法は、現在進行中の[GeneralPurposeDebugAllocatorプロジェクト](https://github.com/andrewrk/zig-general-purpose-allocator/#current-status)で使用されているのを見ることができます。

## ジェネリックなデータ構造と関数

型とは、コンパイル時に知っておかなければならない値です：

{{< zigdoctest "assets/zig-code/features/18-types.zig" >}}

ジェナリックなデータ構造は、単に`type`を返す関数です：

{{< zigdoctest "assets/zig-code/features/19-generics.zig" >}}

## コンパイル時反映とコンパイル時コード実行

[@typeInfo](https://ziglang.org/documentation/master/#typeInfo)ビルトイン関数でリフレクションを実現します：

{{< zigdoctest "assets/zig-code/features/20-reflection.zig" >}}

Zig標準ライブラリは、この手法でフォーマットprintを実装しています。[小さくシンプルな言語](#small-simple-language)であるにもかかわらず、ZigのフォーマットprintはすべてZigで実装されているのです。一方、C言語では、printfのコンパイルエラーはコンパイラにハードコードされています。同様に、Rustでは、整形印刷マクロはコンパイラにハードコーディングされています。

Zigは関数やコードのブロックをコンパイル時に評価することもできます。グローバル変数の初期化など、いくつかのコンテキストでは、式は暗黙のうちにコンパイル時に評価されます。そうでなければ、[comptime](https://ziglang.org/documentation/master/#comptime)というキーワードを使って、明示的にコンパイル時にコードを評価することができます。これは、アサーションと組み合わせたときに特に強力になります：

{{< zigdoctest "assets/zig-code/features/21-comptime.zig" >}}

## FFI/バインディングを使用しないCライブラリとの統合

[@cImport](https://ziglang.org/documentation/master/#cImport)は、型、変数、関数、簡単なマクロを直接インポートして、Zigで使用することができます。また、インライン関数をC言語からZigに変換することもできます。

[libsoundio](http://libsound.io/)使って正弦波を出す例です：

<u>sine.zig</u>
{{< zigdoctest "assets/zig-code/features/22-sine-wave.zig" >}}

```
$ zig build-exe sine.zig -lsoundio -lc
$ ./sine
Output device: Built-in Audio Analog Stereo
^C
```

[このZigのコードは、同等のC言語のコードよりもかなりシンプルです](https://gist.github.com/andrewrk/d285c8f912169329e5e28c3d0a63c1d8)また、より多くの安全保護機能を備えており、これらはすべてCのヘッダーファイルを直接インポートすることで実現されています（APIバインディングなし）。

*Zigは、C言語がC言語のライブラリを使うより、Cのライブラリを使う方が得意です。*

### ZigはC言語コンパイラでもある

ここでは、ZigがC言語のコードを構築する例を紹介します：

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

このとき実行されたC言語コンパイラのコマンドは`--verbose-cc`で確認することができます：
```
$ zig build-exe hello.c --library c --verbose-cc
zig cc -MD -MV -MF zig-cache/tmp/42zL6fBH8fSo-hello.o.d -nostdinc -fno-spell-checking -isystem /home/andy/dev/zig/build/lib/zig/include -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-gnu -isystem /home/andy/dev/zig/build/lib/zig/libc/include/generic-glibc -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-any -isystem /home/andy/dev/zig/build/lib/zig/libc/include/any-linux-any -march=native -g -fstack-protector-strong --param ssp-buffer-size=4 -fno-omit-frame-pointer -o zig-cache/tmp/42zL6fBH8fSo-hello.o -c hello.c -fPIC
```

なお、もう一度コマンドを実行すると、出力はなく、即座に終了します：
```
$ time zig build-exe hello.c --library c --verbose-cc

real	0m0.027s
user	0m0.018s
sys	0m0.009s
```

これは、[Build Artifact Caching](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching)のおかげです。Zigは.dファイルを自動的に解析し、作業の重複を避けるために堅牢なキャッシュシステムを使用します。

ZigはC言語コードをコンパイルできるだけでなく、ZigをC言語コンパイラとして使用する非常に良い理由があります：[Zigはlibcと一緒に出荷されています](#zig-ships-with-libc).

### C言語コードに依存する関数、変数、型のエクスポート

Zigの主な使用例の1つは、他のプログラミング言語から呼び出せるように、C言語のABIを持つライブラリをエクスポートすることです。関数、変数、型の前に`export`キーワードを付けると、それらがライブラリAPIの一部となります：

<u>mathtest.zig</u>
{{< zigdoctest "assets/zig-code/features/23-math-test.zig" >}}

静的ライブラリを作成するには：
```
$ zig build-lib mathtest.zig
```

シェアードライブラリを作成するには：
```
$ zig build-lib mathtest.zig -dynamic
```

ここでは、[Zig Build System](#zig-build-system)を使った例を紹介します：

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

## クロスコンパイルは第一級のユースケース

Zigは[サポート表](#support-table)にあるどのターゲットに対しても、[Tier3サポート](#tier-3-support)以上の条件でビルドすることが可能です。「クロスツールチェーン」をインストールしたりする必要はありません。以下は、ネイティブなHello Worldです：

{{< zigdoctest "assets/zig-code/features/4-hello.zig" >}}

あとは、x86_64-windows, x86_64-macos, aarch64-linux用にビルドします：
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

[Tier 3](#tier-3-support)以上のターゲットであれば、どのようなターゲットにも有効である。

### Zigにはlibcが付属しています

利用可能なlibcのターゲットは`zig targets`で見つけることができます：
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

このことは、これらのターゲットの`--library c`は*どのシステムファイルにも依存しない*ということを意味します！

もう一度、[Cのhello worldの例](#zig-is-also-a-c-compiler)を見てみましょう：
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

[glibc](https://www.gnu.org/software/libc/)は静的ビルドをサポートしていませんが、[musl](https://www.musl-libc.org/)はサポートしています：
```
$ zig build-exe hello.c --library c -target x86_64-linux-musl
$ ./hello
Hello world
$ ldd hello
  not a dynamic executable
```

この例では、Zigはmusl libcをソースからビルドし、それに対してリンクしています。x86_64-linux用のmusl libcのビルドは[caching system](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching)のおかげで利用可能なままなので、このlibcが再び必要になったときには即座に利用可能な状態になります。

つまり、この機能はどのプラットフォームでも利用できるのです。WindowsとmacOSのユーザーは、上記のどのターゲットに対しても、ZigとCのコードをビルドし、libcに対してリンクすることができます。同様に、他のアーキテクチャ用にクロスコンパイルすることも可能です：
```
$ zig build-exe hello.c --library c -target aarch64-linux-gnu
$ file hello
hello: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, for GNU/Linux 2.0.0, with debug_info, not stripped
```

ある意味、ZigはCコンパイラーよりも優れたCコンパイラーです！

この機能は、Zigと一緒にクロスコンパイルツールチェーンをバンドルしている以上のものです。例えば、Zigが出荷するlibcのヘッダの総サイズは、非圧縮で22MiBです。一方、x86_64のmusl libc + linux headersだけで8MiB、glibcでは3.1MiB（glibcにはlinux headersがない）ですが、Zigには現在40のlibcsが同梱されています。素朴なバンドルでは、444MiBになります。しかし、この[process_headers tool](https://github.com/ziglang/zig/blob/0.4.0/libc/process_headers.zig)と、いくつかの[good old manual labor](https://github.com/ziglang/zig/wiki/Updating-libc)のおかげで、Zigのバイナリtarballは、これらすべてのターゲットに対してlibcをサポートし、さらにcompiler-rt、libunwind、libcxx、そしてclang互換のC言語コンパイラにもかかわらず、およそ30 MiBのままになっています。比較のために、llvm.orgからclang 8.0.0自体のWindowsバイナリビルドは、132MiBです。

なお、[Tier 1 Support](#tier-1-support)ターゲットのみが徹底的にテストされています。今後、[libcsの追加](https://github.com/ziglang/zig/issues/514)(Windows用も含む)及び[すべてのlibcsに対してビルドするためのテストカバレッジの追加](https://github.com/ziglang/zig/issues/2058)が予定されています。

[Zigパッケージマネージャを搭載する予定](https://github.com/ziglang/zig/issues/943)ですがまだできていません。そのひとつは、Cライブラリのパッケージを作ることです。これによって、[Zigビルドシステム](#zig-build-system)ZigプログラマにとってもCプログラマにとっても魅力的なものになるはずです。

## Zigビルドシステム

Zigにはビルドシステムが付属しているので、makeやcmakeなどは必要ありません。
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


その`--help`メニューを見てみましょう。
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

利用可能なステップの1つが実行されていることがわかります。
```
$ zig build run
All your base are belong to us.
```

以下は、ビルドスクリプトの例です：

- [OpenGLテトリスゲームのビルドスクリプト](https://github.com/andrewrk/tetris/blob/master/build.zig)
- [ベアメタルRaspberry Pi 3アーケードゲーム構築スクリプト](https://github.com/andrewrk/clashos/blob/master/build.zig)
- [自作Zigコンパイラのビルドスクリプト](https://github.com/ziglang/zig/blob/master/build.zig)

## 非同期関数による並行処理

Zig 0.5.0[非同期関数の導入](https://ziglang.org/download/0.5.0/release-notes.html#Async-Functions)。この機能はホストOSに依存せず、ヒープで確保されたメモリにも依存しない。つまり、自立したターゲットで非同期関数が利用できるのです。

Zigは関数が非同期かどうかを推測し、非同期でない関数では`async`/`await`を許可します。これは、**Zigライブラリはブロッキングと非同期I/Oの区別がつかない**ということを意味します。[Zigは関数カラーを避ける](http://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/).



Zig標準ライブラリは、非同期関数をスレッドプールに多重化するイベントループを実装し、M:N並列を実現しています。マルチスレッドの安全性と競合検出は、現在活発に研究されている分野です。

## 幅広いターゲットへの対応

Zigは、ターゲットごとにサポートレベルを伝える「サポートティア」制度を採用しています。

[Zig 0.8.0時点でのサポート表](/download/0.8.0/release-notes.html#Support-Table)

## パッケージメンテナへのフレンドリーな対応

リファレンスのZigコンパイラはまだ完全にセルフホスティングされていませんが、何があっても、システムC++コンパイラを持つことから、どんなターゲットに対しても完全にセルフホスティングされたZigコンパイラを持つことまでは、[ちょうど3ステップ](https://github.com/ziglang/zig/issues/853)で済みます。Maya Rashishが指摘するように、[Zigの他のプラットフォームへの移植は楽しくてスピーディ](http://coypu.sdf.org/porting-zig.html)なのです。

非デバッグ[ビルドモード](https://ziglang.org/documentation/master/#Build-Mode)は再現性/決定性があります。

[JSON版ダウンロードページ](/download/index.json)があります。

Zigチームには、パッケージの保守を経験したメンバーが何人もいます。

- [Daurnimator](https://github.com/daurnimator)は[Arch Linuxパッケージ](https://archlinux.org/packages/extra/x86_64/zig/)を保守しています。
- [Marc Tiehuis](https://tiehuis.github.io/)は、Visual Studio Codeパッケージを管理しています。
- [Andrew Kelley](https://andrewkelley.me/)は、1年ほどかけて[DebianとUbuntuのパッケージング](https://qa.debian.org/developer.php?login=superjoe30%40gmail.com&comaint=yes)を行い、さりげなく[nixpkgs](https://github.com/NixOS/nixpkgs/)にコントリビュートしています。
- [Jeff Fowler](https://blog.jfo.click/)はHomebrewパッケージを保守し、[Sublimeパッケージ](https://github.com/ziglang/sublime-zig-language)を開始しました(現在は[emekoi](https://github.com/emekoi)が保守しています)。
