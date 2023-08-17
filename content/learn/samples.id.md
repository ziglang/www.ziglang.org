---
title: "Contoh Kode"
mobile_menu_title: "Contoh Kode"
toc: true
---

## Deteksi kebocoran memori
Dengan menggunakan `std.heap.GeneralPurposeAllocator`, anda dapat melacak pembebasan ganda dan kebocoran memori.

{{< zigdoctest "assets/zig-code/samples/1-memory-leak.zig" >}}


## Interoperabilitas dengan Bahasa C
Contoh mengimpor file header C dan menghubungkannya ke libc dan raylib.

{{< zigdoctest "assets/zig-code/samples/2-c-interop.zig" >}}


## Zigg Zagg
Zig *dioptimalkan* untuk wawancara pemrograman (sebenarnya tidak).

{{< zigdoctest "assets/zig-code/samples/3-ziggzagg.zig" >}}


## Tipe Generik (Generic Types)
Di Zig, types merupakan nilai-nilai comptime dan kami menggunakan fungsi yang mengembalikan type untuk mengimplementasikan algoritma dan struktur data generik. Dalam contoh ini, kami mengimplementasikan sebuah antrian generik sederhana dan menguji perilakunya.

{{< zigdoctest "assets/zig-code/samples/4-generic-type.zig" >}}


## Menggunakan cURL dari Zig

{{< zigdoctest "assets/zig-code/samples/5-curl.zig" >}}
