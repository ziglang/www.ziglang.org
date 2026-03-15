const win = @import("std").os.windows;

extern "user32" fn MessageBoxA(?win.HWND, [*:0]const u8, [*:0]const u8, u32) callconv(.winapi) i32;

pub fn main() !void {
    _ = MessageBoxA(null, "world!", "Hello", 0);
}

// test
