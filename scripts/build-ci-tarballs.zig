const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const cwd = try std.fs.cwd();

    // Directory to store CI tarballs
    const ciTarballsDir = "ci-tarballs";

    // Create or open the directory
    var dir = try cwd.createDir(ciTarballsDir, 0o755) catch |err| {
        if (err == std.os.error.EEXIST) {
            const existing_dir = try cwd.openDir(ciTarballsDir);
            return existing_dir;
        } else {
            return err;
        }
    };

    // TODO: Replace this with actual tarball creation logic for CI updates
    // For demonstration, create a dummy tarball file with timestamp
    const timestamp = try std.time.milliTimestamp();
    const tarballName = std.fmt.allocPrint(allocator, "ci-update-{}.tar.xz", .{timestamp}) catch return;
    defer allocator.free(tarballName);

    const tarballPath = std.fs.path.join(&.{ciTarballsDir, tarballName});
    defer allocator.free(tarballPath);

    // Create dummy tarball file
    const file = try cwd.createFile(tarballPath, .{});
    defer file.close();

    try file.writeAll("Dummy tarball content for CI update\n");

    // Manage stored tarballs: keep only the most recent 20 files
    try manageOldTarballs(cwd, ciTarballsDir, 20);

    std.debug.print("Created CI tarball: {s}\n", .{tarballName});
}

fn manageOldTarballs(cwd: std.fs.Dir, dirName: []const u8, maxFiles: usize) !void {
    var dir = try cwd.openDir(dirName);
    defer dir.close();

    var files = std.ArrayList(std.fs.Dir.Entry).init(std.heap.page_allocator);
    while (true) {
        const entry = try dir.readDir();
        if (entry == null) break;
        if (entry.kind == .file) {
            try files.append(entry);
        }
    }

    // Sort files by modification time descending (newest first)
    files.sortWithComparator(comptime std.fs.Dir.Entry, fn(a: std.fs.Dir.Entry, b: std.fs.Dir.Entry) bool {
        return a.mtime > b.mtime;
    });

    // Delete files exceeding maxFiles
    if (files.items.len > maxFiles) {
        for (files.items[maxFiles..]) |file| {
            const path = std.fs.path.join(&.{dirName, file.name});
            try cwd.deleteFile(path);
            std.debug.print("Deleted old CI tarball: {s}\n", .{file.name});
        }
    }

    files.deinit();
}
