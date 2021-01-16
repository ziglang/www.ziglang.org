---
title: Home
mobile_menu_title: "Home"
---
{{< slogan get_started="INIZIA QUI" docs="Documentazione" notes="Note">}}
Zig e' un linguaggio di programmazione general-purpose e toolchain per
mantenere software **robusto**, **ottimale**, e **riusabile**.
{{< /slogan >}}

{{< flexrow class="container" style="padding: 20px 0; justify-content: space-between;">}}
{{% div class="features" %}}

# ⚡ Un Linguaggio Semplice
Concentrati nel debuggare la tua applicazione, invece di debuggare la tua conoscenza del linguaggio di programmazione.

- Nessun controllo di flusso implicito.
- Niente allocazioni dinamiche implicite.
- Nessun preprocessore, niente macro. 

# ⚡ Comptime
Un nuovo approccio alla metaprogrammazione basato sull'esecuzione di codice durante la compilazione e valutazione pigra del codice.

- Chiama qualunque funzione mentre compili.
- Manipola tipi come valori senza nessuno spreco a runtime.
- Comptime emula l'archittetura per cui stai compilando.

# ⚡ Sicurezza ed Alte Prestazioni
Scrivi codice efficiente, chiaro e in grado di gestire ogni errore.

- Il linguaggio guida elegantemente la tua logica di gestione degli errori.
- Controlli a runtime configurabili ti permettono di trovare un equilibrio tra prestazioni e garanzie di sicurezza.
- Usa i tipi vettore per esprimere istruzioni SIMD in modo portabile.

{{% flexrow style="justify-content:center;" %}}
{{% div %}}
<h1>
    <a href="{{< ref path="learn/overview.en.md" lang="en">}}" class="button" style="display: inline;">Overview dettagliata</a>
</h1>
{{% /div %}}
{{% div  style="margin-left: 5px;" %}}
<h1>
    <a href="{{< ref path="learn/samples.en.md" lang="en">}}" class="button" style="display: inline;">Altri esempi di codice</a>
</h1>
{{% /div %}}
{{% /flexrow %}}
{{% /div %}}
{{< div class="codesample" >}}

{{% zigdoctest "assets/zig-code/index.zig" %}}

{{< /div >}}
{{< /flexrow >}}

{{% div class="alt-background" %}}
{{% div class="container"  style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="Comunità" %}}

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div style="width:25%" %}}
<img src="https://raw.githubusercontent.com/ziglang/logo/master/ziggy.svg" style="max-height: 200px">
{{% /div %}}

{{% div class="community-message" %}}
# La comunità Zig è decentralizzata
Chiunque è libero di avviare e mantenere un proprio spazio per permettere alla comunità di interagire.
Non c'è nessuna distinzione tra spazi "ufficiali" e non, ma ogni posto ha le proprie regole e moderatori.

<div style="">
<h1>
	<a href="https://github.com/ziglang/zig/wiki/Community" class="button" style="display: inline;">Esplora le comunità</a>
</h1>
</div>
{{% /div %}}
{{< /flexrow >}}
<div style="height: 50px;"></div>

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div class="main-development-message" %}}
# Sviluppo del progetto
Il repository di Zig può essere trovato a [https://github.com/ziglang/zig](https://github.com/ziglang/zig), dove manteniamo anche l'issue tracker e discutiamo le proposte di miglioramento.  
I contributori sono tenuti a rispettare il [codice di comportamento](https://github.com/ziglang/zig/blob/master/CODE_OF_CONDUCT.md) di Zig.
{{% /div %}}
{{% div style="width:40%" %}}
<img src="https://raw.githubusercontent.com/ziglang/logo/master/zero.svg" style="max-height: 200px">
{{% /div %}}
{{< /flexrow >}}
{{% /div %}}
{{% /div %}}


{{% div class="container" style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="Zig Software Foundation" %}}
## La ZSF e' una corporazione non-profit.

La Zig Software Foundation e' una corporazione non-profit fondata nel 2020 da Andrew Kelley, il creatore di Zig, con l'obbiettivo di supportare lo sviluppo del linguaggio. Al momento la fondazione è in grado di offire pagamento a rate competitivi ad un piccolo numero di contributori. Speriamo di poter estendere questa offerta a più contibutori nel prossimo futuro.

La Zig Software Foundation si sostiene tramite donazioni.

<h1>
	<a href="zsf/" class="button" style="display:inline;">Ulteriori dettagli</a>
</h1>
{{% /div %}}


{{< div class="alt-background" style="padding: 20px 0;">}}
{{% div class="container" title="Sponsors" %}}
# Aziende Sponsor
Le seguenti compagnie offrono diretto supporto finanziario alla Zig Software Foundation.

{{% sponsor-logos "monetary" %}}
 <a href="https://pex.com" rel="noopener nofollow" target="_blank"><picture>
   <picture>
     <source srcset="/pex-white.svg" media="(prefers-color-scheme: dark)">
     <img src="/pex-dark.svg">
   </picture>
 </a>
{{% /sponsor-logos %}}
# GitHub Sponsors

Grazie a tutte le persone che [supportano Zig](zsf/), il progetto fa riferimento all propria comunità open source, invece che ad uno stuolo di shareholder. In particolare, i seguenti illustri individui supportano Zig per un quantitativo di 200 USD/mese o superiore:

- [Karrick McDermott](https://github.com/karrick)
- [Raph Levien](https://raphlinus.github.io/)
- [ryanworl](https://github.com/ryanworl)
- [Stevie Hryciw](https://www.hryx.net/)
- [Josh Wolfe](https://github.com/thejoshwolfe)
- [SkunkWerks, GmbH](https://skunkwerks.at/)
- [drfuchs](https://github.com/drfuchs)
- Eleanor Bartle

Questa sezione e' aggiornata all'inizio di ogni mese.
{{% /div %}}
{{< /div >}}
























