---
title: "Exemples de code"
mobile_menu_title: "Exemples de code"
toc: true
---

## Détection de fuites de mémoire
En utilisant `std.heap.GeneralPurposeAllocator` vous pouvez trouver les libérations multiples de mémoire et les fuites.

{{< zigdoctest "assets/zig-code/samples/1-memory-leak.zig" >}}


## interopérabilité avec le C
Un exemple d'import d'en-tête C et de compilation avec à la fois la libc et la raylib.

{{< zigdoctest "assets/zig-code/samples/2-c-interop.zig" >}}


## Zigg Zagg
Zig est *optimisé* pour les entretiens d'embauche demandant de comprendre du code (bon… peut-être pas vraiment).

{{< zigdoctest "assets/zig-code/samples/3-ziggzagg.zig" >}}


## Types génériques
Les types de Zig sont des valeurs à la compilation.
Nous pouvons donc utiliser des fonctions qui retournent un type pour implémenter des algorithmes génériques et des structures de données.
Dans l'exemple suivant nous implémentons une file générique et testons son comportement.

{{< zigdoctest "assets/zig-code/samples/4-generic-type.zig" >}}

## Utiliser cURL depuis Zig

{{< zigdoctest "assets/zig-code/samples/5-curl.zig" >}}
