---
başlık: "Detaylı Genel Bakış"
mobil_menu_başlık: "Genel Bakış"
toc: true
---

# Özellik Vurguları

## Küçük, basit dil

Uygulamanızı hata ayıklamak yerine programlama dilinizin bilgisini hata ayıklamaya odaklanın.

Zig'in tüm sözdizimi, [500 satırlık bir PEG dilbilgisi dosyası](https://ziglang.org/documentation/master/#Grammar) ile belirlenmiştir.

**Gizli kontrol akışı yoktur**, gizli bellek tahsisi yoktur, önişlemci yoktur ve makrolar yoktur. Zig kodu birşey çağırmıyorsa, çağırmıyordur. Bu, aşağıdaki kodun yalnızca `foo()` ve ardından `bar()`'ı çağırdığından emin olabileceğiniz ve bunun için herhangi bir şeyin türlerini bilmeye ihtiyaç duymadan garanti edildiği anlamına gelir:

```zig
var a = b + c.d;
foo();
bar();
```

Gizli kontrol akışı örnekleri:

- D dilinde, `@property` işlevleri, bir işlevi çağırdığınızı düşündüğünüz alan erişimi ile çağırdığınız yöntemlerdir, bu nedenle yukarıdaki örnekte `c.d` bir işlev çağırabilir.
- C++, D ve Rust dilinde operatör aşırı yükleme (operator overloading) bulunur, bu nedenle `+` operatörü bir işlevi çağırabilir.
- C++, D ve Go dilinde hata/çözümleme istisnaları bulunur, bu nedenle `foo()` bir istisna fırlatabilir ve `bar()`'ın çağrılmasını engelleyebilir.

Zig, tüm kontrol akışının yalnızca dilin anahtar kelimeleri ve işlev çağrılarıyla yönetilmesi sayesinde kod bakımını ve okunabilirliğini teşvik eder.

## Performans ve Güvenlik: İkisini Birlikte Seçin

Zig, dört [derleme moduna](https://ziglang.org/documentation/master/#Build-Mode) sahiptir ve bunlar [kapsam hassasiyetine](https://ziglang.org/documentation/master/#setRuntimeSafety) kadar karışık bir şekilde birbirleriyle kullanılabilir.

| Parametre                                                                                          | [Debug](/documentation/master/#Debug) | [ReleaseSafe](/documentation/master/#ReleaseSafe) | [ReleaseFast](/documentation/master/#ReleaseFast) | [ReleaseSmall](/documentation/master/#ReleaseSmall) |
| -------------------------------------------------------------------------------------------------- | ------------------------------------- | ------------------------------------------------- | ------------------------------------------------- | --------------------------------------------------- |
| Optimizasyonlar - hızı artırır, hata ayıklamayı zorlaştırır, derleme süresini etkiler              |                                       | -O3                                               | -O3                                               | -Os                                                 |
| Çalışma Zamanı Güvenlik Kontrolleri - hızı etkiler, boyutu etkiler, belirsiz davranışı tespit eder | Açık                                  | Açık                                              |                                                   |                                                     |

İşte derleme moduna bakılmaksızın [Tam Sayı Taşması](https://ziglang.org/documentation/master/#Integer-Overflow)nin nasıl göründüğü:

{{< zigdoctest "assets/zig-code/features/1-integer-overflow.zig" >}}

Güvenlik kontrolü yapılan yapılarda çalışma zamanında nasıl göründüğü:

{{< zigdoctest "assets/zig-code/features/2-integer-overflow-runtime.zig" >}}

Bu [yığın izleri](#tüm-hedeflerde-yığın-izlemeleri), [bağımsız](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html) dahil tüm hedeflerde çalışır.

Zig ile güvenliğe yönelik bir derleme moduna güvenebilir ve performans engellerinde güvenliği seçici olarak devre dışı bırakabilirsiniz. Örneğin, önceki örnek aşağıdaki gibi değiştirilebilir:

{{< zigdoctest "assets/zig-code/features/3-undefined-behavior.zig" >}}

Zig, hem hata önleme hem de performans artırma için bir bıçak gibi keskin bir şekilde [belirsiz davranışı](https://ziglang.org/documentation/master/#Undefined-Behavior) kullanır.

Performanstan bahsetmişken, Zig C'den daha hızlıdır.

- Referans uygulama, son teknoloji optimizasyonlar için bir arka uç olarak LLVM'yi kullanır.
- Diğer projelerin "Bağlantı Süresi Optimizasyonu" (LTO) dediği şeyi Zig otomatik olarak yapar.
- Yerel hedefler için, gelişmiş CPU özellikleri etkinleştirilir (-march=native), çünkü [Çapraz derleme birinci sınıf bir kullanım durumudur](#çapraz-derleme-birinci-sınıf-bir-kullanım-durumudur).
- Dikkatle seçilen belirsiz davranış. Örneğin, Zig'de hem işaretli hem de işaretsiz tamsayılar taşma durumunda belirsiz davranışa sahiptir, C'de ise sadece işaretli tamsayılarda. Bu, [C'de mümkün olmayan optimizasyonlara imkan sağlar](https://godbolt.org/z/n_nLEU).

- Zig doğrudan bir [SIMD vektör tipini](https://ziglang.org/documentation/master/#Vectors) sunar, böylece taşınabilir vektörize edilmiş kod yazmak kolaylaşır

Lütfen Zig'nin tamamen güvenli bir dil olmadığını unutmayın. Zig'nin güvenlik hikayesini takip etmek isteyenler için bu konulara abone olun:

- [Tüm türlerin belirsiz davranışını, güvenlik kontrolü yapılamayanları da içeren şekilde sıralayın](https://github.com/ziglang/zig/issues/1966)
- [Debug ve ReleaseSafe modlarını tamamen güvenli hale getirin](https://github.com/ziglang/zig/issues/2301)

## Zig, C'ye bağlı olmak yerine onunla rekabet eder

Zig Standart Kütüphanesi, libc ile entegre olur, ancak ona bağımlı değildir. İşte "Merhaba Dünya" örneği:

{{< zigdoctest "assets/zig-code/features/4-hello.zig" >}}

Bu, `-O ReleaseSmall` ile derlendiğinde, hata ayıklama sembolleri çıkarıldığında, tek iş parçacıklı modda, x86_64-linux hedefi için 9.8 KiB boyutunda bir statik çalıştırılabilir dosya üretir:

```
$ zig build-exe hello.zig -O ReleaseSmall -fstrip -fsingle-threaded
$ wc -c hello
9944 hello
$ ldd hello
  not a dynamic executable
```

Windows derlemesi daha da küçüktür ve 4096 bayt olur:

```
$ zig build-exe hello.zig -O ReleaseSmall -fstrip -fsingle-threaded -target x86_64-windows
$ wc -c hello.exe
4096 hello.exe
$ file hello.exe
hello.exe: PE32+ executable (console) x86-64, for MS Windows
```

## Sıra bağımsız üst düzey bildirimler

Global değişkenler gibi üst düzey bildirimler sıra bağımsızdır ve tembelce analiz edilir. Global değişkenlerin başlangıç değerleri [derleme zamanında değerlendirilir](#derleme-zamanı-yansıma-ve-derleme-zamanı-kodu-yürütme).

{{< zigdoctest "assets/zig-code/features/5-global-variables.zig" >}}

## Null işaretçiler yerine Opsiyonel tip

Diğer programlama dillerinde, null referanslar birçok çalışma zamanı istisnasının kaynağıdır ve hatta [bilgisayar bilimindeki en kötü hata](https://www.lucidchart.com/techblog/2015/08/31/the-worst-mistake-of-computer-science/) olarak suçlanır.

Düz Zig işaretçileri null olamaz:

{{< zigdoctest "assets/zig-code/features/6-null-to-ptr.zig" >}}

Ancak, herhangi bir tür, ? ile önekleyerek [opsiyonel bir tipe](https://ziglang.org/documentation/master/#Optionals) dönüştürülebilir:

{{< zigdoctest "assets/zig-code/features/7-optional-syntax.zig" >}}

Bir opsionel değeri açmak için, varsayılan bir değer sağlamak için `orelse` kullanılabilir:

{{< zigdoctest "assets/zig-code/features/8-optional-orelse.zig" >}}

Başka bir seçenek ise if kullanmaktır:

{{< zigdoctest "assets/zig-code/features/9-optional-if.zig" >}}

Aynı sözdizimi [while](https://ziglang.org/documentation/master/#while) ile de çalışır:

{{< zigdoctest "assets/zig-code/features/10-optional-while.zig" >}}

## El ile bellek yönetimi

Zig ile yazılmış bir kütüphane her yerde kullanılmaya uygun olabilir:

- [Masaüstü uygulamaları](https://github.com/TM35-Metronome/)
- Düşük gecikmeli sunucular
- [İşletim Sistemi çekirdekleri](https://github.com/AndreaOrru/zen)
- [Gömülü cihazlar](https://github.com/skyfex/zig-nrf-demo/)
- Gerçek zamanlı yazılım, örneğin canlı performanslar, uçaklar, kalp pilleri
- [Web tarayıcıları veya WebAssembly ile diğer eklentiler](https://shritesh.github.io/zigfmt-web/)
- C ABI'sini kullanarak diğer programlama dilleri tarafından

Bunu başarmak için, Zig programcıları kendi başına belleği yönetmeli ve bellek tahsisi başarısızlığını ele almalıdır.

Bu, Zig Standart Kütüphanesi için de geçerlidir. Bellek tahsisi gerektiren herhangi bir işlev, bir bellek tahsis edici parametre kabul eder. Sonuç olarak, Zig Standart Kütüphanesi, bağımsız hedef için bile kullanılabilir.

[Hata işleme konusunda taze bir yaklaşım](#hata-işleme-konusunda-taze-bir-yaklaşım) ile birlikte, Zig [defer](https://ziglang.org/documentation/master/#defer) ve [errdefer](https://ziglang.org/documentation/master/#errdefer) sağlar, böylece tüm kaynak yönetimi - sadece bellek değil - basit ve kolayca doğrulanabilir hale gelir.

`defer` örneği için [FFI/bağlayıcısız C kütüphaneleriyle entegrasyon](#ffibağlayıcısız-c-kütüphaneleriyle-entegrasyon)'e bakabilirsiniz. İşte `errdefer` kullanımına örnek:

{{< zigdoctest "assets/zig-code/features/11-errdefer.zig" >}}

## Hata işleme konusunda taze bir yaklaşım

Hatalar değerlerdir ve göz ardı edilemezler:

{{< zigdoctest "assets/zig-code/features/12-errors-as-values.zig" >}}

Hatalar [catch](https://ziglang.org/documentation/master/#catch) ile ele alınabilir:

{{< zigdoctest "assets/zig-code/features/13-errors-catch.zig" >}}

[try](https://ziglang.org/documentation/master/#try) anahtar kelimesi `catch |err| return err` için bir kısayoldur:

{{< zigdoctest "assets/zig-code/features/14-errors-try.zig" >}}

Bunun bir [yığın izlemesi](#tüm-hedeflerde-yığın-izlemeleri) değil, bir [Hata Dönüş İzlemesi](https://ziglang.org/documentation/master/#Error-Return-Traces) olduğunu unutmayın. Kod, bu izi bulmak için yığını çözmenin bedelini ödemedi.

Hatalar için kullanılan [switch](https://ziglang.org/documentation/master/#switch) anahtar kelimesi, tüm olası hataların ele alındığından emin olur:

{{< zigdoctest "assets/zig-code/features/15-errors-switch.zig" >}}

[unreachable](https://ziglang.org/documentation/master/#unreachable) anahtar kelimesi, hiçbir hatanın oluşmayacağını belirtmek için kullanılır:

{{< zigdoctest "assets/zig-code/features/16-unreachable.zig" >}}

Bu, güvensiz yapılandırma modlarında [belirsiz davranış](#performans-ve-güvenlik-ikisini-birlikte-seçin) tetikler, bu yüzden sadece başarı garantilendiğinde kullanmaya dikkat edin.

### Tüm hedeflerde yığın izlemeleri

Bu sayfada gösterilen yığın izlemeleri ve [hata dönüş izlemeleri](https://ziglang.org/documentation/master/#Error-Return-Traces), [1. Düzey Destek](#1-düzey-destek) ve bazı [2. Düzey Destek](#2-düzey-destek) hedeflerde çalışır. [bağımsız bile](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html)!

Ayrıca, standart kütüphane herhangi bir noktada bir yığın izi yakalama ve bunu daha sonra standart hataya dökme özelliği vardır:

{{< zigdoctest "assets/zig-code/features/17-stack-traces.zig" >}}

Bu teknik, devam eden [GeneralPurposeDebugAllocator projesinde](https://github.com/andrewrk/zig-general-purpose-allocator/#current-status) kullanıldığını görebilirsiniz.

## Generic veri yapıları ve fonksiyonlar

Tipler derleme zamanında bilinmesi gereken değerlerdir:

{{< zigdoctest "assets/zig-code/features/18-types.zig" >}}

Generic bir veri yapısı sadece bir `type` döndüren bir fonksiyondur:

{{< zigdoctest "assets/zig-code/features/19-generics.zig" >}}

## Derleme zamanı yansıma ve derleme zamanı kodu yürütme

[@typeInfo](https://ziglang.org/documentation/master/#typeInfo) yerleşik işlevi, yansımayı sağlar:

{{< zigdoctest "assets/zig-code/features/20-reflection.zig" >}}

Zig Standart Kütüphanesi, biçimlendirilmiş yazdırma işlemini gerçekleştirmek için bu tekniği kullanır. Küçük ve basit bir dil olmasına rağmen, Zig'in biçimlendirilmiş yazdırma işlemi tamamen Zig'de uyarlanmıştır. Bununla birlikte, C'de printf için derleme hataları derleyiciye sabitlenmiştir. Benzer şekilde, Rust'ta biçimlendirilmiş yazdırma makrosu derleyiciye sabitlenmiştir.

Zig ayrıca derleme zamanında işlevleri ve kod bloklarını değerlendirebilir. Global değişken başlatmaları gibi bazı bağlamlarda, ifade otomatik olarak derleme zamanında değerlendirilir. Aksi takdirde, [comptime](https://ziglang.org/documentation/master/#comptime) anahtar kelimesi ile açıkça derleme zamanında kod değerlendirilebilir. Bu, özellikle doğrulamalarla birleştirildiğinde oldukça güçlü olabilir:

{{< zigdoctest "assets/zig-code/features/21-comptime.zig" >}}

## FFI/bağlayıcısız C kütüphaneleriyle entegrasyon

[@cImport](https://ziglang.org/documentation/master/#cImport), türleri, değişkenleri, işlevleri ve basit makroları Zig'de kullanmak için doğrudan C'den içe aktarır. Hatta satır içi (inline) işlevleri C'den Zig'e çevirir.

İşte [libsoundio](http://libsound.io/) kullanarak bir sinüs dalga yayma örneği:

<u>sine.zig</u>
{{< zigdoctest "assets/zig-code/features/22-sine-wave.zig" >}}

```
$ zig build-exe sine.zig -lsoundio -lc
$ ./sine
Output device: Built-in Audio Analog Stereo
^C
```

[Bu Zig kodu](https://gist.github.com/andrewrk/d285c8f912169329e5e28c3d0a63c1d8), eşdeğer C kodundan önemli ölçüde daha basittir ve daha fazla güvenlik korumasına sahiptir ve tüm bunlar, C başlık dosyasını doğrudan içe aktararak gerçekleştirilir - API bağlaması yoktur.

_Zig, C kütüphanelerini kullanmada C'den daha iyidir._

### Zig aynı zamanda bir C derleyicisidir

İşte Zig'in C kodunu derlemesiyle ilgili bir örnek:

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

`--verbose-cc` seçeneğini kullanarak bu komutun hangi C derleyici komutunu yürüttüğünü görebilirsiniz:

```
$ zig build-exe hello.c --library c --verbose-cc
zig cc -MD -MV -MF zig-cache/tmp/42zL6fBH8fSo-hello.o.d -nostdinc -fno-spell-checking -isystem /home/andy/dev/zig/build/lib/zig/include -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-gnu -isystem /home/andy/dev/zig/build/lib/zig/libc/include/generic-glibc -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-any -isystem /home/andy/dev/zig/build/lib/zig/libc/include/any-linux-any -march=native -g -fstack-protector-strong --param ssp-buffer-size=4 -fno-omit-frame-pointer -o zig-cache/tmp/42zL6fBH8fSo-hello.o -c hello.c -fPIC
```

Komutu tekrar çalıştırırsanız, çıktı olmadığını ve anında tamamlandığını göreceksiniz:

```
$ time zig build-exe hello.c --library c --verbose-cc

real	0m0.027s
user	0m0.018s
sys	0m0.009s
```

Bu, [Derleme Artifakt Önbelleği](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching) sayesinde olur. Zig, .d dosyasını otomatik olarak ayrıştırır ve işi tekrarlamaktan kaçınmak için sağlam bir önbelleğe alma sistemi kullanır.

Zig yalnızca C kodunu derlemekle kalmaz, aynı zamanda Zig'i bir C derleyicisi olarak kullanmak için çok iyi bir neden vardır: [Zig, libc ile birlikte gelir](#zig-libc-ile-birlikte-gelir)

### C kodunun bağımlı olması için işlevleri, değişkenleri ve türleri dışa aktarın

Zig'in birincil kullanım durumlarından biri, diğer programlama dilleri için C ABI ile bir kitaplığı (header file) dışa aktarmaktır. İşlevlerin, değişkenlerin ve türlerin önüne konan `export` anahtar kelimesi, bunların kütüphane API'sinin bir parçası olmasını sağlar:

<u>mathtest.zig</u>
{{< zigdoctest "assets/zig-code/features/23-math-test.zig" >}}

Statik bir kütüphane oluşturmak için:

```
$ zig build-lib mathtest.zig
```

Paylaşımlı (dinamik) bir kütüphane oluşturmak için:

```
$ zig build-lib mathtest.zig -dynamic
```

İşte [Zig Derleme Sistemi](#zig-derleme-sistemi) ile bir örnek:

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

## Çapraz derleme birinci sınıf bir kullanım durumudur

Zig, [Destek Tablosu'ndaki](#desteklenen-geniş-hedef-aralığı) [3. Kademe Destek](#tier-3-support) veya desteği daha iyi olan hedefler için derleyebilir. Herhangi bir "çapraz araç zinciri" kurulumu veya benzeri bir şeye ihtiyaç yoktur. İşte yerel bir Hello World örneği:

{{< zigdoctest "assets/zig-code/features/4-hello.zig" >}}

Şimdi x86_64-windows, x86_64-macos ve aarch64-linux için derlemek için:

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

Bu, [3. Kademe](#tier-3-support)+ hedeflerde çalışır, [3. Kademe](#tier-3-support)+ hedefler için çalışır.

## Zig, libc ile birlikte gelir

Kullanılabilir libc hedeflerini `zig targets` komutuyla bulunabilir:

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

Bu, bu hedefler için `--library c` _herhangi bir sistem dosyasına bağımlı olmadığı_ anlamına gelir!

Hadi [C hello world örneğine](#zig-aynı-zamanda-bir-c-derleyicisidir) bir göz atalım:

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

[glibc](https://www.gnu.org/software/libc/) statik olarak derlemeyi desteklemez, ancak [musl](https://www.musl-libc.org/) destekler:

```
$ zig build-exe hello.c --library c -target x86_64-linux-musl
$ ./hello
Hello world
$ ldd hello
  not a dynamic executable
```

Bu örnekte Zig, musl libc'yi kaynaktan oluşturdu ve ardından ona karşı bağlantı kurdu. x86_64-linux için musl libc derlemesi, [önbellekleme sistemi](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching) sayesinde kullanılabilir durumda kalır, böylece bu libc'ye tekrar ihtiyaç duyulduğunda anında kullanılabilir olacaktır.

Bu, bu işlevin herhangi bir platformda kullanılabilir olduğu anlamına gelir. Windows ve macOS kullanıcıları, yukarıda listelenen hedeflerden herhangi biri için Zig ve C kodunu derleyebilir ve libc'ye bağlayabilir. Benzer şekilde, kod diğer mimariler için çapraz derlenebilir:

```
$ zig build-exe hello.c --library c -target aarch64-linux-gnu
$ file hello
hello: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, for GNU/Linux 2.0.0, with debug_info, not stripped
```

Bazı açılardan Zig, C derleyicilerinden daha iyi bir C derleyicisidir!

Bu işlevsellik, Zig ile birlikte çapraz derleme araç zincirini birleştirmekten daha fazlasını içerir. Örneğin, Zig'in gönderdiği libc başlıklarının toplam boyutu sıkıştırılmamış olarak 22 MiB'dir. Bununla birlikte, x86_64 için musl libc + linux başlıkları yalnızca 8 MiB, glibc için ise 3.1 MiB'dir (glibc linux başlıklarını içermez). Bununla birlikte, Zig şu anda 40 libc ile birlikte gelirken, Zig'in clang uyumlu bir C derleyicisi olmasına rağmen, derleyici-rt, libunwind ve libcxx ile birlikte Zig'in toplam boyutu yaklaşık 30 MiB'dir. Karşılaştırma yapmak gerekirse, llvm.org'dan indirilen Windows ikili yapısı olarak oluşturulan clang 8.0.0'in kendisi 132 MiB'dir.

Yalnızca [1. Kademe Destek](#tier-1-support) hedeflerin ayrıntılı bir şekilde test edildiğine dikkat edin. [Daha fazla libc eklemek](https://github.com/ziglang/zig/issues/514) (Windows dahil) ve tüm libc'lerle derleme test kapsamını [eklemek](https://github.com/ziglang/zig/issues/2058) planlanmaktadır.

Zig Paket Yöneticisi oluşturmak [planlanmıştır](https://github.com/ziglang/zig/issues/943), ancak henüz tamamlanmamıştır. Mümkün olacak şeylerden biri de C kütüphaneleri için bir paket oluşturmaktır. Bu, [Zig Derleme Sistemini](#zig-derleme-sistemi) hem Zig programcıları hem de C programcıları için çekici hale getirecektir.

## Zig Derleme Sistemi

Zig, make, cmake veya benzeri bir şeye ihtiyaç duymadan bir derleme sistemiyle birlikte gelir.

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

Şimdi `--help` menüsüne bir göz atalım.

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

Kullanılabilir komutlardan biri `run` olduğunu görebilirsiniz.

```
$ zig build run
All your base are belong to us.
```

İşte bazı örnek derleme betikleri:

- [OpenGL Tetris oyununun derleme betiği](https://github.com/andrewrk/tetris/blob/master/build.zig)
- [Bare metal Raspberry Pi 3 arcade oyununun derleme betiği](https://github.com/andrewrk/clashos/blob/master/build.zig)
- [Kendi kendini barındıran Zig derleyicisinin derleme betiği](https://github.com/ziglang/zig/blob/master/build.zig)

## Asenkron Fonksiyonlar ile Eşzamanlılık

Zig 0.5.0 [asenkron fonksiyonları tanıttı](https://ziglang.org/download/0.5.0/release-notes.html#Async-Functions). Bu özellik, ana işletim sistemi veya hatta heap bellekten bağımsızdır. Bu, asenkron fonksiyonların bağımsız hedefler için kullanılabilir olduğu anlamına gelir.

Zig, bir işlevin eşzamansız olup olmadığını anlar ve eşzamansız olmayan işlevlerde eşzamansız/beklemeye izin verir; bu, Zig kitaplıklarının, eşzamansız G/Ç'ye (I/O) karşı engelleme konusunda bilinçsiz olduğu anlamına gelir. [Zig, işlev renklerinden kaçınır](http://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/).

Zig Standard Kütüphanesi, M:N eşzamanlılık için asenkron fonksiyonları bir thread havuzuna aktaran bir etkinlik döngüsü uygular. Çoklu iş parçacığı güvenliği (multithreading safety) ve yarış tespiti (race detection) aktif araştırma alanlarıdır.

## Desteklenen Geniş Hedef Aralığı

Zig, farklı hedefler için destek seviyesini iletmek için bir "destek seviyesi" sistemi kullanır.

[Zig 0.8.0'a göre Destek Tablosu](/download/0.8.0/release-notes.html#Support-Table)

## Paket bakımıyla ilgilenenlere dostane

Referans Zig derleyicisi henüz tamamen kendi kendini (self-hosted) barındırmamış olsa da, [her ne olursa olsun](https://github.com/ziglang/zig/issues/853) bir sistem C++ derleyicisine sahip olmaktan, herhangi bir hedef için tamamen kendi kendini barındıran bir Zig derleyicisine geçmek için sadece 3 adım atmanız gerekecektir. Maya Rashish'in belirttiği gibi, [Zig'i diğer platformlara taşımak eğlenceli ve hızlı](http://coypu.sdf.org/porting-zig.html).

Hata ayıklama olmayan [derleme modları](https://ziglang.org/documentation/master/#Build-Mode) tekrarlanabilir/deterministik niteliğe sahiptir.

İndirme sayfasının [JSON versiyonu](/download/index.json) bulunmaktadır.

Zig ekibinin birçok üyesi paket bakımı konusunda deneyime sahiptir.

- [Daurnimator](https://github.com/daurnimator), [Arch Linux paketini](https://archlinux.org/packages/extra/x86_64/zig/) yönetir.
- [Marc Tiehuis](https://tiehuis.github.io/), Visual Studio Code paketini yönetir.
- [Andrew Kelley](https://andrewkelley.me/), yaklaşık bir yıl [Debian ve Ubuntu paketleme](https://qa.debian.org/developer.php?login=superjoe30%40gmail.com&comaint=yes) çalışmaları yapmış ve [nixpkgs](https://github.com/NixOS/nixpkgs/)'a katkıda bulunmaktadır.
- [Jeff Fowler](https://blog.jfo.click/), Homebrew paketini yönetir ve [Sublime paketini](https://github.com/ziglang/sublime-zig-language) başlatmıştır (şu anda [emekoi](https://github.com/emekoi) tarafından yönetilmektedir).
