---
title: Einstieg
mobile_menu_title: "Einstieg"
toc: true
---


## Release oder Nightly Build?
Zig hat noch nicht die Version 1.0 erreicht und der aktuelle Release-Zyklus ist an neue Releases von LLVM gebunden, die etwa alle 6 Monate erscheinen.
In der Praxis **liegen Zigs Releases weit auseinander und werden bei der momentanen Entwicklungsgeschwindigkeit schnell veraltet**.

Die getaggten Versionen können verwendet werden, aber wenn du tiefer in Zig einsteigen möchtest, **empfehlen wir, auf ein Nightly Build umzusteigen**, vor allem, weil du so einfacher Hilfe bekommen kannst: der Großteil der Community und Seiten wie 
[ziglearn.org](https://ziglearn.org) verfolgen aus obigen Gründen den Master-Branch.

Die gute Nachricht ist, dass es sehr einfach ist, von einer Version von Zig auf eine andere umzusteigen, oder sogar mehrere Versionen gleichzeitig zu nutzen: Zigs Releases sind einfach Archive, die alles Notwendige enthalten und überall im System platziert werden können.


## Zig installieren
### Direkter Download
Dies ist der einfachste Weg, Zig zu bekommen: nimm ein Paket von der [Downloads](/download)-Seite,
extrahiere es in ein Verzeichnis und füge es an deinen `PATH` an, um Zig von überall nutzen zu können.

#### Auf Windows den PATH ändern
Um deine PATH-Variable auf Windows einzustellen, führe **einen** der folgenden Codeschnipsel mit Powershell aus.
Entscheide dich, ob du diese Änderung systemweit durchführen willst (erfordert eine mit Adminrechten ausgeführte Powershell)
oder nur für deinen Benutzer, und **ändere den Schnipsel, um auf deine Kopie von Zig zu verweisen**.
Das `;` vor dem `C:` ist kein Tippfehler.

Systemweit (**Admin**-Powershell):
```
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "Machine") + ";C:\dein-pfad\zig-windows-x86_64-deine-version",
   "Machine"
)
```

Benutzerweise (Powershell):
```
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\dein-pfad\zig-windows-x86_64-deine-version",
   "User"
)
```
Wenn du fertig bist, starte die Powershell neu.

#### Auf Linux, macOS oder BSD den PATH ändern
Füge das Verzeichnis der zig-Binärdatei zu deiner PATH-Umgebungsvariable hinzu.

Dazu wird meistens eine Zeile an das Startupscript (`.profile`, `.zshrc`, ...) der Shell angefügt:
```bash
export PATH=$PATH:~/pfad/von/zig
```
Wenn du fertig bist, rufe `source` mit deiner Startupdatei auf oder starte die Shell neu.




### Paketmanager
#### Windows
Zig ist auf [Chocolatey](https://chocolatey.org/packages/zig) verfügbar.
```
choco install zig
```

#### macOS

**Homebrew**  
Neuestes Release:
```
brew install zig
```

**MacPorts**
```
port install zig
```
#### Linux
Zig ist in vielen Paketmanagern für Linux verfügbar. [Hier](https://github.com/ziglang/zig/wiki/Install-Zig-from-a-Package-Manager)
ist eine aktuelle Liste; beachte aber, dass einige Pakete möglicherweise veraltete Versionen von Zig enthalten.

### Zig selbst kompilieren
[Hier](https://github.com/ziglang/zig/wiki/Building-Zig-From-Source) 
findest du weitere Informationen darüber, wie man Zig für Linux, macOS und Windows selbst kompiliert.

## Empfohlene Tools
### Syntaxhighlighter und LSP
Alle größeren Texteditoren unterstützen Syntaxhighlighting für Zig. 
Einige bringen dies mit, für andere muss ein Plugin installiert werden.  

Wenn du Zig besser mit deinem Editor integrieren möchtest, schau dir [zigtools/zls](https://github.com/zigtools/zls) und den Abschnitt [Tools](../tools/) an.

## Hello World ausführen
Wenn du die Installation erfolgreich abgeschlossen hast, solltest du Zig aus der Shell ausführen können.

Probieren wir das mit deinem ersten Zig-Programm aus!

Wechsle in dein Projektverzeichnis und führe aus:
```bash
mkdir hello-world
cd hello-world
zig init-exe
```

Das sollte Folgendes ausgeben:
```
info: Created build.zig
info: Created src/main.zig
info: Next, try `zig build --help` or `zig build run`
```

Der Befehl `zig build run` sollte dann das Programm kompilieren und ausführen, was dann
```
info: All your codebase are belong to us.
```
ausgibt. Glückwunsch, du hast jetzt eine funktionierende Installation von Zig!

## Nächste Schritte
**Sieh dir auch auch die anderen Ressourcen im Abschnitt [Lernen](../) an**, suche dir die Dokumentation für deine Version (Hinweis: Nightly Builds sollten die `master`-Dokumentation benutzen) und lies vielleicht [ziglearn.org](https://ziglearn.org).

Zig ist ein junges Projekt, und wir haben leider nicht die Kapazitäten, umfangreiche Dokumentation und Lernmaterialien zu erzeugen. Wenn du feststeckst, kannst du aber auch [einer Zig-Community beitreten](https://github.com/ziglang/zig/wiki/Community), oder Initiativen wie [Zig SHOWTIME](https://zig.show) ansehen.

Wenn dir Zig gefällt und du helfen willst, die Entwicklung voranzutreiben, kannst du [der Zig Software Foundation spenden](../../zsf).
<img src="/heart.svg" style="vertical-align:middle; margin-right: 5px">.
