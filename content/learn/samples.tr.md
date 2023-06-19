---
title: "Örnek Kodlar"
mobile_menu_title: "Kod Örnekleri"
toc: true
---

## Bellek sızıntısı tespiti

`std.heap.GeneralPurposeAllocator` kullanarak çift serbest bırakmaları ve bellek sızıntılarını takip edebilirsiniz.

{{< zigdoctest "assets/zig-code/samples/1-memory-leak.zig" >}}

## C ile uyumluluk

Bir C başlık dosyasını içe aktarma ve hem libc'ye hem de raylib'e bağlanma örneği.

{{< zigdoctest "assets/zig-code/samples/2-c-interop.zig" >}}

## Zigg Zagg

Zig, mülakatlarda kodlamaya _optimize edilmiştir_ (gerçekte değil).

{{< zigdoctest "assets/zig-code/samples/3-ziggzagg.zig" >}}

## Genel Tipler

Zig'de tipler derleme zamanı değerleridir ve genel algoritmaları ve veri yapılarını uygulamak için bir tür döndüren fonksiyonları kullanırız. Bu örnekte basit bir genel kuyruk uyguluyoruz ve davranışını test ediyoruz.

{{< zigdoctest "assets/zig-code/samples/4-generic-type.zig" >}}

## Zig'den cURL kullanımı

{{< zigdoctest "assets/zig-code/samples/5-curl.zig" >}}
