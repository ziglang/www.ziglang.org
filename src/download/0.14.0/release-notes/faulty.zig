/// `ptr` points to a `[len]u32`.
pub const BufferA = extern struct { ptr: ?[*]u32 = null, len: usize = 0 };
// The default values given above are trying to make the buffer default to "empty".
var empty_buf_a: BufferA = .{};
// However, they violate the guidance given in the language reference, because you can write this:
var bad_buf_a: BufferA = .{ .len = 10 };
// That's not safe, because the `null` and `0` defaults are "tied together". Decl literals make it
// convenient to represent this case correctly:

/// `ptr` points to a `[len]u32`.
pub const BufferB = extern struct {
    ptr: ?[*]u32,
    len: usize,
    pub const empty: BufferB = .{ .ptr = null, .len = 0 };
};
// We can still easily create an empty buffer:
var empty_buf_b: BufferB = .empty;
// ...but the language no longer hides incorrect field overrides from us!
// If we want to override a field, we'd have to specify both, making the error obvious:
var bad_buf_b: BufferB = .{ .ptr = null, .len = 10 }; // clearly wrong!

// syntax
