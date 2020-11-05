{#code_begin|exe_build_err|discard#}
const std = @import("std");

pub fn main() void {
    _ = std.fs.cwd().openFile("does_not_exist/foo.txt", .{});
}
{#code_end#}