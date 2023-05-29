---
title: "Ausführliche Übersicht"
mobile_menu_title: "Übersicht"
toc: true
---
# Feature Highlights
## Kleine, einfache Sprache
Debugge deine Anwendung, nicht deine Kenntnis der Programmiersprache.

Zig's gesamte Syntax ist in 500 Zeilen [PEG-Grammatik](https://ziglang.org/documentation/master/#Grammar) beschrieben.

Es gibt **keinen versteckten Kontrollfluss**, keine versteckten Speicherallokationen, keinen Präprozessor, und keine Makros. Wenn Zig Code nicht aussieht, als ober in einen Funktionsaufruf springt, dann tut er das nicht. Das bedeutet, dass du sicher sein kannst, dass der folgende Code nur `foo()` und dann `bar()` aufruft, und das ist garantiert, ohne die Typen von irgendwelchen Werten zu kennen:

```zig
var a = b + c.d;
foo();
bar();
```

Beispiele von verstecktem Kontrollfluss:

- D hat `@property`-Funktionen -- Methoden, deren Aufruf wie ein Feldzugriff aussieht, also könnte im obigen Beispiel `c.d` eine Funktion aufrufen.
- C++, D, und Rust haben Operatorenüberladung, also könnte der Operator `+` eine Funktion aufrufen.
- C++, D, und Go haben throw/catch-Ausnahmen, also könnte `foo()` eine Ausnahme werfen und die Ausführung von `bar()` verhindern.

 Zig fördert Codewartung und Lesbarkeit, indem Kontrollfluss ausschließlich mit Schlüsselwörtern und Funktionsaufrufen geschieht.

## Performance und Sicherheit: wähle zwei

Zig hat vier [Buildmodi](https://ziglang.org/documentation/master/#Build-Mode), sie können [Scope-weise](https://ziglang.org/documentation/master/#setRuntimeSafety) kombiniert werden.

| Parameter | [Debug](/documentation/master/#Debug) | [ReleaseSafe](/documentation/master/#ReleaseSafe) | [ReleaseFast](/documentation/master/#ReleaseFast) | [ReleaseSmall](/documentation/master/#ReleaseSmall) |
|-----------|-------|-------------|-------------|--------------|
Optimierungen - bessere Geschwindigkeit,<br /> schlechteres Debugging und Compilierdauer | | -O3 | -O3| -Os |
Laufzeitsicherheitschecks - schlechtere Geschwindigkeit <br />und Programmgröße, Crashes statt undefiniertem Verhalten | On | On | | |

So sieht [Integer Overflow](https://ziglang.org/documentation/master/#Integer-Overflow) zur Compilezeit aus, in jedem Buildmodus:

{{< zigdoctest "assets/zig-code/features/1-integer-overflow.zig" >}}

So sieht er zur Laufzeit aus, in safety-checked-Builds:

{{< zigdoctest "assets/zig-code/features/2-integer-overflow-runtime.zig" >}}


Die [Stacktraces funktionieren auf allen Targets](#stacktraces-auf-allen-targets), auch [freestanding](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html).

Zig erlaubt es, sich auf einen Buildmodus mit aktivierter Sicherheit zu verlassen, und die Sicherheit an Performanceengpässen selektiv zu deaktivieren. Das vorherige Beispiel könnte so verändert werden:

{{< zigdoctest "assets/zig-code/features/3-undefined-behavior.zig" >}}

Zig benutzt [undefiniertes Verhalten](https://ziglang.org/documentation/master/#Undefined-Behavior) als ein  messerscharfes Instrument zur Vermeidung von Bugs und Performanceverbesserung.

Apropos Performance: Zig ist schneller als C.

- Die Referenzimplementierung nutzt LLVM als Backend für Optimierungen auf dem neuesten Stand der Technik.
- Was andere Sprachen "Link Time Optimization" nennen, tut Zig automatisch.
- Für native Targets sind moderne CPU-Features aktiviert (`-march=native`), denn [Crosscompiling ist ein primärer Einsatzfall](#crosscompiling-ist-ein-primärer-einsatzfall).
- Sorgfältig ausgewähltes undefiniertes Verhalten. Zum Beispiel haben in Zig sowohl signed und unsigned Integers undefiniertes Verhalten beim Überlauf, was in C nur bei signed Integers der Fall ist. Das [ermöglicht Optimierungen, die in C nicht möglich sind](https://godbolt.org/z/n_nLEU).
- Zig stellt einen [Vektortyp für SIMD](https://ziglang.org/documentation/master/#Vectors) zur Verfügung, der es einfach macht, portablen vektorisierten Code zu schreiben.

Beachte bitte, dass Zig keine vollständig sichere Sprache ist. Interessierte an der Geschichte von Zigs Sicherheit können diese Issues abbonieren:

- [enumerate all kinds of undefined behavior, even that which cannot be safety-checked](https://github.com/ziglang/zig/issues/1966)
- [make Debug and ReleaseSafe modes fully safe](https://github.com/ziglang/zig/issues/2301)

## Zig ist nicht abhängig von C, sondern konkurriert mit C

Zigs Standardbibliothek kann libc einbeziehen, aber ist nicht darauf angewiesen. Hier ist Hello World:

{{< zigdoctest "assets/zig-code/features/4-hello.zig" >}}

Mit `-O ReleaseSmall` kompiliert, ohne Debugsymbole, im Single Thread-Modus, wird für das Target x86_64-linux eine 9.8 KiB große statische Programmdatei erzeugt:
```
$ zig build-exe hello.zig -O ReleaseSmall --strip --single-threaded
$ wc -c hello
9944 hello
$ ldd hello
  not a dynamic executable
```

Ein Build auf Windows ist noch kleiner, nur 4096 Bytes:
```
$ zig build-exe hello.zig -O ReleaseSmall --strip --single-threaded -target x86_64-windows
$ wc -c hello.exe
4096 hello.exe
$ file hello.exe
hello.exe: PE32+ executable (console) x86-64, for MS Windows
```

## Deklarationen in beliebiger Reihenfolge

Deklarationen im Toplevel, wie globale Variablen, sind reihenfolgenunabhängig und werden nur bei Bedarf ausgewertet. Die Initialisierungswerte globaler Variablen werden [zur Compilezeit ausgewertet](#introspektion-und-codeausführung-zur-compilezeit).

{{< zigdoctest "assets/zig-code/features/5-global-variables.zig" >}}

## Optionale Typen statt Nullpointer

In anderen Programmiersprachen sind Nullzeiger die Quelle vieler Laufzeitprobleme, und werden sogar beschuldigt, [der schlimmste Fehler der Computerwissenwschaft](https://www.lucidchart.com/techblog/2015/08/31/the-worst-mistake-of-computer-science/) zu sein.

Rohe Pointer können in Zig nicht Null sein:

{{< zigdoctest "assets/zig-code/features/6-null-to-ptr.zig" >}}

Jedoch kann jeder Typ durch ein vorgestelltes ? in einen [optionalen Typ](https://ziglang.org/documentation/master/#Optionals) verwandelt werden:

{{< zigdoctest "assets/zig-code/features/7-optional-syntax.zig" >}}

Um einen optionalen Typ zu entpacken, kann ein `orelse` verwendet werden, um einen Default-Wert anzugeben:

{{< zigdoctest "assets/zig-code/features/8-optional-orelse.zig" >}}

Stattdessen kann auch ein if verwendet werden:

{{< zigdoctest "assets/zig-code/features/9-optional-if.zig" >}}

Dieselbe Syntax funktioniert mit [while](https://ziglang.org/documentation/master/#while):

{{< zigdoctest "assets/zig-code/features/10-optional-while.zig" >}}

## Manuelle Speicherverwaltung

Eine in Zig verfasste Bibliothek kann überall verwendet werden:

- [Desktopanwendungen](https://github.com/TM35-Metronome/)
- Server mit geringer Latenz
- [Betriebssystemkernel](https://github.com/AndreaOrru/zen)
- [Embedded-Geräte](https://github.com/skyfex/zig-nrf-demo/)
- Echtzeitsoftware, z.B. Liveauftritte, Flugzeuge, Herzschrittmacher
- [In Webbrowsern oder anderen Plugins mit WebAssembly](https://shritesh.github.io/zigfmt-web/)
- Mit anderen Programmiersprachen, über die C ABI

Um das zu erreichen, müssen Zig-Programmierer ihren Speicher selbst verwalten und mit scheiternder Speicherallokation umgehen.

Das trifft auch auf die Standardbibliothek zu. Alle Funktionen, die Speicher allozieren müssen, nehmen einen `Allocator` als Parameter an. Damit kann die Standardbibliothek sogar auf dem Freestanding-Target verwendet werden.

Außer einem [neuen Ansatz zur Fehlerbehandlung](#ein-neuer-ansatz-zur-fehlerbehandlung), stellt Zig [defer](https://ziglang.org/documentation/master/#defer) und [errdefer](https://ziglang.org/documentation/master/#errdefer) zur Verfügung, um alle Ressourcenverwaltung -- nicht nur Speicher -- einfach und leicht verifizierbar zu machen.

Für Beispiele von `defer` siehe [Integration mit C-Bibliotheken ohne FFI/Bindings](#integration-mit-c-bibliotheken-ohne-ffibindings). Hier ist ein Beispiel von `errdefer`:
{{< zigdoctest "assets/zig-code/features/11-errdefer.zig" >}}


## Ein neuer Ansatz zur Fehlerbehandlung

Fehler sind Werte, und können nicht ignoriert werden:

{{< zigdoctest "assets/zig-code/features/12-errors-as-values.zig" >}}

Fehler können mit [catch](https://ziglang.org/documentation/master/#catch) verarbeitet werden:

{{< zigdoctest "assets/zig-code/features/13-errors-catch.zig" >}}

Das Schlüsselwort [try](https://ziglang.org/documentation/master/#try) ist eine Abkürzung für `catch |err| return err`:

{{< zigdoctest "assets/zig-code/features/14-errors-try.zig" >}}

Bemerke, dass das ein [Error Return Trace](https://ziglang.org/documentation/master/#Error-Return-Traces) ist, kein [Stacktrace](#stacktraces-auf-allen-targets). Der Code hat nicht den Preis einer Stackabwicklung gezahlt, um den Trace zu erhalten.

Das [switch](https://ziglang.org/documentation/master/#switch)-Schlüsselwort, benutzt mit einem Fehlerwert, stellt sicher, dass alle möglichen Fehler behandelt werden:

{{< zigdoctest "assets/zig-code/features/15-errors-switch.zig" >}}

Das Schlüsselwort [unreachable](https://ziglang.org/documentation/master/#unreachable) kann genutzt werden, um zu versichern, dass kein Fehler auftreten kann:

{{< zigdoctest "assets/zig-code/features/16-unreachable.zig" >}}

Das führt in den ungesicherten Buildmodi zu [undefiniertem Verhalten](#performance-und-sicherheit-wähle-zwei) und sollte nur genutzt werden, wenn der Erfolg wirklich garantiert ist.

### Stacktraces auf allen Targets

Die Stacktraces und [Error Return Trace](https://ziglang.org/documentation/master/#Error-Return-Traces) auf dieser Seite funktionieren für alle Targets mit [Tier 1 Support](#tier-1-support) und einige mit [Tier 2 Support](#tier-2-support). [Sogar Freestanding](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html)!

Außerdem kann die Standardbibliothek an jedem Punkt einen Stacktrace aufzeichnen und später ausgeben:

{{< zigdoctest "assets/zig-code/features/17-stack-traces.zig" >}}

Diese Technik wird für den (in Entwicklung befindlichen) [GeneralPurposeDebugAllocator](https://github.com/andrewrk/zig-general-purpose-allocator/#current-status) verwendet.

## Generische Datenstrukturen und Funktionen

Typen sind Werte, die zur Compilezeit bekannt sein müssen:

{{< zigdoctest "assets/zig-code/features/18-types.zig" >}}

Eine generische Datenstruktur ist einfach eine Funktion, die einen `type` zurückgibt:

{{< zigdoctest "assets/zig-code/features/19-generics.zig" >}}

## Introspektion und Codeausführung zur Compilezeit

Die Builtinfunktion [@typeInfo](https://ziglang.org/documentation/master/#typeInfo) erlaubt Introspektion:

{{< zigdoctest "assets/zig-code/features/20-reflection.zig" >}}

Die Standardbibliothek benutzt diese Technik, um formatierte Ausgabe zu implementieren. Obwohl es eine [kleine, einfache Sprache](#kleine-einfache-sprache) ist, wurde die formatierte Ausgabe vollständig in Zig programmiert. Währenddessen sind die Compilierfehler für `printf` in den C-Compiler und das Formatierungsmakro in den Rust-Compiler hartkodiert.

Zig kann auch Funktionen und Codeblöcke zur Compilezeit auswerten. In einigen Kontexten, wie der Initialisierung von globalen Variablen, geschieht dies implizit. Andernfalls kann Code mit dem Schlüsselwort [comptime](https://ziglang.org/documentation/master/#comptime) explizit zur Compilezeit ausgewertet werden. In Kombination mit Assertions ist dies ein mächtiges Werkzeug:

{{< zigdoctest "assets/zig-code/features/21-comptime.zig" >}}

## Integration mit C-Bibliotheken ohne FFI/Bindings

[@cImport](https://ziglang.org/documentation/master/#cImport) importiert direkt Typen, Variablen, Funktionen und einfache Makros aus C-Bibliotheken und kann sogar Funktionen von C nach Zig übersetzen.

Hier ist ein Beispiel, das mit [libsoundio](http://libsound.io/) ein Sinuswelle ausgibt:

<u>sine.zig</u>
{{< zigdoctest "assets/zig-code/features/22-sine-wave.zig" >}}

```
$ zig build-exe sine.zig -lsoundio -lc
$ ./sine
Output device: Built-in Audio Analog Stereo
^C
```

[Dieser Zig-Code ist signifikant einfacher als der äquivalente C-Code](https://gist.github.com/andrewrk/d285c8f912169329e5e28c3d0a63c1d8), hat mehr Sicherheitsvorkehrungen, und all das wird mit einem einfache `@cImport` der C-Headerdateien erreicht -- ohne API-Bindings.

*Zig kann C-Bibliotheken besser nutzen als das C selbst kann.*

### Zig ist auch ein C-Compiler

Hier ist ein Beispiel dafür, wie Zig C-Code kompiliert:

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

Die Flag `--verbose-cc` zeigt, welcher C-Compiler-Befehl ausgeführt wird:
```
$ zig build-exe hello.c --library c --verbose-cc
zig cc -MD -MV -MF zig-cache/tmp/42zL6fBH8fSo-hello.o.d -nostdinc -fno-spell-checking -isystem /home/andy/dev/zig/build/lib/zig/include -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-gnu -isystem /home/andy/dev/zig/build/lib/zig/libc/include/generic-glibc -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-any -isystem /home/andy/dev/zig/build/lib/zig/libc/include/any-linux-any -march=native -g -fstack-protector-strong --param ssp-buffer-size=4 -fno-omit-frame-pointer -o zig-cache/tmp/42zL6fBH8fSo-hello.o -c hello.c -fPIC
```

Wird der Befehl erneut ausgeführt, bricht er sofort ab, ohne den Compiler aufzurufen:
```
$ time zig build-exe hello.c --library c --verbose-cc

real	0m0.027s
user	0m0.018s
sys	0m0.009s
```

Das geschieht dank dem [Build Artifact Caching](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching). Zig parst automatisch die erzeugte Depfile und benutzt ein robustes Cachesystem, um redundante Arbeit zu vermeiden.

Nicht nur kann Zig C kompilieren, sondern es gibt auch einen sehr guten Grund, Zig als C-Compiler zu nutzen: [Zig enthält libc](#zig-enthält-libc).

### Export von Funktionen, Variablen und Typen für C-Code

Ein primärer Einsatzfall für Zig ist es, eine Bibliothek mit C ABI zu exportieren, die von anderen Sprachen genutzt werden kann. Das Schlüsselwort `export` vor Funktionen, Variablen und Typen macht sie zu einem Teil der API der Bibliothek:

<u>mathtest.zig</u>
{{< zigdoctest "assets/zig-code/features/23-math-test.zig" >}}

Um eine statische Bibliothek zu erzeugen:
```
$ zig build-lib mathtest.zig
```

Um eine dynamische Bibliothek zu erzeugen:
```
$ zig build-lib mathtest.zig -dynamic
```

Hier ein Beispiel des [Zig-Buildsystems](#zigs-buildsystem):

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

## Crosscompiling ist ein primärer Einsatzfall

Zig kann für jedes der Targets im [Support Table](#support-table) mit [Tier 3 Support](#tier-3-support) oder besser kompilieren. Dazu muss keine "cross toolchain" oder Ähnliches muss installiert werden. Hier ist ein natives Hello World:

{{< zigdoctest "assets/zig-code/features/4-hello.zig" >}}

Und jetzt Builds für x86_64-windows, x86_64-macosx und aarch64v8-linux:
```
$ zig build-exe hello.zig -target x86_64-windows
$ file hello.exe
hello.exe: PE32+ executable (console) x86-64, for MS Windows
$ zig build-exe hello.zig -target x86_64-macosx
$ file hello
hello: Mach-O 64-bit x86_64 executable, flags:<NOUNDEFS|DYLDLINK|TWOLEVEL|PIE>
$ zig build-exe hello.zig -target aarch64v8-linux
$ file hello
hello: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), statically linked, with debug_info, not stripped
```

Das funktioniert auf jedem Target mit [Tier 3](#tier-3-support)+, für jedes Target mit [Tier 3](#tier-3-support)+.

### Zig enthält libc

`zig targets` listet unter anderem die verfügbaren libc-Targets auf:
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

Das bedeutet, dass `--library c` für diese Targets *von keinerlei Systemdateien abhängt*!

Sehen wir uns  wieder das [Hello World-Beispiel in C](#zig-ist-auch-ein-c-compiler) an:
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

Im Gegensatz zu [glibc](https://www.gnu.org/software/libc/) unterstützt [musl](https://www.musl-libc.org/) statische Kompilierung:
```
$ zig build-exe hello.c --library c -target x86_64-linux-musl
$ ./hello
Hello world
$ ldd hello
  not a dynamic executable
```

In diesem Beispiel hat Zig musls Quellcode kompiliert und verlinkt. Dank dem [Cachesystem](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching) bleibt das Build von musl-libc für `x86_64-linux` verfügbar und kann bei Bedarf sofort genutzt werden.

Das bedeutet, dass die Funktionalität auf jeder Plattform verfügbar ist. Nutzer von Windows und macOS können Zig- und C-Code für jedes der obigen Targets kompilieren und gegen libc linken. Auf ähnliche Art und Weise kann Code für andere Prozessorarchitekturen crosskompiliert werden:
```
$ zig build-exe hello.c --library c -target aarch64v8-linux-gnu
$ file hello
hello: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, for GNU/Linux 2.0.0, with debug_info, not stripped
```

In mancher Hinsicht kann Zig besser C kompilieren als C-Compiler!

Diese Funktionalität ist mehr als eine mit Zig gebündelte Cross-Toolchain. Zum Beispiel sind die libc-Header, die Zig mitbringt, unkomprimiert 22 MiB groß. Dabei kommen die Header für musl libc + Linux auf x86_64 alleine auf 8 MiB, und die Header für glibc machen 3.1 MiB aus (glibc fehlen die Linux-Header), aber Zig enthält momentan 40 libcs. Ohne Bündelung wären das 444 MiB. Dank meines Tools [process_headers](https://github.com/ziglang/zig/blob/0.4.0/libc/process_headers.zig) jedoch, und ein wenig [guter alter manueller Arbeit](https://github.com/ziglang/zig/wiki/Updating-libc), bleiben Zigs binäre Tarballs bei insgesamt rund 30 MiB, trotz Unterstützung für libc auf all diesen  Targets, sowie compiler-rt, libunwind und libcxx, und dem Clang-kompatiblen C-Compiler. Zum Vergleich: das Build von clang 8.0.0 von llvm.org für Windows ist 132 MiB groß.

Beachte, dass nur die Targets im [Tier 1 Support](#tier-1-support) ausführlich getestet wurden. Es ist geplant, [mehr libcs](https://github.com/ziglang/zig/issues/514) hinzuzufügen (auch für Windows), und [Testabdeckung für Builds gegen alle libcs](https://github.com/ziglang/zig/issues/2058) zu erreichen.

Ein [Paketmanager für Zig](https://github.com/ziglang/zig/issues/943) ist geplant, aber noch nicht fertig. Damit soll es möglich werden, Pakete für C-Bibliotheken zu erstellen. Dies würde das [Zigs Buildsystem](#zigs-buildsystem) für Zig- und C-Programmierer gleichermaßen attraktiv machen.

## Zigs Buildsystem

Zig enthält ein Buildsystem, das make, cmake oder Ähnliches ersetzen kann.
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


Schauen wir uns das Menü `--help` an:
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

Einer der verfügbaren Steps ist es, den Code direkt auszuführen (`run`):
```
$ zig build run
All your base are belong to us.
```

Hier sind einige Buildscripts als Beispiel:

- [Build script of OpenGL Tetris game](https://github.com/andrewrk/tetris/blob/master/build.zig)
- [Build script of bare metal Raspberry Pi 3 arcade game](https://github.com/andrewrk/clashos/blob/master/build.zig)
- [Build script of self-hosted Zig compiler](https://github.com/ziglang/zig/blob/master/build.zig)

## Parallelität mit async-Funktionen

Zig 0.5.0 hat [async-Funktionen eingeführt](https://ziglang.org/download/0.5.0/release-notes.html#Async-Functions). Dieses Feature ist nicht vom Hostsystem oder Heapspeicher abhängig. Das bedeutet, dass async-Funktionen auch auf dem Freestanding-Target verfügbar sind.

Zig leitet automatisch ab, ob eine Funktion async ist, und erlaubt `async`/`await` auf nicht-async-Funktionen, was **Zig-Bibliotheken agnostisch gegenüber blockierendem oder asynchronen I/O** macht. [Zig vermeidet Funktionenfarben](http://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/).



Die Standardbibliothek implementiert eine Eventschleife, die async-Funktionen über einen Threadpool verteilt und damit N:M-Concurrency erlaubt. An den Bereichen der Multithreading-Sicherheit und Erkennung von Race-Conditions wird aktiv gearbeitet.

## Breite Menge an unterstützten Targets

Zig kommuniziert die Unterstützung von verschiedenen Targets mit "Support Tiers". Beachte, dass die Anforderungen für [Tier 1 Support](#tier-1-support) hoch sind -- [Tier 2 Support](#tier-2-support) ist immer noch ziemlich nützlich.

### Support Table

| | Freestanding | Linux 3.16+ | macOS 10.13+ | Windows 8.1+ | FreeBSD 12.0+ | NetBSD 8.0+ | DragonFly​BSD 5.8+ | UEFI |
|-|---------------|-------------|--------------|--------------|---------------|-------------|-------------------|------|
| x86_64 | [Tier 1](#tier-1-support) | [Tier 1](#tier-1-support) | [Tier 1](#tier-1-support) | [Tier 2](#tier-2-support) | [Tier 2](#tier-2-support) | [Tier 2](#tier-2-support) | [Tier 2](#tier-2-support) | [Tier 2](#tier-2-support) |
| arm64 | [Tier 1](#tier-1-support) | [Tier 2](#tier-2-support) | [Tier 2](#tier-2-support) | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | N/A | [Tier 3](#tier-3-support) |
| arm32 | [Tier 1](#tier-1-support) | [Tier 2](#tier-2-support) | N/A | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | N/A | [Tier 3](#tier-3-support) |
| mips32 LE | [Tier 1](#tier-1-support) | [Tier 2](#tier-2-support) | N/A | N/A | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | N/A | N/A |
| i386 | [Tier 1](#tier-1-support) | [Tier 2](#tier-2-support) | [Tier 4](#tier-4-support) | [Tier 2](#tier-2-support) | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | N/A | [Tier 2](#tier-2-support) |
| riscv64 | [Tier 1](#tier-1-support) | [Tier 2](#tier-2-support) | N/A | N/A | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | N/A | [Tier 3](#tier-3-support) |
| bpf | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | N/A | N/A | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | N/A | N/A |
| hexagon | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | N/A | N/A | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | N/A | N/A |
| mips32 BE | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | N/A | N/A | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | N/A | N/A |
| mips64 | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | N/A | N/A | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | N/A | N/A |
| amdgcn | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | N/A | N/A | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | N/A | N/A |
| sparc | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | N/A | N/A | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | N/A | N/A |
| s390x | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | N/A | N/A | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | N/A | N/A |
| lanai | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | N/A | N/A | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | N/A | N/A |
| powerpc32 | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | [Tier 4](#tier-4-support) | N/A | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | N/A | N/A |
| powerpc64 | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | [Tier 4](#tier-4-support) | N/A | [Tier 3](#tier-3-support) | [Tier 3](#tier-3-support) | N/A | N/A |
| avr | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A |
| riscv32 | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | [Tier 4](#tier-4-support) |
| xcore | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A |
| nvptx | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A |
| msp430 | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A |
| r600 | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A |
| arc | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A |
| tce | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A |
| le | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A |
| amdil | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A |
| hsail | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A |
| spir | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A |
| kalimba | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A |
| shave | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A |
| renderscript | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A | [Tier 4](#tier-4-support) | [Tier 4](#tier-4-support) | N/A | N/A |


### WebAssembly Support Table

|        | Freestanding | emscripten | WASI   |
|--------|---------------|------------|--------|
| wasm32 | [Tier 1](#tier-1-support)        | [Tier 3](#tier-3-support)     | [Tier 1](#tier-1-support) |
| wasm64 | [Tier 4](#tier-4-support)        | [Tier 4](#tier-4-support)     | [Tier 4](#tier-4-support) |


### Tier-System

#### Tier 1 Support
- Zig kann für diese Targets nicht nur Maschinencode erzeugen, auch die plattformunabhängigen Abstraktionen der Standardbibliothek wurden jeweils vollständig implementiert.
- Der CI-Server testet diese Targets automatisch bei jedem Commit zum Master-Branch, und aktualisiert die [Downloadseite]({{< ref "/download/" >}}) mit Links zu den vorkompilierten Binärdateien.
- Diese Targets haben vollständige Debuginformations-Fähigkeiten und erzeugen bei fehlgeschlagenen Assertions [Stacktraces](#stacktraces-auf-allen-targets).
- [die libc ist auch beim Crosskompilieren verfügbar](#zig-enthält-libc).
- Alle Verhaltenstests und anwendbaren Standardbibliothekstests werden für diese Targets bestanden. Alle Features der Sprache funktionieren korrekt.

#### Tier 2 Support
- Die Standardbibliothek unterstützt diese Targets, kann aber teilweise "Unsupported OS"-Kompilezeitfehler erzeugen. Um die Lücken in der Standardbibliothek auszufüllen, kann gegen libc oder andere Bibliotheken verlinkt werden.
- Diese Targets funktionieren, aber werden möglicherweise nicht automatisch getestet, können also gelegentlich rückfällig werden.
- Einige Tests werden für diese Targets möglicherweise deaktiviert, während wir an [Tier 1 Support](#tier-1-support) arbeiten.

#### Tier 3 Support

- Die Standardbibliothek weiß wenig bis gar nichts von diesen Targets.
- Weil Zig auf LLVM basiert, kann es momentan für diese Targets kompilieren, und in LLVM sind sie standardmäßig aktiviert.
- Diese Targets sind nicht standardmäßig getestet; um zu ihnen zu kompilieren, muss man wahrscheinlich zu Zig beitragen.
- Der Compiler muss möglicherweise aktualisiert werden, mit Informationen zu
  - Aufrufkonvention der C ABI für das jeweilige Target
  - Den Größen der Integertypen in C
  - Bootstrapcode und Standard-Panikhandler
- `zig targets` enthält diese Targets auf jeden Fall

#### Tier 4 Support

- Unterstützung für diese Targets ist rein experimentell.
- LLVM enthält dies möglicherweise als experimentelles Target; damit es verfügbar ist, sind Zig-seitige Dateien oder ein speziell konfiguriertes LLVM-Build notwendig. `zig targets` zeigt das Target an, wenn es verfügbar ist.
- Dieses Target wird möglicherweise von einer offiziellen Seite als veraltet eingestuft, wie zum Beispiel [macosx/i386](https://support.apple.com/en-us/HT208436); in dem Fall wird es Tier 4 nie verlassen.
- Dieses Target unterstützt möglicherweise nur `--emit asm` und kann keine Objektdateien ausgeben.

## Einfache Unterstützung von Paketen

Der Compiler ist noch nicht vollständig selbst-gehostet, aber es bleiben unter allen Umständen [höchstens drei Schritte](https://github.com/ziglang/zig/issues/853), um von einem System-C++-Compiler aus einen eigenständigen Zig-Compiler für jedes Target zu erreichen. Wie Maya Rashish anmerkt, [lässt sich Zig angenehm und schnell auf andere Plattformen portieren](http://coypu.sdf.org/porting-zig.html).

Nicht-Debug-[Buildmodi](https://ziglang.org/documentation/master/#Build-Mode) sind reproduzierbar/deterministisch.

Es gibt eine [JSON-Version der Downloadseite](/download/index.json).

Einige Mitglieder des Teams haben Erfahrung im Verwalten von Paketen.

- [Daurnimator](https://github.com/daurnimator) unterstützt ein [Paket für Arch Linux](https://www.archlinux.org/packages/community/x86_64/zig/)
- [Marc Tiehuis](https://tiehuis.github.io/) unterstützt das Paket für Visual Studio Code.
- [Andrew Kelley](https://andrewkelley.me/) hat etwa ein Jahr lang [Debian- und Ubuntupakete verwaltet](https://qa.debian.org/developer.php?login=superjoe30%40gmail.com&comaint=yes) und trägt gelegentlich zu [nixpkgs](https://github.com/NixOS/nixpkgs/) bei.
- [Jeff Fowler](https://blog.jfo.click/) verwaltet das Homebrew-Paket und begann das [Paket für Sublime](https://github.com/ziglang/sublime-zig-language) (jetzt verwaltet von [emekoi](https://github.com/emekoi)).
