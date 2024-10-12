const std = @import("std");
const model = @import("deancord").model;
const http = std.http;

pub const base_url = "https://discord.com/api/v10";

pub const endpoints = @import("./rest/endpoints.zig");
pub const RestClient = @import("./rest/RestClient.zig");
pub const EndpointClient = @import("./rest/EndpointClient.zig");
pub const HttpInteractionServer = @import("./interaction_server/HttpServer.zig");

const multipart = @import("./rest/multipart.zig");

pub const multipart_boundary = multipart.boundary;

pub fn allocDiscordUriStr(alloc: std.mem.Allocator, comptime fmt: []const u8, args: anytype) ![]const u8 {
    return try std.fmt.allocPrint(alloc, base_url ++ fmt, args);
}

pub fn discordApiCallUri(allocator: std.mem.Allocator, path: []const u8, query: ?[]const u8) !std.Uri {
    const realPath = try std.mem.concat(allocator, u8, &.{ "/api/v10", path });
    defer allocator.free(realPath);

    var uri = std.Uri{
        .scheme = "https",
        .host = .{ .raw = "discord.com" },
        .path = .{ .raw = realPath },
    };
    if (query) |real_query| {
        uri.query = .{ .raw = real_query };
    }
    return uri;
}

pub const writeMultipartFormDataBody = multipart.writeMultipartFormDataBody;

pub fn QueryStringFormatMixin(comptime T: type) type {
    return struct {
        pub fn format(self: T, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) @TypeOf(writer).Error!void {
            comptime {
                if (!std.mem.eql(u8, fmt, "query")) {
                    @compileError("QueryStringFormatMixin used for type " ++ @typeName(@TypeOf(self)) ++ ", but {query} was not used as format specifier");
                }
            }

            var is_first = false;

            inline for (std.meta.fields(@TypeOf(self))) |field| {
                const field_type_info = @typeInfo(field.type);
                const raw_value = @field(self, field.name);

                const value_nullable = switch (field_type_info) {
                    .Optional => raw_value,
                    else => @as(?field.type, raw_value),
                };
                if (value_nullable) |value| {
                    if (@TypeOf(value) == []const u8) {
                        try std.fmt.format(writer, "{s}={s}", .{ field.name, value });
                    } else {
                        try std.fmt.format(writer, "{s}={}", .{ field.name, value });
                    }

                    if (!is_first) {
                        try writer.writeByte('&');
                    }
                    is_first = false;
                }
            }
        }
    };
}

pub const default_stringify_config = .{
    .whitespace = .minified,
    .emit_null_optional_fields = true,
    .emit_strings_as_arrays = false,
    .escape_unicode = false,
    .emit_nonportable_numbers_as_strings = true,
};
