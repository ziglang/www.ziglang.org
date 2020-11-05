{#code_begin|exe|stack_traces#}
const std = @import("std");
const builtin = @import("builtin");

var address_buffer: [8]usize = undefined;

var trace1 = builtin.StackTrace{
    .instruction_addresses = address_buffer[0..4],
    .index = 0,
};

var trace2 = builtin.StackTrace{
    .instruction_addresses = address_buffer[4..],
    .index = 0,
};

pub fn main() void {
    foo();
    bar();

    std.debug.print("first one:\n", .{});
    std.debug.dumpStackTrace(trace1);
    std.debug.print("\n\nsecond one:\n", .{});
    std.debug.dumpStackTrace(trace2);
}

fn foo() void {
    std.debug.captureStackTrace(null, &trace1);
}

fn bar() void {
    std.debug.captureStackTrace(null, &trace2);
}
{#code_end#}