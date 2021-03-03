---
title: "Codebeispiele"
mobile_menu_title: "Codebeispiele"
toc: true
---

## Speicherlecks aufdecken
Der `std.heap.GeneralPurposeAllocator` kann Doppel-Freigabe und Speicherlecks nachverfolgen.

{{< zigdoctest "assets/zig-code/samples/1-memory-leak.zig" >}}


## Interoperabilität mit C
Import einer C-Headerdatei und Linken gegen libc und raylib.

{{< zigdoctest "assets/zig-code/samples/2-c-interop.zig" >}}


## Zigg Zagg
Zig ist für Programmierinterviews *optimiert* (nicht wirklich).

{{< zigdoctest "assets/zig-code/samples/3-ziggzagg.zig" >}}


## Generische Typen
In Zig sind Typen Compilezeitwerte; wir benutzen Funktionen, die Typen zurückgeben, um generische Algorithmen und Datenstrukturen zu implementieren. In diesem Beispiel implementieren wir eine einfache generische Queue und testen ihr Verhalten.

{{< zigdoctest "assets/zig-code/samples/4-generic-type.zig" >}}


## cURL mit Zig benutzen

{{< zigdoctest "assets/zig-code/samples/5-curl.zig" >}}
