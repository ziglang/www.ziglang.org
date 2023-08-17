---
title: Memulai
mobile_menu_title: "Memulai"
toc: true
---

## Rilis Berlabel atau Build Nightly?
Zig belum mencapai versi 1.0 dan siklus rilis saat ini terkait dengan rilis baru dari LLVM, yang memiliki jangka waktu sekitar ~6 bulan.
Secara praktis, **rilis Zig cenderung berjauhan dan akhirnya menjadi kurang relevan mengingat kecepatan pengembangan saat ini**.

Tidak masalah untuk mengevaluasi Zig menggunakan versi berlabel, tetapi jika anda memutuskan untuk menyukai Zig dan ingin memperdalam, **kami mendorong anda untuk melakukan upgrade ke build nightly**, karena itu akan lebih mempermudah anda untuk mendapatkan bantuan: sebagian besar komunitas dan situs seperti [ziglearn.org](https://ziglearn.org) melacak atau menggunakan branch master karena alasan yang telah dijelaskan di atas.

Berita baiknya adalah untuk beralih dari satu versi Zig ke versi lainnya sangatlah mudah, atau bahkan memiliki beberapa versi yang ada di sistem pada saat yang bersamaan: rilis Zig adalah arsip mandiri yang dapat ditempatkan di mana saja dalam sistem anda.

## Instal Zig
### Unduh langsung
Ini adalah cara paling mudah untuk mendapatkan Zig: ambil bundle Zig untuk platform anda dari halaman [Unduhan](/download),
ekstrak di dalam direktori, dan tambahkan ke `PATH` anda agar bisa memanggil `zig` dari lokasi manapun.

#### Mengatur PATH di Windows
Untuk mengatur PATH di Windows anda, jalankan **salah satu** potongan kode berikut di dalam Powershell.
Pilih apakah anda ingin menerapkan perubahan ini secara keseluruhan pada sistem (memerlukan hak admin untuk menjalankan Powershell)
atau hanya untuk pengguna, dan **pastikan untuk mengubah potongan kode agar mengarah ke lokasi tempat salinan Zig anda berada**.
Tanda `;` sebelum `C:` bukanlah kesalahan ketik.

Untuk seluruh sistem (dengan hak admin Powershell):
```
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "Machine") + ";C:\your-path\zig-windows-x86_64-your-version",
   "Machine"
)
```

Tingkat pengguna (Powershell):
```
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\your-path\zig-windows-x86_64-your-version",
   "User"
)
```
Setelah selesai, restart Powershell anda.

#### Mengatur PATH di Linux, macOS, BSD
Tambahkan lokasi binary Zig anda ke dalam variabel lingkungan PATH.

Biasanya ini dilakukan dengan menambahkan baris export ke dalam skrip startup shell anda (`.profile`, `.zshrc`, ...)
```bash
export PATH=$PATH:~/path/to/zig
```
Setelah selesai, anda bisa `source` berkas startup anda atau restart shell anda.

### Package managers
#### Windows
**WinGet**  
Zig tersedia di [WinGet](https://github.com/microsoft/winget-pkgs/tree/master/manifests/z/zig/zig).
```
winget install -e --id zig.zig
```

**Chocolatey**  
Zig tersedia di [Chocolatey](https://chocolatey.org/packages/zig).
```
choco install zig
```

**Scoop**  
Zig tersedia di [Scoop](https://scoop.sh/#/apps?q=zig&id=7e124d6047c32d426e4143ab395d863fc9d6d491).
```
scoop install zig
```
[dev build](https://scoop.sh/#/apps?q=zig&id=921df07e75042de645204262e784a17c2421944c) terbaru:
```
scoop bucket add versions
scoop install versions/zig-dev
```

#### macOS

**Homebrew**  
Rilis berlabel terbaru:
```
brew install zig
```

**MacPorts**
```
port install zig
```
#### Linux
Zig juga tersedia di banyak pengelola paket untuk Linux. [Di sini](https://github.com/ziglang/zig/wiki/Install-Zig-from-a-Package-Manager)
anda dapat menemukan daftar yang terbaru, namun perlu diingat bahwa beberapa paket mungkin mengemas versi Zig yang sudah lama.

### Membangun dari Sumber
[Di sini](https://github.com/ziglang/zig/wiki/Building-Zig-From-Source) 
anda dapat menemukan informasi lebih lanjut tentang cara membangun Zig dari sumber untuk Linux, macOS, dan Windows.

## Daftar Tool yang direkomendasikan
### Syntax highlight dan LSP
Semua teks editor utama memiliki dukungan syntax highlight untuk Zig.
Beberapa mengemasnya, lainnya memerlukan pemasangan plugin.

Jika anda tertarik untuk mengintegrasikan Zig dengan editor anda secara lebih mendalam,
cek [zigtools/zls](https://github.com/zigtools/zls).

Jika anda ingin tahu apa lagi yang tersedia, lihat bagian [Daftar Tool](../tools/).

## Jalankan Hello World
Jika anda berhasil menyelesaikan proses instalasi dengan benar, sekarang anda seharusnya dapat memanggil kompiler Zig dari shell anda.
Mari kita uji ini dengan membuat program Zig pertama anda!

Beralihlah ke direktori proyek anda dan jalankan:
```bash
mkdir hello-world
cd hello-world
zig init-exe
```

Ini seharusnya menampilkan:
```
info: Created build.zig
info: Created src/main.zig
info: Next, try `zig build --help` or `zig build run`
```

Menjalankan `zig build run` kemudian akan mengkompilasi eksekutor dan menjalankannya, akhirnya menghasilkan:
```
info: All your codebase are belong to us.
```

Selamat, anda telah memiliki instalasi Zig yang berfungsi!


## Langkah selanjutnya
**Cek sumber lain yang ada di bagian [Belajar](../)**, pastikan untuk menemukan dokumentasi untuk versi Zig anda
(catatan: build nightly harus menggunakan dokumen `master`) dan pertimbangkan untuk membaca [ziglearn.org](https://ziglearn.org).

Zig adalah proyek baru dan sayangnya kami belum memiliki kapasitas untuk menghasilkan dokumentasi dan materi pembelajaran yang luas
untuk semuanya, jadi anda sebaiknya mempertimbangkan [bergabung dengan salah satu komunitas Zig yang sudah ada](https://github.com/ziglang/zig/wiki/Community)
untuk mendapatkan bantuan ketika anda mengalami kesulitan, serta mengeksplorasi inisiatif seperti [Zig SHOWTIME](https://zig.show).

Akhirnya, jika anda menikmati Zig dan ingin membantu mempercepat pengembangannya, [pertimbangkan untuk berdonasi ke Zig Software Foundation](../../zsf)
<img src="/heart.svg" style="vertical-align:middle; margin-right: 5px">.
