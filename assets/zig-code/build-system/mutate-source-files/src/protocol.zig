// zig-doctest: syntax --name protocol
pub const Header = extern struct {
    magic: u64,
    width: u32,
    height: u32,
};
