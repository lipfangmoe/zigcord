const std = @import("std");

pub fn fmt(data: anytype) Formatter(@TypeOf(data)) {
    return .{ .data = data };
}

pub fn Formatter(comptime T: type) type {
    return struct {
        data: T,

        pub fn format(self: @This(), w: *std.Io.Writer) error{WriteFailed}!void {
            try formatAsQueryString(self.data, w);
        }
    };
}

pub fn formatAsQueryString(data: anytype, writer: *std.Io.Writer) error{WriteFailed}!void {
    const T = switch (@typeInfo(@TypeOf(data))) {
        .pointer => std.meta.Child(@TypeOf(data)),
        else => @TypeOf(data),
    };
    const t_typeinfo = @typeInfo(T).@"struct";
    var is_first_print = true;
    inline for (t_typeinfo.field_names) |field_name| {
        const value = @field(data, field_name);
        if (willPrint(value)) {
            if (!is_first_print) {
                try writer.writeByte('&');
            }
            is_first_print = false;
        }
        try formatField(field_name, writer, value);
    }
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

test formatAsQueryString {
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

        pub const format = formatAsQueryString;
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
