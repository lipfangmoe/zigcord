//! Datatype that discord uses for uploading images via JSON.

const std = @import("std");

mime_type: []const u8,
data: []const u8,

const ImageData = @This();
const encoder = std.base64.Base64Encoder.init(std.base64.standard_alphabet_chars, '=');

pub fn jsonStringify(self: ImageData, json_writer: anytype) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const size = encoder.calcSize(self.data.len);
    const buf = arena.allocator().alloc(u8, size) catch return error.UnexpectedWriteFailure;

    const base64data = encoder.encode(buf, self.data);
    try json_writer.print("data:{s};base64,{s}", .{ self.mime_type, base64data });
}

pub fn jsonParse(alloc: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !ImageData {
    const str = std.json.innerParse([]const u8, alloc, source, options);
    return fromString(str) catch return std.json.ParseError(source).InvalidCharacter;
}

pub fn jsonParseFromValue(alloc: std.mem.Allocator, source: std.json.Value, options: std.json.ParseOptions) !ImageData {
    const str = try std.json.innerParseFromValue([]const u8, alloc, source, options);
    return fromString(str) catch return std.json.ParseFromValueError.InvalidCharacter;
}

pub fn fromString(str: []const u8) !ImageData {
    const colon_idx = 4;
    if (str[colon_idx] != ':') {
        return error.ColonExpected;
    }
    if (!std.mem.eql(u8, str[0..colon_idx], "data")) {
        return error.DataExpected;
    }
    const semicolon_idx = std.mem.indexOfScalar(u8, str, ';') orelse return error.SemicolonExpected;
    if (semicolon_idx < colon_idx) {
        return error.SemicolonBeforeColon;
    }

    const comma_idx = std.mem.indexOfScalar(u8, str, ',') orelse return error.CommaExpected;
    if (comma_idx < semicolon_idx) {
        return error.CommaBeforeSemicolon;
    }
    if (!std.mem.eql(u8, str[semicolon_idx + 1 .. comma_idx], "base64")) {
        return error.Base64Expected;
    }

    const mime_type = str[colon_idx + 1 .. semicolon_idx];
    const data = str[colon_idx + 1 .. semicolon_idx];
    return ImageData{
        .mime_type = mime_type,
        .data = data,
    };
}
