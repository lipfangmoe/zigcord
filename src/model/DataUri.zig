//! Datatype that discord uses for uploading images via JSON.

const std = @import("std");

mime_type: []const u8,
base64: []const u8,

const DataUri = @This();
const decoder = std.base64.Base64Decoder.init(std.base64.standard_alphabet_chars, '=');

pub fn jsonStringify(self: DataUri, json_writer: anytype) !void {
    try json_writer.print("data:{s};base64,{s}", .{ self.mime_type, self.base64 });
}

pub fn jsonParse(alloc: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !DataUri {
    const str = std.json.innerParse([]const u8, alloc, source, options);
    return fromString(str) catch return std.json.ParseError(source).InvalidCharacter;
}

pub fn jsonParseFromValue(alloc: std.mem.Allocator, source: std.json.Value, options: std.json.ParseOptions) !DataUri {
    const str = try std.json.innerParseFromValue([]const u8, alloc, source, options);
    return fromString(str) catch return std.json.ParseFromValueError.InvalidCharacter;
}

pub fn fromString(str: []const u8) !DataUri {
    const colon_idx = 4;
    if (str[colon_idx] != ':') {
        return error.InvalidFormat;
    }
    if (!std.mem.eql(u8, str[0..colon_idx], "data")) {
        return error.DataExpected;
    }
    const semicolon_idx = std.mem.indexOfScalar(u8, str, ';') orelse return error.SemicolonExpected;
    if (semicolon_idx < colon_idx) {
        return error.InvalidFormat;
    }

    const comma_idx = std.mem.indexOfScalar(u8, str, ',') orelse return error.CommaExpected;
    if (comma_idx < semicolon_idx) {
        return error.InvalidFormat;
    }
    if (!std.mem.eql(u8, str[semicolon_idx + 1 .. comma_idx], "base64")) {
        return error.NotBase64;
    }

    const mime_type = str[colon_idx + 1 .. semicolon_idx];
    const base64 = str[comma_idx + 1 ..];
    return DataUri{
        .mime_type = mime_type,
        .base64 = base64,
    };
}

test fromString {
    const encoded = "data:text/plain;base64,aGVsbG8gd29ybGQ=";
    const data_uri = try DataUri.fromString(encoded);
    try std.testing.expectEqualStrings("text/plain", data_uri.mime_type);
    try std.testing.expectEqualStrings("aGVsbG8gd29ybGQ=", data_uri.base64);
}
