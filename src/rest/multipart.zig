const std = @import("std");
const zigcord = @import("../root.zig");
const jconfig = zigcord.jconfig;

pub const boundary = "f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2";

pub fn writeMultipartFormDataBody(value: anytype, comptime upload_field_name: []const u8, writer: *std.Io.Writer) !void {
    try printUploadAny(@field(value, upload_field_name), upload_field_name, writer);
    try printPayloadJson(value, upload_field_name, writer);

    try writer.writeAll("--" ++ boundary ++ "--");
    try writer.flush();
}

fn printUploadAny(value: anytype, field_name: []const u8, writer: *std.Io.Writer) !void {
    if (@TypeOf(value) == *std.Io.Reader) {
        try printUpload(value, field_name, writer);
        return;
    }

    // check a couple recursive cases
    switch (@typeInfo(@TypeOf(value))) {
        .optional => {
            if (value) |nn_value| {
                try printUploadAny(nn_value, field_name, writer);
                return;
            } else {
                return;
            }
        },
        .pointer => |ptr| {
            switch (ptr.size) {
                .slice => {
                    for (0.., value) |idx, each_value| {
                        var buf: [100]u8 = undefined;
                        const field_name_with_idx = std.fmt.bufPrint(&buf, "{s}[{d}]", .{ field_name, idx }) catch return error.UnexpectedWriteFailure;
                        try printUploadAny(each_value, field_name_with_idx, writer);
                    }
                    return;
                },
                else => |ptr_size| {
                    @compileError("Unsupported pointer size " ++ @tagName(ptr_size));
                },
            }
        },
        else => @compileError("Unsupported type " ++ @typeName(@TypeOf(value))),
    }
}

fn printUpload(value: *std.Io.Reader, field_name: []const u8, writer: *std.Io.Writer) !void {
    try printHeader(field_name, writer);

    _ = try value.streamRemaining(writer);
    try writer.writeAll("\r\n");
}

fn printPayloadJson(value: anytype, comptime upload_field_name: []const u8, writer: *std.Io.Writer) !void {
    try printHeader("payload_json", writer);

    var stringifier = std.json.Stringify{ .writer = writer };
    try stringifier.beginObject();
    inline for (std.meta.fields(@TypeOf(value))) |field| {
        if (comptime std.mem.eql(u8, field.name, upload_field_name)) {
            continue;
        }
        const field_value = @field(value, field.name);
        switch (@typeInfo(field.type)) {
            .optional => {
                if (field_value) |nn_value| {
                    try stringifier.objectField(field.name);
                    try stringifier.write(nn_value);
                }
            },
            else => {
                try stringifier.objectField(field.name);
                try stringifier.write(field_value);
            },
        }
    }
    try stringifier.endObject();

    try writer.writeAll("\r\n");
}

fn printHeader(field_name: []const u8, writer: *std.Io.Writer) !void {
    try writer.writeAll("--" ++ boundary ++ "\r\n");
    try writer.print("Content-Disposition: form-data; name=\"{s}\"\r\n\r\n", .{field_name});
}

test "multipart single upload" {
    const Foo = struct {
        foo: *std.Io.Reader,
        bar: []const u8,
        baz: ?i64 = null,

        pub fn format(self: @This(), writer: *std.Io.Writer) !void {
            writeMultipartFormDataBody(self, "foo", writer) catch return error.WriteFailed;
        }
        pub const jsonStringify = zigcord.jconfig.stringifyWithOmit;
    };

    const my_upload = "this is my upload";
    var reader = std.Io.Reader.fixed(my_upload);
    const foo = Foo{ .foo = &reader, .bar = "some string" };

    var buf: [1000]u8 = undefined;
    const output = try std.fmt.bufPrint(&buf, "{f}", .{foo});

    const expected =
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2\r\n" ++
        "Content-Disposition: form-data; name=\"foo\"\r\n" ++
        "\r\n" ++
        "this is my upload\r\n" ++
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2\r\n" ++
        "Content-Disposition: form-data; name=\"payload_json\"\r\n" ++
        "\r\n" ++
        "{\"bar\":\"some string\"}\r\n" ++
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2--";
    try std.testing.expectEqualStrings(expected, output);
}

test "multipart multi upload" {
    const Foo = struct {
        foo: []const *std.Io.Reader,
        bar: []const u8,
        baz: ?i64 = null,

        pub fn format(self: @This(), writer: *std.Io.Writer) !void {
            writeMultipartFormDataBody(self, "foo", writer) catch return error.WriteFailed;
        }
        pub const jsonStringify = zigcord.jconfig.stringifyWithOmit;
    };

    const my_upload1 = "this is my first upload";
    const my_upload2 = "this is my second upload";
    var reader1 = std.Io.Reader.fixed(my_upload1);
    var reader2 = std.Io.Reader.fixed(my_upload2);
    const foo = Foo{ .foo = &.{ &reader1, &reader2 }, .bar = "some string" };

    var buf: [1000]u8 = undefined;
    const output = try std.fmt.bufPrint(&buf, "{f}", .{foo});

    const expected =
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2\r\n" ++
        "Content-Disposition: form-data; name=\"foo[0]\"\r\n" ++
        "\r\n" ++
        "this is my first upload\r\n" ++
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2\r\n" ++
        "Content-Disposition: form-data; name=\"foo[1]\"\r\n" ++
        "\r\n" ++
        "this is my second upload\r\n" ++
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2\r\n" ++
        "Content-Disposition: form-data; name=\"payload_json\"\r\n" ++
        "\r\n" ++
        "{\"bar\":\"some string\"}\r\n" ++
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2--";
    try std.testing.expectEqualStrings(expected, output);
}

test "multipart optional single upload - present" {
    const Foo = struct {
        foo: ?*std.Io.Reader,
        bar: []const u8,
        baz: ?i64 = null,

        pub fn format(self: @This(), writer: *std.Io.Writer) !void {
            writeMultipartFormDataBody(self, "foo", writer) catch return error.WriteFailed;
        }
        pub const jsonStringify = zigcord.jconfig.stringifyWithOmit;
    };

    const my_upload = "this is my upload";
    var reader = std.Io.Reader.fixed(my_upload);
    const foo = Foo{ .foo = &reader, .bar = "some string" };

    var buf: [1000]u8 = undefined;
    const output = try std.fmt.bufPrint(&buf, "{f}", .{foo});

    const expected =
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2\r\n" ++
        "Content-Disposition: form-data; name=\"foo\"\r\n" ++
        "\r\n" ++
        "this is my upload\r\n" ++
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2\r\n" ++
        "Content-Disposition: form-data; name=\"payload_json\"\r\n" ++
        "\r\n" ++
        "{\"bar\":\"some string\"}\r\n" ++
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2--";
    try std.testing.expectEqualStrings(expected, output);
}

test "multipart optional single upload - null" {
    const Foo = struct {
        foo: ?*std.Io.Reader,
        bar: []const u8,
        baz: ?i64 = null,

        pub fn format(self: @This(), writer: *std.Io.Writer) !void {
            writeMultipartFormDataBody(self, "foo", writer) catch return error.WriteFailed;
        }
        pub const jsonStringify = zigcord.jconfig.stringifyWithOmit;
    };

    const foo = Foo{ .foo = null, .bar = "some string" };

    var buf: [1000]u8 = undefined;
    const output = try std.fmt.bufPrint(&buf, "{f}", .{foo});

    const expected =
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2\r\n" ++
        "Content-Disposition: form-data; name=\"payload_json\"\r\n" ++
        "\r\n" ++
        "{\"bar\":\"some string\"}\r\n" ++
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2--";
    try std.testing.expectEqualStrings(expected, output);
}

test "multipart optional multi upload" {
    const Foo = struct {
        foo: []const ?*std.Io.Reader,
        bar: []const u8,
        baz: ?i64 = null,

        pub fn format(self: @This(), writer: *std.Io.Writer) !void {
            writeMultipartFormDataBody(self, "foo", writer) catch return error.WriteFailed;
        }
        pub const jsonStringify = zigcord.jconfig.stringifyWithOmit;
    };

    const my_upload2 = "this is my second upload";
    var reader = std.Io.Reader.fixed(my_upload2);
    const foo = Foo{ .foo = &.{ null, &reader }, .bar = "some string" };

    var buf: [1000]u8 = undefined;
    const output = try std.fmt.bufPrint(&buf, "{f}", .{foo});

    const expected =
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2\r\n" ++
        "Content-Disposition: form-data; name=\"foo[1]\"\r\n" ++
        "\r\n" ++
        "this is my second upload\r\n" ++
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2\r\n" ++
        "Content-Disposition: form-data; name=\"payload_json\"\r\n" ++
        "\r\n" ++
        "{\"bar\":\"some string\"}\r\n" ++
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2--";
    try std.testing.expectEqualStrings(expected, output);
}
