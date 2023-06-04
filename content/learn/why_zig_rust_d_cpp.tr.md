---
title: "Zaten C++, D ve Rust Var İken Neden Zig?"
mobile_menu_title: "Neden Zig?"
toc: true
---

## Gizli kontrol akışı yok

Eğer Zig kodu, bir işlevi çağırmıyorsa, o zaman çağırmaz. Bu, aşağıdaki kodun sadece `foo()` ve ardından `bar()` çağırdığından emin olabileceğiniz anlamına gelir ve bunu herhangi bir şeyin türlerini bilmek zorunda kalmadan garanti eder:

```zig
var a = b + c.d;
foo();
bar();
```

Gizli kontrol akışı örnekleri:

- D'nin `@property` işlevleri, yukarıdaki örnekte `c.d`'nin bir işlevi çağırabileceği gibi görünen yöntemlerdir.
- C++, D ve Rust'da operatör aşırı yüklemesi bulunur, bu nedenle `+` operatörü bir işlevi çağırabilir.
- C++, D ve Go'da atma/yakalama istisnaları vardır, bu nedenle `foo()` bir istisna fırlatabilir ve `bar()`'ın çağrılmasını engelleyebilir. (Elbette, Zig'de bile `foo()` bir işlemi bekleyebilir ve `bar()`'ın çağrılmasını engelleyebilir, ancak bu her Turing tamamlanabilir dilde olabilir.)

Bu tasarım kararının amacı, okunabilirliği artırmaktır.

## Gizli tahsis yok

Zig, bellek tahsisinde el değmeyen bir yaklaşıma sahiptir. `new` anahtar kelimesi veya başka bir dil özelliği kullanılmaz (örneğin dize birleştirme operatörü[1]). Belleğin tamamı, dil tarafından değil, kütüphane ve uygulama kodu tarafından yönetilir.

Gizli tahsis örnekleri:

- Go'nun `defer` işlevi, işleve yerel bir yığın oluştururken (function-local stack) bellek tahsis eder. Bu kontrol akışının çalışma şekli için sezgisel bir yol olmamasının yanı sıra, döngü içinde `defer` kullanırsanız yetersiz bellek alanı hatalarına neden olabilir.
- C++ koşullu işlemler, bir koşullu işlemi çağırmak için bellek tahsis eder.
- Go'da bir işlev çağrısı, gorutinlerin küçük yığınlar tahsis etmesi nedeniyle bellek tahsisine neden olabilir ve çağrı yığını derinleştikçe yeniden boyutlandırılır.
- Ana Rust standart kütüphane API'leri, hafıza tükenmesi durumunda hatalar fırlatır ve alternatif olarak bellek tahsis parametreleri kabul eden API'ler ikincil düşünce olarak yer alır (bkz. [rust-lang/rust#29802](https://github.com/rust-lang/rust/issues/29802)).

Çöp toplayıcı, temizleme tarafındaki kanıtları gizlediğinden, neredeyse tüm çöp toplama dilleri etrafa saçılmış gizli ayırmalara sahiptir.

Gizli tahsislerin temel sorunu, bir kod parçasının _yeniden kullanılabilirliğini_ engellemesidir ve gereksiz yere kodun uygun olduğu ortamların sayısını sınırlamasıdır. Basitçe söylemek gerekirse, bir işlem çağrısının ve kontrol akışının bellek tahsisinin yan etkisi olmamasına güvenmek gereken kullanım durumları vardır ve bir programlama dili, bu garantiyi gerçekçi bir şekilde sağlayabiliyorsa yalnızca bu kullanım durumlarına hizmet edebilir.

Zig'de, bellek tahsisi yapmak için gerekli olan standart kütüphane özellikleri vardır, ancak bunlar dilin kendisine yerleşik olmayan isteğe bağlı standart kütüphane özellikleridir. Bir bellek tahsisleyiciyi hiç başlatmazsanız, programınızın bellek tahsis etmeyeceğinden emin olabilirsiniz.

Bellek tahsisi gerektiren her standart kütüphane özelliği, bunu yapabilmek için bir `Allocator` parametresi kabul eder. Bu, Zig standart kütüphanesinin bağımsız hedefler için destek sağladığı anlamına gelir. Örneğin, `std.ArrayList` ve `std.AutoHashMap` bare-metal programlama için kullanılabilir!

Özel bellek tahsisleyicileri, manuel bellek yönetimini kolaylaştırır. Zig, kullanım sonrası use-after-free ve double-free kullanım karşısında bellek güvenliğini koruyan bir hata ayıklama tahsisleyicisine sahiptir. Bellek sızıntılarının yığın izlerini otomatik olarak algılar ve yazdırır. Her bir tahsislemeyi bağımsız olarak yönetmek yerine her bir tahsislemeyi bir araya getirip hepsini bir seferde serbest bırakan bir arena tahsisleyici vardır. Özel amaçlı tahsisleyiciler, belirli bir uygulamanın performansını veya bellek kullanımını iyileştirmek için kullanılabilir.

[1]: Aslında bir dize birleştirme operatörü vardır (genellikle bir dizi birleştirme operatörü), ancak yalnızca derleme zamanında çalışır, bu nedenle herhangi bir çalışma zamanı bellek tahsisi yapmaz.

## Standart Kütüpheden Bağımsızlık için Birinci Sınıf Destek

Yukarıda ima edildiği gibi, Zig tamamen isteğe bağlı bir standart kitaplığa sahiptir. Her standart kütüphane API'si yalnızca onu kullanırsanız programınıza derlenir. Zig, libc'ye karşı bağlanma veya ona karşı bağlanmama konusunda eşit desteğe sahiptir. Zig, bare-metal ve yüksek performanslı geliştirmeye dosttur.

Her iki dünyanın da en iyisi; örneğin Zig'te, WebAssembly programları hem standart kütüphanenin normal özellikleri kullanılabilir hem de WebAssembly'a derlemeyi destekleyen diğer programlama dilleriyle karşılaştırıldığında en küçük çıktıyla sonuçlanabilir.

## Kütüphaneler İçin Taşınabilir Bir Dil

Programlamanın kutsal kâselerinden biri kodun yeniden kullanımıdır. Ne yazık ki, pratikte kendimizi tekerleği defalarca yeniden icat ederken buluyoruz. Çoğu zaman bunun haklı bir sebebi vardır.

- Bir uygulamanın gerçek zamanlı gereksinimleri varsa, bellek toplama veya herhangi bir belirsiz davranış kullanan herhangi bir kütüphane bağımlılığı diskalifiye edilir.
- Bir dil hataları görmezden gelmeyi çok kolaylaştırıyorsa ve böylece bir kütüphanenin hataları doğru bir şekilde işlediğini ve yukarı doğru taşıdığını doğrulamak zor olursa, kütüphaneyi görmezden gelip yeniden uygulamak cazip olabilir. Zig, bir programcının en tembel davranışının hataları doğru bir şekilde işlemek olduğu şekilde tasarlandığından, bir kütüphanenin hataları doğru bir şekilde yukarı taşımasını güvenilir bir şekilde sağlayabilirsiniz.
- Şu anda, pragmatik olarak C'nin en çok yönlü ve taşınabilir dil olduğu doğrudur. C koduyla etkileşim yeteneği olmayan herhangi bir dil, unutulmaya mahkumdur Zig, aynı anda harici işlevler için C ABI'ye uymayı kolaylaştırarak ve uygulamalardaki yaygın hataları önleyen güvenlik ve dil tasarımı sunarak kitaplıklar için yeni taşınabilir dil olmaya çalışıyor.

## Varolan Projeler İçin Bir Paket Yöneticisi ve Derleme Sistemi

Zig bir programlama dili olsa da, geleneksel bir C/C++ projesi bağlamında da kullanışlı olması amaçlanan bir derleme sistemi ve paket yöneticisi ile birlikte gelir.

Zig kodu yerine C veya C++ kodu yazabilirsiniz ve Zig'i otomatik araçlar, cmake, make, scons, ninja vb. yerine kullanabilirsiniz. Üstelik bunun üzerine, yerel hedefleri düzenlemek ve birden çok dil ve kütüphane arasında karmaşık iş akışlarını yönetmek için yeterli özgürlüğe sahipsiniz. Zig, derleme sürecini ve araçları uyarlamak için esnek bir yapı sunar.

Zig'in paket yöneticisi, projelerinizi ve bağımlılıklarınızı yönetmek için basit ve tutarlı bir arayüz sunar. Paketlerin, yerel kaynak kodu dahil olmak üzere birden çok projede paylaşılmasını sağlar. Bu, daha önce bahsedilen kodun yeniden kullanılabilirliği için de büyük bir avantajdır.

## Basitlik

C++, Rust ve D gibi diller o kadar çok özelliğe sahiptir ki, üzerinde çalıştığınız uygulamanın gerçek anlamından dikkati dağıtabilirler. Bir kişi kendini, uygulamayı hata ayıklamak yerine, programlama diline dair bilgisini hakkında hata ayıklamaya çalışırken bulabilir.

Zig'de makrolar ve meta programlama yoktur, ancak karmaşık programları açık, tekrarlamayan bir şekilde ifade etmek için yine de yeterince güçlüdür. Hatta Rust bile `format!` gibi özel durumları olan makrolara sahiptir, ki bunlar derleyici tarafından uygulanır. Oysa Zig'de, karşılık gelen işlev, derleyicide özel durum kodu olmadan standart kütüphanede uygulanmıştır.

## Araçlar

Zig, [indirme bölümünden](/download/) indirilebilir. Zig, Linux, Windows, macOS ve FreeBSD için çalıştırılabilir dosyalar sağlar. Aşağıda, bu arşivlerden biriyle neler elde edilebileceği açıklanmaktadır:

- Tek bir arşiv indirilerek ve çıkarılarak kurulur, sistem yapılandırması gerekmez.
- Statik olarak derlenir, bu yüzden çalışma zamanı bağımlılıkları yoktur.
- Olgun ve iyi desteklenen LLVM altyapısını kullanır, derin optimizasyon ve çoğu büyük platform için destek sağlar.
- Hemen hemen tüm büyük platformlara otomatik çapraz derleme desteği sunar.
- Desteklenen herhangi bir platform için gerektiğinde dinamik olarak derlenen libc'nin kaynak kodunu içerir.
- Önbellekleme özelliğine sahip derleme sistemi içerir.
- libc desteğiyle C ve C++ kodunu derler.
