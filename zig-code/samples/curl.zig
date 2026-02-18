//compile with `zig build-exe curl.zig -lcurl -lc $(pkg-config --cflags libcurl)`
const std = @import("std");
const cURL = @cImport({
    @cInclude("curl/curl.h");
});

const ResponseContext = struct {
    buffer: std.ArrayList(u8),
    allocator: std.mem.Allocator,
};

pub fn main() !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena_state.deinit();

    const allocator = arena_state.allocator();

    // global curl init, or fail
    if (cURL.curl_global_init(cURL.CURL_GLOBAL_ALL) != cURL.CURLE_OK)
        return error.CURLGlobalInitFailed;
    defer cURL.curl_global_cleanup();

    // curl easy handle init, or fail
    const handle = cURL.curl_easy_init() orelse return error.CURLHandleInitFailed;
    defer cURL.curl_easy_cleanup(handle);

    var response_ctx = ResponseContext{
        .buffer = std.ArrayList(u8).empty,
        .allocator = allocator,
    };

    // superfluous when using an arena allocator, but
    // important if the allocator implementation changes
    // defer response_ctx.buffer.deinit(allocator);

    // setup curl options
    if (cURL.curl_easy_setopt(handle, cURL.CURLOPT_URL, "https://ziglang.org") != cURL.CURLE_OK)
        return error.CouldNotSetURL;

    // set write function callbacks
    if (cURL.curl_easy_setopt(handle, cURL.CURLOPT_WRITEFUNCTION, writeToArrayListCallback) != cURL.CURLE_OK)
        return error.CouldNotSetWriteCallback;
    if (cURL.curl_easy_setopt(handle, cURL.CURLOPT_WRITEDATA, &response_ctx) != cURL.CURLE_OK)
        return error.CouldNotSetWriteCallback;

    // perform
    if (cURL.curl_easy_perform(handle) != cURL.CURLE_OK)
        return error.FailedToPerformRequest;

    std.log.info("Got response of {d} bytes", .{response_ctx.buffer.items.len});
    std.debug.print("{s}\n", .{response_ctx.buffer.items});
}

fn writeToArrayListCallback(
    data: *anyopaque,
    size: usize,
    nmemb: usize,
    user_data: *anyopaque,
) callconv(.c) usize {
    var ctx: *ResponseContext = @ptrCast(@alignCast(user_data));
    var typed_data: [*]u8 = @ptrCast(data);
    ctx.buffer.appendSlice(ctx.allocator, typed_data[0 .. nmemb * size]) catch return 0;
    return nmemb * size;
}

// syntax
