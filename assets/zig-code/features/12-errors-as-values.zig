// zig-doctest: build --fail discarded --name discard
const std = @import("std");

pub fn main() void {
    _ = std.fs.cwd().openFile("does_not_exist/foo.txt", .{});
}
