---
title: "Pourquoi Zig alors qu'il existe déjà C++, D, et Rust ?"
mobile_menu_title: "Pourquoi Zig..."
toc: true
---


## Pas de flot de contrôle caché

Si un code en Zig ne semble pas faire appel à une fonction, c'est qu'il ne le fait pas.
Vous pouvez être sûr que le code suivant ne fait appel qu'à `foo()` puis `bar()`, sans même connaître les types impliqués :

```zig
var a = b + c.d;
foo();
bar();
```

Exemples de flots de contrôle cachés :

- D a des fonctions `@property`, des méthodes qui ressemblent à de simples accès à des champs d'une structure, `c.d` peut être un appel à une fonction.
- C++, D, et Rust ont de la surcharge d'opérateurs, donc l'opérateur `+` peut appeler une fonction.
- C++, D, et Go ont des exceptions *throw/catch*, donc `foo()` peut lancer une exception, et empêcher `bar()` d'être appelé.
(Bien sûr, même en Zig `foo()` pourrait être bloquant et empêcher `bar()` d'être appelée, mais cela pourrait survenir dans n'importe quel langage Turing-complet.)

L'objectif de cette conception est d'améliorer la lisibilité.

## Aucune allocation cachée

Zig ne gère pas lui-même les allocations mémoire sur le *tas*.
Il n'y a pas de mot clé `new` ou autre fonctionnalité qui utiliserait un allocateur de mémoire (comme un opérateur de concaténation de chaînes de caractères par exemple[1]).
Le concept de *tas* est géré par une bibliothèque ou le code de l'application, pas par le langage.

Exemples d'allocations cachées :

* En Go, `defer` alloue de la mémoire dans la pile de la fonction.
En plus d'être un flot de contrôle contre-intuitif, cela peut provoquer des erreurs d'allocation de mémoire si `defer` est utilisé dans une boucle.
* Les coroutines C++ allouent de la mémoire sur le tas pour appeler une coroutine.
* En Go, un appel de fonction peut engendrer une allocation sur le tas.
Les *goroutines* allouent des petites piles qui finissent par être redimensionnées lorsque la pile est trop sollicitée.
* Les API standards de Rust plantent sur des conditions de manque de mémoire.
Les API alternatives qui acceptent un allocateur de mémoire sont des réflexions après coup (voir [rust-lang/rust#29802 (EN)](https://github.com/rust-lang/rust/issues/29802)).

Presque tous les langages avec ramasse-miettes (*garbage collector*) ont des flots de contrôle cachés éparpillés, puisque le ramasse-miettes cache la libération de la mémoire.

Le principal problème avec les allocations de mémoire cachées est qu'elles empêchent la réutilisation du code dans certains environnements.
Certains cas nécessitent de n'avoir aucune allocation mémoire, donc le langage de programmation doit fournir cette garantie.

En Zig, certaines fonctions de la bibliothèque standard qui fournissent et fonctionnent avec des allocateurs de mémoire.
Ces fonctions sont optionnelles, non incluses dans le langage de programmation lui-même.
Si vous n'allouez pas de mémoire dans le tas, vous pouvez être sûr que votre programme ne le fera pas.

Chaque fonction de la bibliothèque standard nécessitant d'allouer de la mémoire sur le tas prend un paramètre `Allocator`.
Cela veut dire que la bibliothèque standard de Zig prend en charge les cibles `freestanding` (qui ne nécessitent pas de système d'exploitation).
Par exemple, `std.ArrayList` et `std.AutoHashMap` peuvent être utilisées pour de la programmation matérielle !

Les allocateurs de mémoire sur mesure rendent simple la gestion manuelle de la mémoire.
Zig a un allocateur de mémoire de debug qui vérifie les erreurs comme les utilisations après libération (*use-after-free*) et les double libérations (*double free*).
Il détecte automatiquement et affiche la trace de la pile en cas de fuite de mémoire.
Zig possède également un allocateur *arène* permettant de multiples allocations de mémoire puis de toutes les libérer en une seule fois.
D'autres allocateurs, plus spécifiques, peuvent améliorer les performances ou l'usage de la mémoire pour des besoins spécifiques.

[1]: En réalité, il y a un opérateur de concaténation de chaînes de caractères (un opérateur de concaténation de tableaux, pour être plus précis), mais il fonctionne à la compilation.
Il n'y a donc pas d'allocation sur le tas à l'exécution.

## Prise en charge de Zig sans bibliothèque standard

Comme indiqué plus tôt, la bibliothèque standard de Zig est entièrement optionnelle.
Chaque API n'est compilée dans le programme que si elle est utilisée.
Zig a la même prise en charge avec ou sans libc.
Zig encourage son utilisation directement sur le matériel et le développement à haute performance.

Ceci est le meilleur des deux mondes.
Par exemple, les programmes WebAssembly peuvent utiliser les fonctionnalités habituelles de la bibliothèque standard, et quand même avoir des exécutables de petite taille comparés aux autres langages prenant en charge WebAssembly.

## Un langage pour des bibliothèques portables

Le saint Graal en programmation est de pouvoir réutiliser le code.
Malheureusement, en pratique, nous réécrivons les mêmes fonctions, les mêmes bibliothèques… et cela est souvent justifié.

* Si l'application nécessite du temps-réel, alors toute bibliothèque utilisant un ramasse-miettes ou tout autre comportement non déterministe est disqualifiée.
* Si le langage rend trop facile pour le développeur d'ignorer les erreurs, et qu'il faut s'assurer que la bibliothèque les gère correctement.
Il peut être tentant de mettre de côté la bibliothèque et de la réécrire.
Zig est conçu pour que la gestion correcte des erreurs soit la chose la plus paresseuse à faire pour le développeur, et que donc nous soyons confiant dans la bibliothèque.
* Pour le moment il est en pratique vrai que le C est le langage le plus versatile et portable.
Tout langage n'ayant pas de possibilité d'interagir avec le C risque de disparaître.
Zig est une tentative de devenir le nouveau langage portable pour les bibliothèques en rendant à la fois facile de se conformer à l'ABI C pour les fonctions exportées, et introduisant de la sécurité et une conception de langage qui empêche les erreurs les plus communes dans les implémentations.

## Un gestionnaire de paquets et un outil de construction

Zig est un langage de programmation, mais il fournit également un outil de construction et un gestionnaire de paquets qui sont pensés pour être utiles même dans un contexte de développement C/C++.

Non seulement vous pouvez écrire du code C ou C++, mais vous pouvez également utiliser Zig comme un remplaçant aux `autotools`, cmake, make, scons, ninja, etc.
Et en plus de cela, il *fournira* un gestionnaire de paquets pour les dépendances natives.
L'outil de construction est conçu pour être utile même si le code est entièrement en C ou C++.

Les gestionnaires de paquets du système comme `apt`, `pacman`, `homebrew` et les autres sont nécessaires pour une bonne expérience utilisateur, mais sont insuffisants pour des développeurs.
Un gestionnaire de paquets pour un langage spécifique peut faire la différence entre ne pas avoir de contributeurs et en avoir des dizaines.
Pour des projets libres, avoir des difficultés à compiler le projet est un énorme frein pour les contributeurs potentiels.
Pour les projets en C/C++, avoir des dépendances peut être fatal, surtout sur Windows où il n'y a pas de gestionnaire de paquets.
Même pour compiler Zig lui-même, les contributeurs potentiels ont des difficultés avec la dépendance à LLVM.
Zig offre une solution simple pour les projets de dépendre sur des bibliothèques natives, sans dépendre du gestionnaire de paquets du système, évitant ainsi les problèmes de dépendances ou de mauvaises versions installées.
Les projets sont presque garantis de compiler du premier coup, peu importe l'état du système ou la plateforme utilisée ou ciblée.

Zig permet de remplacer l'outil de construction du projet avec un langage raisonnable utilisant une API déclarative pour construire les projets.
Zig remplace aussi le gestionnaire de paquets, permettant de dépendre de bibliothèques en C.
Avoir des bibliothèques facilement réutilisables permet en définitive de produire du code de plus haut niveau.

## Simplicité

C++, Rust, et D ont énormément de fonctionnalités et peuvent rendre le code plus complexe que nécessaire.
Il est possible de passer du temps à se remémorer des détails du langage plutôt qu'à coder le cœur de son application, c'est une distraction.

Zig n'a pas de macros ni de métaprogrammation, et pourtant le langage exprime des programme complexes d'une manière claire, non répétitive.
Même Rust implémente en dur certaines macros, comme `format!`.
L'équivalent en Zig est implémenté dans la bibliothèque standard sans code en dur dans le compilateur.

## Outils

Zig peut être téléchargé depuis [la section Téléchargements](/fr/download/).
Zig fournit des archives avec un binaire pré-compilé pour Linux, Windows, macOS et FreeBSD.

Grâce à ces archives, nous obtenons :

* un compilateur Zig, compilé statiquement et donc sans dépendances système
* l'installation via l'extraction d'une simple archive, sans configuration du système
* des optimisations avancées grâce à l'infrastructure LLVM et une prise en charge de la plupart des plateformes connues
* la cross-compilation sans effort
* la libc d'un certain nombre de plateformes, qui seront compilées seulement quand nécessaire
* un outil de construction avec un cache
* un compilateur C et C++ avec la libc nécessaire au système cible
