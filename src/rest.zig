const std = @import("std");
const model = @import("zigcord").model;
const http = std.http;

pub const base_url = if (@import("builtin").is_test) "http://127.0.0.1/api/v10" else "https://discord.com/api/v10";

pub const RestClient = @import("./rest/RestClient.zig");
pub const EndpointClient = @import("./rest/EndpointClient.zig");
pub const HttpInteractionServer = @import("./interaction_server/HttpServer.zig");
pub const upload = @import("./rest/upload.zig");
pub const Upload = upload.Upload;

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

pub const getTransferEncoding = multipart.getTransferEncoding;
pub const writeMultipartFormDataBody = multipart.writeMultipartFormDataBody;

pub fn QueryStringFormatMixin(comptime T: type) type {
    return struct {
        pub fn format(self: T, writer: *std.Io.Writer) std.Io.Writer.Error!void {
            const fields = std.meta.fields(T);
            var is_first_print = true;
            inline for (fields) |field| {
                const value = @field(self, field.name);
                if (willPrint(value)) {
                    if (!is_first_print) {
                        try writer.writeByte('&');
                    }
                    is_first_print = false;
                }
                try formatField(field.name, writer, value);
            }
        }
    };
}

fn willPrint(raw_value: anytype) bool {
    const field_type_info = @typeInfo(@TypeOf(raw_value));

    const value_nullable = switch (field_type_info) {
        .optional => raw_value,
        else => @as(?@TypeOf(raw_value), raw_value),
    };
    const value = value_nullable orelse return false;

    if (@TypeOf(value) == []const u8) {
        return true;
    }

    if (@typeInfo(@TypeOf(value)) == .pointer and @typeInfo(@TypeOf(value)).pointer.size == .slice) {
        var anything_to_print = false;
        for (value) |each| {
            const elem_will_print = willPrint(each);
            if (elem_will_print) {
                anything_to_print = true;
            }
        }
        return anything_to_print;
    }

    if (comptime std.meta.hasMethod(@TypeOf(value), "format")) {
        return true;
    }

    return true;
}

// returns whether anything was printed as a result of this call
fn formatField(name: []const u8, writer: *std.Io.Writer, raw_value: anytype) std.Io.Writer.Error!void {
    const field_type_info = @typeInfo(@TypeOf(raw_value));

    const value_nullable = switch (field_type_info) {
        .optional => raw_value,
        else => @as(?@TypeOf(raw_value), raw_value),
    };
    const value = value_nullable orelse return;

    if (@TypeOf(value) == []const u8) {
        try writer.print("{s}={s}", .{ name, value });
        return;
    }

    if (@typeInfo(@TypeOf(value)) == .pointer and @typeInfo(@TypeOf(value)).pointer.size == .slice) {
        var is_first_print = true;
        for (value) |each| {
            if (willPrint(each)) {
                if (!is_first_print) {
                    try writer.writeByte('&');
                }
                is_first_print = false;
            }
            try formatField(name, writer, each);
        }
        return;
    }

    if (comptime std.meta.hasMethod(@TypeOf(value), "format")) {
        try writer.print("{s}={f}", .{ name, value });
        return;
    }

    try writer.print("{s}={any}", .{ name, value });
}

test QueryStringFormatMixin {
    const Point = struct {
        x: u64,
        y: u64,
        pub fn format(self: @This(), writer: *std.Io.Writer) !void {
            try writer.print("({d},{d})", .{ self.x, self.y });
        }
    };
    const TestEnum = enum { foo, bar };
    const Test = struct {
        str: []const u8,
        strs: []const []const u8,
        @"enum": TestEnum,
        enums: []const TestEnum,
        point: Point,
        points: []const Point,
        opt_null: ?u64,
        opt_nonnull: ?u64,
        slice_opts_normal: []const ?u64,
        slice_opts_null_prefix: []const ?u64,
        slice_opts_null_suffix: []const ?u64,
        slice_opts_empty: []const ?u64,
        slice_opts_only_null: []const ?u64,

        pub const format = QueryStringFormatMixin(@This()).format;
    };

    const value: Test = .{
        .str = "str",
        .strs = &.{ "str1", "str2", "str3" },
        .@"enum" = .foo,
        .enums = &.{ .foo, .bar, .foo },
        .point = .{ .x = 1, .y = 2 },
        .points = &.{
            .{ .x = 1, .y = 2 },
            .{ .x = 6, .y = 7 },
        },
        .opt_null = null,
        .opt_nonnull = 42,
        .slice_opts_normal = &.{ 1, 2 },
        .slice_opts_null_prefix = &.{ null, 1, null, 3 },
        .slice_opts_null_suffix = &.{ 1, null, 3, null },
        .slice_opts_empty = &.{},
        .slice_opts_only_null = &.{null},
    };

    var buf: [500]u8 = undefined;
    var writer: std.Io.Writer = .fixed(&buf);

    try writer.print("{f}", .{value});
    const expected =
        "str=str&strs=str1&strs=str2&strs=str3&enum=.foo&enums=.foo&enums=.bar&enums=.foo" ++
        "&point=(1,2)&points=(1,2)&points=(6,7)&opt_nonnull=42" ++
        "&slice_opts_normal=1&slice_opts_normal=2" ++
        "&slice_opts_null_prefix=1&slice_opts_null_prefix=3" ++
        "&slice_opts_null_suffix=1&slice_opts_null_suffix=3";

    try std.testing.expectEqualStrings(expected, writer.buffered());
}
