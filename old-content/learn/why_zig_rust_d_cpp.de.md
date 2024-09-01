---
title: "Warum Zig, wenn es schon C++, D und Rust gibt?"
mobile_menu_title: "Warum Zig, wenn..."
toc: true
---


## Kein versteckter Kontrollfluss

Wenn Zig-Code nicht aussieht, als ob er in einen Funktionsaufruf springt, dann tut er das nicht. Das bedeutet, dass du sicher sein kannst, dass der folgende Code nur `foo()` und dann `bar()` aufruft, und das ist garantiert, ohne die Typen von irgendwelchen Werten zu kennen:

```zig
var a = b + c.d;
foo();
bar();
```

Beispiele von verstecktem Kontrollfluss:

* D hat `@property`-Funktionen -- Methoden, deren Aufruf wie ein Feldzugriff aussieht, also könnte im obigen Beispiel `c.d` eine Funktion aufrufen.
* C++, D, und Rust haben Operatorenüberladung, also könnte der Operator `+` eine Funktion aufrufen.
* C++, D, und Go haben throw/catch-Ausnahmen, also könnte `foo()` eine Ausnahme werfen und die Ausführung von `bar()` verhindern. (Natürlich kann auch in Zig `foo()` in eine Endlosschleife geraten und so die Ausführung von `bar()` verhindern, aber das ist in jeder Turing-vollständigen Sprache möglich.)

Diese Designentscheidung wurde getroffen, um die Lesbarkeit zu verbessern.

## Keine versteckten Speicherallokationen

Zig mischt sich nicht in Heapallokationen ein. Es gibt kein `new`-Schlüsselwort oder andere Sprachfeatures, die Allokationen nutzen (z.B. Verkettungsoperatoren für Strings[1]).
Das gesamte Konzept des Heaps wird von Bibliotheks- und Anwendungscode verwaltet, nicht von der Sprache.

Beispiele versteckter Allokationen:

* Das Schlüsselwort `defer` in Go alloziert Speicher auf einem funktionslokalen Stapel. Abgesehen von dem unintuitiven Kontrollfluss kann ein `defer` innerhalb einer Schleife zu unerwartetem Speicherüberlauf führen.
* Koroutinen in C++ allozieren beim Aufruf Heapspeicher.
* In Go kann ein Funktionsaufruf zu Heapallokationen führen, weil Goroutinen kleine Stapel allozieren, die vergrößert werden müssen, wenn der Aufrufstapel zu tief wird.
* Rusts Standardbibliotheks-API führt zu einer Panik, wenn kein freier Speicher verfügbar ist, und alternative APIs mit Allokator-Parametern wurden nur nachträglich bedacht (siehe [rust-lang/rust#29802](https://github.com/rust-lang/rust/issues/29802)).

Fast alle Sprachen mit Garbage Collector sind voller Allokationen, die von der automatischen Speicherverwaltung versteckt werden.

Das Hauptproblem an versteckten Allokationen ist es, dass sie die Wiederverwendbarkeit von Code verhindern, indem sie die Menge an Systemen, die ihn verwenden können, unnötig einschränken. Einfach gesagt gibt es Anwendungsfälle, in denen man sich darauf verlassen können muss, dass Kontrollfluss und Funktionsaufrufe keine Nebeneffekte auf die Speicherallokation haben, und eine Sprache kann diese Anwendungsfälle nur bedienen, wenn sie solche Garantien machen kann.

Zigs Standardbibliothek bietet Features, die Heapallokationen bereitstellen und damit arbeiten, aber diese sind optional, nicht in die Sprache selbst eingebaut.
Wenn du nie einen Allokator initialisierst, kannst du dir sicher sein, dass dein Programm nichts alloziert.

Jedes Feature der Standardbibliothek, das Heapspeicher allozieren muss, nimmt dazu einen `Allocator` als Parameter an. Das bedeutet, dass Zigs Standardbibliothek Freestanding-Targets unterstützt. Zum Beispiel können `std.ArrayList` und `std.AutoHashMap` für Bare-Metal-Programme genutzt werden!

Eigene Allokatoren machen manuelle Speicherverwaltung kinderleicht. Zig hat einen Debug-Allokator, der Speichersicherheit bei Use-after-free und Double-free garantiert. Er detektiert und logt automatisch Speicherlecks. Es gibt einen Arena-Allokator, der beliebig viele Allokationen bündeln und zusammen freigeben kann (statt sie einzeln zu verwalten). Besondere Allokatoren können genutzt werden, um Performance oder Speichernutzung nach den Anforderungen einer Anwendung zu optimieren.

[1]: Tatsächlich gibt es einen Verkettungsoperator für Strings und Arrays, der aber nur zur Compilezeit benutzbar ist und damit auch keine Laufzeit-Heapallokation mit sich bringt.

## Vollständige Unterstützung für keine Standardbibliothek

Wie oben angedeutet, ist Zigs Standardbibliothek absolut optional. Jede API wird nur kompiliert, wenn sie gebraucht wird. Zig unterstützt es gleichermaßen, mit der libc zu linken oder nicht. Zig eignet sich besonders gut für Bare-Metal- und High-Performance-Entwicklung.

Damit hat man das Beste aus beiden Welten: zum Beispiel können WebAssembly-Programme in Zig die normalen Features der Standardbibliothek nutzen, und gleichzeitig im Vergleich zu anderen WebAssembly-Sprachen winzigste Programmdateien erzeugen.

## Eine portable Sprache für Bibliotheken

Ein heiliger Gral des Programmierens ist Code-Wiederverwendung. Leider scheint es in der Praxis, dass wir das Rad immer wieder neu erfinden. Häufig ist das gerechtfertigt.

* Wenn eine Anwendung Echtzeitanforderungen hat, dann ist jede Bibliothek, die Garbage Collection oder ein anderes nicht-deterministisches Verhalten verwendet, als Abhängigkeit disqualifiziert.
* Wenn eine Sprache es zu einfach macht, Fehler zu ignorieren und zu schwer, zu überprüfen, ob eine Bibliothek Fehler korrekt behandelt und auflöst, kann es verlockend sein, die Bibliothek zu ignorieren und sie neu zu implementieren, um sicherzugehen, dass alle relevanten Fehler korrekt behandelt werden. Zig ist so konzipiert, dass das Faulste, was ein Programmierer tun kann, die korrekte Behandlung von Fehlern ist, und so kann man einigermaßen sicher sein, dass eine Bibliothek Fehler korrekt weitergeben wird.
* Derzeit ist aus pragmatischer Sicht C die vielseitigste und portabelste Sprache. Jede Sprache, die nicht mit mit C-Code interagieren kann, riskiert es, in der Versenkung zu verschwinden. Zig versucht, die neue portable Sprache für Bibliotheken zu werden, indem es gleichzeitig C ABI-Konformität für externe Funktionen vereinfacht und Sicherheit und ein Sprachdesign einführt, das häufige Fehler innerhalb der Implementierungen verhindert.

## Ein Paketmanager und Build-System für bestehende Projekte

Zig ist eine Programmiersprache, aber sie bringt auch ein Build-System und einen Paketmanager mit, die auch für traditionelle C/C++-Projekte nützlich sein sollen.

Zig kann nicht nur C- oder C++-Code ersetzen, sondern auch autotools, cmake, make, scons, ninja usw. Und obendrein bietet es (bald™) einen Paketmanager für native Abhängigkeiten. Dieses Build-System ist auch für Projekte relevant, deren gesamte Codebasis aus C oder C++ besteht.

System-Paketmanager wie apt-get, pacman, homebrew und andere sind für Endbenutzer hilfreich, aber sie können für die Bedürfnisse der Entwickler unzureichend sein. Ein sprachspezifischer Paketmanager kann für ein Projekt den Unterschied zwischen keinen und dutzenden Mitwirkenden ausmachen. Bei Open-Source-Projekten ist die Schwierigkeit, das Projekt überhaupt zu kompilieren, eine große Hürde für potentielle Mitwirkende. Für Projekte in C/C++ können Abhängigkeiten fatal sein, besonders auf Windows, wo es keinen Paketmanager gibt. Selbst wenn man nur Zig selbst baut, macht die Abhängigkeit von LLVM den meisten potentiellen Mitwirkenden Schwierigkeiten. Zig bietet (bald) eine Möglichkeit für direkte Abhängigkeiten von nativen Bibliotheken - ohne sich auf den Paketmanager des Benutzers verlassen zu müssen, und auf eine Art und Weise, die erfolgreiche Builds praktisch garantiert, unabhängig vom verwendeten System und der Target-Plattform.

Zig bietet an, das Build-System eines Projekts durch eine vernünftige Sprache zu ersetzen, die eine deklarative API für das Erstellen von Projekten verwendet, die auch eine Paketverwaltung und damit die Möglichkeit bietet, tatsächlich von anderen C-Bibliotheken abzuhängen. Die Fähigkeit, Abhängigkeiten gut zu verwalten, ermöglicht Abstraktionen auf höherer Ebene und damit die Verbreitung von wiederverwendbarem High-Level-Code.

## Einfachheit

C++, Rust und D haben eine große Zahl Features, die von der Bedeutung des Anwendungscodes ablenken können. So muss man früher oder später seine Kenntnis der Programmiersprache debuggen, statt das eigentliche Programm reparieren zu können.

Zig hat keine Makros und keine gesonderte Metaprogrammierung, und ist trotzdem mächtig genug, komplexe Programme einfach und ohne Wiederholungen auszudrücken. Sogar Rust, mit Makros, macht `format!` zu einem Sonderfall und implementiert es im Compiler selbst. Die äquivalente Funktion in Zig ist mit normalem Zig-Code in der Standardbibliothek implementiert.

## Tooling

Zig kann von der [Downloadseite](/download/) heruntergeladen werden. Die binären Archive für Linux, Windows, macOS und FreeBSD...

* werden einfach durch Entpacken des Archivs installiert
* sind statisch kompiliert
* benutzen die ausgereifte, gut unterstützte LLVM-Infrastruktur, die weitreichende Optimierungen und Unterstützung für die meisten größeren Plattformen enthält
* sind mit Quellcode für libc gebündelt, der für jede unterstützte Plattform bei Bedarf automatisch kompiliert wird
* enthalten ein Buildsystem mit Caching
* kompilieren C- und C++-Code mit Unterstützung für libc
