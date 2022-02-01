---
title: Accueil
mobile_menu_title: "Accueil"
---
{{< slogan get_started="DÉBUTER" docs="Documentation" notes="Historique" lang="fr" >}}
Zig est un langage de programmation généraliste ainsi qu'une toolchain ayant pour objectifs la **robustesse**, l'**optimisation** et la **réutilisation du code**.
{{< /slogan >}}

{{< flexrow class="container" style="padding: 20px 0; justify-content: space-between;" >}}
{{% div class="features" %}}

# ⚡ Un langage simple
Concentrez-vous sur le debug de votre application et non sur le debug de votre connaissance du langage.

- Pas de flots de contrôle cachés.
- Pas d'allocations mémoire cachées.
- Pas de préprocesseur ni de macros.

# ⚡ Comptime
Une nouvelle approche de la métaprogrammation basée sur une exécution à la compilation et une évaluation paresseuse.

- Appelez n'importe quelle fonction à la compilation.
- Manipulez les types comme des valeurs sans coût à l'exécution.
- Comptime émule l'architecture cible.

# ⚡ Compiler avec Zig
Améliorer progressivement votre code source C/C++/Zig.

- Remplacez votre compilateur C/C++ par Zig, il est sans dépendance et gère la compilation croisées "out-of-the-box".
- Profitez de `zig build` pour créer un environnement de développement égal et constant sur toutes plateformes.
- Ajoutez une partie Zig à vos projets C/C++, le LTO multi-langage est activé par défaut.

{{% flexrow style="justify-content:center;" %}}
{{% div %}}
<h1>
    <a href="learn/overview/" class="button" style="display: inline;">Vue d'ensemble</a>
</h1>
{{% /div %}}
{{% div  style="margin-left: 5px;" %}}
<h1>
    <a href="learn/samples/" class="button" style="display: inline;">Exemples de code</a>
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
<img src="/ziggy.svg" style="max-height: 200px">
{{% /div %}}

{{% div class="community-message" %}}
# La communauté Zig est décentralisée
Tout le monde est libre de créer et de maintenir son propre espace d'échange et de communication pour la communauté.
Il n'y a pas de canal « officiel », en revanche, chaque espace a ses propres modérateurs et ses propres règles.

<div style="">
<h1>
	<a href="https://github.com/ziglang/zig/wiki/Community" class="button" style="display: inline;">Voir toutes les communautés</a>
</h1>
</div>
{{% /div %}}
{{< /flexrow >}}
<div style="height: 50px;"></div>

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div class="main-development-message" %}}
# Développement principal
Le dépôt Zig se trouve ici [https://github.com/ziglang/zig](https://github.com/ziglang/zig).
Nous y listons les problèmes rencontrés et discutons des propositions.
Les contributeurs doivent suivre le [code de conduite de Zig](https://github.com/ziglang/zig/blob/master/CODE_OF_CONDUCT.md)
{{% /div %}}
{{% div style="width:40%" %}}
<img src="/zero.svg" style="max-height: 200px">
{{% /div %}}
{{< /flexrow >}}
{{% /div %}}
{{% /div %}}


{{% div class="container" style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="Zig Software Foundation" %}}
## La ZSF est une organisation à but non lucratif 501(c)(3).

La fondation Zig (*Zig Software Foundation*) est une organisation à but non lucratif fondée en 2020 par Andrew Kelley, le créateur de Zig, avec pour objectif de prendre en charge le développement du langage.
La ZSF est actuellement en capacité d'offrir du travail rémunéré à un taux compétitif à un petit nombre de contributeurs.
Nous espérons à l'avenir pouvoir étendre cette offre à d'autres développeurs.

La fondation Zig est soutenue par des dons.

<h1>
	<a href="zsf/" class="button" style="display:inline;">En apprendre plus</a>
</h1>
{{% /div %}}


{{< div class="alt-background" style="padding: 20px 0;">}}
{{% div class="container" title="Sponsors" %}}
# Entreprises sponsors 
Les entreprises suivantes fournissent un support financier direct à la fondation Zig (ZSF).

{{% sponsor-logos "monetary" %}}
 <a href="https://pex.com" rel="noopener nofollow" target="_blank"><picture>
   <picture>
     <source srcset="/pex-white.svg" media="(prefers-color-scheme: dark)">
     <img src="/pex-dark.svg">
   </picture>
 </a>
{{% /sponsor-logos %}}

# Parrainages GitHub
Merci aux personnes qui [parrainent Zig](zsf/), le projet est davantage redevable à la communauté open source qu'aux entreprises.
En particulier, ces personnes formidables sponsorisent Zig à hauteur de 200 $/mois ou plus :

{{< ghsponsors >}}

Cette section est mise à jour au début de chaque mois.
{{% /div %}}
{{< /div >}}
