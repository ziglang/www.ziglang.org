const std = @import("std");
const assert = std.debug.assert;
const expect = std.testing.expect;
test "initialize sentinel-terminated array" {
    // the sentinel does not need to match the value
    const arr: [2:0]u8 = @splat(10);
    try expect(arr[0] == 10);
    try expect(arr[1] == 10);
    try expect(arr[2] == 0);
}
test "initialize runtime array" {
    var runtime_known: u8 = undefined;
    runtime_known = 123;
    // the operand can be runtime-known, giving a runtime-known array
    const arr: [2]u8 = @splat(runtime_known);
    try expect(arr[0] == 123);
    try expect(arr[1] == 123);
}
test "initialize zero-length sentinel-terminated array" {
    var runtime_known: u8 = undefined;
    runtime_known = 123;
    const arr: [0:10]u8 = @splat(runtime_known);
    // the operand was runtime-known, but since the array length was zero, the result is comptime-known
    comptime assert(arr[0] == 10);
}

// test
