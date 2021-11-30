---
title: 홈
mobile_menu_title: "홈"
---
{{< slogan get_started="GET STARTED" docs="Documentation" notes="Changes" lang="en" >}}
Zig는 **견고**하고, **최적화**되어 있으며, **재사용이 가능한** 소프트웨어의 개발 및 관리를 위한 범용 프로그래밍 언어 및 툴체인입니다.
{{< /slogan >}}

{{< flexrow class="container" style="padding: 20px 0; justify-content: space-between;" >}}
{{% div class="features" %}}

# ⚡ 간결한 언어
프로그래밍 언어 지식을 디버깅하는 대신, 프로그램의 디버깅에만 집중하세요.

- 숨겨진 흐름 제어 없음.
- 숨겨진 메모리 할당 없음.
- 전처리기와 매크로 없음.

# ⚡ 컴파일 타임
컴파일 타임 코드 실행 기능과 지연 평가 기능을 활용한, 메타프로그래밍의 새로운 접근법을 확인해보세요.

- 어떤 함수든 컴파일 타임에 호출 가능.
- 런타임 오버헤드 없이 모든 자료형을 값처럼 수정 가능.
- 컴파일 과정에서 대상 아키텍처를 그대로 에뮬레이트 가능.

# ⚡ Zig를 통한 코드 관리
C/C++/Zig 코드베이스를 점진적으로 향상시키세요.

- Zig를 크로스 컴파일을 지원하며, 다른 컴파일러를 바로 대체할 수 있는 독립적인 C/C++ 컴파일러로 사용 가능.
- `zig build`를 이용하여 모든 플랫폼에서 일관성 있는 개발 환경 구축 가능.
- 여러 언어를 대상으로 링크 타임 최적화 (LTO) 기능을 지원하여, C/C++ 프로젝트에 Zig 컴파일 단위를 부담 없이 추가 가능.

{{% flexrow style="justify-content:center;" %}}
{{% div %}}
<h1>
    <a href="learn/overview/" class="button" style="display: inline;">자세히 알아보기</a>
</h1>
{{% /div %}}
{{% div  style="margin-left: 5px;" %}}
<h1>
    <a href="learn/samples/" class="button" style="display: inline;">코드 예제 더 보기</a>
</h1>
{{% /div %}}
{{% /flexrow %}}
{{% /div %}}
{{< div class="codesample" >}}

{{% zigdoctest "assets/zig-code/index.zig" %}}

{{< /div >}}
{{< /flexrow >}}


{{% div class="alt-background" %}}
{{% div class="container"  style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="Community" %}}

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div style="width:25%" %}}
<img src="/ziggy.svg" style="max-height: 200px">
{{% /div %}}

{{% div class="community-message" %}}
# The Zig community is decentralized 
Anyone is free to start and maintain their own space for the community to gather.  
There is no concept of "official" or "unofficial", however, each gathering place has its own moderators and rules.

<div style="">
<h1>
	<a href="https://github.com/ziglang/zig/wiki/Community" class="button" style="display: inline;">See all Communities</a>
</h1>
</div>
{{% /div %}}
{{< /flexrow >}}
<div style="height: 50px;"></div>

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div class="main-development-message" %}}
# Main development
The Zig repository can be found at [https://github.com/ziglang/zig](https://github.com/ziglang/zig), where we also host the issue tracker and discuss proposals.  
Contributors are expected to follow Zig's [Code of Conduct](https://github.com/ziglang/zig/blob/master/CODE_OF_CONDUCT.md).
{{% /div %}}
{{% div style="width:40%" %}}
<img src="/zero.svg" style="max-height: 200px">
{{% /div %}}
{{< /flexrow >}}
{{% /div %}}
{{% /div %}}


{{% div class="container" style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="Zig Software Foundation" %}}
## The ZSF is a 501(c)(3) non-profit corporation.

The Zig Software Foundation is a non-profit corporation founded in 2020 by Andrew Kelley, the creator of Zig, with the goal of supporting the development of the language. Currently, the ZSF is able to offer paid work at competitive rates to a small number of core contributors. We hope to be able to extend this offer to more core contributors in the future.

The Zig Software Foundation is sustained by donations.

<h1>
	<a href="zsf/" class="button" style="display:inline;">Learn More</a>
</h1>
{{% /div %}}


{{< div class="alt-background" style="padding: 20px 0;">}}
{{% div class="container" title="Sponsors" %}}
# Corporate Sponsors 
The following companies are providing direct financial support to the Zig Software foundation.

{{% sponsor-logos "monetary" %}}
 <a href="https://pex.com" rel="noopener nofollow" target="_blank"><picture>
   <picture>
     <source srcset="/pex-white.svg" media="(prefers-color-scheme: dark)">
     <img src="/pex-dark.svg">
   </picture>
 </a>
{{% /sponsor-logos %}}

# GitHub Sponsors
Thanks to people who [sponsor Zig](zsf/), the project is accountable to the open source community rather than corporate shareholders. In particular, these fine folks sponsor Zig for $200/month or more:

{{< ghsponsors >}}

This section is updated at the beginning of each month.
{{% /div %}}
{{< /div >}}
























