---
title: "코드 예제"
mobile_menu_title: "코드 예제"
toc: true
---

## 메모리 누수 감지
`std.heap.GeneralPurposeAllocator`를 사용하면 이중 해제 및 메모리 누수를 추적할 수 있습니다.

{{< zigdoctest "assets/zig-code/samples/1-memory-leak.zig" >}}


## C 상호운용성
C 헤더를 가져와 libc 및 raylib 양쪽으로 link하는 예제.

{{< zigdoctest "assets/zig-code/samples/2-c-interop.zig" >}}


## Zigg Zagg
Zig는 코딩 인터뷰에 *최적화* 되어 있습니다 (실제로는 아님).

{{< zigdoctest "assets/zig-code/samples/3-ziggzagg.zig" >}}


## Generic 타입
Zig에서 타입은 comptime 값이며 generic 알고리즘과 자료구조를 구현하기 위해 타입을 리턴하는 함수를 사용합니다. 이 예제에서는 간단한 generic 큐를 구현하고 그 동작을 테스트할 것입니다.

{{< zigdoctest "assets/zig-code/samples/4-generic-type.zig" >}}


## Zig에서 cURL 사용하기

{{< zigdoctest "assets/zig-code/samples/5-curl.zig" >}}
