---
title: ホーム
mobile_menu_title: "ホーム"
---
{{< slogan get_started="始めましょう" docs="ドキュメント" notes="変更点" lang="ja" >}}
Zigは、**堅牢**、**最適**、および**再利用可能**なソフトウェアをメンテナンスするための汎用プログラミング言語およびツールチェインです。
{{< /slogan >}}

{{< flexrow class="container" style="padding: 20px 0; justify-content: space-between;" >}}
{{% div class="features" %}}

# ⚡ シンプルな言語
プログラミング言語の知識をデバッグするよりも、アプリケーションのデバッグにフォーカスしてください。

- 隠された制御フローはありません。
- 隠されたメモリ割り当てはありません。
- プリプロセッサ、マクロもありません。

# ⚡ コンプタイム
コンパイル時のコード実行と遅延評価に基づくメタプログラミングへの新しいアプローチ。

- コンパイル時に任意の関数を呼び出します。
- ランタイムオーバーヘッドなしに型を値として操作します。
- コンプタイムはターゲットアーキテクチャをエミュレートします。

# ⚡ Zigでメンテナンス
C/C++/Zigのコードベースを段階的に改善することができます。

- Zigを依存性ゼロのドロップインC/C++コンパイラとして使用し、すぐにクロスコンパイルをサポートします。
- `zig build`を活用し、全てのプラットフォームで一貫した開発環境を構築します。
- C/C++プロジェクトにZigのコンパイルユニットを追加することができます。

{{% flexrow style="justify-content:center;" %}}
{{% div %}}
<h1>
    <a href="learn/overview/" class="button" style="display: inline;">詳細な概要</a>
</h1>
{{% /div %}}
{{% div  style="margin-left: 5px;" %}}
<h1>
    <a href="learn/samples/" class="button" style="display: inline;">その他のコードサンプル</a>
</h1>
{{% /div %}}
{{% /flexrow %}}
{{% /div %}}
{{< div class="codesample" >}}

{{% zigdoctest "assets/zig-code/index.zig" %}}

{{< /div >}}
{{< /flexrow >}}


{{% div class="alt-background" %}}
{{% div class="container"  style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="コミュニティ" %}}

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div style="width:25%" %}}
<img src="/ziggy.svg" style="max-height: 200px">
{{% /div %}}

{{% div class="community-message" %}}
# Zigのコミュニティは分散型
誰でも自由に、コミュニティが集う場を立ち上げ、メンテナンスすることができます。
「公式」「非公式」という概念はありませんが、それぞれの集いの場には、モデレーターやルールがあります。

<div style="">
<h1>
	<a href="https://github.com/ziglang/zig/wiki/Community" class="button" style="display: inline;">すべてのコミュニティを見る</a>
</h1>
</div>
{{% /div %}}
{{< /flexrow >}}
<div style="height: 50px;"></div>

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div class="main-development-message" %}}
# 主な開発内容
Zigのリポジトリは[https://github.com/ziglang/zig](https://github.com/ziglang/zig)にあります。ここでは、イシュー・トラッカーもホストしており、提案についても議論しています。
コントリビュータはZigの[行動規範](https://github.com/ziglang/zig/blob/master/.github/CODE_OF_CONDUCT.md)を遵守することが求められます。
{{% /div %}}
{{% div style="width:40%" %}}
<img src="/zero.svg" style="max-height: 200px">
{{% /div %}}
{{< /flexrow >}}
{{% /div %}}
{{% /div %}}


{{% div class="container" style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="Zigソフトウェア財団" %}}
## ZSFは501(c)(3)の非営利法人です。

Zigソフトウェア財団は、Zigの生みの親であるAndrew Kelleyが2020年に設立した非営利法人で、Zigの言語開発を支援することを目的としています。現在、ZSFは少数のコア・コントリビュータに競争力のある料金で有償の仕事を提供することができます。将来的には、より多くのコア・コントリビュータにこのオファーを拡大できるようにしたいと考えています。

Zigソフトウェア財団は、寄付金によって運営されています。

<h1>
	<a href="zsf/" class="button" style="display:inline;">詳しく</a>
</h1>
{{% /div %}}


{{< div class="alt-background" style="padding: 20px 0;">}}
{{% div class="container" title="スポンサー" %}}
# 企業スポンサー
以下の企業は、Zig Software財団に直接的な資金援助を行っています。

{{% monetary-sponsor-logos %}}

# GitHubスポンサー
[Zigをスポンサー](zsf/)してくださる方々のおかげで、このプロジェクトは企業の株主ではなく、オープンソースコミュニティに対して説明責任を果たすことができるのです。特に、月々200ドル以上でZigのスポンサーになってくださっている方々は素晴らしい方々です:

{{< ghsponsors >}}

このセクションは、毎月月初に更新されます。
{{% /div %}}
{{< /div >}}
