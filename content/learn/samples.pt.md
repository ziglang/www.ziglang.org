---
title: "Examplos de Código"
mobile_menu_title: "Examplos de Código"
toc: true
---

## Detecção de vazamento de memória
Utilizando `std.GeneralPurposeAllocator` você pode detectar liberação dupla e vazamentos de memória.

{{< zigdoctest "assets/zig-code/samples/1-memory-leak.zig" >}}


## Interoperabilidade com C
Exemplo de importação de um arquivo de cabeçalho C e vinculação tanto à libc como à raylib.

{{< zigdoctest "assets/zig-code/samples/2-c-interop.zig" >}}


## Zigg Zagg
Zig é *optimizado* para codificar declarações (não exatamente!!).

{{< zigdoctest "assets/zig-code/samples/3-ziggzagg.zig" >}}


## Tipos Genéricos
Os tipos em Zig são valores comptime e usamos funções que retornam um tipo para implementar algoritmos genéricos e estruturas de dados. Neste exemplo, implementamos uma fila (qeue) genérica simples e testamos seu comportamento.

{{< zigdoctest "assets/zig-code/samples/4-generic-type.zig" >}}


## Utilizando o código do cURL (escrito em C) em Zig

{{< zigdoctest "assets/zig-code/samples/5-curl.zig" >}}
