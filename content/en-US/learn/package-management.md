[← Back to Learn](/learn/)

# Zig Package Management Guide

A comprehensive guide to understanding and using Zig’s decentralized, content-addressed package manager.

## Table of Contents

- [Introduction](#introduction)
- [Core Concepts](#core-concepts)
- [Getting Started](#getting-started)
- [Common Workflows](#common-workflows)
- [Advanced Usage](#advanced-usage)
- [Reference](#reference)

## Introduction

### What Makes Zig’s Package Manager Different?

Most package managers rely on central registries and version numbers to manage dependencies. Zig takes a fundamentally different approach: it’s **decentralized** and **content-addressed**.

**Traditional approach:**

```json
{
  "lodash": "^4.17.21",  // Might resolve to 4.17.22 tomorrow
  "react": "~18.2.0"     // Could be any 18.2.x version
}
```

**Zig’s approach:**

```zig
.dependencies = .{
    .lodash = .{
        .url = "https://example.com/lodash-4.17.21.tar.gz",
        .hash = "12203f48c6cf5de9a2d4558209f72b18e2c9f3f8e6c6f71450628dffbfce00b40", // Always gets EXACTLY this code
    },
}
```

### Key Benefits

**Reproducible Builds**: The same `build.zig.zon` file always resolves to identical source code across all environments and developers.

**Enhanced Security**: Every package download is verified against its cryptographic hash, preventing tampering or unexpected changes.

**No Single Point of Failure**: No central registry means packages can be hosted anywhere. The hash guarantees integrity regardless of the source.

**Automatic Caching**: Packages are cached by their content hash, so multiple projects automatically share identical dependencies.

**No Version Conflicts**: Zig intentionally doesn’t support version ranges or constraints. Each dependency is pinned to exact content via its hash.

## Core Concepts

### Content-Addressed Packages

In Zig, **the content hash IS the version**. When code changes, the hash changes, making it effectively a different package. This eliminates the ambiguity of semantic versioning ranges.

```zig
// These are completely different packages to Zig
.my_lib_v1 = .{ .hash = "12203f48c6cf5de9a2d4558209f72b18e2c9f3f8e6c6f71450628dffbfce00b40" },
.my_lib_v2 = .{ .hash = "1220e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" },
```

### The Package Manifest

Every Zig project with dependencies has a `build.zig.zon` file that serves as the package manifest. This file defines:

- Project metadata (name, version)
- Minimum required Zig version
- Which files belong to the package
- External dependencies

### Dependencies vs Modules

- **Dependency**: An external package listed in `build.zig.zon`
- **Module**: A Zig code unit that can be imported with `@import()`
- A dependency can expose one or more modules to your code

### The Global Cache

Zig maintains a global cache of all downloaded packages:

- **Linux/macOS**: `~/.cache/zig/`
- **Windows**: `%LOCALAPPDATA%\zig\cache\`

Packages are stored by their hash, enabling automatic sharing across projects.

## Getting Started

### Your First Dependency

Let’s add a real dependency to understand the workflow. We’ll use the popular Zig Zap web framework.

**Step 1: Add the dependency**

```bash
zig fetch --save https://github.com/zigzap/zap/archive/v0.1.7-pre.tar.gz
```

This command:

1. Downloads the package from the URL
1. Computes its SHA-256 hash
1. Creates or updates `build.zig.zon` with the dependency entry

**Step 2: Examine the generated manifest**

After running `zig fetch`, your `build.zig.zon` will look like this:

```zig
.{
    .name = "my-project",
    .version = "0.1.0",
    .minimum_zig_version = "0.11.0",
    .paths = .{
        "build.zig",
        "build.zig.zon", 
        "src",
    },
    .dependencies = .{
        .zap = .{
            .url = "https://github.com/zigzap/zap/archive/v0.1.7-pre.tar.gz",
            .hash = "122036b1948caa15c2c9054286b3057877f7b152a5102c9262511bf89554dc836ee5",
        },
    },
}
```

**Step 3: Wire up the dependency in your build script**

Edit your `build.zig` to make the dependency available to your code:

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "my-app",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Get the dependency and add its module to our executable
    const zap_dep = b.dependency("zap", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("zap", zap_dep.module("zap"));

    b.installArtifact(exe);
}
```

**Step 4: Use the dependency in your code**

Now you can import and use Zap in your Zig source files:

```zig
const std = @import("std");
const zap = @import("zap");

pub fn main() !void {
    std.log.info("Using Zap framework!", .{});
    // Use Zap functionality here
}
```

### Understanding the Manifest Structure

Let’s break down each part of `build.zig.zon`:

```zig
.{
    // Project identification
    .name = "my-project",              // Your package name
    .version = "0.1.0",                // Informational only - not used for resolution
    .minimum_zig_version = "0.11.0",   // Minimum required Zig version

    // Package contents (what gets hashed)
    .paths = .{
        "build.zig",                   // Build script
        "build.zig.zon",               // This manifest
        "src",                         // Source directory
        "README.md",                   // Documentation
        "LICENSE",                     // License file
        // Add other files/directories as needed
    },

    // External dependencies
    .dependencies = .{
        .dependency_name = .{
            .url = "https://...",      // Where to download
            .hash = "1220...",         // Content verification (SHA-256)
        },
    },
}
```

**Important**:

- The `.paths` field determines what gets included when another project depends on yours
- Only list files that are part of your package’s public interface
- The `.version` field is purely informational and not used for dependency resolution

## Common Workflows

### Supported Package Formats

Zig’s package manager supports various URL schemes and archive formats:

**URL Schemes:**

- `https://` - Standard HTTPS downloads
- `http://` - HTTP downloads (use HTTPS when possible)
- `file://` - Local file URLs
- `git+https://` - Git repositories over HTTPS
- `git+http://` - Git repositories over HTTP

**Archive Formats:**

- `.tar` - Uncompressed tarballs
- `.tar.gz` / `.tgz` - Gzip-compressed tarballs
- `.tar.xz` / `.txz` - XZ-compressed tarballs
- `.tar.zst` / `.tzst` - Zstandard-compressed tarballs
- `.zip` - ZIP archives
- `.jar` - Java archives (treated as ZIP)

**Git References:**
When using git URLs, specify the commit, tag, or branch using a fragment:

```bash
zig fetch --save "git+https://github.com/user/repo#v1.0.0"     # Tag
zig fetch --save "git+https://github.com/user/repo#main"       # Branch
zig fetch --save "git+https://github.com/user/repo#abc123"     # Commit
```

### Adding Dependencies

**Method 1: Using `zig fetch` (Recommended)**

```bash
# Automatically downloads, hashes, and updates build.zig.zon
zig fetch --save https://github.com/user/package/archive/v1.0.0.tar.gz
```

**Method 2: Manual entry with hash discovery**

1. Add to build.zig.zon dependencies with empty hash:

```zig
.my_package = .{
    .url = "https://github.com/user/package/archive/v1.0.0.tar.gz",
    .hash = "", // Leave empty initially
},
```

1. Run `zig build` to get the correct hash:

```
error: dependency 'my_package' is missing hash field
    note: expected .hash = "1220a7d6be5b6b069e5c7f5e2b37d87d565f11d9f9c6f9d8c68c0f3e7a2b3c4d5e6f7",
```

1. Copy the hash from the error message into your build.zig.zon

### Updating Dependencies

To update to a newer version:

```bash
# Update existing dependency to new version
zig fetch --save=my_package https://github.com/user/package/archive/v2.0.0.tar.gz
```

This updates both the URL and hash for the named dependency.

### Local Development

When developing a library alongside an application that uses it, use path dependencies:

```zig
.dependencies = .{
    .my_local_lib = .{
        .path = "../my-library-project",
        // No .hash needed - changes are reflected immediately
    },
}
```

Path dependencies are perfect for:

- Developing multiple related packages
- Testing unreleased changes
- Monorepo setups

**Note**: When switching from a path dependency to a URL dependency, you must add the hash field.

### Version Management Strategy

Since Zig uses content hashes instead of semantic versions:

**For Library Authors:**

- Use clear, descriptive Git tags (e.g., `v1.0.0`)
- Provide stable URLs for releases (GitHub releases, not branch archives)
- Document breaking changes in release notes
- Include the hash in release notes for user convenience

**For Library Users:**

- Pin to specific release URLs (avoid branch URLs like `main.tar.gz`)
- Use path dependencies during active development
- Test thoroughly before updating hashes
- Keep a changelog of dependency updates

### Troubleshooting Hash Mismatches

If you see a hash mismatch error:

```
error: hash mismatch: manifest declares
122036b1948caa15c2c9054286b3057877f7b152a5102c9262511bf89554dc836ee5
but the fetched package has  
1220a7d6be5b6b069e5c7f5e2b37d87d565f11d9f9c6f9d8c68c0f3e7a2b3c4d5e6f7
```

This is a **security feature**, not a bug. It means:

1. The content at the URL has changed
1. Someone may have updated the package
1. The URL might point to different content (e.g., a branch was updated)

**To fix:**

- Verify the URL is correct and points to the intended version
- Copy the correct hash from the error message into your `build.zig.zon`
- Consider if you actually want to update to this new version

### Understanding Package Hashes

**How Hashes Are Computed:**

1. Package is downloaded and extracted to a temporary directory
1. Manifest (`build.zig.zon`) inclusion rules are applied
1. Excluded files are deleted
1. Hash is computed from remaining files in deterministic order
1. Package is moved to cache using the computed hash

**What Affects the Hash:**

- File contents and paths (normalized across platforms)
- Symbolic link targets
- Which files are included via the `.paths` field
- The hash does NOT include empty directories
- File permissions are normalized (only executable bit matters)

**Debugging Hash Mismatches:**
If you get unexpected hash mismatches:

- Ensure the URL points to a stable release, not a branch
- Check if upstream retagged or modified the release
- Verify your `.paths` field includes all necessary files
- Use `tar -tvf archive.tar.gz` to inspect archive contents

### Common Errors and Solutions

**Error: “unable to fetch package: HTTP request failed”**

- Check your internet connection
- Verify the URL is accessible
- Some corporate networks may block certain domains

**Error: “dependency ‘foo’ has no module named ‘bar’”**

- Check the dependency’s build.zig to see what modules it exports
- Module names don’t always match package names

**Error: “url field is missing an explicit ref”**

- Git URLs require a specific commit/tag/branch
- Use the fragment syntax: `git+https://example.com/repo#ref`
- Zig will suggest the current HEAD commit if you omit it

**Error: “unable to unpack tarball”**

- File may already exist (e.g., case-sensitive filesystem issues)
- Corrupt archive or network issues
- Check file permissions in the package

**Error: “package not found at path”**

- Only occurs with `--offline` mode
- Package hasn’t been fetched yet
- Run without `--offline` to fetch it

**Error: “invalid fingerprint”**

- Package name doesn’t match the fingerprint
- If forking, use the suggested fingerprint value
- For new packages, add the suggested fingerprint

## Advanced Usage

### Package Identity and Fingerprints

Zig uses a fingerprint system to verify package identity across versions:

```zig
.{
    .name = "my_package",
    .version = "1.0.0",
    .fingerprint = 0x1234567890abcdef,  // Unique package identifier
    // ...
}
```

**How Fingerprints Work:**

- Generated from the package name using a deterministic algorithm
- Ensures the same logical package maintains its identity across versions
- Prevents name squatting and typosquatting attacks
- If omitted, Zig will suggest the correct value in error messages

**When to Use:**

- Always include for packages you publish
- For new packages, use the suggested value from Zig’s error message
- For forked packages, generate a new fingerprint from your package name

### Creating Your Own Package

Any Zig project can be a package. The key is exposing modules in your `build.zig`:

```zig
// In your library's build.zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    // Standard target and optimization setup
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create a module that other projects can import
    _ = b.addModule("my_library", .{
        .root_source_file = b.path("src/lib.zig"),
    });

    // Optional: Add unit tests
    const lib_tests = b.addTest(.{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_tests = b.addRunArtifact(lib_tests);
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_lib_tests.step);
}
```

**Package Layout:**

```
my-library/
├── build.zig          # Build script with module definition
├── build.zig.zon      # Package manifest
├── src/
│   ├── lib.zig        # Main library interface
│   └── internal/      # Internal implementation
├── LICENSE
└── README.md
```

**Your library’s build.zig.zon:**

```zig
.{
    .name = "my_library",
    .version = "1.0.0",
    .minimum_zig_version = "0.11.0",
    .paths = .{
        "build.zig",
        "build.zig.zon",
        "src",
        "LICENSE",
        "README.md",
    },
    .dependencies = .{
        // Your library's dependencies here
    },
}
```

### Platform-Specific Dependencies

Handle platform-specific dependencies in your build.zig:

```zig
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "my-app",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Only add Windows-specific dependency on Windows
    if (target.result.os.tag == .windows) {
        const win_dep = b.dependency("windows_utils", .{
            .target = target,
            .optimize = optimize,
        });
        exe.root_module.addImport("win_utils", win_dep.module("utils"));
    }

    b.installArtifact(exe);
}
```

### Composite Packages

Create packages that bundle functionality from multiple dependencies:

```zig
// In a "web_toolkit" package's build.zig
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Get sub-dependencies
    const json_dep = b.dependency("json_parser", .{
        .target = target,
        .optimize = optimize,
    });
    const http_dep = b.dependency("http_client", .{
        .target = target,
        .optimize = optimize,
    });

    // Create composite module that imports both
    const web_module = b.addModule("web_toolkit", .{
        .root_source_file = b.path("src/toolkit.zig"),
    });
    
    // Add the sub-dependencies to our module
    web_module.addImport("json", json_dep.module("json"));
    web_module.addImport("http", http_dep.module("http"));
}
```

Users of `web_toolkit` get both JSON and HTTP functionality through a single import.

### Dependency Resolution

Zig handles dependency conflicts through content-addressing:

**Diamond Dependencies:**

```
Your Project
├── Library A (uses JSON parser hash: 1220abc...)
└── Library B (uses JSON parser hash: 1220def...)
```

Both JSON parser versions coexist in the cache. Each library gets exactly the version it expects. There’s no version conflict because they’re different packages with different hashes.

**Transitive Dependencies:**
You don’t need to manually manage transitive dependencies. If Library A depends on Library B, and you depend on Library A, Zig automatically fetches Library B when needed.

## Reference

### Command Reference

**Package Management Commands:**

```bash
# Add new dependency
zig fetch --save <url>

# Update existing dependency  
zig fetch --save=<dependency_name> <new_url>

# List all available build options
zig build --help

# Build without network access (uses cached packages)
zig build --offline
```

**Cache Management:**

```bash
# View cache location
zig env

# Clear entire cache (safe - will re-download as needed)
rm -rf ~/.cache/zig/  # Linux/macOS
rmdir /s %LOCALAPPDATA%\zig\cache  # Windows
```

### build.zig.zon Schema

```zig
.{
    // Required fields
    .name = "string",                // Package name (max 32 chars)
    .version = "string",             // Version string (max 32 chars, informational only)
    
    // Recommended fields
    .minimum_zig_version = "string", // Minimum Zig version (e.g., "0.11.0")
    
    // Optional fields
    .fingerprint = 0x...,            // Package identity verification (64-bit hex)
    .paths = .{                      // Files/dirs included in package hash
        "string",                    // File or directory path
        // ... more paths
    },
    
    .dependencies = .{
        .dep_name = .{
            // Remote dependency
            .url = "string",         // Download URL (required)
            .hash = "string",        // SHA-256 hash (required)
        },
        .local_dep = .{
            // Local dependency
            .path = "string",        // Relative path to local package
        },
    },
}
```

**Field Constraints:**

- Maximum manifest file size: 10 MB
- Package name: max 32 characters, must be valid Zig identifier
- Version string: max 32 characters
- Hash: SHA-256 hex string (64 characters)

### Cache Structure

```
~/.cache/zig/
├── p/                           # Packages (content-addressed)
│   ├── 122036b1948c.../         # Package by hash
│   ├── 1220e3b0c442.../         # Another package
│   └── ...
├── h/                           # HTTP cache
├── tmp/                         # Temporary files
└── ...
```

Each package directory contains the extracted contents of the downloaded archive, stored by its content hash.

### Special File Handling

**Executable Detection:**
Zig automatically detects and sets executable permissions based on file content:

- Files with shebang (`#!`) headers
- ELF binaries (Linux/Unix executables)
- Mach-O binaries (macOS executables)

This ensures executables work correctly regardless of how they were packaged.

**Empty Directories:**

- Empty directories are automatically excluded from packages
- Only directories containing files are preserved
- This keeps packages clean and reduces size

**Symbolic Links:**

- Symlinks are preserved within packages
- Links pointing outside the package directory cause errors
- Path separators in symlinks are normalized across platforms

### Best Practices

**For Library Authors:**

1. **Stable Releases**: Always tag releases and use GitHub releases or similar stable URLs
1. **Clear Module Names**: Use descriptive module names that match your package purpose
1. **Minimal Dependencies**: Keep your dependency tree shallow
1. **Documentation**: Include hash values in release notes
1. **Semantic Versioning**: Use it for human understanding, even though Zig doesn’t use it for resolution
1. **Test Coverage**: Include comprehensive tests that run with `zig build test`

**For Library Users:**

1. **Pin Specific Versions**: Always use tagged release URLs, not branch references
1. **Verify Updates**: Test thoroughly when updating dependency hashes
1. **Document Changes**: Keep a log of dependency updates and why they were made
1. **Local Development**: Use path dependencies when actively developing related packages
1. **Security**: Verify URLs before trusting hash values from error messages

**For Teams:**

1. **Version Control**: Always commit `build.zig.zon` to your repository
1. **Never Commit Cache**: Add `zig-cache/` to `.gitignore`
1. **Consistent Naming**: Establish naming conventions for dependencies
1. **Update Policy**: Define when and how to update dependencies
1. **Mirror Critical Dependencies**: Consider hosting critical dependencies yourself
1. **CI/CD**: Ensure your CI system has network access or pre-populated caches

### Limitations and Considerations

1. **No Version Ranges**: This is by design - every dependency is exact
1. **No Central Registry**: You must find package URLs yourself
1. **No Automatic Updates**: Updates are always explicit and manual
1. **URL Stability**: Depends on package authors maintaining stable URLs
1. **Network Required**: First fetch always requires network access
1. **File Size Limits**:
- Maximum manifest size: 10 MB
- No hard limit on package size, but be considerate
1. **Path Restrictions**:
- Package names: max 32 characters
- Must be valid Zig identifiers
- No absolute paths in dependencies
1. **Platform Differences**:
- Path separators are normalized
- Only executable bit is preserved (not full Unix permissions)
- Symlinks must point within the package

### Security Considerations

1. **Always verify URLs** before trusting hashes from untrusted sources
1. **Use HTTPS** URLs whenever possible
1. **Pin specific releases** rather than branch references
1. **Review dependencies** before adding them
1. **The hash protects integrity**, not authenticity - verify the source

These limitations are intentional design decisions that prioritize reproducibility and simplicity over convenience features found in other package managers.
