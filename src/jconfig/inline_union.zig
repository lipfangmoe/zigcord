const std = @import("std");

/// A jsonStringify function which inlines the value in a tagged union
pub fn stringifyUnionInline(self: anytype, json_writer: anytype) !void {
    const self_typeinfo = @typeInfo(@TypeOf(self));
    switch (self_typeinfo) {
        .Pointer => |ptr| {
            if (@typeInfo(ptr.child) != .Union) {
                @compileError("stringifyUnionInline may only be called with a union type, or a pointer to a union type. Found '" ++ @typeName(@TypeOf(self)) ++ "'");
            }

            switch (self.*) {
                inline else => |value| try json_writer.write(value),
            }
        },
        .Union => {
            switch (self) {
                inline else => |value| try json_writer.write(value),
            }
        },
        else => @compileError("stringifyUnionInline may only be called with a union type, or a pointer to a union type. Found '" ++ @typeName(@TypeOf(self)) ++ "'"),
    }
}

/// Mixin which means "any of the following". Stringifies by just stringifying the target value. Parses by trying to parse each union field in declared order.
pub fn InlineUnionJsonMixin(comptime T: type) type {
    switch (@typeInfo(T)) {
        .Union => {},
        else => @compileError("InlineUnionJsonMixin may only be used on a union type. Found: '" ++ @typeName(T) ++ "'"),
    }

    return struct {
        pub fn jsonStringify(self: T, jw: anytype) !void {
            switch (self) {
                inline else => |value| try jw.write(value),
            }
        }

        pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !T {
            const json_value = try std.json.innerParse(std.json.Value, allocator, source, options);
            return jsonParseFromValue(allocator, json_value, options);
        }

        pub fn jsonParseFromValue(alloc: std.mem.Allocator, source: std.json.Value, options: std.json.ParseOptions) std.json.ParseFromValueError!T {
            inline for (std.meta.fields(T)) |field| {
                if (std.json.innerParseFromValue(field.type, alloc, source, options)) |value| {
                    return @unionInit(T, field.name, value);
                } else |_| {}
            } else {
                std.log.err("invalid format for type '{s}', provided json: {s}", .{ @typeName(T), std.json.fmt(source, .{}) });
                return error.InvalidEnumTag;
            }
        }
    };
}

test "union inline - regular" {
    const TestUnion = union(enum) {
        number: i64,
        string: []const u8,

        pub usingnamespace InlineUnionJsonMixin(@This());
    };

    const twenty = TestUnion{ .number = 20 };
    const bar = TestUnion{ .string = "bar" };

    const actual_twenty_str = try std.json.stringifyAlloc(std.testing.allocator, twenty, .{});
    defer std.testing.allocator.free(actual_twenty_str);
    const actual_bar_str = try std.json.stringifyAlloc(std.testing.allocator, bar, .{});
    defer std.testing.allocator.free(actual_bar_str);

    try std.testing.expectEqualStrings("20", actual_twenty_str);
    try std.testing.expectEqualStrings("\"bar\"", actual_bar_str);
}

test "union inline - inside struct" {
    const TestUnion = union(enum) {
        number: i64,
        string: []const u8,

        pub usingnamespace InlineUnionJsonMixin(@This());
    };
    const TestStruct = struct {
        foo: []const u8,
        onion: TestUnion,
    };

    const twenty = TestStruct{ .foo = "foo", .onion = .{ .number = 20 } };
    const bar = TestStruct{ .foo = "foo", .onion = .{ .string = "bar" } };

    const actual_twenty_str = try std.json.stringifyAlloc(std.testing.allocator, twenty, .{});
    defer std.testing.allocator.free(actual_twenty_str);
    const actual_bar_str = try std.json.stringifyAlloc(std.testing.allocator, bar, .{});
    defer std.testing.allocator.free(actual_bar_str);

    try std.testing.expectEqualStrings("{\"foo\":\"foo\",\"onion\":20}", actual_twenty_str);
    try std.testing.expectEqualStrings("{\"foo\":\"foo\",\"onion\":\"bar\"}", actual_bar_str);
}
