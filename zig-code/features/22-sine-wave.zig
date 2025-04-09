const c = @cImport(@cInclude("soundio/soundio.h"));
const std = @import("std");

fn sio_err(err: c_int) !void {
    switch (err) {
        c.SoundIoErrorNone => {},
        c.SoundIoErrorNoMem => return error.NoMem,
        c.SoundIoErrorInitAudioBackend => return error.InitAudioBackend,
        c.SoundIoErrorSystemResources => return error.SystemResources,
        c.SoundIoErrorOpeningDevice => return error.OpeningDevice,
        c.SoundIoErrorNoSuchDevice => return error.NoSuchDevice,
        c.SoundIoErrorInvalid => return error.Invalid,
        c.SoundIoErrorBackendUnavailable => return error.BackendUnavailable,
        c.SoundIoErrorStreaming => return error.Streaming,
        c.SoundIoErrorIncompatibleDevice => return error.IncompatibleDevice,
        c.SoundIoErrorNoSuchClient => return error.NoSuchClient,
        c.SoundIoErrorIncompatibleBackend => return error.IncompatibleBackend,
        c.SoundIoErrorBackendDisconnected => return error.BackendDisconnected,
        c.SoundIoErrorInterrupted => return error.Interrupted,
        c.SoundIoErrorUnderflow => return error.Underflow,
        c.SoundIoErrorEncodingString => return error.EncodingString,
        else => return error.Unknown,
    }
}

var seconds_offset: f32 = 0;

fn write_callback(
    maybe_outstream: ?[*]c.SoundIoOutStream,
    frame_count_min: c_int,
    frame_count_max: c_int,
) callconv(.C) void {
    _ = frame_count_min;
    const outstream: *c.SoundIoOutStream = &maybe_outstream.?[0];
    const layout = &outstream.layout;
    const float_sample_rate: f32 = @floatFromInt(outstream.sample_rate);
    const seconds_per_frame = 1.0 / float_sample_rate;
    var frames_left = frame_count_max;

    while (frames_left > 0) {
        var frame_count = frames_left;

        var areas: [*]c.SoundIoChannelArea = undefined;
        sio_err(c.soundio_outstream_begin_write(
            maybe_outstream,
            @ptrCast(&areas),
            &frame_count,
        )) catch |err| std.debug.panic("write failed: {s}", .{@errorName(err)});

        if (frame_count == 0) break;

        const pitch = 440.0;
        const radians_per_second = pitch * 2.0 * std.math.pi;
        var frame: c_int = 0;
        while (frame < frame_count) : (frame += 1) {
            const float_frame: f32 = @floatFromInt(frame);
            const sample = std.math.sin((seconds_offset + float_frame *
                seconds_per_frame) * radians_per_second);
            {
                var channel: usize = 0;
                while (channel < @as(usize, @intCast(layout.channel_count))) : (channel += 1) {
                    const channel_ptr = areas[channel].ptr;
                    const sample_ptr: *f32 = @alignCast(@ptrCast(&channel_ptr[@intCast(areas[channel].step * frame)]));
                    sample_ptr.* = sample;
                }
            }
        }
        const float_frame_count: f32 = @floatFromInt(frame_count);
        seconds_offset += seconds_per_frame * float_frame_count;

        sio_err(c.soundio_outstream_end_write(maybe_outstream)) catch |err| std.debug.panic("end write failed: {s}", .{@errorName(err)});

        frames_left -= frame_count;
    }
}

pub fn main() !void {
    const soundio = c.soundio_create();
    defer c.soundio_destroy(soundio);

    try sio_err(c.soundio_connect(soundio));

    c.soundio_flush_events(soundio);

    const default_output_index = c.soundio_default_output_device_index(soundio);
    if (default_output_index < 0) return error.NoOutputDeviceFound;

    const device = c.soundio_get_output_device(soundio, default_output_index) orelse return error.OutOfMemory;
    defer c.soundio_device_unref(device);

    std.debug.print("Output device: {s}\n", .{device.*.name});

    const outstream = c.soundio_outstream_create(device) orelse return error.OutOfMemory;
    defer c.soundio_outstream_destroy(outstream);

    outstream.*.format = c.SoundIoFormatFloat32NE;
    outstream.*.write_callback = write_callback;

    try sio_err(c.soundio_outstream_open(outstream));

    try sio_err(c.soundio_outstream_start(outstream));

    while (true) c.soundio_wait_events(soundio);
}

// syntax
