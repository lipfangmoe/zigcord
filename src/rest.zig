const std = @import("std");
const model = @import("root").model;
const http = std.http;

pub const base_url = "https://discord.com/api/v10";

pub const endpoints = @import("./rest/endpoints.zig");
pub const Client = @import("./rest/Client.zig");

pub fn allocDiscordUriStr(alloc: std.mem.Allocator, comptime fmt: []const u8, args: anytype) ![]const u8 {
    return try std.fmt.allocPrint(alloc, base_url ++ fmt, args);
}

pub fn auditLogHeaders(audit_log_reason: ?[]const u8) []const std.http.Header {
    if (audit_log_reason) |reason| {
        return &.{std.http.Header{ .name = "X-Audit-Log-Reason", .value = reason }};
    } else {
        return &.{};
    }
}

pub fn formatAsMultipartFormData(self: anytype, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
    std.debug.assert(std.mem.eql(u8, fmt, "form"));

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const boundary = "f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2";

    inline for (std.meta.fields(@TypeOf(self))) |field| {
        const value_opt = @field(self, field.name);
        if (value_opt) |value| {
            try writer.writeAll("--" ++ boundary ++ "\r\n");

            if (std.mem.eql(u8, field.name, "files")) {
                for (0.., value) |idx, file_reader_nullable| {
                    if (file_reader_nullable) |file_reader| {
                        try std.fmt.format(writer, "Content-Disposition: form-data; name=\"files[{d}]\"\r\n\r\n", .{idx});

                        var fifo = std.fifo.LinearFifo(u8, .{ .Static = 10_000 }).init();
                        try fifo.pump(file_reader, writer);
                    }
                }
                continue;
            } else {
                const value_json = try std.json.stringifyAlloc(allocator, value, .{});
                try writer.writeAll("Content-Disposition: form-data; name=\"" ++ field.name ++ "\"\r\n\r\n");
                try writer.writeAll(value_json);
            }
            try writer.writeAll("\r\n");
        }
    }

    try writer.writeAll("--" ++ boundary ++ "--");
}

pub fn formatAsQueryString(self: anytype, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
    std.debug.assert(std.mem.eql(u8, fmt, "query"));

    var is_first = false;

    inline for (std.meta.fields(@TypeOf(self))) |field| {
        const fieldType = @typeInfo(field.type);
        const value = @field(self, field.name);
        if (fieldType == .Optional and value == null) {
            continue;
        }

        try std.fmt.format(writer, "{s}={s}", .{ field.name, value });

        if (!is_first) {
            try writer.writeByte('&');
        }
        is_first = false;
    }
}

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
