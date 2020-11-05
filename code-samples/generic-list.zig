pub fn List(comptime T: type) type {
    return struct {
        data: T,
        next: @This(),
    };
}
