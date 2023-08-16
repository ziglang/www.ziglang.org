---
title: Beranda
mobile_menu_title: "Beranda"
---
{{< slogan get_started="MULAI SEKARANG" docs="Dokumentasi" notes="Perubahan" lang="id" >}}
Zig adalah bahasa pemrograman serbaguna dan toolchain untuk menjaga software tetap **handal**, **optimal**, dan **dapat digunakan kembali**.
{{< /slogan >}}

{{< flexrow class="container" style="padding: 20px 0; justify-content: space-between;" >}}
{{% div class="features" %}}

# ⚡ Bahasa Sederhana
Fokus perbaiki aplikasi anda daripada menghadapi masalah pemahaman bahasa pemrograman anda.

- Tidak ada control flow yang tersembunyi.
- Tidak ada alokasi memori yang tersembunyi.
- Tanpa preprocessor, tanpa makro.

# ⚡ Comptime
Pendekatan baru dalam metapemrograman berdasarkan eksekusi kode saat kompilasi dan lazy evaluation.

- Memanggil fungsi apa pun saat kompilasi.
- Memanipulasi type sebagai value tanpa beban waktu eksekusi saat runtime.
- Comptime meniru arsitektur target.

# ⚡ Kelola dengan Zig
Tingkatkan secara bertahap basis kode C/C++/Zig anda.

- Gunakan Zig sebagai kompiler C/C++ yang dapat langsung digunakan tanpa perlu dependensi, dan mendukung kompilasi lintas platform.
- Manfaatkan perintah `zig build` untuk menciptakan lingkungan pengembangan yang konsisten di semua platform.
- Tambahkan unit kompilasi Zig ke proyek C/C++; cross-language LTO diaktifkan secara default.

{{% flexrow style="justify-content:center;" %}}
{{% div %}}
<h1>
    <a href="learn/overview/" class="button" style="display: inline;">Penjelasan lengkap</a>
</h1>
{{% /div %}}
{{% div  style="margin-left: 5px;" %}}
<h1>
    <a href="learn/samples/" class="button" style="display: inline;">Contoh kode lebih lanjut</a>
</h1>
{{% /div %}}
{{% /flexrow %}}
{{% /div %}}
{{< div class="codesample" >}}

{{% zigdoctest "assets/zig-code/index.zig" %}}

{{< /div >}}
{{< /flexrow >}}


{{% div class="alt-background" %}}
{{% div class="container"  style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="Komunitas" %}}

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div style="width:25%" %}}
<img src="/ziggy.svg" style="max-height: 200px">
{{% /div %}}

{{% div class="community-message" %}}
# Komunitas Zig terdesentralisasi
Siapa pun bebas untuk memulai dan menjaga tempat komunitas mereka sendiri untuk berkumpul.
Tidak ada konsep "resmi" atau "tidak resmi", namun, setiap tempat berkumpul memiliki moderator dan aturan sendiri.

<div style="">
<h1>
	<a href="https://github.com/ziglang/zig/wiki/Community" class="button" style="display: inline;">Lihat semua komunitas</a>
</h1>
</div>
{{% /div %}}
{{< /flexrow >}}
<div style="height: 50px;"></div>

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div class="main-development-message" %}}
# Pengembangan Utama
Repositori Zig dapat ditemukan di [https://github.com/ziglang/zig](https://github.com/ziglang/zig), di mana kami juga menghosting pelacak isu dan membahas proposal.
Kontributor diharapkan mengikuti [Kode Etik](https://github.com/ziglang/zig/blob/master/.github/CODE_OF_CONDUCT.md) Zig.
{{% /div %}}
{{% div style="width:40%" %}}
<img src="/zero.svg" style="max-height: 200px">
{{% /div %}}
{{< /flexrow >}}
{{% /div %}}
{{% /div %}}


{{% div class="container" style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="Zig Software Foundation" %}}
## ZSF adalah korporasi nirlaba 501(c)(3).

Zig Software Foundation adalah korporasi nirlaba yang didirikan pada tahun 2020 oleh Andrew Kelley, pencipta Zig, dengan tujuan mendukung pengembangan bahasa tersebut. Saat ini, ZSF mampu menawarkan pekerjaan berbayar dengan tarif kompetitif kepada sejumlah kecil kontributor inti. Kami berharap dapat memperluas penawaran ini kepada lebih banyak kontributor inti di masa depan.

Zig Software Foundation dapat menjalankan kegiatannya berkat donasi.

<h1>
	<a href="zsf/" class="button" style="display:inline;">Pelajari Selengkapnya</a>
</h1>
{{% /div %}}


{{< div class="alt-background" style="padding: 20px 0;">}}
{{% div class="container" title="Para Sponsor" %}}
# Sponsor Perusahaan 
Berikut adalah perusahaan-perusahaan yang memberikan dukungan keuangan langsung kepada Zig Software foundation.

{{% monetary-sponsor-logos %}}


# Sponsor-sponsor dari GitHub
Terima kasih kepada orang-orang yang [mensponsori Zig](zsf/), proyek ini bertanggung jawab kepada komunitas open source daripada pemegang saham korporasi. Secara khusus, orang-orang hebat ini mensponsori Zig sebesar $200/bulan atau lebih:

{{< ghsponsors >}}

Bagian ini diperbarui setap awal bulan.
{{% /div %}}
{{< /div >}}
