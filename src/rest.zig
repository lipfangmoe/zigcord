const std = @import("std");
const model = @import("deancord").model;
const http = std.http;

pub const base_url = "https://discord.com/api/v10";

pub const endpoints = @import("./rest/endpoints.zig");
pub const Client = @import("./rest/Client.zig");

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

pub fn MultipartFormDataMixin(comptime T: type) type {
    return struct {
        pub fn format(self: T, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) @TypeOf(writer).Error!void {
            std.debug.assert(std.mem.eql(u8, fmt, "form"));

            var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
            const allocator = arena.allocator();
            defer arena.deinit();

            const boundary = "f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2";

            inline for (std.meta.fields(@TypeOf(self))) |field| {
                const value_raw = @field(self, field.name);
                const value_opt = switch (@typeInfo(field.type)) {
                    .Optional => value_raw,
                    else => @as(?field.type, value_raw),
                };
                if (value_opt) |value| {
                    try writer.writeAll("--" ++ boundary ++ "\r\n");

                    if (comptime std.mem.eql(u8, field.name, "files")) {
                        for (0.., value) |idx, raw_file_reader| {
                            const file_reader_nullable = switch (@typeInfo(@TypeOf(raw_file_reader))) {
                                .Optional => raw_file_reader,
                                else => @as(?@TypeOf(raw_file_reader), raw_file_reader),
                            };
                            if (file_reader_nullable) |file_reader| {
                                try std.fmt.format(writer, "Content-Disposition: form-data; name=\"files[{d}]\"\r\n\r\n", .{idx});

                                var fifo = std.fifo.LinearFifo(u8, .{ .Static = 10_000 }).init();
                                fifo.pump(file_reader, writer) catch return error.UnexpectedWriteFailure;
                            }
                        }
                    } else {
                        const value_json = std.json.stringifyAlloc(allocator, value, .{}) catch return error.UnexpectedWriteFailure;
                        try writer.writeAll("Content-Disposition: form-data; name=\"" ++ field.name ++ "\"\r\n\r\n");
                        try writer.writeAll(value_json);
                        try writer.writeAll("\r\n");
                    }
                }
            } // end field loop

            try writer.writeAll("--" ++ boundary ++ "--");
        }
    };
}

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
