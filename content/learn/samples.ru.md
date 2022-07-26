---
title: "Примеры кода"
mobile_menu_title: "Примеры кода"
toc: true
---

## Обнаружение утечки памяти
Используя `std.heap.GeneralPurposeAllocator`, вы можете отслеживать двойное освобождение памяти и утечки памяти.

{{< zigdoctest "assets/zig-code/samples/1-memory-leak.zig" >}}


## Совместимость с C
Пример импортирования заголовочного файла C и связывания с библиотекой raylib и стандартной библиотекой C.

{{< zigdoctest "assets/zig-code/samples/2-c-interop.zig" >}}


## Zigg Zagg
Zig *оптимизирован* для собеседований (не совсем).

{{< zigdoctest "assets/zig-code/samples/3-ziggzagg.zig" >}}


## Обобщённые типы
В Zig типы являются значениями времени компиляции, и мы используем функции, которые возвращают тип, чтобы реализовывать обобщённые алгоритмы и структуры данных. В этом примере мы реализовываем простую обобщённую очередь и тестируем её поведение.

{{< zigdoctest "assets/zig-code/samples/4-generic-type.zig" >}}


## Вызов cURL с Zig

{{< zigdoctest "assets/zig-code/samples/5-curl.zig" >}}
