---
title: "快速入门"
mobile_menu_title: "快速入门"
toc: true
---

{{% div class="box thin"%}}
**<center>Apple Silicon 用户须知</center>**
Zig 有实验性的代码签名支持。你将能够在你的 M1 Mac 上使用 Zig，但目前获得 arm64 macOS 版 Zig 的唯一方法是自己编译。请务必查看[从源码开始构建](#从源码构建)部分。
{{% /div %}}


## 选择带标签的版本还是夜间构建版本？
Zig 还没有达到 v1.0 版本，目前的发布周期与 LLVM 的新版本挂钩，其发布周期约为 6 个月。
从实际情况来看，**Zig 的发布往往相隔很远，以目前的开发速度，最终会变得陈旧**。

使用有标签的版本来体验 Zig 是可以的，但如果你决定喜欢 Zig 并想深入了解，**我们鼓励你升级到夜间构建**，主要是因为这样你会更容易得到帮助：大多数社区和像 [ziglearn.org](https://ziglearn.org) 这样的网站都会跟踪主分支，原因如上所述。

好消息是，从一个 Zig 版本切换到另一个版本非常容易，甚至可以在系统中同时存在多个版本。Zig 发布的版本是独立的存档，可以放在系统的任何地方。


## 安装 Zig
### 直接下载
这是最直接的获取 Zig 的方法：从[下载](../../download)页面为你的平台获取压缩包，
将其解压到一个目录，将其添加到你的 PATH 环境变量里，然后就可在任意位置调用 Zig 了。

#### 在 Windows 上设置 PATH
要在 Windows 上设置 PATH，请在 PowerShell 中运行以下**任一**代码片段:
选择你是要在系统级别上应用此更改 （需要在有管理员权限的情况下运行 PowerShell）
还是只针对你使用的用户，**并确保更改代码以指向 Zig 所在的位置**。
注意在 `C:` 之前的 `;` 不是拼写错误。

系统级安装 (**管理员** PowerShell):
```
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "Machine") + ";C:\your-path\zig-windows-x86_64-your-version",
   "Machine"
)
```

用户级安装 (PowerShell):
```
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\your-path\zig-windows-x86_64-your-version",
   "User"
)
```
运行完毕后重启你的 PowerShell 实例。

#### 在 Linux, macOS, BSD 上设置 PATH
将 zig 二进制镜像的位置添加到 PATH 环境变量中。

这通常可以通过在你的 shell 启动脚本（`.profile`，`.zshrc` 等）中添加一个 export 语句来实现
```bash
export PATH=$PATH:~/path/to/zig
```
完成后，可以 `source` 你的启动文件或者重启 shell。




### 包管理
#### Windows
Zig 在 [Chocolatey](https://chocolatey.org/packages/zig) 上可用。
```
choco install zig
```

#### macOS

**Homebrew**
注意: Homebrew 暂时还没有支持 Apple Silicon 的 bottle 。如果你拥有 M1 Mac，你必须从源码构建。

最新带标签版本：
```
brew install zig
```

从 github master 分支获取的最新构建：
```
brew install zig --HEAD
```

**MacPorts**
```
port install zig
```
#### Linux
Zig 也存在于许多 Linux 的包管理器中。 [从这里（英文）](https://github.com/ziglang/zig/wiki/Install-Zig-from-a-Package-Manager)
可以找到一个更新的列表，但请记住，一些软件包管理器可能会附带过时的 Zig 版本。

### 从源码构建
[从这里（英文）](https://github.com/ziglang/zig/wiki/Building-Zig-From-Source)
可以找到更多关于如何在 Linux、macOS 和 Windows 下从源代码构建 Zig 的信息。

## 推荐工具
### 语法高亮和语言服务器（LSP）
所有主流文本编辑器都有 Zig 的语法高亮支持。
有一些内置此功能，有一些需要安装插件。

如果你对 Zig 和你的编辑器的深度整合感兴趣，可以查看 [zigtools/zls](https://github.com/zigtools/zls)。

如果你对其他的工具感兴趣，可以查看[工具](../tools/)章节。

## 运行“你好，世界”
如果你正确地完成了安装过程，你现在应该可以从你的 shell 中运行 Zig 编译器了。
让我们创建你的第一个 Zig 程序来测试一下吧！

导航到你存放项目的文件夹，运行：
```bash
mkdir hello-world
cd hello-world
zig init-exe
```

这将会输出：
```
info: Created build.zig
info: Created src/main.zig
info: Next, try `zig build --help` or `zig build run`
```

运行 `zig build run` 应该会编译成可执行文件并运行，最终结果将会是：
```
info: All your codebase are belong to us.
```

恭喜你，你已经安装好了 Zig！

## 下一步
**查看在[学习](../)章节的其他资源**，请务必找到与你的 Zig 版本匹配的文档。
（注意：夜间构建版本应该使用主分支上的文档），并考虑读一读 [ziglearn.org](https://ziglearn.org)。

Zig 是一个年轻的项目，遗憾的是我们还没有能力为所有的东西制作大量的文档和学习材料。因此，你应该考虑[加入其中一个 Zig 社区](https://github.com/ziglang/zig/wiki/Community)
以在遇到问题是获取帮助，同样也可以看看 [Zig SHOWTIME（英文）](https://zig.show)。

最后，如果你喜欢 Zig 并想加速 Zig 开发，[考虑捐助 Zig 软件基金会](../../zsf)
<img src="/heart.svg" style="vertical-align:middle; margin-right: 5px">。
