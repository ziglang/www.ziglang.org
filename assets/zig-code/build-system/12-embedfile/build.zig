// zig-doctest: build-system -- -Dlanguage=ja --summary all
const std = @import("std");

pub fn build(b: *std.Build) void {
    const lang = b.option([]const u8, "language", "language of the greeting") orelse "en";
    const tool = b.addExecutable(.{
        .name = "word_select",
        .root_source_file = .{ .path = "tools/word_select.zig" },
    });

    const tool_step = b.addRunArtifact(tool);
    tool_step.addArg("--input-file");
    tool_step.addFileArg(.{ .path = "tools/words.json" });
    tool_step.addArg("--output-file");
    const output = tool_step.addOutputFileArg("word.txt");
    tool_step.addArgs(&.{ "--lang", lang });

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "hello",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    exe.addAnonymousModule("word", .{ .source_file = output });

    b.installArtifact(exe);
}
