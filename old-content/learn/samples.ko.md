---
title: "코드 예제"
mobile_menu_title: "코드 예제"
toc: true
---

## 메모리 누수 감지
`std.heap.GeneralPurposeAllocator`를 사용하면 메모리의 중복 해제 (double free) 및 메모리 누수를 추적할 수 있습니다.

{{< zigdoctest "assets/zig-code/samples/1-memory-leak.zig" >}}


## C언어와의 상호 운용성
아래 예제에서는 C 헤더 파일을 불러오고 libc와 raylib 라이브러리를 링크합니다.

{{< zigdoctest "assets/zig-code/samples/2-c-interop.zig" >}}


## Zigg Zagg
Zig는 코딩 인터뷰에 *최적화*되어 있습니다 (실제로는 아님).

{{< zigdoctest "assets/zig-code/samples/3-ziggzagg.zig" >}}


## Generic 타입
Zig의 모든 자료형은 컴파일 시간에 결정되며, 제너릭 (generic)한 알고리즘과 자료 구조를 구현하기 위해 자료형을 반환하는 함수를 사용합니다. 아래 예제에서는 간단한 제너릭 큐를 구현하고 큐가 제대로 구현이 되었는지 테스트해봅니다.

{{< zigdoctest "assets/zig-code/samples/4-generic-type.zig" >}}


## Zig에서 cURL 사용하기

{{< zigdoctest "assets/zig-code/samples/5-curl.zig" >}}
