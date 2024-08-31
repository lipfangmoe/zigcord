const std = @import("std");

pub fn PackedFlagsMixin(comptime FlagStruct: type) type {
    if (@typeInfo(FlagStruct) != .Struct or @typeInfo(FlagStruct).Struct.backing_integer == null) {
        @compileError("FlagEnum must be a packed struct");
    }

    const BackingInteger = comptime @typeInfo(FlagStruct).Struct.backing_integer orelse @compileError("FlagEnum must be a packed struct");

    return struct {
        pub fn format(self: FlagStruct, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            try std.fmt.formatIntValue(@as(BackingInteger, @bitCast(self)), fmt, options, writer);
        }
        pub fn jsonStringify(self: FlagStruct, jsonWriter: anytype) !void {
            try jsonWriter.write(@as(BackingInteger, @bitCast(self)));
        }
        pub fn jsonParse(alloc: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !FlagStruct {
            return @bitCast(try std.json.innerParse(BackingInteger, alloc, source, options));
        }
        pub fn jsonParseFromValue(alloc: std.mem.Allocator, source: std.json.Value, options: std.json.ParseOptions) !FlagStruct {
            return @bitCast(try std.json.innerParseFromValue(BackingInteger, alloc, source, options));
        }
    };
}
