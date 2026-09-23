const std = @import("std");
const builtin = @import("builtin");

pub const base_url = if (builtin.is_test) "http://127.0.0.1/api/v10" else "https://discord.com/api/v10";

pub fn allocDiscordUriStr(alloc: std.mem.Allocator, comptime fmt: []const u8, args: anytype) ![]const u8 {
    return try std.fmt.allocPrint(alloc, base_url ++ fmt, args);
}
