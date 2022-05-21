---
title: 家
mobile_menu_title: "家"
---
{{< slogan get_started="GET STARTED" docs="文档" notes="变化" lang="zh" >}}
Zig 是一种通用的编程语言和工具链，用于维护**健壮**、**最优**和**可重用**的软件  
{{< /slogan >}}

{{< flexrow class="container" style="padding: 20px 0; justify-content: space-between;" >}}
{{% div class="features" %}}

# ⚡ 一种简单的语言
专注于调试你的应用程序，而不是调试你的编程语言知识

- 没有隐式控制流
- 没有隐式内存分配
- 没有预处理器，没有宏

# ⚡ 编译期代码执行
基于编译期代码执行和惰性求值的全新元编程方法

- 编译期调用任意函数
- 在没有运行时开销的情况下，将类型作为值进行操作
- 编译期模拟目标架构

# ⚡ 用Zig维护代码
逐步改善你的C/C++/Zig代码库

- 将Zig作为一个零依赖的，支持开箱即用交叉编译的C/C++编译器
- 利用 `zig build`在所有平台上创建一个一致的开发环境
- 在C/C++项目中添加一个Zig编译单元，跨语言LTO默认启用

{{% flexrow style="justify-content:center;" %}}
{{% div %}}

<h1>
    <a href="learn/overview/" class="button" style="display: inline;">深入了解</a>
</h1>

{{% /div %}}
{{% div  style="margin-left: 5px;" %}}

<h1>
    <a href="learn/samples/" class="button" style="display: inline;">更多示例</a>
</h1>

{{% /div %}}
{{% /flexrow %}}
{{% /div %}}
{{< div class="codesample" >}}

{{% zigdoctest "assets/zig-code/index.zig" %}}

{{< /div >}}
{{< /flexrow >}}

{{% div class="alt-background" %}}
{{% div class="container"  style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="社区" %}}

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div style="width:25%" %}}
<img src="/ziggy.svg" style="max-height: 200px">
{{% /div %}}

{{% div class="community-message" %}}
# Zig社区是去中心化的
任何人都可以自由创建和维护自己的社区空间  
没有“官方”或“非官方”的概念，但是，每个社区都有自己的版主和规则

<div style="">
<h1>
	<a href="https://github.com/ziglang/zig/wiki/Community" class="button" style="display: inline;">查看所有社区</a>
</h1>
</div>

{{% /div %}}
{{< /flexrow >}}

<div style="height: 50px;"></div>

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div class="main-development-message" %}}

# 发展情况
Zig 源码仓库可以在 [https://github.com/ziglang/zig](https://github.com/ziglang/zig)找到，我们同时也在那里跟踪问题和讨论提案  
贡献者应该遵守Zig的[行为准则](https://github.com/ziglang/zig/blob/master/.github/CODE_OF_CONDUCT.md)
{{% /div %}}
{{% div style="width:40%" %}}
<img src="/zero.svg" style="max-height: 200px">
{{% /div %}}
{{< /flexrow >}}
{{% /div %}}
{{% /div %}}


{{% div class="container" style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="Zig软件基金会" %}}
## ZSF是一家501(c)(3)非营利公司

Zig软件基金会是由Zig的创造者Andrew Kelley在2020年成立的非营利性公司，目标是支持该语言的发展。目前，ZSF能够以有竞争力的价格向少数核心贡献者提供有偿工作。我们希望在未来能够将这一优惠扩大到更多的核心贡献者 

Zig 软件基金会由捐款维持

<h1>
	<a href="zsf/" class="button" style="display:inline;">了解更多</a>
</h1>

{{% /div %}}


{{< div class="alt-background" style="padding: 20px 0;">}}
{{% div class="container" title="赞助商" %}}
# 企业赞助商
以下公司为 Zig 软件基金会提供直接的资金支持

{{% sponsor-logos "monetary" %}}
 <a href="https://pex.com" rel="noopener nofollow" target="_blank"><picture>

   <picture>
     <source srcset="/pex-white.svg" media="(prefers-color-scheme: dark)">
     <img src="/pex-dark.svg">
   </picture>
 </a>
{{% /sponsor-logos %}}

# GitHub 赞助
感谢那些[赞助Zig](zsf/)的人，该项目对开源社区而不是公司股东负责。特别地，这些好心人以200$/月或更高的金额赞助了Zig：

{{< ghsponsors >}}

本表单将会在每月初更新
{{% /div %}}
{{< /div >}}
