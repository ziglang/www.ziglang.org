---
title: "Vue d'ensemble du projet Zig"
mobile_menu_title: "Vue d'ensemble"
toc: true
---
# Fonctionnalités
## Un langage simple

L'effort doit se faire sur la correction de votre application plutôt que sur la connaissance du langage.

La syntaxe de Zig est entièrement spécifiée dans [500 lignes de grammaire PEG (EN)](https://ziglang.org/documentation/master/#Grammar).

Rien n'est caché : ni **flots de contrôle**, ni allocations de mémoire.
Zig n'a pas de préprocesseur ni de macros.
Si un code en Zig ne semble pas faire appel à une fonction, c'est qu'il ne le fait pas.
Vous pouvez donc être sûr que le code suivant ne fait appel qu'à `foo()` puis `bar()`, sans même connaître les types impliqués :

```zig
var a = b + c.d;
foo();
bar();
```

Exemples de flots de contrôle cachés :

- D a des fonctions `@property`, des méthodes qui ressemblent à de simples accès à des champs d'une structure, `c.d` peut être un appel à une fonction.
- C++, D, et Rust ont de la surcharge d'opérateurs, donc l'opérateur `+` peut appeler une fonction.
- C++, D, et Go ont des exceptions *throw/catch*, donc `foo()` peut lancer une exception, et empêcher `bar()` d'être appelé.

Zig promeut la maintenance et la lisibilité du code : tout flot de contrôle est géré exclusivement avec des mots clés du langage et des appels de fonction.

## Performance ET sécurité

Zig a quatre [modes de compilation (EN)](https://ziglang.org/documentation/master/#Build-Mode), et ils peuvent être combinés jusqu'à une granularité aussi fine que le [bloc de code (EN)](https://ziglang.org/documentation/master/#setRuntimeSafety).

| Mode de compilation | [Debug](/documentation/master/#Debug) | [ReleaseSafe](/documentation/master/#ReleaseSafe) | [ReleaseFast](/documentation/master/#ReleaseFast) | [ReleaseSmall](/documentation/master/#ReleaseSmall) |
|-----------|-------|-------------|-------------|--------------|
Optimisations : + vitesse d'exécution, - détection d'erreurs, - durée de compilation | | -O3 | -O3| -Os |
Vérifications à l'exécution : - vitesse d'exécution, - taille, + plantage si comportement indéfini | On | On | | |

(Note : **'+'** indique un avantage, **'-'** indique un inconvénient.)

Voici ce à quoi ressemble un [dépassement d'entier (EN)](https://ziglang.org/documentation/master/#Integer-Overflow) à la compilation, peu importe le mode de compilation :

{{< zigdoctest "assets/zig-code/features/1-integer-overflow.zig" >}}

Voici ce à quoi ressemble l'exécution avec une compilation avec des vérifications de sécurité :

{{< zigdoctest "assets/zig-code/features/2-integer-overflow-runtime.zig" >}}

Ces [traces d'appels fonctionnent sur toutes les cibles](#traces-de-pile-dexécution-sur-toutes-les-cibles), et également en [« freestanding » (binaire autonome, sans système d'exploitation) (EN)](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html).

Zig permet de compiler son programme avec des vérifications à l'exécution, tout en les désactivant seulement où les performances sont trop impactées.
L'exemple précédent pourrait être modifié comme cela :

{{< zigdoctest "assets/zig-code/features/3-undefined-behavior.zig" >}}

Zig détecte les [comportements indéfinis (EN)](https://ziglang.org/documentation/master/#Undefined-Behavior) à la compilation pour la prévention d'erreurs et l'amélioration des performances.

En parlant de performances, Zig est plus rapide que le C.

- L'implémentation de référence utilise LLVM comme backend pour avoir l'état de l'art des optimisations.
- Ce que les autres projets appellent « Link Time Optimization », Zig l'a automatiquement.
- Pour les cibles natives, les fonctionnalités CPU avancées sont activées (-march=native) grâce à la [prise en charge de premier plan de la cross-compilation](#la-cross-compilation-est-un-usage-de-première-importance).
- Les comportements indéfinis sont soigneusement choisis.
Par exemple, en Zig les entiers signés et non signés ont un comportement indéfini lors d'un dépassement mémoire, contrairement à C où seul le dépassement d'entiers signés est indéfini.
Cela [facilite les optimisations qui ne sont pas disponibles en C](https://godbolt.org/z/n_nLEU).
- Zig expose directement le [type « vecteur SIMD »](https://ziglang.org/documentation/master/#Vectors), permettant d'écrire facilement du code vectorisé portable.

Important à noter, Zig n'est pas à considérer comme un langage *sécurisé*.
Pour ceux qui sont intéressés par suivre les histoires de sécurité dans Zig, abonnez-vous à ces fils de discussion :

- [Énumérer tous les types de comportements indéfinis, même ceux qui ne peuvent être vérifiés (EN)](https://github.com/ziglang/zig/issues/1966)
- [Rendre les modes de compilation *Debug* et *ReleaseSafe* entièrement sécurisés (EN)](https://github.com/ziglang/zig/issues/2301)

## Zig est en compétition avec le C, il n'en dépend pas

La bibliothèque standard de Zig intègre la libc, mais n'en dépend pas.
Voici un Hello World :

{{< zigdoctest "assets/zig-code/features/4-hello.zig" >}}

Quand ce code est compilé avec `-O ReleaseSmall`, les symboles de debug retirés, sur un seul fil d'exécution, cela produit un binaire statique de 9.8 KiB pour la cible x86_64 :
```
$ zig build-exe hello.zig --release-small --strip --single-threaded
$ wc -c hello
9944 hello
$ ldd hello
  not a dynamic executable
```

Le binaire produit pour Windows est encore plus petit, seulement 4096 octets :
```
$ zig build-exe hello.zig --release-small --strip --single-threaded -target x86_64-windows
$ wc -c hello.exe
4096 hello.exe
$ file hello.exe
hello.exe: PE32+ executable (console) x86-64, for MS Windows
```

## Déclarations de premier niveau indépendantes de l'ordre

Les déclarations de premier niveau, comme les variables globales, sont indépendantes de l'ordre dans lequel elles sont écrites et leur analyse est paresseuse.
Les valeurs d'initialisation des variables globales sont [évaluées à la compilation](#réflexivité-et-exécution-de-code-à-la-compilation).

{{< zigdoctest "assets/zig-code/features/5-global-variables.zig" >}}

## Type optionnel plutôt que des pointeurs null

Dans d'autres langages de programmation, les références *null* sont sources d'erreurs à l'exécution, et sont même soupçonnées être [la pire erreur en informatique (EN)](https://www.lucidchart.com/techblog/2015/08/31/the-worst-mistake-of-computer-science/).

Les pointeurs en Zig ne peuvent pas être null :

{{< zigdoctest "assets/zig-code/features/6-null-to-ptr.zig" >}}

Cependant, tout type peut devenir un [type optionnel (EN)](https://ziglang.org/documentation/master/#Optionals) en le préfixant par `?:`

{{< zigdoctest "assets/zig-code/features/7-optional-syntax.zig" >}}

Pour récupérer la valeur d'un type optionnel, nous devons utiliser `orelse` pour fournir une valeur par défaut :

{{< zigdoctest "assets/zig-code/features/8-optional-orelse.zig" >}}

Une autre option est d'utiliser un `if` :

{{< zigdoctest "assets/zig-code/features/9-optional-if.zig" >}}

Cette syntaxe fonctionne également avec [while (EN)](https://ziglang.org/documentation/master/#while):

{{< zigdoctest "assets/zig-code/features/10-optional-while.zig" >}}

## Gestion manuelle de la mémoire

Une bibliothèque écrite en Zig peut être utilisée n'importe où :

- [Applications de bureau](https://github.com/TM35-Metronome/) & [jeux](https://github.com/dbandstra/oxid)
- Serveur basse latence
- [Noyaux de systèmes d'exploitation](https://github.com/AndreaOrru/zen)
- [Embarqué](https://github.com/skyfex/zig-nrf-demo/)
- Logiciels temps-réel, comme des performances en direct, dans des avions, des pacemakers
- [Dans des navigateurs web ou des modules WebAssembly](https://shritesh.github.io/zigfmt-web/)
- Par d'autres langages de programmation, utilisant l'ABI de C

Pour accomplir tout cela, les développeurs de Zig doivent gérer la mémoire et les erreurs d'allocation.

Cela est vrai également pour la bibliothèque standard de Zig.
Chaque fonction nécessitant d'allouer de la mémoire accepte un *allocateur* en paramètre.
Par conséquent, la bibliothèque standard de Zig peut être utilisée même pour un binaire « freestanding » (application autonome, sans système d'exploitation).

En plus d'apporter un [point de vue nouveau sur la gestion d'erreurs](#une-nouvelle-manière-de-gérer-les-erreurs), Zig fournit [defer (EN)](https://ziglang.org/documentation/master/#defer) et [errdefer (EN)](https://ziglang.org/documentation/master/#errdefer) pour rendre la gestion de *toutes les ressources* plus simple et facilement vérifiable (pas seulement la mémoire).

Pour un exemple de `defer`, voir [l'intégration des bibliothèques C sans FFI/bindings](#intégration-avec-les-bibliothèques-c-sans-ffibindings).
Voici un exemple de code utilisant `errdefer` :

{{< zigdoctest "assets/zig-code/features/11-errdefer.zig" >}}


## Une nouvelle manière de gérer les erreurs

Les erreurs sont des valeurs, et ne peuvent pas être ignorées :

{{< zigdoctest "assets/zig-code/features/12-errors-as-values.zig" >}}

Les erreurs peuvent être gérées avec [catch (EN)](https://ziglang.org/documentation/master/#catch):

{{< zigdoctest "assets/zig-code/features/13-errors-catch.zig" >}}

Le mot clé [try (EN)](https://ziglang.org/documentation/master/#try) est un raccourci pour `catch |err| return err`:

{{< zigdoctest "assets/zig-code/features/14-errors-try.zig" >}}

À noter que ceci est une [trace de retour d'erreur (EN)](https://ziglang.org/documentation/master/#Error-Return-Traces), pas une [trace d'une pile d'exécution](#traces-de-pile-dexécution-sur-toutes-les-cibles).
Le code n'a pas à payer le coût du déroulement d'une pile d'exécution pour arriver à cette trace.

Le mot clé [switch (EN)](https://ziglang.org/documentation/master/#switch) utilisé sur une erreur assure que toutes les erreurs possibles sont gérées :

{{< zigdoctest "assets/zig-code/features/15-errors-switch.zig" >}}

Le mot clé [unreachable (EN)](https://ziglang.org/documentation/master/#unreachable) est utilisé pour affirmer qu'aucune erreur ne peut survenir :

{{< zigdoctest "assets/zig-code/features/16-unreachable.zig" >}}

Cela implique un [comportement indéfini](#performance-et-sécurité) dans les modes de compilation non sûrs, donc assurez-vous de l'utiliser uniquement quand le succès est garanti.

### Traces de pile d'exécution sur toutes les cibles

Les traces de piles d'exécution et les [traces de retour d'erreurs (EN)](https://ziglang.org/documentation/master/#Error-Return-Traces) montrées sur cette page fonctionnent sur toutes les cibles ayant une [prise en charge de niveau 1](#prise-en-charge-niveau-1) et certaines cibles de [niveau 2](#prise-en-charge-niveau-2).
Y compris [freestanding (EN)](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html) !

De plus, la bibliothèque standard a la possibilité de capturer une trace d'exécution et de l'afficher plus tard :

{{< zigdoctest "assets/zig-code/features/17-stack-traces.zig" >}}

Vous pouvez voir cette technique utilisée dans le projet actuel d'[allocateur générique (EN)](https://github.com/andrewrk/zig-general-purpose-allocator/#current-status).

## Structures de données et fonctions génériques

Les types sont des valeurs qui doivent être connues à la compilation :

{{< zigdoctest "assets/zig-code/features/18-types.zig" >}}

Une structure de données générique est simplement une fonction qui retourne un `type` :

{{< zigdoctest "assets/zig-code/features/19-generics.zig" >}}

## Réflexivité et exécution de code à la compilation

La fonction intégrée [@typeInfo (EN)](https://ziglang.org/documentation/master/#typeInfo) fournit de la réflexivité :

{{< zigdoctest "assets/zig-code/features/20-reflection.zig" >}}

La bibliothèque standard de Zig utilise cette technique pour implémenter l'affichage formaté.
Malgré la volonté de faire de Zig un langage [simple](#un-langage-simple), l'affichage formaté est entièrement implémentée en Zig.
Pendant ce temps, en C, les erreurs de printf à la compilation sont codées en dur dans le compilateur.
De façon similaire, en Rust, les macros de formatage sont codées en dur dans le compilateur.

Zig peut également évaluer les fonctions et les blocs de code à la compilation.
Dans certains contextes, comme l'initialisation des variables globales, l'expression est implicitement évaluée à la compilation.
Autrement, il est également possible d'évaluer explicitement le code à la compilation en utilisant le mot clé [comptime (EN)](https://ziglang.org/documentation/master/#comptime).
Cela est particulièrement utile une fois combiné avec des assertions :

{{< zigdoctest "assets/zig-code/features/21-comptime.zig" >}}

## Intégration avec les bibliothèques C sans FFI/bindings

[@cImport (EN)](https://ziglang.org/documentation/master/#cImport) importe directement les types, variables, fonctions et les macros simples en Zig.
Ce mot clé peut même traduire les fonctions *inline* du C à Zig.

Voici un exemple de diffusion d'une onde sinusoïdale via la bibliothèque [libsoundio](http://libsound.io/) :

<u>sine.zig</u>
{{< zigdoctest "assets/zig-code/features/22-sine-wave.zig" >}}

```
$ zig build-exe sine.zig -lsoundio -lc
$ ./sine
Output device: Built-in Audio Analog Stereo
^C
```

[Ce code Zig est bien plus simple que son équivalent en C](https://gist.github.com/andrewrk/d285c8f912169329e5e28c3d0a63c1d8) et est également plus sécurisé.
Tout ceci est accompli en important le fichier d'en-tête C - aucune API n'est utilisée.

*Zig est meilleur que le C à utiliser des bibliothèques… C.*

### Zig est également un compilateur C

Voici un exemple de code C compilé avec Zig :

<u>hello.c</u>
```c
#include <stdio.h>

int main(int argc, char **argv) {
    printf("Hello world\n");
    return 0;
}
```

```
$ zig build-exe --c-source hello.c --library c
$ ./hello
Hello world
```

Nous pouvons utiliser `--verbose-cc` pour voir la commande de compilation :
```
$ zig build-exe --c-source hello.c --library c --verbose-cc
zig cc -MD -MV -MF zig-cache/tmp/42zL6fBH8fSo-hello.o.d -nostdinc -fno-spell-checking -isystem /home/andy/dev/zig/build/lib/zig/include -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-gnu -isystem /home/andy/dev/zig/build/lib/zig/libc/include/generic-glibc -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-any -isystem /home/andy/dev/zig/build/lib/zig/libc/include/any-linux-any -march=native -g -fstack-protector-strong --param ssp-buffer-size=4 -fno-omit-frame-pointer -o zig-cache/tmp/42zL6fBH8fSo-hello.o -c hello.c -fPIC
```

À noter que si nous relançons la commande à nouveau, rien n'est affiché et la commande se termine instantanément :
```
$ time zig build-exe --c-source hello.c --library c --verbose-cc

real	0m0.027s
user	0m0.018s
sys	0m0.009s
```

Ceci est rendu possible grâce au [cache de compilation (EN)](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching).
Zig analyse les fichiers `.d` (générés grâce à Clang) et utilise un système de cache robuste pour recompiler seulement le nécessaire.

Zig peut compiler du code C, mais il y a une vraie bonne raison de l'utiliser comme tel : [Zig est livré avec la libc](#zig-fournit-la-libc).

### Export de fonctions, variables, et de types pour du code C

Un des usages de Zig est d'exporter une bibliothèque avec l'ABI C pour d'autres langages de programmation.
Le mot clé `export` devant des fonctions, des variables ou des types les intègre à l'API de la bibliothèque :

<u>mathtest.zig</u>
{{< zigdoctest "assets/zig-code/features/23-math-test.zig" >}}

Pour créer une bibliothèque statique :
```
$ zig build-lib mathtest.zig
```

Pour créer une bibliothèque partagée :
```
$ zig build-lib mathtest.zig -dynamic
```

Voici un exemple avec le [système de construction de Zig](#système-de-construction-de-zig) :

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

## La cross-compilation est un usage de première importance

Zig peut compiler pour n'importe quelle cible du [tableau prise en charge](#prise-en-charge-des-systèmes) avec un [niveau 3](#prise-en-charge-niveau-3) ou mieux.
Pas besoin d'installer une chaîne de compilation.
Voici un simple Hello World :

{{< zigdoctest "assets/zig-code/features/4-hello.zig" >}}

Maintenant voici comment le compiler pour `x86_64-windows`, `x86_64-macosx`, et `aarch64v8-linux` :
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

Cela fonctionne sur toutes les cibles de [niveau 3](#prise-en-charge-niveau-3) ou plus, pour n'importe quelle cible de [niveau 3](#prise-en-charge-niveau-3) ou plus.

### Zig fournit la libc

Vous pouvez trouver les cibles disponibles avec `zig targets` :
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

Cela signifie que `--library c` pour ces cibles *ne dépend d'aucun fichier du système* !

Revoyons l'[exemple de Hello World en C](#zig-est-également-un-compilateur-c) :
```
$ zig build-exe --c-source hello.c --library c
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

[glibc (EN)](https://www.gnu.org/software/libc/) ne prend pas en charge la compilation statique, mais [musl (EN)](https://www.musl-libc.org/) oui :
```
$ zig build-exe --c-source hello.c --library c -target x86_64-linux-musl
$ ./hello
Hello world
$ ldd hello
  not a dynamic executable
```

Dans cet exemple, Zig compile la libc musl depuis les sources puis l'utilise pour notre application.
Les fichiers de construction de cette bibliothèque restent disponibles pour de futures compilations (elle n'aura pas à être recompilée) grâce au [système de cache (EN)](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching).

Cette fonctionnalité est disponible pour toutes les plateformes.
Les utilisateurs de Windows et macOS peuvent compiler du code C et Zig, les lier à la libc, pour toutes les cibles listées au-dessus.
De même, le code peut être compilé pour d'autres architectures :
```
$ zig build-exe --c-source hello.c --library c -target aarch64v8-linux-gnu
$ file hello
hello: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, for GNU/Linux 2.0.0, with debug_info, not stripped
```

D'une certaine façon, Zig est un meilleur compilateur C que les compilateurs C !

Cette fonctionnalité est plus qu'un outil pour créer une chaîne de compilation croisée.
Par exemple, la taille totale des en-têtes de libc que Zig fournit est de 22 MiB sans compression.
Pendant ce temps, seulement les en-têtes pour musl et linux pour `x86_64` font déjà 8 MiB, et glibc fait déjà 3.1 MiB à lui seul (sans les en-têtes de linux).
Pourtant, Zig est actuellement fourni avec 40 libc.
Avec un paquetage naïf cela voudrait dire 444 MiB.
Cependant, grâce à un [outil de gestion d'en-têtes (EN)](https://github.com/ziglang/zig/blob/0.4.0/libc/process_headers.zig), et à un [travail manuel minutieux (EN)](https://github.com/ziglang/zig/wiki/Updating-libc), les archives de Zig restent autour de 30 MiB, malgré le support de toutes ces cibles, en plus des bibliothèques `compiler-rt`, `libunwind` et `libcxx`, et malgré le fait d'être un compilateur C compatible Clang.
En comparaison, clang 8.0.0 seul pour Windows pèse 132 MiB.

À noter que seules les cibles [de niveau 1](#prise-en-charge-niveau-1) ont été testées en détail.
Il est prévu d'[ajouter d'autres libc (EN)](https://github.com/ziglang/zig/issues/514) (en incluant Windows), et d'ajouter des [tests de couverture pour compiler vers toutes les architectures (EN)](https://github.com/ziglang/zig/issues/2058).

Un [gestionnaire de paquets Zig (EN)](https://github.com/ziglang/zig/issues/943) est prévu, mais il n'est pas encore là.
Cela permettra de créer des paquets pour des bibliothèques C et rendra le [système de construction de Zig](#système-de-construction-de-zig) attractif à la fois pour les développeurs C et Zig.

## Système de construction de Zig

Zig est fourni avec un système de construction, *rendant inutile make, cmake et les autres*.
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


Regardons le menu `--help` :
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

Comme nous pouvons le voir, une des commandes disponibles est `run`.
```
$ zig build run
All your base are belong to us.
```

Voici quelques exemples de scripts de construction :

- [Script de construction d'un jeu Tetris OpenGL](https://github.com/andrewrk/tetris/blob/master/build.zig)
- [Script de construction d'un jeu d'arcade pour Raspberry Pi 3 (freestanding)](https://github.com/andrewrk/clashos/blob/master/build.zig)
- [Script de construction du compilateur Zig (indépendant de LLVM)](https://github.com/ziglang/zig/blob/master/build.zig)

## Concurrence avec les fonctions Async

Zig 0.5.0 [a introduit les fonctions async (EN)](https://ziglang.org/download/0.5.0/release-notes.html#Async-Functions).
Cette fonctionnalité n'a pas de dépendance au système d'exploitation hôte ou même à l'allocation de mémoire dans le tas.
Cela veut dire que les fonctions async sont disponibles pour la cible « freestanding » (sans système d'exploitation).

Zig déduit si une fonction est async, et permet `async`/`await` sur des fonctions non async.
Les **bibliothèques Zig sont donc les mêmes avec des appels bloquants ou des entrées et sorties asynchrones**.
[Zig évite la coloration des fonctions (EN)](http://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/).


La bibliothèque standard Zig implémente une boucle d'événements qui multiplexe les fonctions asynchrones dans un pool de fils d'exécution pour une concurrence de type M:N.
La sécurité de multiples fils d'exécution et la détection de *race condition* sont des domaines de recherche actifs.

## Une large variété de cibles est disponible

Zig a un système de « niveaux de prise en charge » pour communiquer autour des différentes cibles.
À noter que la barre est haute pour atteindre le [niveau 1](#prise-en-charge-niveau-1) - la prise en charge de [niveau 2](#prise-en-charge-niveau-2) est déjà intéressante.

### Prise en charge des systèmes

| | free standing | Linux 3.16+ | macOS 10.13+ | Windows 8.1+ | FreeBSD 12.0+ | NetBSD 8.0+ | DragonFly​BSD 5.8+ | UEFI |
|-|---------------|-------------|--------------|--------------|---------------|-------------|-------------------|------|
| x86_64 | [Niveau 1](#prise-en-charge-niveau-1) | [Niveau 1](#prise-en-charge-niveau-1) | [Niveau 1](#prise-en-charge-niveau-1) | [Niveau 2](#prise-en-charge-niveau-2) | [Niveau 2](#prise-en-charge-niveau-2) | [Niveau 2](#prise-en-charge-niveau-2) | [Niveau 2](#prise-en-charge-niveau-2) | [Niveau 2](#prise-en-charge-niveau-2) |
| arm64 | [Niveau 1](#prise-en-charge-niveau-1) | [Niveau 2](#prise-en-charge-niveau-2) | [Niveau 2](#prise-en-charge-niveau-2) | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | N/A | [Niveau 3](#prise-en-charge-niveau-3) |
| arm32 | [Niveau 1](#prise-en-charge-niveau-1) | [Niveau 2](#prise-en-charge-niveau-2) | N/A | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | N/A | [Niveau 3](#prise-en-charge-niveau-3) |
| mips32 LE | [Niveau 1](#prise-en-charge-niveau-1) | [Niveau 2](#prise-en-charge-niveau-2) | N/A | N/A | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | N/A | N/A |
| i386 | [Niveau 1](#prise-en-charge-niveau-1) | [Niveau 2](#prise-en-charge-niveau-2) | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 2](#prise-en-charge-niveau-2) | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | N/A | [Niveau 2](#prise-en-charge-niveau-2) |
| riscv64 | [Niveau 1](#prise-en-charge-niveau-1) | [Niveau 2](#prise-en-charge-niveau-2) | N/A | N/A | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | N/A | [Niveau 3](#prise-en-charge-niveau-3) |
| bpf | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | N/A | N/A | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | N/A | N/A |
| hexagon | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | N/A | N/A | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | N/A | N/A |
| mips32 BE | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | N/A | N/A | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | N/A | N/A |
| mips64 | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | N/A | N/A | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | N/A | N/A |
| amdgcn | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | N/A | N/A | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | N/A | N/A |
| sparc | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | N/A | N/A | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | N/A | N/A |
| s390x | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | N/A | N/A | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | N/A | N/A |
| lanai | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | N/A | N/A | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | N/A | N/A |
| powerpc32 | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | N/A | N/A |
| powerpc64 | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | [Niveau 3](#prise-en-charge-niveau-3) | [Niveau 3](#prise-en-charge-niveau-3) | N/A | N/A |
| avr | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A |
| riscv32 | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | [Niveau 4](#prise-en-charge-niveau-4) |
| xcore | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A |
| nvptx | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A |
| msp430 | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A |
| r600 | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A |
| arc | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A |
| tce | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A |
| le | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A |
| amdil | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A |
| hsail | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A |
| spir | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A |
| kalimba | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A |
| shave | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A |
| renderscript | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A | [Niveau 4](#prise-en-charge-niveau-4) | [Niveau 4](#prise-en-charge-niveau-4) | N/A | N/A |


### Prise en charge de WebAssembly

|        | free standing | emscripten | WASI   |
|--------|---------------|------------|--------|
| wasm32 | [Niveau 1](#prise-en-charge-niveau-1)        | [Niveau 3](#prise-en-charge-niveau-3)     | [Niveau 1](#prise-en-charge-niveau-1) |
| wasm64 | [Niveau 4](#prise-en-charge-niveau-4)        | [Niveau 4](#prise-en-charge-niveau-4)     | [Niveau 4](#prise-en-charge-niveau-4) |


### Niveaux de prise en charge

#### Prise en charge niveau 1
- Zig peut non seulement générer du code pour ces cibles, mais les abstractions de la bibliothèque standard ont des implémentations pour ces cibles.
- Le serveur d'intégration continue teste automatiquement ces cibles sur chaque commit de la branche master, et met à jour [la page de téléchargement](/fr/download) avec des liens vers des binaires pré-compilés.
- Ces cibles ont des informations de debug et par conséquent produisent des [traces de piles d'exécution](#traces-de-pile-d'exécution-sur-toutes-les-cibles) lors des assertions fausses.
- [La libc est disponible pour ces cibles même lors d'une cross-compilation](#zig-fournit-la-libc).
- Tous les tests de comportement et de la bibliothèque standard passent pour cette cible.
Toutes les fonctionnalités du langage fonctionnent correctement.

#### Prise en charge niveau 2
- La bibliothèque standard prend en charge cette cible, mais il est possible que certaines API ne soient pas complètes (erreur *Unsupported OS* à la compilation).
Il est cependant possible de lier l'application à une libc pour compléter ce qui manque dans la bibliothèque standard.
- Ces cibles sont connues pour fonctionner, mais ne sont pas entièrement automatisées, donc il faut s'attendre à des régressions occasionnelles.
- Certains tests peuvent être désactivés pour ces cibles en attendant une [prise en charge de niveau 1](#prise-en-charge-niveau-1).

#### Prise en charge niveau 3

- La bibliothèque standard a peu voir pas du tout connaissance de ces cibles.
- Comme Zig est fondé sur LLVM, il a la capacité de compiler pour ces cibles, disponibles par défaut grâce à LLVM.
- Ces cibles ne sont pas souvent testées ; il est probable de devoir contribuer à Zig pour arriver à un résultat satisfaisant.
- Le compilateur Zig peut avoir besoin d'être mis à jour pour connaître quelques informations sur la cible, comme :
  - la taille des entiers en C
  - la convention d'appel à l'ABI C
  - le code d'initialisation et la gestion d'erreurs par défaut
- `zig targets` inclut cette cible.

#### Prise en charge niveau 4

- La prise en charge de ces cibles est entièrement expérimentale.
- LLVM peut avoir ces cibles comme *expérimentales*, ce qui veut dire qu'il est nécessaire d'utiliser les binaires fournis par Zig pour avoir accès à ces cibles, ou compiler soi-même LLVM avec des options spécifiques.
`zig targets` affichera ces cibles si elles sont disponibles.
- Ces cibles sont considérées abandonnées par l'organisme officiellement en charge, comme [macosx/i386 (EN)](https://support.apple.com/en-us/HT208436), et dans ce cas ces cibles seront toujours bloquées au niveau 4 de prise en charge.
- Zig (via LLVM) permet de générer du code assembleur via `--emit asm` mais pas de fichiers objet.

## Agréable pour les mainteneurs de paquets

Le compilateur Zig de référence n'est pas complètement autonome pour le moment (il ne se compile pas lui-même).
Mais peu importe, il ne reste [exactement que 3 étapes (EN)](https://github.com/ziglang/zig/issues/853) pour avoir un système autonome pouvant compiler pour n'importe quelle cible et se débarrasser de la dépendance à un compilateur C++.
Pour citer Maya Rashish : [porter Zig sur d'autres plateformes est fun et rapide (EN)](http://coypu.sdf.org/porting-zig.html).

Les modes de compilation [sans debug (EN)](/documentation/master/#Build-Mode) sont reproductibles, déterministes.

Il y a une [version JSON de la page de téléchargements](/download/index.json).

Plusieurs membres de l'équipe derrière Zig ont de l'expérience dans le maintien de paquets.

- [Daurnimator](https://github.com/daurnimator) maintien le [paquet pour Arch Linux](https://www.archlinux.org/packages/community/x86_64/zig/)
- [Marc Tiehuis](https://tiehuis.github.io/) maintien le paquet pour Visual Studio Code.
- [Andrew Kelley](https://andrewkelley.me/) a passé à peu près un an à faire des [paquets pour Debian et Ubuntu](https://qa.debian.org/developer.php?login=superjoe30%40gmail.com&comaint=yes), et contribue occasionnellement à [nixpkgs](https://github.com/NixOS/nixpkgs/).
- [Jeff Fowler](https://blog.jfo.click/) maintien le paquet pour Homebrew et a créé le [Sublime package](https://github.com/ziglang/sublime-zig-language) (désormais maintenu par [emekoi](https://github.com/emekoi)).
