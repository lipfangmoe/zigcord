const std = @import("std");
const http = std.http;

pub const base_url = "https://discord.com/api/v10";

pub const application_commands = @import("./rest/application_commands.zig");
pub const application_role_connection_metadata = @import("./rest/application_role_connection_metadata.zig");
pub const application = @import("./rest/application.zig");
pub const audit_log = @import("./rest/audit_log.zig");
pub const Client = @import("./rest/Client.zig");
pub const interactions = @import("./rest/interactions.zig");

pub fn discordApiCallUri(allocator: std.mem.Allocator, path: []const u8, query: ?[]const u8) !std.Uri {
    const realPath = try std.mem.concat(allocator, u8, &.{ "/api/v10", path });
    defer allocator.free(realPath);

    return std.Uri{ .scheme = "https", .host = "discord.com", .path = realPath, .query = query };
}

pub const default_stringify_config = .{
    .whitespace = .minified,
    .emit_null_optional_fields = true,
    .emit_strings_as_arrays = false,
    .escape_unicode = false,
    .emit_nonportable_numbers_as_strings = true,
};
