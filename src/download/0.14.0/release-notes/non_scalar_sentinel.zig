export fn foo() void {
    const S = struct { a: u32 };
    var arr = [_]S{ .{ .a = 1 }, .{ .a = 2 } };
    const s = arr[0..1 :.{ .a = 1 }];
    _ = s;
}

// test_error=non-scalar sentinel
