const std = @import("std");
const Person = @import("person").Person;

pub fn main() !void {
    const p: Person = .{};
    std.log.info("Hello {any}\n", .{p});
}

// syntax
