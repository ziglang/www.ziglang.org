const std = @import("std");

pub fn main() void {
    const file: std.fs.File = std.fs.cwd().openFile("does_not_exist/foo.txt", .{}) catch |err| label: {
        std.debug.print("unable to open file: {}\n", .{err});
        break :label .stderr();
    };
    file.writeAll("all your codebase are belong to us\n") catch return;
}

// exe=succeed
