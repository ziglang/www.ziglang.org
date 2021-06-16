---
title: "Ejemplos de código"
mobile_menu_title: "Ejemplos"
toc: true
---

## Detección de fugas de memoria
Usando `std.heap.GeneralPurposeAllocator` se pueden rastrear liberaciones dobles y fugas de memoria.

{{< zigdoctest "assets/zig-code/samples/1-memory-leak.zig" >}}


## Interoperabilidad con C
Ejemplo de importación de un archivo de encabezado de C y link hacia libc y raylib.

{{< zigdoctest "assets/zig-code/samples/2-c-interop.zig" >}}


## Zigg Zagg
Zig está *optimizado* para entrevistas de trabajo de programador (es broma!).

{{< zigdoctest "assets/zig-code/samples/3-ziggzagg.zig" >}}


## Tipos genéricos
En Zig, los tipos son valores en tiempo de compilación y usamos funciones que retornan un tipo para implementar algoritmos genéricos y estructuras de datos. En este ejemplo implementamos una cola simple y probamos su comportamiento.

{{< zigdoctest "assets/zig-code/samples/4-generic-type.zig" >}}


## Usando cURL desde Zig

{{< zigdoctest "assets/zig-code/samples/5-curl.zig" >}}
