const std = @import("std");
const zine = @import("zine");
const assert = std.debug.assert;

/// Used for updating the langref documentation version links of old releases.
const releases = [_][]const u8{
    "0.1.0",
    "0.1.1",
    "0.2.0",
    "0.3.0",
    "0.4.0",
    "0.5.0",
    "0.6.0",
    "0.7.0",
    "0.7.1",
    "0.8.0",
    "0.8.1",
    "0.9.0",
    "0.9.1",
    "0.10.0",
    "0.10.1",
    "0.11.0",
    "0.12.0",
    "0.12.1",
    "0.13.0",
};

pub fn build(b: *std.Build) void {
    var build_assets = std.ArrayList(zine.BuildAsset).init(b.allocator);
    runZigScripts(b, &build_assets, "assets/zig-code", &.{
        "index.zig",

        "samples/0-windows-msgbox.zig",
        "samples/1-memory-leak.zig",
        "samples/2-c-interop.zig",
        "samples/3-ziggzagg.zig",
        "samples/4-generic-type.zig",
        "samples/5-curl.zig",

        "build-system/1-simple-executable/build.zig",
        "build-system/1-simple-executable/hello.zig",
        "build-system/10-release/build.zig",
        "build-system/10-release/hello.zig",
        "build-system/10.5-system-tool/build.zig",
        "build-system/10.5-system-tool/src/main.zig",
        "build-system/11-zig-tool/build.zig",
        "build-system/11-zig-tool/tools/word_select.zig",
        "build-system/11-zig-tool/src/main.zig",
        "build-system/12-embedfile/build.zig",
        "build-system/12-embedfile/tools/word_select.zig",
        "build-system/12-embedfile/src/main.zig",
        "build-system/13-import/build.zig",
        "build-system/13-import/src/main.zig",
        "build-system/13-import/tools/generate_struct.zig",
        "build-system/2-user-provided-options/build.zig",
        "build-system/2-user-provided-options/example.zig",
        "build-system/3-standard-config-options/build.zig",
        "build-system/3-standard-config-options/hello.zig",
        "build-system/conditional-compilation/build.zig",
        "build-system/conditional-compilation/app.zig",
        "build-system/convenience-run-step/build.zig",
        "build-system/convenience-run-step/hello.zig",
        "build-system/dynamic-library/build.zig",
        "build-system/mutate-source-files/build.zig",
        "build-system/mutate-source-files/tools/proto_gen.zig",
        "build-system/mutate-source-files/src/main.zig",
        "build-system/mutate-source-files/src/protocol.zig",
        "build-system/simple-static-library/build.zig",
        "build-system/simple-static-library/fizzbuzz.zig",
        "build-system/simple-static-library/demo.zig",
        "build-system/system-libraries/build.zig",
        "build-system/unit-testing/build.zig",
        "build-system/unit-testing/main.zig",
        "build-system/unit-testing-skip-foreign/build.zig",
        "build-system/write-files/build.zig",
        "build-system/write-files/src/main.zig",

        "features/1-integer-overflow.zig",
        "features/2-integer-overflow-runtime.zig",
        "features/3-undefined-behavior.zig",
        "features/4-hello.zig",
        "features/5-global-variables.zig",
        "features/6-null-to-ptr.zig",
        "features/7-optional-syntax.zig",
        "features/8-optional-orelse.zig",
        "features/9-optional-if.zig",
        "features/10-optional-while.zig",
        "features/11-errdefer.zig",
        "features/12-errors-as-values.zig",
        "features/13-errors-catch.zig",
        "features/14-errors-try.zig",
        "features/15-errors-switch.zig",
        "features/16-unreachable.zig",
        "features/17-stack-traces.zig",
        "features/18-types.zig",
        "features/19-generics.zig",
        "features/20-reflection.zig",
        "features/21-comptime.zig",
        "features/22-sine-wave.zig",
        "features/23-math-test.zig",
        "features/24-build.zig",
        "features/25-all-bases.zig",
        "features/26-build.zig",
    });

    zine.multilingualWebsite(b, .{
        .debug = true,
        .host_url = "https://ziglang.org",
        .i18n_dir_path = "i18n",
        .layouts_dir_path = "layouts",
        .assets_dir_path = "assets",
        .build_assets = build_assets.items,
        .static_assets = &.{
            "external-link-dark.svg",
            "external-link-light.svg",
            "heart.svg",
            "zig-logo-dark.svg",
            "zig-logo-light.svg",
            "zig-performance-logo-dark.svg",
            "zig-performance-logo-light.svg",

            "sponsors/Blacksmith_Logo-Black.svg",
            "sponsors/Blacksmith_Logo-White.svg",
            "sponsors/coil-logo-black.svg",
            "sponsors/coil-logo-white.svg",
            "sponsors/dropbox.png",
            "sponsors/lavatech.png",
            "sponsors/pex-dark.svg",
            "sponsors/pex-white.svg",
            "sponsors/scaleway.png",
            "sponsors/shiguredo-logo-dark.svg",
            "sponsors/shiguredo-logo-light.svg",
            "sponsors/tb-logo-black.png",
            "sponsors/tb-logo-white.png",
            "sponsors/zml.svg",

            "chart/chartist-1.3.0.css",
            "chart/chartist-1.3.0.umd.js",
        },
        .locales = &.{
            .{
                .code = "en-US",
                .name = "English (original)",
                .site_title = "Zig Programming Language",
                .content_dir_path = "content/en-US",
                .output_prefix_override = "",
            },
            .{
                .code = "it-IT",
                .name = "Italiano",
                .site_title = "Zig Programming Language",
                .content_dir_path = "content/it-IT",
            },
            .{
                .code = "de-DE",
                .name = "Deutsch",
                .site_title = "Zig Programmiersprache",
                .content_dir_path = "content/de-DE",
            },
            .{
                .code = "uk-UA",
                .name = "Українська",
                .site_title = "Zig Programming Language",
                .content_dir_path = "content/uk-UA",
            },
            .{
                .code = "ja-JP",
                .name = "日本語",
                .site_title = "Zig Programming Language",
                .content_dir_path = "content/ja-JP",
            },
            .{
                .code = "zh-CN",
                .name = "中文",
                .site_title = "Zig 编程语言",
                .content_dir_path = "content/zh-CN",
            },
        },
    });
}

fn runZigScripts(
    b: *std.Build,
    assets: *std.ArrayList(zine.BuildAsset),
    assets_dir_path: []const u8,
    paths: []const []const u8,
) void {
    const doctest_dep = b.dependency("doctest", .{
        .target = b.host,
        .optimize = .Debug,
    });
    const doctest_exe = doctest_dep.artifact("doctest");
    assets.ensureUnusedCapacity(paths.len) catch unreachable;

    for (paths) |p| {
        const lp = runSingleZigScript(b, doctest_exe, assets_dir_path, p);
        assets.appendAssumeCapacity(.{
            .name = p,
            .lp = lp,
        });
    }
}

fn runSingleZigScript(
    b: *std.Build,
    doctest_exe: *std.Build.Step.Compile,
    assets_dir_path: []const u8,
    path: []const u8,
) std.Build.LazyPath {
    const cmd = b.addRunArtifact(doctest_exe);
    cmd.addArgs(&.{
        "--zig",        b.graph.zig_exe,
        "--cache-root", b.cache_root.path orelse ".",
    });
    if (b.zig_lib_dir) |p| {
        cmd.addArg("--zig-lib-dir");
        cmd.addDirectoryArg(p);
    }
    cmd.addArgs(&.{"-i"});
    cmd.addFileArg(b.path(b.fmt("{s}/{s}", .{ assets_dir_path, path })));

    cmd.addArgs(&.{"-o"});
    return cmd.addOutputFileArg(path);
}

pub fn oldBuild(b: *std.Build) void {
    const doctest_dep = b.dependency("doctest", .{
        .target = b.host,
        .optimize = .Debug,
    });
    const doctest_exe = doctest_dep.artifact("doctest");
    const docgen_exe = doctest_dep.artifact("docgen");

    installReleaseNotes(b, doctest_exe, docgen_exe);

    for (releases) |release| {
        const input_wf = b.addWriteFiles();
        _ = input_wf.add("vernav", verNavHtml(b.allocator, release));

        const docgen_cmd = b.addRunArtifact(docgen_exe);
        docgen_cmd.addArgs(&.{"--code-dir"});
        docgen_cmd.addDirectoryArg(input_wf.getDirectory());

        docgen_cmd.addFileArg(b.path(b.fmt("src/documentation/{s}/index.html", .{release})));
        const generated = docgen_cmd.addOutputFileArg("index.html");

        const copy_generated = b.addWriteFiles();
        copy_generated.addCopyFileToSource(generated, b.fmt("content/documentation/{s}/index.html", .{release}));

        b.getInstallStep().dependOn(&copy_generated.step);
    }
}

fn installReleaseNotes(
    b: *std.Build,
    doctest_exe: *std.Build.Step.Compile,
    docgen_exe: *std.Build.Step.Compile,
) void {
    const dirname = "src/download/0.13.0/release-notes";
    var dir = b.build_root.handle.openDir(dirname, .{ .iterate = true }) catch |err| {
        std.debug.panic("unable to open '{s}' directory: {s}", .{ dirname, @errorName(err) });
    };
    defer dir.close();

    var wf = b.addWriteFiles();
    var it = dir.iterateAssumeFirstIteration();
    while (it.next() catch @panic("failed to read dir")) |entry| {
        if (std.mem.startsWith(u8, entry.name, ".") or entry.kind != .file)
            continue;

        const out_basename = b.fmt("{s}.out", .{std.fs.path.stem(entry.name)});
        const cmd = b.addRunArtifact(doctest_exe);
        cmd.addArgs(&.{
            "--zig",        b.graph.zig_exe,
            // TODO: enhance doctest to use "--listen=-" rather than operating
            // in a temporary directory
            "--cache-root", b.cache_root.path orelse ".",
        });
        if (b.zig_lib_dir) |p| {
            cmd.addArg("--zig-lib-dir");
            cmd.addDirectoryArg(p);
        }
        cmd.addArgs(&.{"-i"});
        cmd.addFileArg(b.path(b.fmt("{s}/{s}", .{ dirname, entry.name })));

        cmd.addArgs(&.{"-o"});
        _ = wf.addCopyFile(cmd.addOutputFileArg(out_basename), out_basename);
    }

    const docgen_cmd = b.addRunArtifact(docgen_exe);
    docgen_cmd.addArgs(&.{"--code-dir"});
    docgen_cmd.addDirectoryArg(wf.getDirectory());

    docgen_cmd.addFileArg(b.path("src/download/0.13.0/release-notes.html"));
    const generated = docgen_cmd.addOutputFileArg("release-notes.html");

    const copy_generated = b.addWriteFiles();
    copy_generated.addCopyFileToSource(generated, "content/download/0.13.0/release-notes.html");

    b.getInstallStep().dependOn(&copy_generated.step);
}

fn verNavHtml(arena: std.mem.Allocator, active_release: []const u8) []const u8 {
    errdefer @panic("OOM");
    var buffer: std.ArrayListUnmanaged(u8) = .{};
    var found = false;
    for (releases, 0..) |release, i| {
        if (std.mem.eql(u8, release, active_release)) {
            found = true;
            try buffer.appendSlice(arena, release);
            try buffer.appendSlice(arena, " |\n");
        } else {
            skip: {
                if (i + 1 >= releases.len) break :skip;
                const next_str = releases[i + 1];
                const this_parsed = std.SemanticVersion.parse(release) catch
                    std.debug.panic("bad semantic version: '{s}'", .{release});
                const next_parsed = std.SemanticVersion.parse(next_str) catch
                    std.debug.panic("bad semantic version: '{s}'", .{next_str});
                if (next_parsed.major == this_parsed.major and
                    next_parsed.minor == this_parsed.minor)
                {
                    assert(next_parsed.patch > this_parsed.patch);
                    continue;
                }
            }

            try buffer.appendSlice(arena, "<a href=\"https://ziglang.org/documentation/");
            try buffer.appendSlice(arena, release);
            try buffer.appendSlice(arena, "/\">");
            try buffer.appendSlice(arena, release);
            try buffer.appendSlice(arena, "</a> |\n");
        }
    }
    if (!found) std.debug.panic("release '{s}' not found", .{active_release});

    try buffer.appendSlice(arena, "<a href=\"https://ziglang.org/documentation/master/\">master</a>");

    return buffer.items;
}
