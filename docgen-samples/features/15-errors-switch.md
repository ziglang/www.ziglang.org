{#code_begin|test_err#}
const std = @import("std");

test "switch on error" {
    const result = parseInt("hi", 10) catch |err| switch (err) {};
}

fn parseInt(buf: []const u8, radix: u8) !u64 {
    var x: u64 = 0;

    for (buf) |c| {
        const digit = try charToDigit(c);

        if (digit >= radix) {
            return error.DigitExceedsRadix;
        }

        x = try std.math.mul(u64, x, radix);
        x = try std.math.add(u64, x, digit);
    }

    return x;
}

fn charToDigit(c: u8) !u8 {
    const value = switch (c) {
        '0'...'9' => c - '0',
        'A'...'Z' => c - 'A' + 10,
        'a'...'z' => c - 'a' + 10,
        else => return error.InvalidCharacter,
    };

    return value;
}
{#code_end#}