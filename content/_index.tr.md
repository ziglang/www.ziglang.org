---
title: Ana Sayfa
mobile_menu_title: "Ana Sayfa"
---

{{< slogan get_started="BAŞLAYIN" docs="Dökümantasyon" notes="Değişiklikler" lang="tr" >}}
Zig, **güçlü**, **optimal** ve **yeniden kullanılabilir** yazılımı sürdürmek için genel amaçlı bir programlama dili ve araç zinciridir.
{{< /slogan >}}

{{< flexrow class="container" style="padding: 20px 0; justify-content: space-between;" >}}
{{% div class="features" %}}

# ⚡ Basit Bir Dil

Uygulamanızı hata ayıklamak yerine, programlama dilinizin bilgisini hata ayıklama üzerinde odaklanın.

- Gizli kontrol akışı yok.
- Gizli bellek tahsisi yok.
- Önişlemci veya makrolar yok.

# ⚡ Derleme Zamanı (Comptime)

Derleme zamanında kod yürütme ve tembel değerlendirme prensibine dayanan, metaprogramlama için yeni bir yaklaşım.

- Derleme zamanında herhangi bir işlevi çağırın.
- Türleri değer olarak manipüle edin ve çalışma zamanı gereksinimi olmadan.
- Comptime hedef mimariyi taklit eder.

# ⚡ Zig ile Sürdürülebilirliği Sağlayın

C/C++/Zig kod tabanınızı aşamalı olarak iyileştirin.

- Zig'i, kendisi ile gelen, çapraz derlemeyi destekleyen bir C/C++ derleyicisi olarak kullanın.
- Tüm platformlarda tutarlı bir geliştirme ortamı oluşturmak için `zig build`'i kullanın.
- C/C++ projelerine Zig derleme birimi ekleyin; çapraz dil LTO varsayılan olarak etkindir.

{{% flexrow style="justify-content:center;" %}}
{{% div %}}

<h1>
    <a href="learn/overview/" class="button" style="display: inline;">Detaylı bakış</a>
</h1>
{{% /div %}}
{{% div  style="margin-left: 5px;" %}}
<h1>
    <a href="learn/samples/" class="button" style="display: inline;">Daha fazla kod örneği</a>
</h1>
{{% /div %}}
{{% /flexrow %}}
{{% /div %}}
{{< div class="codesample" >}}

{{% zigdoctest "assets/zig-code/index.zig" %}}

{{< /div >}}
{{< /flexrow >}}

{{% div class="alt-background" %}}
{{% div class="container"  style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="Topluluk" %}}

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div style="width:25%" %}}
<img src="/ziggy.svg" style="max-height: 200px">
{{% /div %}}

{{% div class="community-message" %}}

# Zig topluluğu merkeziyetsizdir

Herkes topluluğun toplanması için kendi alanını başlatabilir ve sürdürebilir.
"Resmi" veya "resmi olmayan" kavramı yoktur, ancak her toplanma yeri kendi moderatörleri ve kuralları bulunmaktadır.

<div style="">
<h1>
	<a href="https://github.com/ziglang/zig/wiki/Community" class="button" style="display: inline;">Toplulukları İnceleyin</a>
</h1>
</div>
{{% /div %}}
{{< /flexrow >}}
<div style="height: 50px;"></div>

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div class="main-development-message" %}}

# Ana Geliştirme

Zig deposuna [https://github.com/ziglang/zig](https://github.com/ziglang/zig) adresinden ulaşabilirsiniz. Aynı zamanda sorun takibini yapmak ve önerileri tartışmak için bu adreste yer alıyoruz.
Katkıda bulunanların Zig'in [Davranış Kurallarına](https://github.com/ziglang/zig/blob/master/.github/CODE_OF_CONDUCT.md) uymaları beklenmektedir.
{{% /div %}}
{{% div style="width:40%" %}}
<img src="/zero.svg" style="max-height: 200px">
{{% /div %}}
{{< /flexrow >}}
{{% /div %}}
{{% /div %}}

{{% div class="container" style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="Zig Software Foundation" %}}

## The ZSF is a 501(c)(3) kar amacı gütmeyen bir kuruluştur.

Zig Yazılım Vakfı (ZSF), 2020 yılında Zig'in yaratıcısı Andrew Kelley tarafından kurulan, dilin geliştirilmesini desteklemeyi amaçlayan bir kar amacı gütmeyen kuruluştur. Şu anda, ZSF, sınırlı sayıda çekirdek katkıcıya rekabetçi ücretlerle çalışma imkanı sunabilmektedir. Gelecekte bu teklifi daha fazla çekirdek katkıcıya genişletmeyi umuyoruz.

Zig Yazılım Vakfı, bağışlarla sürdürülmektedir.

<h1>
	<a href="zsf/" class="button" style="display:inline;">Daha Fazla Bilgi Edinin</a>
</h1>
{{% /div %}}

{{< div class="alt-background" style="padding: 20px 0;">}}
{{% div class="container" title="Sponsors" %}}

# Kurumsal Sponsorlar

Aşağıdaki şirketler, Zig Yazılım Vakfı'na doğrudan mali destek sağlamaktadır.

{{% monetary-sponsor-logos %}}

# GitHub Sponsorları

Zig'i [sponsor olan](zsf/) insanlara teşekkürlerimizi sunarız. Bu proje, şirket hissedarları yerine açık kaynak topluluğuna hesap verebilir hale gelmiştir. Özellikle, aşağıdaki kişiler Zig'e aylık $200 veya daha fazla sponsor olmaktadır:

{{< ghsponsors >}}

Bu bölüm her ayın başında güncellenmektedir.
{{% /div %}}
{{< /div >}}
