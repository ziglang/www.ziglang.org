{#code_begin|exe|reflection#}
const std = @import("std");

const Header = struct {
    magic: u32,
    name: []const u8,
};

pub fn main() void {
    printInfoAboutStruct(Header);
}

fn printInfoAboutStruct(comptime T: type) void {
    const info = @typeInfo(T);
    inline for (info.Struct.fields) |field| {
        std.debug.print(
            "{} has a field called {} with type {}\n",
            .{
                @typeName(T),
                field.name,
                @typeName(field.field_type),
            },
        );
    }
}
{#code_end#}