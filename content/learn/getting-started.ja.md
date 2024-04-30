---
title: 始めましょう
mobile_menu_title: "始めましょう"
toc: true
---

## タグ付きリリースかナイトリービルドか？
Zigはまだv1.0に到達しておらず、現在のリリースサイクルはLLVMの新リリースに連動しており、その周期は6ヶ月程度となっています。
現実的には、**Zigのリリースは間隔が開きがちで、現在の開発スピードからするといずれ陳腐化する**と言われています。

タグ付きバージョンを使ってZigを評価するのは良いのですが、もしZigが好きでもっと深く知りたいと思ったら
**ナイトリービルドにアップグレードすることをお勧めします** 。
そうすれば、助けを得るのがより簡単になるからです：[zig.guide](https://zig.guide)のようなサイトは、上記の理由から master ブランチを追跡しています。

Zigのバージョンを切り替えるのはとても簡単で、同時に複数のバージョンをシステム上に存在させることも可能です。Zigのリリースは自己完結型のアーカイブで、システムのどこにでも配置することができます。


## Zigをインストールする
### 直接ダウンロード
これが最もストレートなZigの入手方法です：[Downloads](/download)ページから、あなたのプラットフォーム用のZigバンドルを取得し、
ディレクトリに解凍して`PATH`に追加すれば、どの場所からでも`zig`を呼び出すことができるようになります。

#### WindowsでのPATHの設定
Windowsでパスを設定するには、Powershellインスタンスで次のコードのスニペットのうち**1つ**を実行します。
この変更をシステム全体に適用するか（管理者権限でPowershellを実行する必要があります）、自分のユーザーだけに適用するかを選択します。
また、**必ず、あなたのZigのコピーがある場所を指すようにスニペットを変更してください**。
`C:`の前の`;`はタイプミスではありません。

システム全体(**管理者** Powershell):
```
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "Machine") + ";C:\your-path\zig-windows-x86_64-your-version",
   "Machine"
)
```

ユーザーレベル（Powershell）：
```
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\your-path\zig-windows-x86_64-your-version",
   "User"
)
```
完了後、Powershellインスタンスを再起動します。

#### Linux、macOS、BSDでのPATHの設定
zigバイナリの場所をPATH環境変数に追加してください。

これは通常、シェルのスタートアップスクリプト(`.profile`, `.zshrc`, ...)にexport行を追加することで行われます。
```bash
export PATH=$PATH:~/path/to/zig
```
終了後、スタートアップファイルを`source`するか、シェルを再起動します。




### パッケージマネージャ
#### Windows
**WinGet**  
Zigは[WinGet](https://github.com/microsoft/winget-pkgs/tree/master/manifests/z/zig/zig)で使用できます。
```
winget install -e --id zig.zig
```

**Chocolatey**  
Zigは[Chocolatey](https://chocolatey.org/packages/zig)で使用できます。
```
choco install zig
```

**Scoop**  
Zigは[Scoop](https://scoop.sh/#/apps?q=zig&id=7e124d6047c32d426e4143ab395d863fc9d6d491)で使用できます。
```
scoop install zig
```
最新の[開発版](https://scoop.sh/#/apps?q=zig&id=921df07e75042de645204262e784a17c2421944c)：
```
scoop bucket add versions
scoop install versions/zig-dev
```

#### macOS

**Homebrew**
最新のタグ付きリリース：
```
brew install zig
```

**MacPorts**
```
port install zig
```
#### Linux
ZigはLinux用の多くのパッケージマネージャにも含まれています。[こちら](https://github.com/ziglang/zig/wiki/Install-Zig-from-a-Package-Manager)には最新のリストがありますが、
パッケージによっては古いバージョンのZigがバンドルされている場合があることに留意してください。

### ソースからのビルド
[こちら](https://github.com/ziglang/zig/wiki/Building-Zig-From-Source)には、
Linux、macOS、Windows用のZigをソースからビルドする方法についての詳細情報が掲載されています。

## 推奨ツール
### シンタックスハイライターとLSP
主要なテキストエディタは、Zigのシンタックスハイライトをサポートしています。
バンドルされているものもあれば、プラグインをインストールする必要があるものもあります。

もし、Zigとエディタとのより深い統合に興味があるなら、
[zigtools/zls](https://github.com/zigtools/zls)をチェックアウトしてください。

他にどんなものがあるか興味がある方は、[ツール](../tools/)のセクションをチェックしてみてください。

## Hello Worldを実行する
インストールが正しく完了すれば、シェルからZigコンパイラを呼び出すことができるはずです。
それでは、最初のZigプログラムを作ってテストしてみましょう!

プロジェクトディレクトリに移動し、実行します：
```bash
mkdir hello-world
cd hello-world
zig init-exe
```

これが出力されるはずです：
```
info: created build.zig
info: created build.zig.zon
info: created src/main.zig
info: created src/root.zig
info: see `zig build --help` for a menu of options
```

`zig build run`を実行すると、実行ファイルがコンパイルされて実行され、最終的に以下のような結果になります：
```
All your codebase are belong to us.
Run `zig build test` to run the tests.
```

おめでとうございます！これでZigのインストールは完了です！

## 次のステップ
**[学ぶ](../) セクションにある他のリソースもチェックし**、あなたのバージョンのZigのドキュメントを見つけてください（注意：ナイトリービルドは `master` ドキュメントを使うべきです）、
そして、[zig.guide](https://zig.guide)を読んでみてください。

Zigは若いプロジェクトであり、残念ながら、すべてのことについて広範な文書や学習資料を作成する能力はまだありません。
したがって、行き詰まったときに助けを得るために[既存のZigコミュニティのいずれかに参加すること](https://github.com/ziglang/zig/wiki/Community)や、
[Zig SHOWTIME](https://zig.show)といった取り組みも検討してみてください。

最後に、もしあなたがZigを楽しんでいて開発のスピードアップに貢献したいとお考えなら、[Zigソフトウェア財団への寄付をご検討ください](../../zsf)
<img src="../../heart.svg" style="vertical-align:middle; margin-right: 5px">.
