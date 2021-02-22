---
title: Débuter
mobile_menu_title: "Débuter"
toc: true
---

{{% div class="box thin"%}}
**<center>Note pour les utilisateurs d'Apple Silicon</center>**
Zig a une prise en charge expérimentale de signature de code.
Vous pourrez utiliser Zig avec votre Mac M1, mais la seule manière de faire fonctionner Zig pour macOS sur arm64 sera de le compiler vous-même.
Pour en savoir plus, allez voir la section [Compilation des sources](#building-from-source).
{{% /div %}}


## Version numérotée ou nightly build ?
Zig n'a pas encore atteint la version 1.0 et le cycle de sorties est lié aux nouvelles versions de LLVM, qui sortent tous les ~6 mois.
En pratique, **les versions de Zig sont éloignées et vont l'être de plus en plus**.

Il est valable d'utiliser Zig dans une version numérotée, mais si vous aimez Zig et que vous voulez aller plus loin, **nous vous encourageons à passer à la version nightly**.
Cela sera plus facile pour vous d'être aidé : la plupart de la communauté et des sites comme [ziglearn.org](https://ziglearn.org) suivent la branche master pour les raisons évoquées plus tôt.

La bonne nouvelle est qu'il est très facile de passer d'une version de Zig à une autre, ou même d'avoir plusieurs versions installées sur le système en même temps : les versions de Zig sont des archives qui se suffisent à elles-mêmes et qui peuvent être placées n'importe où sur le système.


## Installer Zig
### Téléchargement direct
Ceci est la manière la plus simple d'obtenir Zig : téléchargez l'archive Zig pour votre plateforme sur [la page de téléchargements](/download) et mettez son contenu dans votre `PATH` pour pouvoir appeler `zig` depuis n'importe où.

#### Configurer le PATH sur Windows
Pour configurer le chemin (*PATH*) sur Windows, exécutez **une** des instructions de code suivantes dans une instance de Powershell.
Choisissez si vous souhaitez appliquer ce changement à l'échelle du système (nécessite une instance de Powershell avec des privilèges administrateur) ou juste pour votre utilisateur, et **assurez-vous de changer le code pour pointer à l'endroit où se situe votre copie de Zig**.
Le `;` avant `C:` n'est pas une typo.

À l'échelle du système (Powershell **admin**) :
```
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "Machine") + ";C:\votre-chemin\zig-windows-x86_64-your-version",
   "Machine"
)
```

Juste pour votre utilisateur (Powershell) :
```
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\votre-chemin\zig-windows-x86_64-your-version",
   "User"
)
```
Après cela, redémarrez votre instance Powershell.

#### Configurer le PATH sur Linux, macOS, BSD
Ajoutez le chemin vers votre binaire Zig à votre variable d'environnement PATH.

Cela est généralement fait en ajoutant une ligne d'export dans votre script de démarrage de shell (`.profile`, `.zshrc`…)
```bash
export PATH=$PATH:~/chemin/vers/zig
```
Après cela, soit vous faites un `source` de votre script de démarrage, soit vous redémarrez votre terminal.



### Gestionnaires de paquets
#### Windows
Zig est disponible sur [Chocolatey](https://chocolatey.org/packages/zig).
```
choco install zig
```

#### macOS

**Homebrew**
NOTE: Homebrew n'a pas encore de bouteille pour Apple Silicon.
Si vous avez un Mac M1, vous devez compiler Zig depuis les sources.

Dernière version numérotée :
```
brew install zig
```

Dernière version depuis le dépôt Git (branche master) :
```
brew install zig --HEAD
```

**MacPorts**
```
port install zig
```
#### Linux
Zig est également disponible dans divers gestionnaires de paquets pour Linux.
Vous pouvez trouver une [liste mise à jour ici](https://github.com/ziglang/zig/wiki/Install-Zig-from-a-Package-Manager) mais gardez à l'esprit que ces dépôts peuvent ne pas être à jour.

### Compilation des sources
Vous pouvez trouver [plus d'informations ici](https://github.com/ziglang/zig/wiki/Building-Zig-From-Source) sur la manière de compiler Zig depuis les sources pour Linux, macOS ou Windows.

## Outils recommandés
### Serveur de langue (LSP) et coloration de syntaxe
Tous les éditeurs de textes majeurs ont une prise en charge du soulignement de syntaxe pour Zig.
Certains le fournissent de base, d'autres nécessitent l'installation d'un module.

Si vous êtes intéressé par une intégration plus profonde entre Zig et votre éditeur, allez voir [zigtools/zls](https://github.com/zigtools/zls).

D'autres outils sont disponibles, voir la section [Outils](../tools/).

## Lancer un Hello World
Si vous avez installé correctement Zig, vous devriez désormais pouvoir invoquer le compilateur Zig depuis votre terminal.
Essayons ceci en créant votre premier programme Zig !

Naviguez dans votre répertoire de projets et lancez :
```bash
mkdir hello-world
cd hello-world
zig init-exe
```

Cela devrait donner ceci :
```
info: Created build.zig
info: Created src/main.zig
info: Next, try `zig build --help` or `zig build run`
```

Lancer `zig build run` devrait ensuite compiler l'exécutable et le lancer, puis donner ceci :
```
info: All your codebase are belong to us.
```

Félicitations, vous avez une installation fonctionnelle de Zig !

## Prochaines étapes
**Allez voir les autres ressources présentes dans la section [Apprendre](../)**, assurez-vous de regarder la documentation qui correspond à votre version de Zig (note : les nightly doivent utiliser la documentation `master`) et pensez éventuellement à lire [ziglearn.org](https://ziglearn.org).

Zig est un projet assez jeune et malheureusement nous n'avons pas encore la capacité à produire une documentation exhaustive, donc vous devriez considérer [joindre l'une des communautés existantes de Zig](https://github.com/ziglang/zig/wiki/Community) pour obtenir de l'aide si vous rencontrez un problème, ainsi que regarder des initiatives comme [Zig SHOWTIME](https://zig.show).

Enfin, si vous appréciez Zig et que vous souhaitez accélérer le développement, [n'hésitez pas à faire des dons à la Zig Software Foundation](../../zsf).
<img src="../../heart.svg" style="vertical-align:middle; margin-right: 5px">.
