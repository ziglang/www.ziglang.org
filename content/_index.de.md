---
title: Home
mobile_menu_title: "Home"
---
{{< slogan get_started="EINFÜHRUNG" docs="Dokumentation" notes="Änderungen" lang="de">}}
Zig ist eine General-Purpose-Programmiersprache und Toolchain für **robuste**, **optimale** und **wiederverwendbare** Software.  
{{< /slogan >}}

{{< flexrow class="container" style="padding: 20px 0; justify-content: space-between;" >}}
{{% div class="features" %}}

# ⚡ Eine einfache Sprache
Debugge deine Anwendung, nicht deine Kenntnis der Sprache.

- Kein versteckter Kontrollfluss.
- Keine versteckten Speicherallokationen.
- Kein Präprozessor, keine Makros. 

# ⚡ Comptime
Eine moderner Ansatz zur Metaprogrammierung -- basierend auf Compile-Zeit-Ausführung und Lazy Evaluation.

- Rufe jede Funktion zur Compile-Zeit auf.
- Manipuliere Typen als Werte, ohne Laufzeit-Overhead.
- Comptime emuliert die Zielarchitektur.

# ⚡ Performance trifft Sicherheit
Schreibe schnellen und klaren Code, der mit allen Fehlerbedingungen umgehen kann.

- Die Sprache hilft dir dabei, korrekte Fehlerbehandlungen zu schreiben.
- Konfigurierbare Laufzeitüberprüfungen helfen, einen guten Kompromiss zwischen Performance und Sicherheitsgarantien zu finden.
- Nutze Vektortypen, um SIMD-Anweisungen plattformunabhängig auszudrücken.

{{% flexrow style="justify-content:center;" %}}
{{% div %}}
<h1>
    <a href="learn/overview/" class="button" style="display: inline;">Ausführliche Übersicht</a>
</h1>
{{% /div %}}
{{% div  style="margin-left: 5px;" %}}
<h1>
    <a href="learn/samples/" class="button" style="display: inline;">Mehr Codebeispiele</a>
</h1>
{{% /div %}}
{{% /flexrow %}}
{{% /div %}}
{{< div class="codesample" >}}

{{% zigdoctest "assets/zig-code/index.zig" %}}

{{< /div >}}
{{< /flexrow >}}


{{% div class="alt-background" %}}
{{% div class="container"  style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="Community" %}}

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div style="width:25%" %}}
<img src="https://raw.githubusercontent.com/ziglang/logo/master/ziggy.svg" style="max-height: 200px">
{{% /div %}}

{{% div class="community-message" %}}
# Die Zig-Community ist dezentralisiert
Jeder darf einen Raum für die Community schaffen.
Es gibt kein "offiziell" oder "inoffiziell", aber jeder Versammlungsort hat seine eigenen Regeln und Moderatoren.

<div style="">
<h1>
	<a href="https://github.com/ziglang/zig/wiki/Community" class="button" style="display: inline;">Alle Communities ansehen</a>
</h1>
</div>
{{% /div %}}
{{< /flexrow >}}
<div style="height: 50px;"></div>

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div class="main-development-message" %}}
# Entwicklung
Das Zig-Repository ist unter [https://github.com/ziglang/zig](https://github.com/ziglang/zig) zu finden, wo wir auch den Issue-Tracker betreiben und Vorschläge diskutieren.  
Mitwirkende müssen sich an Zigs [Code of Conduct](https://github.com/ziglang/zig/blob/master/.github/CODE_OF_CONDUCT.md) halten.
{{% /div %}}
{{% div style="width:40%" %}}
<img src="https://raw.githubusercontent.com/ziglang/logo/master/zero.svg" style="max-height: 200px">
{{% /div %}}
{{< /flexrow >}}
{{% /div %}}
{{% /div %}}


{{% div class="container" style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="Zig Software Foundation" %}}
## Die ZSF ist eine 501(c)(3) Non-Profit-Organisation.

Die Zig Software Foundation ist eine Non-Profit-Organisation, die 2020 von Andrew Kelley, dem Schöpfer von Zig, gegründet wurde, um die Entwicklung der Sprache zu unterstützen. Momentan bietet die ZSF einigen Kernmitwirkenden konkurrenzfähig bezahlte Arbeit. Wir hoffen, dies künftig weiteren Mitwirkenden anbieten zu können.

Die Zig Software Foundation wird von Spenden erhalten.

<h1>
	<a href="zsf/" class="button" style="display:inline;">Mehr erfahren</a>
</h1>
{{% /div %}}


{{< div class="alt-background" style="padding: 20px 0;">}}
{{% div class="container" title="Sponsoren" %}}
# Unternehmenssponsoren
Die folgenden Unternehmen bieten der Zig Software Foundation direkte finanzielle Unterstützung.

{{% sponsor-logos "monetary" %}}
 <a href="https://pex.com" rel="noopener nofollow" target="_blank"><picture>
   <picture>
     <source srcset="/pex-white.svg" media="(prefers-color-scheme: dark)">
     <img src="/pex-dark.svg">
   </picture>
 </a>
{{% /sponsor-logos %}}

# GitHub-Sponsoren
Dank vieler Unterstützer ist das Projekt der Open-Source-Community und nicht Aktionären Rechenschaft schuldig. Insbesondere [unterstützen](zsf/) diese guten Leute Zig mit monatlich $200 oder mehr:

{{< ghsponsors >}}

Dieser Abschnitt wird zu Beginn jedes Monats aktualisiert.
{{% /div %}}
{{< /div >}}























