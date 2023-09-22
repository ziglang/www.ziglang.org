// zig-doctest: syntax

const win = @import("std").os.windows;

extern "user32" fn MessageBoxA(?win.HWND, [*:0]const u8, [*:0]const u8, win.UINT) callconv(win.WINAPI) i32;

pub fn main() !void {
    _ = MessageBoxA(null, "world!", "Hello", 0);
}
