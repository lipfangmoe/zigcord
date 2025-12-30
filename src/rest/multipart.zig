const std = @import("std");
const zigcord = @import("../root.zig");
const jconfig = zigcord.jconfig;
const Upload = zigcord.rest.Upload;

pub const boundary = "f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2";
const boundary_start = "--" ++ boundary;
const boundary_end = "--" ++ boundary ++ "--";

pub fn writeMultipartFormDataBody(value: anytype, comptime upload_field_name: []const u8, writer: *std.Io.Writer) !void {
    try printUploadAny(@field(value, upload_field_name), upload_field_name, writer);
    try printPayloadJson(value, upload_field_name, writer);

    try writer.writeAll(boundary_end);
    try writer.flush();
}

pub fn getTransferEncoding(value: anytype, comptime upload_field_name: []const u8) error{JsonError}!std.http.Client.Request.TransferEncoding {
    return if (countMultipartFormDataBody(value, upload_field_name)) |length|
        .{ .content_length = length }
    else |err| switch (err) {
        error.SizeUnknown => .chunked,
        error.JsonError => error.JsonError,
    };
}

fn countMultipartFormDataBody(value: anytype, comptime upload_field_name: []const u8) error{ JsonError, SizeUnknown }!usize {
    if (countUploadAny(@field(value, upload_field_name), upload_field_name)) |upload_count| {
        return upload_count + (countPayloadJson(value, upload_field_name) catch return error.JsonError) + boundary_end.len;
    }

    return error.SizeUnknown;
}

fn printUploadAny(value: anytype, field_name: []const u8, writer: *std.Io.Writer) !void {
    if (@TypeOf(value) == Upload) {
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

fn countUploadAny(value: anytype, field_name: []const u8) ?usize {
    if (@TypeOf(value) == Upload) {
        return countUpload(value, field_name);
    }

    // check a couple recursive cases
    switch (@typeInfo(@TypeOf(value))) {
        .optional => {
            if (value) |nn_value| {
                return countUploadAny(nn_value, field_name);
            } else {
                return 0;
            }
        },
        .pointer => |ptr| {
            switch (ptr.size) {
                .slice => {
                    var total: usize = 0;
                    for (0.., value) |idx, each_value| {
                        var buf: [100]u8 = undefined;
                        const field_name_with_idx = std.fmt.bufPrint(&buf, "{s}[{d}]", .{ field_name, idx }) catch unreachable;
                        if (countUploadAny(each_value, field_name_with_idx)) |count| {
                            total += count;
                        }
                    }
                    return total;
                },
                else => |ptr_size| {
                    @compileError("Unsupported pointer size " ++ @tagName(ptr_size));
                },
            }
        },
        else => @compileError("Unsupported type " ++ @typeName(@TypeOf(value))),
    }
}

fn printUpload(value: Upload, field_name: []const u8, writer: *std.Io.Writer) !void {
    try printHeader(field_name, value.filename, value.content_type, writer);

    switch (value.data) {
        .bytes => |bytes| {
            var reader = std.Io.Reader.fixed(bytes);
            _ = try reader.streamRemaining(writer);
        },
        .reader_with_size => |r| {
            var reader = r.reader;
            _ = try reader.streamRemaining(writer);
        },
        .other_reader => |reader| {
            _ = try reader.streamRemaining(writer);
        },
    }
    try writer.writeAll("\r\n");
}

fn countUpload(value: Upload, field_name: []const u8) ?usize {
    if (value.getSize()) |size| {
        return countHeader(field_name, value.filename, value.content_type) + size + 2; // +2 for \r\n
    }
    return null;
}

fn printPayloadJson(value: anytype, comptime upload_field_name: []const u8, writer: *std.Io.Writer) !void {
    try printHeader("payload_json", null, "application/json", writer);

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

fn countPayloadJson(value: anytype, comptime upload_field_name: []const u8) !usize {
    var buf: [1000]u8 = undefined;
    var discarding_writer: std.Io.Writer.Discarding = .init(&buf);
    var stringifier: std.json.Stringify = .{ .writer = &discarding_writer.writer };

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

    return countHeader("payload_json", null, "application/json") + discarding_writer.fullCount() + 2;
}

fn printHeader(field_name: []const u8, filename: ?[]const u8, content_type: []const u8, writer: *std.Io.Writer) !void {
    try writer.writeAll(boundary_start ++ "\r\n");
    try writer.print("Content-Disposition: form-data; name=\"{s}\"", .{field_name});
    if (filename) |fname| {
        try writer.print("; filename=\"{s}\"", .{fname});
    }
    try writer.print("\r\nContent-Type: {s}\r\n\r\n", .{content_type});
}

fn countHeader(field_name: []const u8, filename: ?[]const u8, content_type: []const u8) usize {
    var count: usize = boundary_start.len + 2;
    count += std.fmt.count("Content-Disposition: form-data; name=\"{s}\"", .{field_name});
    if (filename) |fname| {
        count += std.fmt.count("; filename=\"{s}\"", .{fname});
    }
    count += std.fmt.count("\r\nContent-Type: {s}\r\n\r\n", .{content_type});
    return count;
}

test "multipart single upload" {
    const Foo = struct {
        foo: Upload,
        bar: []const u8,
        baz: ?i64 = null,

        pub fn format(self: @This(), writer: *std.Io.Writer) !void {
            writeMultipartFormDataBody(self, "foo", writer) catch return error.WriteFailed;
        }
        pub const jsonStringify = zigcord.jconfig.stringifyWithOmit;
    };

    const my_upload = "this is my upload";
    const foo = Foo{ .foo = .fromBytes("upload.txt", "text/plain", my_upload), .bar = "some string" };

    var buf: [1000]u8 = undefined;
    const output = try std.fmt.bufPrint(&buf, "{f}", .{foo});

    const expected =
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2\r\n" ++
        "Content-Disposition: form-data; name=\"foo\"; filename=\"upload.txt\"\r\n" ++
        "Content-Type: text/plain\r\n" ++
        "\r\n" ++
        "this is my upload\r\n" ++
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2\r\n" ++
        "Content-Disposition: form-data; name=\"payload_json\"\r\n" ++
        "Content-Type: application/json\r\n" ++
        "\r\n" ++
        "{\"bar\":\"some string\"}\r\n" ++
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2--";
    try std.testing.expectEqualStrings(expected, output);
}

test "multipart multi upload" {
    const Foo = struct {
        foo: []const Upload,
        bar: []const u8,
        baz: ?i64 = null,

        pub fn format(self: @This(), writer: *std.Io.Writer) !void {
            writeMultipartFormDataBody(self, "foo", writer) catch return error.WriteFailed;
        }
        pub const jsonStringify = zigcord.jconfig.stringifyWithOmit;
    };

    const my_upload1 = "this is my first upload";
    const my_upload2 = "this is my second upload";
    const foo = Foo{ .foo = &.{ .fromBytes("upload.txt", "text/plain", my_upload1), .fromBytes("upload.txt", "text/plain", my_upload2) }, .bar = "some string" };

    var buf: [1000]u8 = undefined;
    const output = try std.fmt.bufPrint(&buf, "{f}", .{foo});

    const expected =
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2\r\n" ++
        "Content-Disposition: form-data; name=\"foo[0]\"; filename=\"upload.txt\"\r\n" ++
        "Content-Type: text/plain\r\n" ++
        "\r\n" ++
        "this is my first upload\r\n" ++
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2\r\n" ++
        "Content-Disposition: form-data; name=\"foo[1]\"; filename=\"upload.txt\"\r\n" ++
        "Content-Type: text/plain\r\n" ++
        "\r\n" ++
        "this is my second upload\r\n" ++
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2\r\n" ++
        "Content-Disposition: form-data; name=\"payload_json\"\r\n" ++
        "Content-Type: application/json\r\n" ++
        "\r\n" ++
        "{\"bar\":\"some string\"}\r\n" ++
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2--";
    try std.testing.expectEqualStrings(expected, output);
}

test "multipart optional single upload - present" {
    const Foo = struct {
        foo: ?Upload,
        bar: []const u8,
        baz: ?i64 = null,

        pub const jsonStringify = zigcord.jconfig.stringifyWithOmit;
    };

    const my_upload = "this is my upload";
    const foo = Foo{ .foo = .fromBytes("upload.txt", "text/plain", my_upload), .bar = "some string" };

    var buf: [1000]u8 = undefined;
    var output: std.Io.Writer = .fixed(&buf);
    try writeMultipartFormDataBody(foo, "foo", &output);

    const expected =
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2\r\n" ++
        "Content-Disposition: form-data; name=\"foo\"; filename=\"upload.txt\"\r\n" ++
        "Content-Type: text/plain\r\n" ++
        "\r\n" ++
        "this is my upload\r\n" ++
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2\r\n" ++
        "Content-Disposition: form-data; name=\"payload_json\"\r\n" ++
        "Content-Type: application/json\r\n" ++
        "\r\n" ++
        "{\"bar\":\"some string\"}\r\n" ++
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2--";
    try std.testing.expectEqualStrings(expected, output.buffered());
}

test "multipart optional single upload - null" {
    const Foo = struct {
        foo: ?Upload,
        bar: []const u8,
        baz: ?i64 = null,

        pub const jsonStringify = zigcord.jconfig.stringifyWithOmit;
    };

    const foo = Foo{ .foo = null, .bar = "some string" };

    var buf: [1000]u8 = undefined;
    var output: std.Io.Writer = .fixed(&buf);
    try writeMultipartFormDataBody(foo, "foo", &output);

    const expected =
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2\r\n" ++
        "Content-Disposition: form-data; name=\"payload_json\"\r\n" ++
        "Content-Type: application/json\r\n" ++
        "\r\n" ++
        "{\"bar\":\"some string\"}\r\n" ++
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2--";
    try std.testing.expectEqualStrings(expected, output.buffered());
}

test "multipart optional multi upload" {
    const Foo = struct {
        foo: []const ?Upload,
        bar: []const u8,
        baz: ?i64 = null,

        pub const jsonStringify = zigcord.jconfig.stringifyWithOmit;
    };

    const my_upload2 = "this is my second upload";
    const foo = Foo{ .foo = &.{ null, .fromBytes("upload.txt", "text/plain", my_upload2) }, .bar = "some string" };

    var buf: [1000]u8 = undefined;
    var output: std.Io.Writer = .fixed(&buf);
    try writeMultipartFormDataBody(foo, "foo", &output);

    const expected =
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2\r\n" ++
        "Content-Disposition: form-data; name=\"foo[1]\"; filename=\"upload.txt\"\r\n" ++
        "Content-Type: text/plain\r\n" ++
        "\r\n" ++
        "this is my second upload\r\n" ++
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2\r\n" ++
        "Content-Disposition: form-data; name=\"payload_json\"\r\n" ++
        "Content-Type: application/json\r\n" ++
        "\r\n" ++
        "{\"bar\":\"some string\"}\r\n" ++
        "--f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2--";
    try std.testing.expectEqualStrings(expected, output.buffered());
}
