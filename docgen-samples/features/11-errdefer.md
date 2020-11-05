{#code_begin|syntax#}
const Device = struct {
    name: []u8,

    fn create(allocator: *Allocator, id: u32) !Device {
        const device = try allocator.create(Device);
        errdefer allocator.destroy(device);

        device.name = try std.fmt.allocPrint(allocator, "Device(id={})", id);
        errdefer allocator.free(device.name);

        if (id == 0) return error.ReservedDeviceId;

        return device;
    }
};
{#code_end#}