---
title: "Mengapa Zig Jika Sudah Ada C++, D, dan Rust?"
mobile_menu_title: "Mengapa Zig Jika..."
toc: true
---


## Tidak ada control flow tersembunyi

Jika kode Zig tidak terlihat seperti melompat ke fungsi lain, maka memang begitu adanya. Ini berarti anda dapat yakin bahwa kode berikut hanya memanggil `foo()` dan kemudian `bar()`, dan ini dijamin tanpa perlu mengetahui tipe apapun:

```zig
var a = b + c.d;
foo();
bar();
```

Contoh control flow tersembunyi:

* D memiliki fungsi `@property`, merupakan metode yang anda panggil dengan tampilan akses field, jadi dalam contoh di atas, `c.d` mungkin memanggil fungsi.
* C++, D, dan Rust memiliki overloading operator, sehingga operator `+` mungkin memanggil sebuah fungsi.
* C++, D, dan Go memiliki exception throw/catch, sehingga `foo()` mungkin melempar exception dan mencegah pemanggilan `bar()`.

Alasan di balik keputusan desain ini adalah untuk membuatnya lebih mudah dibaca.

## Tidak ada alokasi yang tersembunyi

Zig memiliki pendekatan yang minim dalam hal alokasi heap. Tidak ada kata kunci `new`
atau fitur bahasa lain yang menggunakan alokator heap (misalnya operator penggabungan string[1]).
Konsep heap seluruhnya dikelola oleh library dan aplikasi, bukan oleh bahasa itu sendiri.

Contoh alokasi tersembunyi:

* Dalam bahasa Go, `defer` mengalokasikan memori ke stack function-local. Selain menjadi cara yang tidak intuitif untuk control flow ini bekerja, hal ini dapat menyebabkan kegagalan out-of-memory jika anda menggunakan `defer` di dalam suatu perulangan.
* Coroutines C++ mengalokasikan memori heap untuk memanggil suatu coroutine.
* Dalam Go, panggilan fungsi dapat menyebabkan alokasi heap karena goroutine mengalokasikan stack kecil yang diubah ukurannya saat panggilan untuk stack menjadi cukup dalam.
* API utama dari library standar Rust memunculkan kondisi panic saat out of memory, dan alternatif
  API yang menerima parameter alokator adalah afterthought
  (lihat [rust-lang/rust#29802](https://github.com/rust-lang/rust/issues/29802)).

Hampir semua bahasa yang memiliki garbage kolektor memiliki alokasi tersembunyi tersebar di mana-mana, karena
garbage kolektor menyembunyikan bukti di sisi pembersihan.

Masalah utama dengan alokasi tersembunyi adalah bahwa ini mencegah *reusabilitas* darisebuah kode, secara tidak perlu membatasi jumlah lingkungan di mana kode tersebut cocok untuk digunakan. Singkatnya, ada kasus penggunaan di mana seseorang harus dapat mengandalkan control flow dan panggilan fungsi tanpa memiliki efek samping alokasi memori, oleh karena itu sebuah bahasa pemrograman hanya dapat melayani kasus penggunaan ini jika dapat memberikan jaminan ini dengan realistis.

Di Zig, ada fitur-fitur library standar yang menyediakan dan bekerja dengan alokator heap,
tetapi itu adalah fitur-fitur library standar opsional, bukan bagian dari bahasa itu sendiri.
Jika anda tidak pernah menginisialisasi alokator heap, anda dapat yakin program anda tidak akan mengalokasi heap.

Setiap fitur library standar yang perlu mengalokasikan memori heap menerima parameter `Allocator`
untuk melakukannya. Ini berarti library standar Zig mendukung target freestanding. Misalnya, `std.ArrayList` dan `std.AutoHashMap` dapat digunakan untuk pemrograman bare metal!

Alokator custom membuat pengelolaan memori manual menjadi mudah. Zig memiliki alokator debug yang
mempertahankan keamanan memori dalam menghadapi penggunaan setelah after-free dan double-free. Ini secara otomatis
mendeteksi dan mencetak stack trace dari kebocoran memori. Ada alokator arena sehingga anda dapat
bundle sejumlah alokasi menjadi satu dan membebaskannya semua sekaligus daripada mengelola
setiap alokasi secara independen. Alokator khusus dapat digunakan untuk meningkatkan kinerja
atau penggunaan memori sesuai dengan kebutuhan aplikasi tertentu.

[1]: Sebenarnya ada operator penggabungan string (umumnya operator penggabungan array), tetapi hanya berfungsi pada waktu kompilasi, jadi tetap tidak melakukan alokasi heap saat runtime.

## Dukungan kelas utama untuk penggunaan tanpa library standar

Seperti yang diindikasikan di atas, Zig memiliki library standar yang sepenuhnya opsional. Setiap API library standar hanya akan dikompilasi ke dalam program anda jika anda menggunakannya. Zig memiliki dukungan yang sama baiknya untuk menghubungkan dengan libc maupun tidak. Zig ramah terhadap pengembangan bare-metal dan high-performance.

Ini merupakan yang terbaik dari keduanya; sebagai contoh dalam Zig, program WebAssembly dapat menggunakan fitur normal dari library standar, dan tetap menghasilkan berkas biner yang sangat kecil dibandingkan dengan bahasa pemrograman lain yang mendukung kompilasi ke WebAssembly.

## Bahasa portabel untuk library

Salah satu hal yang diidamkan dalam pemrograman adalah penggunaan kembali kode. Namun, sayangnya dalam praktiknya, kita sering kali menemukan diri kita menciptakan ulang solusi yang sama berulang kali. Seringkali hal ini memang bisa dijustifikasi.

 * Jika sebuah aplikasi memiliki persyaratan waktu nyata, maka setiap library yang menggunakan garbage collection atau perilaku non-deterministik lainnya tidak dapat dijadikan dependensi.
 * Jika sebuah bahasa pemrograman membuatnya mudah untuk mengabaikan error, dan akibatnya sulit untuk memverifikasi bahwa sebuah library menangani dan mempropagasi error dengan benar, bisa jadi kita cenderung mengabaikan library tersebut dan mengimplementasikannya ulang, dengan keyakinan bahwa kita telah menangani semua error yang relevan dengan benar. Zig dirancang sedemikian rupa sehingga hal paling malas yang dapat dilakukan oleh seorang programmer adalah menangani error dengan benar, dan dengan demikian kita dapat cukup yakin bahwa sebuah library akan dengan benar mempropagasi error.
 * Saat ini, secara pragmatis, C adalah bahasa yang paling serbaguna dan portabel. Setiap bahasa yang tidak memiliki kemampuan untuk berinteraksi dengan kode C berisiko menghadapi ketidakjelasan. Zig mencoba menjadi bahasa pemrograman portabel baru untuk library dengan sekaligus membuatnya mudah untuk sesuai dengan ABI (Application Binary Interface) C untuk fungsi-fungsi eksternal, dan memperkenalkan desain keamanan dan bahasa yang mencegah bug-bug umum dalam implementasi.

## Manajer paket dan sistem build untuk proyek yang Sudah Ada

Zig adalah bahasa pemrograman, tetapi juga akan dilengkapi dengan sistem build dan manajer paket yang dimaksudkan untuk bermanfaat bahkan dalam konteks proyek C/C++ tradisional.

anda tidak hanya dapat menulis kode Zig sebagai pengganti kode C atau C++, tetapi anda juga dapat menggunakan Zig sebagai pengganti tool seperti autotools, cmake, make, scons, ninja, dll. Dan di atas ini, Zig (akan) menyediakan manajer paket untuk dependensi native. Sistem build ini dimaksudkan cocok bahkan jika seluruh basis kode proyek hanya berupa C atau C++.

Manajer paket sistem seperti apt-get, pacman, homebrew, dan lainnya penting untuk pengalaman pengguna, tetapi dapat tidak mencukupi untuk kebutuhan pengembang. Sebuah manajer paket khusus bahasa bisa menjadi perbedaan antara tidak memiliki kontributor dan memiliki banyak kontributor. Bagi proyek open source, kesulitan dalam membuat proyek untuk dibangun adalah hambatan besar bagi kontributor potensial. Bagi proyek C/C++, memiliki dependensi dapat berakibat fatal, terutama di Windows, di mana tidak ada manajer paket. Bahkan saat hanya untuk membuild Zig itu sendiri, sebagian besar kontributor potensial mengalami kesulitan dengan dependensi LLVM. Zig (akan) menawarkan cara bagi proyek untuk bergantung pada library native secara langsung - tanpa harus mengandalkan manajer paket sistem pengguna untuk memiliki versi yang benar tersedia, dan dengan cara yang hampir pasti berhasil membuild proyek pada percobaan pertama, terlepas dari sistem yang digunakan dan terlepas dari platform yang ditargetkan.

Zig menawarkan penggantian sistem build proyek dengan bahasa yang wajar menggunakan API deklaratif untuk membuild proyek, yang juga menyediakan manajemen paket, dan dengan demikian kemampuan untuk benar-benar bergantung pada library C lainnya. Kemampuan untuk memiliki dependensi memungkinkan abstraksi tingkat lebih tinggi, dan dengan demikian penyebaran kode tingkat tinggi yang dapat digunakan kembali.

## Kesederhanaan

C++, Rust, dan D memiliki begitu banyak fitur sehingga mereka dapat mengalihkan perhatian dari makna sebenarnya dari aplikasi yang sedang anda kerjakan. Seseorang sering kali menemukan diri mereka melakukan debug terhadap pengetahuan bahasa pemrograman daripada debug terhadap aplikasi itu sendiri.

Zig tidak memiliki makro dan tidak memiliki metaprogramming, namun tetap cukup kuat untuk mengungkapkan program kompleks dengan cara yang jelas dan tidak berulang. Bahkan Rust memiliki makro dengan kasus khusus seperti `format!`, yang diimplementasikan di dalam kompiler itu sendiri. Sementara itu, dalam Zig, fungsi yang setara diimplementasikan dalam library standar tanpa kode kasus khusus di kompiler.

## Tool

Zig dapat diunduh dari halaman [unduhan](/download/). Zig menyediakan arsip binary untuk Linux, Windows, macOS, dan FreeBSD. Berikut adalah apa yang anda dapatkan dengan salah satu arsip ini:

* Diinstal dengan mengunduh dan mengekstrak satu arsip tunggal, tanpa konfigurasi sistem yang diperlukan.
* Dikompilasi secara statis sehingga tidak ada dependensi waktu eksekusi.
* Menggunakan infrastruktur LLVM yang stabil dan didukung dengan baik, yang memungkinkan optimasi yang mendalam dan dukungan untuk sebagian besar platform utama.
* Langsung dapat digunakan untuk cross-compilation ke sebagian besar platform utama.
* Disertakan dengan kode sumber untuk libc yang akan dikompilasi secara dinamis saat diperlukan untuk setiap platform yang didukung.
* Termasuk sistem build dengan caching.
* Mengompilasi kode C dan C++ dengan dukungan libc.
