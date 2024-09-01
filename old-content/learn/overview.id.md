---
title: "Penjelasan Lengkap"
mobile_menu_title: "Penjelasan"
toc: true
---
# Fitur Unggulan
## Bahasa ringkas dan sederhana

Fokus perbaiki aplikasi anda daripada menghadapi masalah dalam pemahaman bahasa pemrograman anda.

Sintaks Zig secara keseluruhan ditentukan dalam [file grammar PEG sepanjang 500 baris](https://ziglang.org/documentation/master/#Grammar).

Tidak ada **control flow tersembunyi**, alokasi memori tersembunyi, preprocessor, atau makro. Jika kode Zig tidak terlihat seperti melompat untuk memanggil sebuah fungsi, maka memang tidak. Ini berarti anda dapat yakin bahwa kode berikut hanya memanggil `foo()` dan kemudian `bar()`, dan ini dijamin tanpa perlu tahu jenis dari apapun:
```zig
var a = b + c.d;
foo();
bar();
```

Contoh control flow tersembunyi:

- D memiliki fungsi `@property`, merupakan metode yang anda panggil dengan tampilan akses field, jadi dalam contoh di atas, `c.d` mungkin memanggil fungsi.
- C++, D, dan Rust memiliki overloading operator, sehingga operator `+` mungkin memanggil sebuah fungsi.
- C++, D, dan Go memiliki exception throw/catch, sehingga `foo()` mungkin melempar exception dan mencegah pemanggilan `bar()`.

 Zig mendorong pemeliharaan dan keterbacaan kode dengan mengelola seluruh control flow secara eksklusif menggunakan kata kunci bahasa dan pemanggilan fungsi.

## Performa dan Keamanan: Pilih Keduanya

Zig memiliki empat [mode build](https://ziglang.org/documentation/master/#Build-Mode), dan semuanya dapat dikombinasikan dan dicocokkan hingga ke [perincian cakupan](https://ziglang.org/documentation/master/#setRuntimeSafety).


| Parameter | [Debug](/documentation/master/#Debug) | [ReleaseSafe](/documentation/master/#ReleaseSafe) | [ReleaseFast](/documentation/master/#ReleaseFast) | [ReleaseSmall](/documentation/master/#ReleaseSmall) |
|-----------|-------|-------------|-------------|--------------|
Optimasi - meningkatkan kecepatan, mengganggu proses debugging, perlambat waktu kompilasi | | -O3 | -O3| -Os |
Cek Keamanan Runtime - perlambat kecepatan, perbesar ukuran, gagal daripada perilaku yang tidak ditentukan | On | On | | |

Berikut tampilan [Integer Overflow](https://ziglang.org/documentation/master/#Integer-Overflow) saat waktu kompilasi, tanpa memandang mode build:

{{< zigdoctest "assets/zig-code/features/1-integer-overflow.zig" >}}

Berikut tampilan saat runtime, pada mode build safety-checked:

{{< zigdoctest "assets/zig-code/features/2-integer-overflow-runtime.zig" >}}


[Stack trace berfungsi pada semua target](#stack-trace-pada-semua-target), termasuk dalam mode [freestanding](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html).

Dengan Zig, seseorang dapat mengandalkan mode build safety-enabled, dan secara selektif menonaktifkan safety pada titik-titik kinerja yang kritis. Sebagai contoh, kode sebelumnya dapat dimodifikasi seperti ini:

{{< zigdoctest "assets/zig-code/features/3-undefined-behavior.zig" >}}

Zig menggunakan [perilaku tidak terdefinisi (undefined behavior)](https://ziglang.org/documentation/master/#Undefined-Behavior) sebagai tool yang sangat presisi untuk mencegah bug dan meningkatkan kinerja.

Berbicara tentang performa, Zig lebih cepat daripada C.

- Implementasi referensi menggunakan LLVM sebagai backend untuk optimisasi terkini.
- Apa yang disebut proyek lain sebagai "Link Time Optimization" Zig melakukannya secara otomatis.
- Untuk sasaran yang spesifik, fitur-fitur canggih pada CPU diaktifkan (-march=native), berkat fakta bahwa [Cross Compiling adalah prioritas utama](#cross-compiling-adalah-prioritas-utama).
- Perilaku tidak terdefinisi (undefined behavior) dipilih dengan hati-hati. Sebagai contoh, dalam Zig, baik signed dan unsigned integer memiliki perilaku tidak terdefinisi (undefined behavior) saat overflow, berbeda dengan signed integer di C. Hal ini [memfasilitasi optimisasi yang tidak tersedia di C](https://godbolt.org/z/n_nLEU).
- Zig secara langsung mengekspos [tipe vektor SIMD](https://ziglang.org/documentation/master/#Vectors), memudahkan penulisan kode vektorisasi portabel.

Harap diingat bahwa Zig bukan bahasa yang sepenuhnya aman. Bagi yang tertarik mengikuti kisah keamanan Zig, berlanggananlah pada isu-isu berikut:

- [mencantumkan semua jenis perilaku tidak terdefinisi, bahkan yang tidak dapat diperiksa keamanannya](https://github.com/ziglang/zig/issues/1966)
- [membuat mode Debug dan ReleaseSafe sepenuhnya aman](https://github.com/ziglang/zig/issues/2301)

## Zig bersaing dengan C alih-alih mengandalkannya

Library Standar Zig terintegrasi dengan libc, namun tidak bergantung padanya. Berikut adalah contoh Hello World:

{{< zigdoctest "assets/zig-code/features/4-hello.zig" >}}

Ketika dikompilasi dengan `-O ReleaseSmall`, simbol-simbol debug dihapus, dalam mode single-threaded, ini menghasilkan file eksekusi statis sebesar 9.8 KiB untuk target x86_64-linux:
```
$ zig build-exe hello.zig -O ReleaseSmall -fstrip -fsingle-threaded
$ wc -c hello
9944 hello
$ ldd hello
  not a dynamic executable
```

Untuk build Windows bahkan lebih kecil, hanya 4096 bytes:
```
$ zig build-exe hello.zig -O ReleaseSmall -fstrip -fsingle-threaded -target x86_64-windows
$ wc -c hello.exe
4096 hello.exe
$ file hello.exe
hello.exe: PE32+ executable (console) x86-64, for MS Windows
```

## Deklarasi top level yang tidak bergantung pada urutan

Deklarasi top level seperti variabel global tidak tergantung pada urutan dan dievaluasi secara lambat (lazily analyzed). Nilai inisialisasi dari variabel global dievaluasi [pada waktu kompilasi](#refleksi-waktu-kompilasi-dan-eksekusi-kode-pada-waktu-kompilasi).

{{< zigdoctest "assets/zig-code/features/5-global-variables.zig" >}}


## Tipe Opsional (Optional type) sebagai pengganti Pointer Null

Dalam bahasa pemrograman lain, referensi null menjadi sumber dari banyak pengecualian saat berjalan, dan bahkan dianggap sebagai [kesalahan terburuk dalam ilmu komputer](https://www.lucidchart.com/techblog/2015/08/31/the-worst-mistake-of-computer-science/).

Pointer Zig yang tidak ditandai dengan eksplisit tidak bisa bernilai null:

{{< zigdoctest "assets/zig-code/features/6-null-to-ptr.zig" >}}

Namun, tipe apa pun dapat diubah menjadi [tipe opsional (optional type)](https://ziglang.org/documentation/master/#Optionals) dengan menambahkan tanda `?` di depannya:

{{< zigdoctest "assets/zig-code/features/7-optional-syntax.zig" >}}

Untuk membuka nilai opsional, dapat menggunakan `orelse` untuk memberikan nilai default:

{{< zigdoctest "assets/zig-code/features/8-optional-orelse.zig" >}}

Pilihan lainnya adalah menggunakan if:

{{< zigdoctest "assets/zig-code/features/9-optional-if.zig" >}}

 Sintaks yang sama berlaku dengan [while](https://ziglang.org/documentation/master/#while):

{{< zigdoctest "assets/zig-code/features/10-optional-while.zig" >}}

## Manajemen memori manual

Library yang ditulis dalam Zig dapat digunakan di berbagai tempat:

- [Aplikasi Desktop](https://github.com/TM35-Metronome/)
- Server dengan laten rendah (low latency)
- [Kernel Sistem Operasi](https://github.com/AndreaOrru/zen)
- [Perangkat Embedded](https://github.com/skyfex/zig-nrf-demo/)
- Real-time software, misalnya live performance, pesawat, pacemakers
- [Di web browser atau plugin lain dengan WebAssembly](https://shritesh.github.io/zigfmt-web/)
- Oleh bahasa pemrograman lain, menggunakan ABI C

Untuk mencapai hal ini, programmer Zig harus mengelola memori mereka sendiri dan mengatasi kegagalan alokasi memori.

Hal ini juga berlaku untuk Zig Standard Library. Fungsi-fungsi apa pun yang perlu mengalokasikan memori menerima parameter alokator. Akibatnya, Zig Standard Library dapat digunakan bahkan untuk target freestanding.

Selain dari [Pendekatan baru dalam penanganan error (error handling)](#pendekatan-baru-dalam-penanganan-error-error-handling), Zig menyediakan [defer](https://ziglang.org/documentation/master/#defer) dan [errdefer](https://ziglang.org/documentation/master/#errdefer) untuk menjadikan manajemen sumber daya - tidak hanya memori - menjadi sederhana dan mudah diverifikasi.

Untuk contoh penggunaan `defer`, lihat [Integrasi dengan library C tanpa FFI/Binding](#integrasi-dengan-library-c-tanpa-ffibindings). Berikut adalah contoh penggunaan `errdefer`:
{{< zigdoctest "assets/zig-code/features/11-errdefer.zig" >}}


## Pendekatan baru dalam penanganan error (error handling)

Error adalah nilai, dan tidak boleh diabaikan:

{{< zigdoctest "assets/zig-code/features/12-errors-as-values.zig" >}}

Semua error dapat ditangani dengan [catch](https://ziglang.org/documentation/master/#catch):

{{< zigdoctest "assets/zig-code/features/13-errors-catch.zig" >}}

Kata kunci [try](https://ziglang.org/documentation/master/#try) merupakan shortcut untuk `catch |err| return err`:

{{< zigdoctest "assets/zig-code/features/14-errors-try.zig" >}}

Perlu dicatat bahwa ini merupakan [Error Return Trace](https://ziglang.org/documentation/master/#Error-Return-Traces), bukan [stack trace](#stack-trace-pada-semua-target). Kode Tidak perlu `stack unwinding` untuk menghasilkan jejak tersebut.

Kata kunci [switch](https://ziglang.org/documentation/master/#switch) yang digunakan pada sebuah error untuk memastikan bahwa semua kemungkinan error telah ditangani:

{{< zigdoctest "assets/zig-code/features/15-errors-switch.zig" >}}

Kata kunci [unreachable](https://ziglang.org/documentation/master/#unreachable) digunakan untuk menegaskan bahwa tidak akan ada error yang terjadi:

{{< zigdoctest "assets/zig-code/features/16-unreachable.zig" >}}

Ini memanggil [perilaku tidak terdefinisi (undefined behavior)](#performa-dan-keamanan-pilih-keduanya) dalam mode build unsafe, jadi pastikan untuk menggunakannya hanya ketika keberhasilan telah terjamin.

### Stack trace pada semua target

Stack trace dan [error return trace](https://ziglang.org/documentation/master/#Error-Return-Traces) yang ditampilkan pada halaman ini berfungsi pada semua [dukungan tier 1](#tier-1-support) dan beberapa [dukungan tier 2](#tier-2-support). [Bahkan untuk freestanding](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html)!

Selain itu, Library Standar memiliki kemampuan untuk menangkap stack trace pada titik manapun dan kemudian mengeluarkannya ke standar error nanti:

{{< zigdoctest "assets/zig-code/features/17-stack-traces.zig" >}}

Anda dapat melihat teknik ini digunakan dalam [proyek GeneralPurposeDebugAllocato](https://github.com/andrewrk/zig-general-purpose-allocator/#current-status) yang sedang berlangsung.

## Struktur dan fungsi data generik

Types adalah nilai yang harus diketahui pada waktu kompilasi:

{{< zigdoctest "assets/zig-code/features/18-types.zig" >}}

Struktur data generik merupakan fungsi yang mengembalikan `type`:

{{< zigdoctest "assets/zig-code/features/19-generics.zig" >}}

## Refleksi waktu kompilasi dan eksekusi kode pada waktu kompilasi

Fungsi bawaan [@typeInfo](https://ziglang.org/documentation/master/#typeInfo) memberikan refleksi:

{{< zigdoctest "assets/zig-code/features/20-reflection.zig" >}}

Library Standar Zig menggunakan teknik ini untuk mengimplementasikan pencetakan berformat. Meskipun Zig adalah [bahasa ringkas dan sederhana](#bahasa-ringkas-dan-sederhana), pencetakan berformat dalam Zig diimplementasikan sepenuhnya dalam Zig. Di sisi lain, dalam bahasa C, kesalahan kompilasi untuk printf diatur secara hard-coded di dalam kompiler. Demikian pula, dalam Rust, makro pencetakan berformat diatur secara hard-coded di dalam kompiler.

Zig juga dapat mengevaluasi fungsi dan blok kode pada waktu kompilasi. Dalam beberapa konteks, seperti inisialisasi variabel global, ekspresi dievaluasi secara implisit pada waktu kompilasi. Jika tidak, kita dapat mengevaluasi kode secara eksplisit pada waktu kompilasi dengan kata kunci [comptime](https://ziglang.org/documentation/master/#comptime). Ini dapat menjadi sangat berguna saat digabungkan dengan assersi:

{{< zigdoctest "assets/zig-code/features/21-comptime.zig" >}}

## Integrasi dengan library C tanpa FFI/bindings

[@cImport](https://ziglang.org/documentation/master/#cImport) mengimpor langsung types, variabel, fungsi, dan makro sederhana dari C untuk digunakan dalam Zig. Bahkan, ini menerjemahkan fungsi inline dari C menjadi Zig.

Berikut adalah contoh menghasilkan gelombang sinus (sine wave) menggunakan [libsoundio](http://libsound.io/):

<u>sine.zig</u>
{{< zigdoctest "assets/zig-code/features/22-sine-wave.zig" >}}

```
$ zig build-exe sine.zig -lsoundio -lc
$ ./sine
Output device: Built-in Audio Analog Stereo
^C
```

[Kode Zig ini jauh lebih sederhana daripada kode C yang setara](https://gist.github.com/andrewrk/d285c8f912169329e5e28c3d0a63c1d8), serta memiliki lebih banyak perlindungan keamanan, dan semua ini dicapai dengan mengimpor langsung berkas header C - tanpa perlu API bindings.

*Zig lebih baik dalam menggunakan library C daripada C dalam menggunakan library C.*

### Zig juga merupakan kompiler C

Berikut contoh Zig build kode C:

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

Anda dapat menggunakan `--verbose-cc` untuk melihat perintah kompiler C yang dieksekusi:
```
$ zig build-exe hello.c --library c --verbose-cc
zig cc -MD -MV -MF zig-cache/tmp/42zL6fBH8fSo-hello.o.d -nostdinc -fno-spell-checking -isystem /home/andy/dev/zig/build/lib/zig/include -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-gnu -isystem /home/andy/dev/zig/build/lib/zig/libc/include/generic-glibc -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-any -isystem /home/andy/dev/zig/build/lib/zig/libc/include/any-linux-any -march=native -g -fstack-protector-strong --param ssp-buffer-size=4 -fno-omit-frame-pointer -o zig-cache/tmp/42zL6fBH8fSo-hello.o -c hello.c -fPIC
```

Perlu diperhatikan bahwa jika anda menjalankan perintah tersebut lagi, tidak ada output, dan proses selesai dengan cepat:
```
$ time zig build-exe hello.c --library c --verbose-cc

real	0m0.027s
user	0m0.018s
sys	0m0.009s
```

Ini berkat [Build Artifact Caching](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching). Zig secara otomatis mengurai file .d dan menggunakan sistem caching yang kuat untuk menghindari duplikasi pekerjaan.

Bukan hanya Zig dapat mengkompilasi kode C, tetapi ada alasan yang sangat bagus untuk menggunakan Zig sebagai kompiler C: [Zig disertai dengan libc](#zig-disertai-dengan-libc).

### Eksport fungsi, variabel, dan types agar dapat digunakan oleh kode C

Salah satu kasus penggunaan utama Zig adalah menghasilkan library dengan ABI C untuk dipanggil oleh bahasa pemrograman lain. Kata kunci `export` sebelum fungsi, variabel, dan tipe membuatnya menjadi bagian dari API library:

<u>mathtest.zig</u>
{{< zigdoctest "assets/zig-code/features/23-math-test.zig" >}}

Untuk membuat library statis:
```
$ zig build-lib mathtest.zig
```

Untuk membuat shared library:
```
$ zig build-lib mathtest.zig -dynamic
```

Berikut contohnya dengan [Sistem Build Zig](#sistem-build-zig):

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

## Cross-compiling adalah prioritas utama

Zig mampu melakukan build untuk salah satu target dari [tabel dukungan](#support-table) dengan [dukungan tier 3](#tier-3-support) atau yang lebih baik. Tidak diperlukan "cross toolchain" yang harus diinstal atau hal serupa. Berikut ini contoh Hello World untuk native target:

{{< zigdoctest "assets/zig-code/features/4-hello.zig" >}}

Sekarang build untuk x86_64-windows, x86_64-macos, dan aarch64-linux:
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

Ini berfungsi pada semua target [dukungan tier 3](#tier-3-support)+, untuk semua target [dukungan tier 3](#tier-3-support)+.

### Zig disertai dengan libc

Anda dapat menemukan target-target libc yang tersedia dengan `zig targets`:
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

Artinya, `--library c` untuk target-target ini *tidak mengandalkan berkas sistem apa pun*!

Mari kita lihat contoh [C hello world](#zig-juga-merupakan-kompiler-c) lagi:
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

[glibc](https://www.gnu.org/software/libc/) tidak mendukung pembangunan statis, tetapi [musl](https://www.musl-libc.org/) mendukung:
```
$ zig build-exe hello.c --library c -target x86_64-linux-musl
$ ./hello
Hello world
$ ldd hello
  not a dynamic executable
```

Pada contoh ini, Zig membuat musl libc dari sumber dan kemudian mengaitkannya. Build musl libc untuk x86_64-linux tetap tersedia berkat [sistem caching](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching), sehingga setiap kali libc ini dibutuhkan kembali, itu akan tersedia seketika.

Ini berarti bahwa fungsionalitas ini tersedia pada platform mana pun. Pengguna Windows dan macOS dapat membangun Zig dan kode C, serta mengaitkannya dengan libc, untuk salah satu target yang terdaftar di atas. Demikian pula, kode dapat dikompilasi silang untuk arsitektur lain:
```
$ zig build-exe hello.c --library c -target aarch64-linux-gnu
$ file hello
hello: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, for GNU/Linux 2.0.0, with debug_info, not stripped
```

Dalam beberapa hal, Zig merupakan kompiler C yang lebih baik daripada kompiler C!

Fungsionalitas ini lebih dari sekadar bundling cross-compilation toolchain bersama dengan Zig. Sebagai contoh, total ukuran header libc yang disertakan Zig adalah 22 MiB tidak terkompresi. Sementara itu, header untuk musl libc + linux headers pada x86_64 saja adalah 8 MiB, dan untuk glibc adalah 3,1 MiB (glibc tidak menyertakan header linux), namun Zig saat ini menyertakan 40 libc. Dengan bundling sederhana, ukurannya akan menjadi 444 MiB. Namun, berkat [tool process_headers ini](https://github.com/ziglang/zig/blob/0.4.0/libc/process_headers.zig), dan beberapa [pekerjaan manual yang baik](https://github.com/ziglang/zig/wiki/Updating-libc), paket tar Zig tetap sekitar 30 MiB secara keseluruhan, meskipun mendukung libc untuk semua target ini, serta compiler-rt, libunwind, dan libcxx, dan meskipun menjadi kompiler C yang kompatibel dengan clang. Untuk perbandingan, build binary Windows dari clang 8.0.0 itu sendiri dari llvm.org adalah 132 MiB.

Perlu diperhatikan bahwa hanya target [dukungan tier 1](#tier-1-support) yang telah diuji secara menyeluruh. Ada rencana untuk [menambahkan lebih banyak libc](https://github.com/ziglang/zig/issues/514) (termasuk untuk Windows), dan untuk [menambahkan cakupan pengujian untuk building dengan semua libc](https://github.com/ziglang/zig/issues/2058).

Rencananya akan ada [Zig Package Manager](https://github.com/ziglang/zig/issues/943), tetapi belum selesai. Salah satu hal yang akan dimungkinkan adalah membuat paket untuk library C. Ini akan membuat [Sistem Build Zig](#sistem-build-zig) menarik bagi programmer Zig dan programmer C.

## Sistem Build Zig

Zig dilengkapi dengan sistem build, sehingga anda tidak perlu make, cmake, atau sejenisnya.
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


Mari kita lihat menu `--help` tersebut.
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

Anda dapat melihat bahwa salah satu langkah yang tersedia adalah `run`.
```
$ zig build run
All your base are belong to us.
```

Berikut beberapa contoh skrip build:

- [Build script of OpenGL Tetris game](https://github.com/andrewrk/tetris/blob/master/build.zig)
- [Build script of bare metal Raspberry Pi 3 arcade game](https://github.com/andrewrk/clashos/blob/master/build.zig)
- [Build script of self-hosted Zig compiler](https://github.com/ziglang/zig/blob/master/build.zig)

## Concurrency melalui Fungsi Async

Zig 0.5.0 [memperkenalkan fungsi async](https://ziglang.org/download/0.5.0/release-notes.html#Async-Functions). Fitur ini tidak memiliki ketergantungan pada sistem operasi host atau bahkan alokasi memori heap. Ini berarti fungsi async tersedia untuk target freestanding.

Zig menyimpulkan apakah sebuah fungsi bersifat async, dan memungkinkan penggunaan `async`/`await` pada fungsi-fungsi yang tidak bersifat async, yang berarti bahwa **library Zig bersifat agnostik terhadap blocking vs async I/O**. [Zig menghindari "warna fungsi"](http://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/).

Library Standar Zig mengimplementasikan event loop yang memfungsikan fungsi-fungsi async ke dalam thread pool untuk concurrency M:N. Keamanan multithreading dan deteksi race adalah area penelitian aktif.

## dukungan untuk beragam target

Zig menggunakan sistem "tingkat dukungan (support tier)" untuk mengkomunikasikan tingkat dukungan untuk berbagai target.

[Tabel dukungan (support tier) saat Zig 0.8.0](/download/0.8.0/release-notes.html#Support-Table)

## Ramah terhadap para pemelihara paket

Referensi kompiler Zig belum sepenuhnya self-hosted, tetapi tidak peduli, [tetap hanya 3 langkah](https://github.com/ziglang/zig/issues/853) untuk beralih dari memiliki sistem kompiler C++ menjadi kompiler Zig yang sepenuhnya self-hosted untuk target apapun. Seperti yang dicatat oleh Maya Rashish, [memporting Zig ke platform lain sangat cepat dan meneyenangkan](http://coypu.sdf.org/porting-zig.html).

[Mode build](https://ziglang.org/documentation/master/#Build-Mode) non-debug bersifat dapat diproduksi/deterministik.

Terdapat [versi JSON dari halaman unduh](/download/index.json).

Beberapa anggota tim Zig memiliki pengalaman dalam memelihara paket.

- [Daurnimator](https://github.com/daurnimator) memelihara paket [Arch Linux](https://archlinux.org/packages/extra/x86_64/zig/)
- [Marc Tiehuis](https://tiehuis.github.io/) memelihara paket Visual Studio Code.
- [Andrew Kelley](https://andrewkelley.me/) menghabiskan setahun atau lebih dalam proses [packaging paket Debian dan Ubuntu](https://qa.debian.org/developer.php?login=superjoe30%40gmail.com&comaint=yes), dan secara santai berkontribusi ke [nixpkgs](https://github.com/NixOS/nixpkgs/).
- [Jeff Fowler](https://blog.jfo.click/) memelihara paket Homebrew dan memulai paket [Sublime](https://github.com/ziglang/sublime-zig-language) (sekarang dikelola oleh [emekoi](https://github.com/emekoi)).

