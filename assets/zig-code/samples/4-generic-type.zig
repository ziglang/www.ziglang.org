// zig-doctest: test --name queue
const std = @import("std");

pub fn Queue(comptime Child: type) type {
    return struct {
        const This = @This();
        const Node = struct {
            data: Child,
            next: ?*Node,
        };
        alloc: *std.mem.Allocator,
        start: ?*Node,
        end: ?*Node,

        pub fn init(alloc: *std.mem.Allocator) This {
            return This{
                .alloc = alloc,
                .start = null,
                .end = null,
            };
        }
        pub fn enqueue(this: *This, value: Child) !void {
            const node = try this.alloc.create(Node);
            node.* = .{ .data = value, .next = null };
            if (this.end) |end| end.next = node //
            else this.start = node;
            this.end = node;
        }
        pub fn dequeue(this: *This) ?Child {
            const start = this.start orelse return null;
            defer this.alloc.destroy(start);
            if (start.next) |next|
                this.start = next
            else {
                this.start = null;
                this.end = null;
            }
            return start.data;
        }
    };
}

test "queue" {
    const alloc = std.testing.allocator;

    var int_queue = Queue(i32).init(alloc);

    try int_queue.enqueue(25);
    try int_queue.enqueue(50);
    try int_queue.enqueue(75);
    try int_queue.enqueue(100);

    try std.testing.expectEqual(int_queue.dequeue(), 25);
    try std.testing.expectEqual(int_queue.dequeue(), 50);
    try std.testing.expectEqual(int_queue.dequeue(), 75);
    try std.testing.expectEqual(int_queue.dequeue(), 100);
    try std.testing.expectEqual(int_queue.dequeue(), null);

    try int_queue.enqueue(5);
    try std.testing.expectEqual(int_queue.dequeue(), 5);
    try std.testing.expectEqual(int_queue.dequeue(), null);
}
