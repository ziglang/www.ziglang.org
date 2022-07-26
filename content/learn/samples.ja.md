---
title: "コード例"
mobile_menu_title: "コード例"
toc: true
---

## メモリリーク検出
`std.heap.GeneralPurposeAllocator`を使用することにより、ダブルフリーやメモリリークを追跡することができます。

{{< zigdoctest "assets/zig-code/samples/1-memory-leak.zig" >}}


## C相互運用性
Cのヘッダーファイルをインポートし、libcとraylibの両方にリンクする例です。

{{< zigdoctest "assets/zig-code/samples/2-c-interop.zig" >}}


## Zigg Zagg
Zigはコーディングのインタビューに*最適化*されています（実際は違います）。

{{< zigdoctest "assets/zig-code/samples/3-ziggzagg.zig" >}}


##  ジェネリック型
Zig では、型はコンプタイムの値であり、型を返す関数を使って一般的なアルゴ リズムやデータ構造を実装しています。この例では、単純な汎用キューを実装し、その挙動をテストします。

{{< zigdoctest "assets/zig-code/samples/4-generic-type.zig" >}}


## ZigからcURLを利用する

{{< zigdoctest "assets/zig-code/samples/5-curl.zig" >}}
