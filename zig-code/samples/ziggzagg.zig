const std = @import("std");

pub fn main() !void {
    var i: usize = 1;
    while (i <= 16) : (i += 1) {
        if (i % 15 == 0) {
            try std.log.info("ZiggZagg", .{});
        } else if (i % 3 == 0) {
            try std.log.info("Zigg", .{});
        } else if (i % 5 == 0) {
            try std.log.info("Zagg", .{});
        } else {
            try std.log.info("{d}", .{i});
        }
    }
}

// exe=succeed
