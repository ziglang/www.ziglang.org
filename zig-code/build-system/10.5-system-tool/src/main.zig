const std = @import("std");

pub fn main() !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    const self_exe_dir_path = try std.fs.selfExeDirPathAlloc(arena);
    var self_exe_dir = try std.fs.cwd().openDir(self_exe_dir_path, .{});
    defer self_exe_dir.close();

    const word = try self_exe_dir.readFileAlloc(arena, "word.txt", 1000);

    var stdout_buffer: [1000]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    try stdout.print("Hello {s}\n", .{word});
    try stdout.flush();
}

// syntax
