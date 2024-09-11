const std = @import("std");
const Person = @import("person").Person;

pub fn main() !void {
    const p: Person = .{};
    try std.io.getStdOut().writer().print("Hello {any}\n", .{p});
}

// syntax
