{#syntax#}
// compile with `zig build-exe zig-curl-test.zig --library curl --library c $(pkg-config --cflags libcurl)`
const std = @import("std");
const cURL = @cImport({
    @cInclude("curl/curl.h");
});

pub fn main() !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena_state.deinit();
    var allocator = &arena_state.allocator;

    // global curl init, or fail
    if (cURL.curl_global_init(cURL.CURL_GLOBAL_ALL) != .CURLE_OK)
        return error.CURLGlobalInitFailed;

    // curl easy handle init, or fail
    const handle = cURL.curl_easy_init() orelse return error.CURLHandleInitFailed;
    defer {
        cURL.curl_easy_cleanup(handle);
        cURL.curl_global_cleanup();
    }

    var response_buffer = std.ArrayList(u8).init(allocator);
    defer response_buffer.deinit();

    // setup curl options
    if (cURL.curl_easy_setopt(handle, .CURLOPT_URL, "https://ziglang.org") != .CURLE_OK)
        return error.CouldNotSetURL;

    // set write function callbacks
    if (cURL.curl_easy_setopt(handle, .CURLOPT_WRITEFUNCTION, writeToArrayListCallback) != .CURLE_OK)
        return error.CouldNotSetWriteCallback;
    if (cURL.curl_easy_setopt(handle, .CURLOPT_WRITEDATA, &response_buffer) != .CURLE_OK)
        return error.CouldNotSetWriteCallback;

    // perform
    if (cURL.curl_easy_perform(handle) != .CURLE_OK)
        return error.FailedToPerformRequest;

    std.log.info("Got response of {} bytes", .{response_buffer.items.len});
    std.debug.print("{}\n", .{response_buffer.items});
}

fn writeToArrayListCallback(data: *c_void, size: c_uint, nmemb: c_uint, user_data: *c_void) callconv(.C) c_uint {
    var buffer = @intToPtr(*std.ArrayList(u8), @ptrToInt(user_data));
    var typed_data = @intToPtr([*]u8, @ptrToInt(data));
    buffer.appendSlice(typed_data[0 .. nmemb * size]) catch return 0;
    return nmemb * size;
}
{#endsyntax#}
