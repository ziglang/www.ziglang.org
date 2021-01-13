---
title: Getting Started
mobile_menu_title: "Getting Started"
toc: true
---

{{% div class="box thin"%}}
**<center>Note for Apple Silicon users</center>**
Zig has experimental support for code signing. You will be able to use Zig with your M1 Mac,
but the only way at the moment to get Zig for arm64 macOS is to compile it yourself.
Make sure to check the [Building from source](#building-from-source) section.
{{% /div %}}


## Tagged release or nightly build?
Zig has not yet reached v1.0 and the current release cycle is tied to new releases of LLVM, which have a ~6 months cadence.
In practical terms, **Zig releases tend to be far apart and eventually become stale given the current speed of development**.

It's fine to evaluate Zig using a tagged version, but if you decide that you like Zig and 
want to dive deeper, **we encourage you to upgrade to a nightly build**, mainly because 
that way it will be easier for you to get help: most of the community and sites like 
[ziglearn.org](https://ziglearn.org) track the master branch for the reasons stated above.

The good news is that it's very easy to switch from one Zig version to another, or even have multiple versions present on the system at the same time: Zig releases are self-contained archives that can be placed anywhere in your system.


## Installing Zig
### Direct download
This is the most straight-forward way of obtaining Zig: grab a Zig bundle for your platform from the [Downloads](/download) page,
extract it in a directory and add it to your `PATH` to be able to call `zig` from any location.

#### Setting up PATH on Windows
To setup your path on Windows run **one** of the following snippets of code in a Powershell instance.
Choose if you want to apply this change on a system-wide level (requires running Powershell with admin privileges)
or just for your user, and **make sure to change the snippet to point at the location where your copy of Zig lies**.
The `;` before `C:` is not a typo.

System wide (**admin** Powershell):
```
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "Machine") + ";C:\your-path\zig-windows-x86_64-your-version",
   "Machine"
)
```

User level (Powershell):
```
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\your-path\zig-windows-x86_64-your-version",
   "User"
)
```
After you're done, restart your Powershell instance.

#### Setting up PATH on Linux, macOS, BSD
Add the location of your zig binary to your PATH environment variable.

This is generally done by adding an export line to your shell startup script (`.profile`, `.zshrc`, ...)
```bash
export PATH=$PATH:~/path/to/zig
```
After you're done, either `source` your startup file or restart your shell.




### Package managers
#### Windows
Zig is available on [Chocolatey](https://chocolatey.org/packages/zig).
```
choco install zig
```

#### macOS

**Homebrew**  
NOTE: Homebrew doesn't have a bottle for Apple Silicon yet. If you have a M1 Mac, you must build Zig from source.

Latest tagged release:
```
brew install zig
```

Latest build from Git master branch:
```
brew install zig --HEAD
```

**MacPorts**
```
port install zig
```
#### Linux
Zig is also present in many package managers for Linux. [Here](https://github.com/ziglang/zig/wiki/Install-Zig-from-a-Package-Manager)
you can find an updated list but keep in mind that some packages might bundle outdated versions of Zig.

### Building from source
[Here](https://github.com/ziglang/zig/wiki/Building-Zig-From-Source) 
you can find more information on how to build Zig from source for Linux, macOS and Windows.

## Recommended tools
### Syntax Highlighters and LSP
All major text editors have syntax highlight support for Zig. 
Some bundle it, some others require installing a plugin.  

If you're interested in a deeper integration between Zig and your editor, 
checkout [zigtools/zls](https://github.com/zigtools/zls).

If you're interested in what else is available, checkout the [Tools](../tools/) section.

## Run Hello World
If you completed the installation process correctly, you should now be able to invoke the Zig compiler from your shell.  
Let's test this by creating your first Zig program!

Navigate to your projects directory and run:
```bash
mkdir hello-world
cd hello-world
zig init-exe
```

This should output:
```
info: Created build.zig
info: Created src/main.zig
info: Next, try `zig build --help` or `zig build run`
```

Running `zig build run` should then compile the executable and run it, ultimately  resulting in:
```
info: All your codebase are belong to us.
```

Congratulations, you have a working Zig installation!  

## Next steps
**Check out other resources present in the [Learn](../) section**, make sure to find the Documentation for your version
of Zig (note: nightly builds should use `master` docs) and consider giving [ziglearn.org](https://ziglearn.org) a read.

Zig is a young project and unfortunately we don't have yet the capacity to produce extensive documentation and learning
materials for everything, so you should consider [joining one of the existing Zig communities](https://github.com/ziglang/zig/wiki/Community)
to get help when you get stuck, as well as checking out initiatives like [Zig SHOWTIME](https://zig.show).

Finally, if you enjoy Zig and want to help speed up the development, [consider donating to the Zig Software Foundation](../../zsf)
<img src="../../heart.svg" style="vertical-align:middle; margin-right: 5px">.
