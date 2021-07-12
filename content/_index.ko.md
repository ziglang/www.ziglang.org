---
title: 홈
mobile_menu_title: "홈"
---
{{< slogan get_started="시작하기" docs="문서" notes="변경사항" lang="ko" >}}
Zig는 **튼튼**하고, **최적화**된, **재사용 가능**한 소프트웨어를 관리하기 위한 범용 프로그래밍 언어 및 툴체인입니다.
{{< /slogan >}}

{{< flexrow class="container" style="padding: 20px 0; justify-content: space-between;" >}}
{{% div class="features" %}}

# ⚡ 간결한 언어
당신의 프로그래밍 언어 지식을 디버깅할게 아니라 애플리케이션을 디버깅하는데 집중하십시오.

- 숨겨진 제어 흐름 없음.
- 숨겨진 메모리 할당 없음.
- 전처리기, 매크로 없음.

# ⚡ Comptime
컴파일 타임의 코드 실행 및 지연 평가에 기반한 메타프로그래밍에 대한 새로운 접근.

- 컴파일 타임에 어떤 함수든 호출하세요.
- 런타임 오버헤드 없이 타입을 값으로 변환하세요.
- Comptime은 대상 아키텍쳐를 에뮬레이트 합니다.

# ⚡ 성능, 안정성을 만나다
모든 오류 조건을 처리할 수 있는 빠르고 명료한 코드를 작성하십시오.

- 오류 처리 로직을 우아하게 가이드 해줍니다.
- 설정 가능한 런타임 체크는 성능과 안정성 보장 사이에서 균형을 맞춰줄 것입니다.
- 벡터 타입을 이용하여 SIMD 명령어를 이식 가능하게 표현하십시오.

{{% flexrow style="justify-content:center;" %}}
{{% div %}}
<h1>
    <a href="learn/overview/" class="button" style="display: inline;">심층 개요</a>
</h1>
{{% /div %}}
{{% div  style="margin-left: 5px;" %}}
<h1>
    <a href="learn/samples/" class="button" style="display: inline;">더 많은 코드 샘플</a>
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
# 분산된 Zig 커뮤니티
누구나 커뮤니티가 모일만한 자신만의 공간을 만들어 유지해도 좋습니다.
"공식"이나 "비공식"이란 개념은 없습니다만, 각 공간에는 관리자와 규칙이 있습니다.

<div style="">
<h1>
	<a href="https://github.com/ziglang/zig/wiki/Community" class="button" style="display: inline;">전체 커뮤니티 보기</a>
</h1>
</div>
{{% /div %}}
{{< /flexrow >}}
<div style="height: 50px;"></div>

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div class="main-development-message" %}}
# 주요 개발
Zig의 저장소는 [https://github.com/ziglang/zig](https://github.com/ziglang/zig)에 있으며, 이곳에서 이슈 트래킹과 제안에 대한 논의를 진행합니다.
기여자는 Zig의 [행동 강령](https://github.com/ziglang/zig/blob/master/CODE_OF_CONDUCT.md)을 따라야 합니다.
{{% /div %}}
{{% div style="width:40%" %}}
<img src="/zero.svg" style="max-height: 200px">
{{% /div %}}
{{< /flexrow >}}
{{% /div %}}
{{% /div %}}


{{% div class="container" style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="Zig Software Foundation" %}}
## ZSF는 501(c)(3) 비영리 기업입니다.

Zig Software Foundation은 언어에 대한 개발을 지원하는 것을 목표로 Zig의 창시자인 Andrew Kelley에 의해 2020년에 설립된 비영리 기업입니다. 현재 ZSF는 소수의 주요 기여자의 작업에 대해 경쟁력 있는 수준의 비용을 제공할 수 있습니다. 앞으로 더 많은 주요 기여자들에게 이런 제공을 확대하길 바랍니다.

Zig Software Foundation은 기부로 유지됩니다.

<h1>
	<a href="zsf/" class="button" style="display:inline;">더 보기</a>
</h1>
{{% /div %}}


{{< div class="alt-background" style="padding: 20px 0;">}}
{{% div class="container" title="Sponsors" %}}
# 기업 후원
다음의 기업들이 Zig Software foundation에 직접적인 재정적 지원을 하고 있습니다.

{{% sponsor-logos "monetary" %}}
 <a href="https://pex.com" rel="noopener nofollow" target="_blank"><picture>
   <picture>
     <source srcset="/pex-white.svg" media="(prefers-color-scheme: dark)">
     <img src="/pex-dark.svg">
   </picture>
 </a>
{{% /sponsor-logos %}}

# GitHub Sponsors
[Zig를 후원](zsf/)해 주시는 분들께 감사드리며, 이 프로젝트는 기업 주주가 아닌 오픈소스 커뮤니티에 책임이 있습니다. 특히, 다음의 훌륭한 분들께서 Zig에 매달 $200 이상을 후원하고 계십니다:

- [**Lager Data**](https://www.lagerdata.com)
- [**drfuchs**](https://github.com/drfuchs)
- [Karrick McDermott](https://github.com/karrick)
- [Raph Levien](https://raphlinus.github.io/)
- [ryanworl](https://github.com/ryanworl)
- [Stevie Hryciw](https://www.hryx.net/)
- [Josh Wolfe](https://github.com/thejoshwolfe)
- [SkunkWerks, GmbH](https://skunkwerks.at/)
- [Derek Collison](https://github.com/derekcollison)
- [NATS.io](https://github.com/nats-io)
- Joran Dirk Greef
- Simon A. Nielsen Knights
- Stephen Gutekanst
- Mataroa.blog
- Yong-Yue 
- Vulfox

이 섹션은 매달 초 갱신됩니다.
{{% /div %}}
{{< /div >}}
























