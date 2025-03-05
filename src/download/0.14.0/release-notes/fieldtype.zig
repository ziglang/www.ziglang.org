const assert = @import("std").debug.assert;
test "struct @FieldType" {
    const S = struct { a: u32, b: f64 };
    comptime assert(@FieldType(S, "a") == u32);
    comptime assert(@FieldType(S, "b") == f64);
}
test "union @FieldType" {
    const U = union { a: u32, b: f64 };
    comptime assert(@FieldType(U, "a") == u32);
    comptime assert(@FieldType(U, "b") == f64);
}
test "tagged union @FieldType" {
    const U = union(enum) { a: u32, b: f64 };
    comptime assert(@FieldType(U, "a") == u32);
    comptime assert(@FieldType(U, "b") == f64);
}

// test
