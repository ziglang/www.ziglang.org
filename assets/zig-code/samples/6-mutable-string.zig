// zig-doctest: syntax
const print = @import("std").debug.print;

pub fn main() void {
    var arr = ("hello world").*;
    print("{s}\n", .{arr}); // prints "hello world"

    arr[0] = 'c';
    print("{s}\n", .{arr}); // prints "cello world"

    arr[1..5].* = ("the quick brown fox")[11..15].*;
    print("{s}\n", .{arr}); // prints "crown world"

    arr[6..].* = ("jewel").*;
    print("{s}\n", .{arr}); // prints "crown jewel"
}
