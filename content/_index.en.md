---
title: Home
mobile_menu_title: "Home"
---
{{< slogan get_started="GET STARTED" docs="Documentation" notes="Changes" lang="en" >}}
Zig is a general-purpose programming language and toolchain for maintaining **robust**, **optimal** and **reusable** software.  
{{< /slogan >}}

{{< flexrow class="container" style="padding: 20px 0; justify-content: space-between;" >}}
{{% div class="features" %}}

# ⚡ A Simple Language
Focus on debugging your application rather than debugging your programming language knowledge.

- No hidden control flow.
- No hidden memory allocations.
- No preprocessor, no macros. 

# ⚡ Comptime
A fresh approach to metaprogramming based on compile-time code execution and lazy evaluation.

- Call any function at compile-time.
- Manipulate types as values without runtime overhead.
- Comptime emulates the target architecture.

# ⚡ Maintain it with Zig
Incrementally improve your C/C++/Zig codebase.

- Use Zig as a zero-dependency, drop-in C/C++ compiler that supports cross-compilation out-of-the-box.
- Leverage `zig build` to create a consistent development environment across all platforms.
- Add a Zig compilation unit to C/C++ projects; cross-language LTO is enabled by default.

{{% flexrow style="justify-content:center;" %}}
{{% div %}}
<h1>
    <a href="learn/overview/" class="button" style="display: inline;">In-depth overview</a>
</h1>
{{% /div %}}
{{% div  style="margin-left: 5px;" %}}
<h1>
    <a href="learn/samples/" class="button" style="display: inline;">More code samples</a>
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
Contributors are expected to follow Zig's [Code of Conduct](https://github.com/ziglang/zig/blob/master/.github/CODE_OF_CONDUCT.md).
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
























