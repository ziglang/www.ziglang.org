---
title: Başlarken
mobile_menu_title: "Başlarken"
toc: true
---

## Etiketli sürüm mü yoksa günlük derleme mi?

Zig henüz v1.0'a ulaşmadı ve mevcut sürüm döngüsü, yaklaşık olarak 6 aylık bir periyoda sahip olan LLVM'in yeni sürümleriyle bağlantılıdır.
Pratikte, **Zig sürümleri genellikle birbirinden uzak olma eğilimindedir ve geliştirme hızının mevcut durumu göz önüne alındığında zamanla eski hale gelir**.

Etiketli bir sürümü kullanarak Zig'i değerlendirmek sorun değildir, ancak Zig'i beğenirseniz ve daha derine inmek isterseniz, **günlük bir derlemeye geçmenizi öneririz**. Bunun nedeni, yardım almanızın daha kolay olmasıdır: topluluğun çoğu ve [zig.guide](https://zig.guide) gibi siteler, yukarıda belirtilen nedenlerle genellikle ana dalları takip eder.

İyi haber şu ki, bir Zig sürümünden diğerine geçmek veya hatta aynı anda sistemde birden fazla sürüm bulundurmak çok kolaydır: Zig sürümleri, herhangi bir konuma yerleştirilebilen kendine yeten arşivlerdir.

## Zig Kurulumu

### Doğrudan indirme

Bu, Zig'i elde etmenin en basit yoludur: [İndirme](/download) sayfasından platformunuza uygun bir Zig paketi alın,
onu bir dizine çıkarın ve `PATH`'inize ekleyerek herhangi bir konumdan `zig` komutunu çağırabilin.

#### Windows'ta PATH Ayarlama

Windows'ta PATH'inizi ayarlamak için bir Powershell örneğinde **yalnızca birini** çalıştırın.
Bu değişikliği sistem genelinde uygulamak isteyip istemediğinizi seçin (yönetici ayrıcalıklarıyla Powershell'i çalıştırma gerektirir)
veya yalnızca kullanıcınız için ve **Zig kopyanızın bulunduğu konumu göstermek için kod parçacığını değiştirmeyi unutmayın**.
`C:` önündeki `;` yazım hatası değildir.

Sistem genelinde (**yönetici** Powershell):

```
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "Machine") + ";C:\kendi-yolunuz\zig-windows-x86_64-sürümünüz",
   "Machine"
)
```

Kullanıcı düzeyinde (Powershell):

```
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\kendi-yolunuz\zig-windows-x86_64-sürümünüz",
   "User"
)
```

İşiniz bittiğinde, Powershell'i yeniden başlatın.

#### Linux, macOS, BSD'de PATH Ayarlama

Zig ikilisinin bulunduğu konumu PATH çevresel değişkeninize ekleyin.

Genellikle bunu, kabuk başlatma komut dosyanıza (`.profile`, `.zshrc`, ...) bir satır ekleyerek yaparsınız:

```bash
export PATH=$PATH:~/zigin/bulunduğu/yol
```

İşiniz bittiğinde başlangıç dosyanıza `source` komutunu uygulayın veya kabuğunuzu yeniden başlatın.

### Paket yöneticileri

#### Windows

Zig, [Chocolatey](https://chocolatey.org/packages/zig) üzerinde mevcuttur.

```
choco install zig
```

#### macOS

**Homebrew**  
En son etiketli sürüm:

```
brew install zig
```

**MacPorts**

```
port install zig
```

#### Linux

Zig ayrıca Linux için birçok paket yöneticisinde bulunmaktadır. [Burada](https://github.com/ziglang/zig/wiki/Install-Zig-from-a-Package-Manager)
güncellenmiş bir liste bulabilirsiniz, ancak bazı paketlerin eski sürümlerini içerebileceğini unutmayın.

### Kaynak kodundan derleme

Daha fazla bilgi için [Burada](https://github.com/ziglang/zig/wiki/Building-Zig-From-Source) Linux, macOS ve Windows için Zig'in nasıl kaynak kodundan derleneceğini bulabilirsiniz.

## Tavsiye Edilen Araçlar

### Sözdizimi Vurgulayıcıları ve LSP

Tüm büyük metin düzenleyicileri, Zig için sözdizimi vurgulama desteğine sahiptir.
Bazıları bunu paket halinde sunar, bazıları ise bir eklenti yüklemeyi gerektirir.

Zig ve editörünüz arasında daha derin bir entegrasyonla ilgileniyorsanız,
[zigtools/zls](https://github.com/zigtools/zls)'ye göz atın.

Başka nelerin mevcut olduğunu öğrenmek isterseniz, [Araçlar](../tools/) bölümüne göz atın.

## Hello World Çalıştırma

Kurulum sürecini doğru bir şekilde tamamladıysanız, artık Zig derleyicisini terminal üzerinden çağırabilirsiniz.  
İlk Zig programınızı oluşturarak bunu test edelim!

Proje dizininize gidin ve şunları çalıştırın:

```bash
mkdir hello-world
cd hello-world
zig init
```

Alttaki çıktıyı vermeli:

```
info: Created build.zig
info: Created src/main.zig
info: Next, try `zig build --help` or `zig build run`
```

`zig build run` komutunu çalıştırarak yürütülebilir dosyayı derleyip çalıştırabilirsiniz, sonuç olarak aşağıdaki gibi bir çıktı almalısınız:

```
info: All your codebase are belong to us.
```

Tebrikler, çalışan bir Zig kurulumunuz var!

## Sonraki adımlar

**[Öğren](../)** bölümünde bulunan diğer kaynaklara göz atın, Zig'in belirli bir sürümü için Belgelendirmeyi bulduğunuzdan emin olun
(not: günlük derlemeler `master` belgelerini kullanmalıdır) ve [zig.guide](https://zig.guide)'u okumayı düşünün.

Zig, genç bir proje ve maalesef her şey için kapsamlı belgelendirme ve öğrenme materyalleri oluşturma kapasitemiz henüz yok,
bu yüzden takıldığınızda yardım almak için [mevcut Zig topluluklarından birine katılmayı](https://github.com/ziglang/zig/wiki/Community)
ve [Zig SHOWTIME](https://zig.show) gibi girişimleri kontrol etmeyi düşünmelisiniz.

Son olarak, Zig'den keyif alıyorsanız ve geliştirmeyi hızlandırmaya yardımcı olmak istiyorsanız, [Zig Yazılım Vakfı'na bağış yapmayı düşünün](../../zsf)
<img src="/heart.svg" style="vertical-align:middle; margin-right: 5px">.
