const std = @import("std");

pub fn PackedFlagsMixin(comptime FlagStruct: type) type {
    if (@typeInfo(FlagStruct) != .Struct or @typeInfo(FlagStruct).Struct.backing_integer == null) {
        @compileError("FlagStruct must be a packed struct with a u64 backing integer");
    }

    if (@typeInfo(FlagStruct).Struct.backing_integer != u64) {
        @compileError("FlagStruct must be a packed struct with a u64 backing integer");
    }

    return struct {
        pub fn format(self: FlagStruct, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            const int: u64 = @bitCast(self);
            try std.fmt.formatIntValue(int, fmt, options, writer);
        }
        pub fn jsonStringify(self: FlagStruct, jsonWriter: anytype) !void {
            const int: u64 = @bitCast(self);
            try jsonWriter.write(int);
        }
        pub fn jsonParse(alloc: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !FlagStruct {
            const int: u64 = try std.json.innerParse(u64, alloc, source, options);
            return @bitCast(int);
        }
        pub fn jsonParseFromValue(alloc: std.mem.Allocator, source: std.json.Value, options: std.json.ParseOptions) !FlagStruct {
            const int: u64 = try std.json.innerParseFromValue(u64, alloc, source, options);
            return @bitCast(int);
        }
    };
}
