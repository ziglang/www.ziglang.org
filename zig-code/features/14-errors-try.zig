const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("does_not_exist/foo.txt", .{});
    defer file.close();
    try file.writeAll("all your codebase are belong to us\n");
}

// exe=fail
