---
title: 시작하기
mobile_menu_title: "시작하기"
toc: true
---


## tag된 릴리즈냐 nightly build냐?
Zig는 아직 v1.0에 도달하지 못했으며, 현재 릴리즈는 LLVM의 새 릴리즈와 묶여 최대 6개월의 주기를 갖습니다.
실질적으로, **Zig는 현재 개발 속도를 고려했을 때 릴리즈마다 간극이 크고 이전 버전이 못쓰게 되는 경향이 있습니다**.

tag된 버전의 Zig로 테스트 해보는 것은 좋으나, Zig가 맘에 들어서 더 깊게 써보고 싶으시다면,
**nightly build로 업그레이드 하시길 권유** 드리는데, 왜냐하면
도움을 구하기 쉬울 것이기 때문입니다: [zig.guide](https://zig.guide) 같은 대부분의
커뮤니티와 사이트들은 상기의 이유로 master 브랜치를 사용합니다.

좋은 소식은, Zig 릴리즈는 시스템의 어디에 놓아도 되는 자체 포함 파일이기 때문에, 버전간 전환은 매우 쉬우며 심지어 여러 버전의 Zig를 한 시스템에 설치하는 것도 가능하다는 겁니다.


## Zig 설치하기
### 직접 다운로드
Zig를 얻는 가장 간단한 방법입니다. [다운로드](/download) 페이지에서 Zig 압축파일을 다운 받아,
원하는 디렉토리에 풀어놓은 뒤 어느 위치에서나 `zig`를 실행할 수 있도록 `PATH`에 추가합니다.

#### Windows에서 PATH 설정하기
Windows에서 PATH를 설정하려면 Powershell에서 다음 중 **하나**의 코드를 실행하십시오.
시스템 전체에 적용되길 바라는지 (Powershell을 관리자 권한으로 실행해야 함)
또는 한 유저에게만 적용되길 바라는지에 따라 선택하되, **설치된 Zig의 위치에 맞춰 코드 내 경로를 수정합니다**.
`C:` 앞에 있는 `;`는 오타가 아니니 주의하세요.

시스템 전체 (**관리자로 실행**된 Powershell):
```
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "Machine") + ";C:\your-path\zig-windows-x86_64-your-version",
   "Machine"
)
```

사용자 단위 (Powershell):
```
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\your-path\zig-windows-x86_64-your-version",
   "User"
)
```
다 끝나면, Powershell을 새로 실행합니다.

#### Linux, macOS, BSD에서 PATH 설정하기
PATH 환경 변수에 Zig 바이너리 파일의 위치를 추가합니다.

이는 보통 쉘 시작 스크립트(`.profile`, `.zshrc`, ...)에 export 한 줄을 추가함으로써 해결 가능합니다.
```bash
export PATH=$PATH:~/path/to/zig
```
다 끝나면, 시작 스크립트를 `source` 하거나 쉘을 새로 시작하십시오.




### 패키지 매니저
#### Windows
[Chocolatey](https://chocolatey.org/packages/zig)에서 Zig를 사용하실 수 있습니다.
```
choco install zig
```

#### macOS

**Homebrew**  
최신 tag된 릴리즈:
```
brew install zig
```

**MacPorts**
```
port install zig
```
#### Linux
Zig는 또한 Linux의 다양한 패키지 매니저에서 지원됩니다. [여기](https://github.com/ziglang/zig/wiki/Install-Zig-from-a-Package-Manager)에서
최신 목록을 확인할 수 있으나 일부 패키지는 옛날 버전을 가지고 있을 수 있으니 주의하십시오.

### 소스로 빌드하기
[여기](https://github.com/ziglang/zig/wiki/Building-Zig-From-Source)에서
Linux, macOS 및 Windows에서 소스로 Zig를 빌드하는 방법에 대한 정보를 찾으실 수 있습니다.

## 추천 도구
### 구문 강조기와 LSP
모든 주요 텍스트 편집기는 Zig의 구문 강조를 지원합니다.
일부는 편집기에 포함되어 있고, 일부는 플러그인을 따로 설치해야 합니다.

Zig와 텍스트 편집기의 깊은 연동에 관심이 있으시다면,
[zigtools/zls](https://github.com/zigtools/zls)를 참고하십시오.

다른 것은 뭐가 있는지 궁금하시다면, [도구](../tools/) 섹션을 참고하세요.

## Hello World 실행
설치 과정을 제대로 마쳤다면, 쉘에서 Zig 컴파일러를 실행할 수 있을겁니다.
첫 Zig 프로그램을 만들어 테스트 해봅시다!

프로젝트 디렉토리로 이동하여 다음을 실행합니다:
```bash
mkdir hello-world
cd hello-world
zig init
```

그러면 다음과 같이 출력됩니다:
```
info: Created build.zig
info: Created src/main.zig
info: Next, try `zig build --help` or `zig build run`
```

`zig build run`을 실행하면 실행파일을 컴파일하고 실행하여, 다음과 같은 결과를 출력합니다:
```
info: All your codebase are belong to us.
```

축하합니다, Zig 설치를 성공적으로 마쳤습니다!

## 다음 단계
**[배우기](../) 섹션에 있는 다른 자료를 확인** 하고, Zig 버전에 맞는 문서를 찾고
(주의: nightly build는 `master` 문서를 사용해야 합니다), [zig.guide](https://zig.guide)를 읽어보십시오.

Zig는 젊은 프로젝트이며 안타깝게도 아직 모든 것에 대한 충분한 문서와 학습 자료를 만들 역량이 되지 않습니다.
그러므로 [Zig 커뮤니티에 가입하여](https://github.com/ziglang/zig/wiki/Community)
막히는게 있을 때에는 도움을 구하고, [Zig SHOWTIME](https://zig.show) 같은 계획을 확인하세요.

마지막으로, Zig를 사용하는 것이 즐거우며 Zig의 개발 속도를 높이는데 도움을 주고 싶으시다면, [Zig Software Foundation에 기부하는 것을 고려해 주세요](../../zsf).
<img src="/heart.svg" style="vertical-align:middle; margin-right: 5px">.
