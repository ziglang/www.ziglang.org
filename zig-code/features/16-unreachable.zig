const std = @import("std");

pub fn main() void {
    const file = std.fs.cwd().openFile("does_not_exist/foo.txt", .{}) catch unreachable;
    file.writeAll("all your codebase are belong to us\n") catch unreachable;
}

// exe=fail
