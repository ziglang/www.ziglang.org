---
title: 홈
mobile_menu_title: "홈"
---
{{< slogan get_started="시작하기" docs="개발 문서" notes="변경 사항" lang="ko" >}}
Zig는 **견고**하고, **최적화**된, 그리고 **재사용이 가능한** 소프트웨어의 개발 및 관리를 위한 범용 프로그래밍 언어 및 툴체인입니다.
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
- 여러 언어를 대상으로 링크 타임 최적화 (LTO) 기능을 지원하여, C/C++ 프로젝트에 Zig 컴파일 단위를 추가 가능.

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
{{% div class="container"  style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="커뮤니티" %}}

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div style="width:25%" %}}
<img src="/ziggy.svg" style="max-height: 200px">
{{% /div %}}

{{% div class="community-message" %}}
# Zig의 다양한 커뮤니티를 만나보세요
누구든지 자유롭게 모일 수 있는 커뮤니티를 만들고 관리할 수 있습니다.  
"공식"이나 "비공식" 커뮤니티라는 개념은 따로 없지만, 각 커뮤니티마다 관리자와 규칙이 모두 다르니 주의해주세요.

<div style="">
<h1>
	<a href="https://github.com/ziglang/zig/wiki/Community" class="button" style="display: inline;">모든 커뮤니티 보기</a>
</h1>
</div>
{{% /div %}}
{{< /flexrow >}}
<div style="height: 50px;"></div>

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div class="main-development-message" %}}
# 주요 개발 커뮤니티
Zig의 저장소 주소는 [https://github.com/ziglang/zig](https://github.com/ziglang/zig)이며, 여기에서 이슈 트래킹과 제안에 대한 논의를 진행합니다.
프로젝트에 기여하실 분들은 Zig의 [행동 지침](https://github.com/ziglang/zig/blob/master/.github/CODE_OF_CONDUCT.md)을 따라야 합니다.
{{% /div %}}
{{% div style="width:40%" %}}
<img src="/zero.svg" style="max-height: 200px">
{{% /div %}}
{{< /flexrow >}}
{{% /div %}}
{{% /div %}}


{{% div class="container" style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="Zig Software Foundation" %}}
## ZSF는 501(c)(3) 비영리 단체입니다.

Zig Software Foundation은 Zig를 만든 Andrew Kelley가 프로그래밍 언어의 개발을 지원하기 위해 2020년에 창립한 비영리 단체입니다. 현재, ZSF는 소수의 프로젝트 핵심 기여자에게만 회사 수준의 급여를 지급할 수 있는 상황입니다. 저희는 미래에 더 많은 프로젝트 핵심 기여자분들에게 급여를 지급할 수 있기를 바라고 있습니다.

Zig Software Foundation은 기부금으로만 운영됩니다.

<h1>
	<a href="zsf/" class="button" style="display:inline;">자세히 알아보기</a>
</h1>
{{% /div %}}


{{< div class="alt-background" style="padding: 20px 0;">}}
{{% div class="container" title="후원자" %}}
# 기업 후원
아래 기업은 Zig Software Foundation을 재정적으로 지원해주고 있는 기업입니다.

{{% sponsor-logos "monetary" %}}
 <a href="https://pex.com" rel="noopener nofollow" target="_blank"><picture>
   <picture>
     <source srcset="/pex-white.svg" media="(prefers-color-scheme: dark)">
     <img src="/pex-dark.svg">
   </picture>
 </a>
{{% /sponsor-logos %}}

# GitHub 후원자
[Zig를 후원](zsf/)해주시는 분들 덕분에, 이 프로젝트는 기업의 주주가 아닌 오픈 소스 커뮤니티가 운영하고 있습니다. 특히, 아래 명단에 있는 분들은 Zig를 매달 $200 이상 후원하고 있습니다:

{{< ghsponsors >}}

이 섹션은 매달 초에 갱신됩니다.
{{% /div %}}
{{< /div >}}
