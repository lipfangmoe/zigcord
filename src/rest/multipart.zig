const std = @import("std");
const deancord = @import("../root.zig");
const deanson = deancord.model.jconfig;

pub const boundary = "f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2";

// TODO - tests
pub fn writeMultipartFormDataBody(value: anytype, comptime upload_field_name: []const u8, writer: anytype) !void {
    var buffered_writer = std.io.bufferedWriter(writer);

    try printUpload(@field(value, upload_field_name), upload_field_name, buffered_writer.writer());
    try printPayloadJson(value, upload_field_name, buffered_writer.writer());

    try buffered_writer.writer().writeAll("--" ++ boundary ++ "--");

    try buffered_writer.flush();
}

fn printUpload(value: anytype, field_name: []const u8, writer: anytype) !void {
    // check a couple recursive cases
    switch (@typeInfo(@TypeOf(value))) {
        .Optional => {
            if (value) |nn_value| {
                try printUpload(nn_value, field_name, writer);
                return;
            } else {
                return;
            }
        },
        .Pointer => |ptr| {
            switch (ptr.size) {
                .Slice => {
                    for (0.., value) |idx, each_value| {
                        var buf: [100]u8 = undefined;
                        const field_name_with_idx = std.fmt.bufPrint(&buf, "{s}[{d}]", .{ field_name, idx }) catch return error.UnexpectedWriteFailure;
                        try printUpload(each_value, field_name_with_idx, writer);
                    }
                    return;
                },
                else => |ptr_size| {
                    @compileError("Unsupported pointer size " ++ @tagName(ptr_size));
                },
            }
        },
        else => {},
    }

    try printHeader(field_name, writer);
    var fifo = std.fifo.LinearFifo(u8, .{ .Static = 10_000 }).init();
    fifo.pump(value, writer) catch return error.UnexpectedWriteFailure;
    try writer.writeAll("\r\n");
}

fn printPayloadJson(value: anytype, comptime upload_field_name: []const u8, writer: anytype) !void {
    try printHeader("payload_json", writer);

    var json_writer = std.json.writeStream(writer, .{});
    defer json_writer.deinit();
    try json_writer.beginObject();
    inline for (std.meta.fields(@TypeOf(value))) |field| {
        if (comptime std.mem.eql(u8, field.name, upload_field_name)) {
            continue;
        }
        const field_value = @field(value, field.name);
        switch (@typeInfo(field.type)) {
            .Optional => {
                if (field_value) |nn_value| {
                    try json_writer.objectField(field.name);
                    try json_writer.write(nn_value);
                }
            },
            else => {
                try json_writer.objectField(field.name);
                try json_writer.write(field_value);
            },
        }
    }
    try json_writer.endObject();

    try writer.writeAll("\r\n");
}

fn printHeader(field_name: []const u8, writer: anytype) !void {
    try writer.writeAll("--" ++ boundary ++ "\r\n");
    try writer.print("Content-Disposition: form-data; name=\"{s}\"\r\n\r\n", .{field_name});
}

test "multipart single upload" {
    const Foo = struct {
        foo: std.io.AnyReader,
        bar: []const u8,
        baz: ?i64 = null,

        pub fn format(self: @This(), comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
            if (comptime !std.mem.eql(u8, fmt, "form")) {
                @compileError("Foo.format should only be called with fmt string {form}");
            }
            try writeMultipartFormDataBody(self, "foo", writer);
        }
        pub const jsonStringify = deancord.model.jconfig.stringifyWithOmit;
    };

    const my_upload = "this is my upload";
    var byte_stream = std.io.fixedBufferStream(my_upload);
    var reader = byte_stream.reader();
    const foo = Foo{ .foo = reader.any(), .bar = "some string" };

    var buf: [1000]u8 = undefined;
    const output = try std.fmt.bufPrint(&buf, "{form}", .{foo});

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
        foo: []const std.io.AnyReader,
        bar: []const u8,
        baz: ?i64 = null,

        pub fn format(self: @This(), comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
            if (comptime !std.mem.eql(u8, fmt, "form")) {
                @compileError("Foo.format should only be called with fmt string {form}");
            }
            try writeMultipartFormDataBody(self, "foo", writer);
        }
        pub const jsonStringify = deancord.model.jconfig.stringifyWithOmit;
    };

    const my_upload1 = "this is my first upload";
    const my_upload2 = "this is my second upload";
    var byte_stream1 = std.io.fixedBufferStream(my_upload1);
    var byte_stream2 = std.io.fixedBufferStream(my_upload2);
    var reader1 = byte_stream1.reader();
    var reader2 = byte_stream2.reader();
    const foo = Foo{ .foo = &.{ reader1.any(), reader2.any() }, .bar = "some string" };

    var buf: [1000]u8 = undefined;
    const output = try std.fmt.bufPrint(&buf, "{form}", .{foo});

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
        foo: ?std.io.AnyReader,
        bar: []const u8,
        baz: ?i64 = null,

        pub fn format(self: @This(), comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
            if (comptime !std.mem.eql(u8, fmt, "form")) {
                @compileError("Foo.format should only be called with fmt string {form}");
            }
            try writeMultipartFormDataBody(self, "foo", writer);
        }
        pub const jsonStringify = deancord.model.jconfig.stringifyWithOmit;
    };

    const my_upload = "this is my upload";
    var byte_stream = std.io.fixedBufferStream(my_upload);
    var reader = byte_stream.reader();
    const foo = Foo{ .foo = reader.any(), .bar = "some string" };

    var buf: [1000]u8 = undefined;
    const output = try std.fmt.bufPrint(&buf, "{form}", .{foo});

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
        foo: ?std.io.AnyReader,
        bar: []const u8,
        baz: ?i64 = null,

        pub fn format(self: @This(), comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
            if (comptime !std.mem.eql(u8, fmt, "form")) {
                @compileError("Foo.format should only be called with fmt string {form}");
            }
            try writeMultipartFormDataBody(self, "foo", writer);
        }
        pub const jsonStringify = deancord.model.jconfig.stringifyWithOmit;
    };

    const foo = Foo{ .foo = null, .bar = "some string" };

    var buf: [1000]u8 = undefined;
    const output = try std.fmt.bufPrint(&buf, "{form}", .{foo});

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
        foo: []const ?std.io.AnyReader,
        bar: []const u8,
        baz: ?i64 = null,

        pub fn format(self: @This(), comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
            if (comptime !std.mem.eql(u8, fmt, "form")) {
                @compileError("Foo.format should only be called with fmt string {form}");
            }
            try writeMultipartFormDataBody(self, "foo", writer);
        }
        pub const jsonStringify = deancord.model.jconfig.stringifyWithOmit;
    };

    const my_upload2 = "this is my second upload";
    var byte_stream2 = std.io.fixedBufferStream(my_upload2);
    var reader2 = byte_stream2.reader();
    const foo = Foo{ .foo = &.{ null, reader2.any() }, .bar = "some string" };

    var buf: [1000]u8 = undefined;
    const output = try std.fmt.bufPrint(&buf, "{form}", .{foo});

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
