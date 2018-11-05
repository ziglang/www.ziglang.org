const std = @import("std");
const path = std.os.path;
const mem = std.mem;

pub fn main() !void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    var arena = std.heap.ArenaAllocator.init(&direct_allocator.allocator);
    defer arena.deinit();

    const allocator = &arena.allocator;

    const download_dir = "www" ++ path.sep_str ++ "download";
    try std.os.makePath(allocator, download_dir);
    const out_file = download_dir ++ path.sep_str ++ "index.html";
    const in_file = "src" ++ path.sep_str ++ "download" ++ path.sep_str ++ "index.html";

    const in_contents = try std.io.readFileAlloc(allocator, in_file);

    var vars = try std.os.getEnvMap(allocator);

    var buffer = try std.Buffer.initSize(allocator, 0);
    errdefer buffer.deinit();

    const State = enum.{
        Start,
        OpenBrace,
        VarName,
        EndBrace,
    };
    const out = &std.io.BufferOutStream.init(&buffer).stream;
    var state = State.Start;
    var var_name_start: usize = undefined;
    var line: usize = 1;
    for (in_contents) |byte, index| {
        switch (state) {
            State.Start => switch (byte) {
                '{' => {
                    state = State.OpenBrace;
                },
                else => try out.writeByte(byte),
            },
            State.OpenBrace => switch (byte) {
                '{' => {
                    state = State.VarName;
                    var_name_start = index + 1;
                },
                else => {
                    try out.writeByte('{');
                    try out.writeByte(byte);
                    state = State.Start;
                },
            },
            State.VarName => switch (byte) {
                '}' => {
                    const var_name = in_contents[var_name_start..index];
                    if (vars.get(var_name)) |value| {
                        if (mem.endsWith(u8, var_name, "BYTESIZE")) {
                            const trimmed = mem.trim(u8, value, " \r\n");
                            try out.print("{Bi1}", try std.fmt.parseInt(u64, trimmed, 10));
                        } else {
                            try out.write(value);
                        }
                    } else {
                        std.debug.warn("line {}: missing variable: {}\n", line, var_name);
                        try out.write("(missing)");
                    }
                    state = State.EndBrace;
                },
                else => {},
            },
            State.EndBrace => switch (byte) {
                '}' => {
                    state = State.Start;
                },
                else => {
                    std.debug.warn("line {}: invalid byte: '0x{x}'", line, byte);
                    std.os.exit(1);
                },
            },
        }
        if (byte == '\n') {
            line += 1;
        }
    }
    try std.io.writeFile(out_file, buffer.toSliceConst());
}
