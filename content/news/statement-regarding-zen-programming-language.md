---
title: "Zigソフトウェア財団とZenプログラミング言語に関する声明"
date: 2020-09-14T00:00:00+00:00
draft: false
lang: ja
---
{{< box >}} 
Original English version available below. We are thankful to <a href="https://hyperia.co.jp/" target="_blank" rel="noopener noreferrer">株式会社HYPERIA</a> and all the members of the Zig community that helped us with the Japanese translation. 
{{< /box >}}

# Zigソフトウェア財団とZenプログラミング言語に関する声明

Zigソフトウェア財団は、Zigの開発者[アンドリュー・ケリー](https://andrewkelley.me/)によって創設された501(c)(3)非営利組織です。本財団はZigプログラミング言語開発のサポートと優れたグローバルコミュニティの育成を目的としています。

対して[Zen](https://zen-lang.org/)はコネクトフリー社によって保守されているZigのクローズドソースフォークです。コネクトフリー社は最近Zenコンパイラのためのライセンスモデルを[発表](https://zen-lang.org/ja-JP/blog/2020-08-20/)し、ソフトウェア開発者は自分で作成したコードのコンパイル済みリリースを配布する上で年間サブスクリプションの購読が必要になりました。

Zigプロジェクトとコネクトフリー社の関係性についてコネクトフリー社は完全には明確にしていません。そこで、本声明ではこの関係性について明確にしたいと考えています。日本の皆様がZenコンパイラへの年間ライセンス料を支払う前に、ZigとZenが分岐した背景を知っていただきたいと考えています。

「[Zigからの発展](https://www.zen-lang.org/ja-JP/docs/appendix-zig/)」ページにおいて、コネクトフリー社はZenはZigバージョン0.3.0から独立して進化してきたとしており、またZigの貢献者である「No.5」と「No.2」はコネクトフリー社の従業員であり、「No.5」はコネクトフリー社創設者のクリストファー・テイト氏であると述べています。この他に、このページではZenがZigと比較してどのような点で優れているかというバリュー・プロポジションと、開発チームのある種の正統性——彼らが信頼に値する存在だということを示そうとしているようです。

Zenが独立的に進化してきたという主張については、私どもはクローズドソースであるコンパイラの内部実装についてはコメントできないものの、Zen標準ライブラリのソースコードはZenリリースの度にまだ入手可能です。このソースコードを読むと、コネクトフリー社がZigプロジェクトからいまだに多くのコードを借用していることが簡単に分かります。ほとんどの場合、彼らの命名規則に合わせるために非常に小さな変化を適用しているに過ぎません。この一例として「async/await」機能があります。この機能はZigバージョン0.6.0 (バージョン0.3.0の約1年半後) で導入されましたが、コネクトフリー社によってZenに実質的に全く変更なくコピーされました。もう一つの例として、[こちらのリンクから二つのイベントループ実装の比較をご覧いただけます](https://github.com/kristoff-it/zenlang-ziglang-eventloop/commit/f67aa04ef081187eb8857e7b5c18c9ed787e0079)。

開発チームについてのお話をしましょう。「No.5」(すなわちクリストファー・テイト氏) はZigプロジェクトの公共の場であるGitHubとIRCで繰り返し問題のある行動を行ったため、プロジェクトから追放されなければならなくなりました。こうした経緯があることをコネクトフリー社は明らかにしていません。その後、テイト氏は「No.2」をZenコンパイラに取り組ませるために雇いましたが、この契約にあたってプライベートな時間で作られたものも含め「No.2」が書いた全てのコードの所有権がコネクトフリー社にも帰属するという契約内容について[適切に明確化することを怠りました](https://github.com/ziglang/zig/pull/2701)。その時以来「No.2」はコネクトフリー社の職を辞めましたが、契約の中に示されている「競業避止義務」条項のために、Zigプロジェクトにしばらくのあいだ貢献することもできません。さらに、テイト氏はいくつかのZigコミュニティで宣伝活動を行い、複数のZigコントリビュータをメール経由でスカウトしようとしていたことが知られています。おそらく「No.2」と同じ契約条件で雇おうとしていたものと考えられます。

以下内容は私どもの公式ウェブサイトからの引用で、Zigソフトウェア財団の使命です。

{{< box >}} 
<i>
Zigソフトウェア財団の使命は、Zigプログラミング言語を促進・保護・発展させること、Zigプログラマーの多様で国際的なコミュニティの成長を支えること、また学生に教育と指導を提供し、次世代のプログラマーを有能かつ倫理的に高い水準を持つ人材へと育成することです。
</i>
{{< /box >}}

コネクトフリー社の創設者であるテイト氏は、[不完全な技術論](https://github.com/ziglang/zig/issues/1530)により彼自身の行動を正当化しようとすると同時に、契約条項を利用してZigの貢献者がこのオープンソースプロジェクトに更に貢献する事を阻止しています。また、コネクトフリー社のZenはZigを表面的にリブランディングしたものに過ぎません。このようなテイト氏の過去と現在の振舞いから、日本の専門家や会社がこうしたクローズドソース製品に頼り生計をたてようとするのは、私どもの良識としてはお勧めできません。

Zigのオープンな設計プロセスは協調の精神に基づいており、オープンソース開発を通じてのみ達成可能なレベルの技術的な卓越性と[圧倒的](https://ziglang.org/download/0.4.0/release-notes.html)[な改善](https://ziglang.org/download/0.5.0/release-notes.html)[スピード](https://ziglang.org/download/0.6.0/release-notes.html)の実現を目指しています。Zigをユニークで革新的な言語たらしめる多くの特徴 (comptime, async/await, sentinel終端ポインタ型, エラー型等々) は、こうした設計プロセスを進めた結果生まれたものです。

以上より、堅固かつ最適で再利用可能なコードの作成に興味のある日本の開発者の皆様を[世界的なZigコミュニティ](https://github.com/ziglang/zig/wiki/Community)にお招きしご参加頂く事で、限られた人たちの特権に1円も払う事なく、本物のコードに触れて楽しんで頂きたいと考えております。

この度は本声明をお読み頂き、誠に有難うございました。

<br/>

Kindest regards,  
Loris Cro - VP of Community  
Zig Software Foundation  

<br/>


【追伸】  
私どもは、教材や説明書を日本語含む様々な言語で伝える事にご協力いただける方を探しています。もしご興味がおありでしたら、こちらまでご連絡ください！[nippon@ziglang.org](mailto:nippon@ziglang.org) 

<div style="width: 100%; text-align: center; margin-top: 2em; margin-bottom: 1em;">
      <span><i>Original English version follows.</i></span>
    </div>

# Statement Regarding the Zen Programming Language

The Zig Software Foundation is a 501(c)(3) non-profit organization created by [Andrew Kelley](https://andrewkelley.me/), the creator of Zig, with the goal of supporting the development of the Zig programming language, as well as fostering an equally excellent global community around it.

[Zen](https://zen-lang.org/) is a closed-source fork of Zig maintained by connectFree, a company that has recently [announced](https://zen-lang.org/ja-JP/blog/2020-08-20/) a licensing model for the Zen compiler that requires software developers to buy a yearly subscription to distribute compiled releases of their code.

In this statement, we want to clarify to the Japanese public the relationship between the Zig project and connectFree, as the latter hasn’t been entirely forthcoming on the subject matter, and we feel potential customers should know the full picture before spending their money.

In the “[Evolution from Zig](https://www.zen-lang.org/ja-JP/docs/appendix-zig/)” page, connectFree states that Zen has evolved independently from Zig since version 0.3.0 and that Zig contributors “No. 2” and “No. 5” are connectFree employees, with “No. 5” being Kristopher Tate, the founder of connectFree. The page is supposed to provide a value proposition for Zen over Zig, as well as to give some sort of “pedigree” to the development team.

With regards to the independence argument, while we can’t comment on the closed-source compiler itself, source files for the Zen standard library can still be obtained with every release of Zen. By reading those source files, it’s easy to see that connectFree is still borrowing heavily from the Zig project, often only applying very minor changes to fit their naming conventions. One example of this is the entirety of the new “async/await” functionality, first introduced in Zig version 0.6.0 (roughly 1.5 years after version 0.3.0) and copied with virtually no change by connectFree. As another example, [here you can see a comparison between the two event loop implementations](https://github.com/kristoff-it/zenlang-ziglang-eventloop/commit/f67aa04ef081187eb8857e7b5c18c9ed787e0079).

As for the development team, connectFree omits how “No. 5” (i.e. Kristopher Tate) had to be banned from the Zig project after repeatedly misbehaving in public, both on GitHub and IRC. After that event, Mr. Tate hired “No. 2” to work on the Zen compiler and [failed to make it adequately clear](https://github.com/ziglang/zig/pull/2701) that the contract also granted connectFree ownership of all code written by “No. 2”, even during private hours. Since then, “No. 2” has resigned from their position at connectFree, but won’t be able to contribute to the Zig project for some time because of a “non-compete” clause present in the contract. Mr. Tate has also tried to advertise in some Zig communities and cold emailed multiple Zig contributors about working for connectFree, presumably under the same contractual obligations that “No. 2” was subjected to.

Taken from our official website, this is the mission of the Zig Software Foundation:

{{< box >}} 
<i>
The mission of the Zig Software Foundation is to promote, protect, and advance the Zig programming language, to support and facilitate the growth of a diverse and international community of Zig programmers, and to provide education and guidance to students, teaching the next generation of programmers to be competent, ethical, and to hold each other to high standards.
</i>
{{< /box >}}


Given past and present behavior by Mr. Tate, we can’t in good conscience recommend to Japanese professionals and businesses to make their livelihood depend on a closed-source, superficial rebranding of Zig, sold by a company whose founder uses [flawed technical arguments](https://github.com/ziglang/zig/issues/1530) to justify his actions while leveraging contractual clauses to prevent Zig contributors from further contributing to the open-source project.

The many features that make Zig a unique and innovative language (comptime, async/await, sentinel-terminated pointer types, error unions, …) are the result of conducting the design process openly, with a collaborative spirit, and with the ultimate goal of reaching a level of technical excellence and [speed](https://ziglang.org/download/0.4.0/release-notes.html) [of](https://ziglang.org/download/0.5.0/release-notes.html) [improvement](https://ziglang.org/download/0.6.0/release-notes.html) that is only truly achievable in open-source software development.

Given all of the above, we invite all Japanese developers interested in writing robust, optimal, and reusable code to join [the global Zig community](https://github.com/ziglang/zig/wiki/Community) and enjoy the real deal, without having to pay a single Yen for the privilege.

<br/>

Kindest regards,  
Loris Cro - VP of Community  
Zig Software Foundation  

<br/>


P.S.  
We are looking for contributors to help write learning materials and documentation in other languages, including Japanese. If you are interested, please get in touch at nippon@ziglang.org!

