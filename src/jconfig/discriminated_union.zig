const std = @import("std");

/// Represents union which is discriminated in JSON representation by an enum field.
pub fn DiscriminatedUnionMixin(comptime T: type, comptime discriminator_field: []const u8) type {
    const UnionTag = switch (@typeInfo(T)) {
        .@"union" => std.meta.Tag(T),
        else => @compileError("prop_discriminated_union.Mixin may only be used on a union type. Found: '" ++ @typeName(T) ++ "'"),
    };

    return struct {
        pub fn jsonStringify(self: T, jw: *std.json.Stringify) !void {
            switch (self) {
                inline else => |value| {
                    if (@TypeOf(value) == void) {
                        try jw.write(null);
                    } else {
                        try jw.write(value);
                    }
                },
            }
        }

        pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !T {
            const json_value = try std.json.innerParse(std.json.Value, allocator, source, options);
            return jsonParseFromValue(allocator, json_value, options);
        }

        pub fn jsonParseFromValue(alloc: std.mem.Allocator, source: std.json.Value, options: std.json.ParseOptions) std.json.ParseFromValueError!T {
            const obj = switch (source) {
                .object => |object| object,
                else => return error.UnexpectedToken,
            };

            const discriminator = obj.get(discriminator_field) orelse return error.MissingField;
            const tag: UnionTag = switch (discriminator) {
                .integer => |int| std.enums.fromInt(UnionTag, int) orelse return error.InvalidEnumTag,
                .string, .number_string => |str| blk: {
                    if (std.fmt.parseInt(i64, str, 10)) |int| {
                        break :blk std.enums.fromInt(UnionTag, int) orelse return error.InvalidEnumTag;
                    } else |_| {
                        break :blk std.meta.stringToEnum(UnionTag, str) orelse return error.InvalidEnumTag;
                    }
                },
                else => return error.InvalidEnumTag,
            };

            switch (tag) {
                inline else => |tag_comptime| {
                    const TagType = @FieldType(T, @tagName(tag_comptime));
                    const parsed = try std.json.innerParseFromValue(TagType, alloc, source, options);
                    return @unionInit(T, @tagName(tag_comptime), parsed);
                },
            }
        }
    };
}

test "discriminated union serialization" {
    const TestUnionTag = enum { int, string };
    const TestUnion = union(TestUnionTag) {
        int: struct {
            tag: TestUnionTag,
            myint: u64,
        },
        string: struct {
            tag: TestUnionTag,
            mystr: []const u8,
        },

        const Mixin = DiscriminatedUnionMixin(@This(), "tag");
        pub const jsonStringify = Mixin.jsonStringify;
        pub const jsonParse = Mixin.jsonParse;
        pub const jsonParseFromValue = Mixin.jsonParseFromValue;
    };

    const twenty: TestUnion = .{ .int = .{ .tag = .int, .myint = 20 } };
    const foo: TestUnion = .{ .string = .{ .tag = .string, .mystr = "foo" } };

    const actual_twenty_str = try std.json.Stringify.valueAlloc(std.testing.allocator, twenty, .{});
    defer std.testing.allocator.free(actual_twenty_str);
    const actual_foo_str = try std.json.Stringify.valueAlloc(std.testing.allocator, foo, .{});
    defer std.testing.allocator.free(actual_foo_str);

    const expected_twenty_str =
        \\{"tag":"int","myint":20}
    ;
    const expected_foo_str =
        \\{"tag":"string","mystr":"foo"}
    ;

    try std.testing.expectEqualStrings(expected_twenty_str, actual_twenty_str);
    try std.testing.expectEqualStrings(expected_foo_str, actual_foo_str);
}

test "discriminated union serialization - with int serialization of enum" {
    const TestUnionTag = enum {
        int,
        string,

        pub const jsonStringify = @import("./enums.zig").stringifyEnumAsInt;
    };
    const TestUnion = union(TestUnionTag) {
        int: struct {
            tag: TestUnionTag,
            myint: u64,
        },
        string: struct {
            tag: TestUnionTag,
            mystr: []const u8,
        },

        const Mixin = DiscriminatedUnionMixin(@This(), "tag");
        pub const jsonStringify = Mixin.jsonStringify;
        pub const jsonParse = Mixin.jsonParse;
        pub const jsonParseFromValue = Mixin.jsonParseFromValue;
    };

    const twenty: TestUnion = .{ .int = .{ .tag = .int, .myint = 20 } };
    const foo: TestUnion = .{ .string = .{ .tag = .string, .mystr = "foo" } };

    const actual_twenty_str = try std.json.Stringify.valueAlloc(std.testing.allocator, twenty, .{});
    defer std.testing.allocator.free(actual_twenty_str);
    const actual_foo_str = try std.json.Stringify.valueAlloc(std.testing.allocator, foo, .{});
    defer std.testing.allocator.free(actual_foo_str);

    const expected_twenty_str =
        \\{"tag":0,"myint":20}
    ;
    const expected_foo_str =
        \\{"tag":1,"mystr":"foo"}
    ;

    try std.testing.expectEqualStrings(expected_twenty_str, actual_twenty_str);
    try std.testing.expectEqualStrings(expected_foo_str, actual_foo_str);
}

test "discriminated union serialization - no tag in program representation (tag should not be serialized)" {
    const TestUnionTag = enum {
        int,
        string,

        pub const jsonStringify = @import("./enums.zig").stringifyEnumAsInt;
    };
    const TestUnion = union(TestUnionTag) {
        int: struct {
            myint: u64,
        },
        string: struct {
            mystr: []const u8,
        },

        const Mixin = DiscriminatedUnionMixin(@This(), "tag");
        pub const jsonStringify = Mixin.jsonStringify;
        pub const jsonParse = Mixin.jsonParse;
        pub const jsonParseFromValue = Mixin.jsonParseFromValue;
    };

    const twenty: TestUnion = .{ .int = .{ .myint = 20 } };
    const foo: TestUnion = .{ .string = .{ .mystr = "foo" } };

    const actual_twenty_str = try std.json.Stringify.valueAlloc(std.testing.allocator, twenty, .{});
    defer std.testing.allocator.free(actual_twenty_str);
    const actual_foo_str = try std.json.Stringify.valueAlloc(std.testing.allocator, foo, .{});
    defer std.testing.allocator.free(actual_foo_str);

    const expected_twenty_str =
        \\{"myint":20}
    ;
    const expected_foo_str =
        \\{"mystr":"foo"}
    ;

    try std.testing.expectEqualStrings(expected_twenty_str, actual_twenty_str);
    try std.testing.expectEqualStrings(expected_foo_str, actual_foo_str);
}

test "discriminated union serialization - inside struct" {
    const TestUnionTag = enum {
        int,
        string,

        pub const jsonStringify = @import("./enums.zig").stringifyEnumAsInt;
    };
    const TestUnion = union(TestUnionTag) {
        int: struct {
            tag: TestUnionTag,
            myint: u64,
        },
        string: struct {
            tag: TestUnionTag,
            mystr: []const u8,
        },

        const Mixin = DiscriminatedUnionMixin(@This(), "tag");
        pub const jsonStringify = Mixin.jsonStringify;
        pub const jsonParse = Mixin.jsonParse;
        pub const jsonParseFromValue = Mixin.jsonParseFromValue;
    };
    const TestStruct = struct {
        bar: []const u8,
        onion: TestUnion,
    };

    const twenty = TestStruct{ .bar = "bar", .onion = .{ .int = .{ .tag = .int, .myint = 20 } } };
    const foo = TestStruct{ .bar = "bar", .onion = .{ .string = .{ .tag = .string, .mystr = "foo" } } };

    const actual_twenty_str = try std.json.Stringify.valueAlloc(std.testing.allocator, twenty, .{});
    defer std.testing.allocator.free(actual_twenty_str);
    const actual_foo_str = try std.json.Stringify.valueAlloc(std.testing.allocator, foo, .{});
    defer std.testing.allocator.free(actual_foo_str);

    const expected_twenty_str =
        \\{"bar":"bar","onion":{"tag":0,"myint":20}}
    ;
    const expected_foo_str =
        \\{"bar":"bar","onion":{"tag":1,"mystr":"foo"}}
    ;

    try std.testing.expectEqualStrings(expected_twenty_str, actual_twenty_str);
    try std.testing.expectEqualStrings(expected_foo_str, actual_foo_str);
}

test "discriminated union deserialization" {
    const TestUnionTag = enum { int, string };
    const TestUnion = union(TestUnionTag) {
        int: struct {
            tag: TestUnionTag,
            myint: u64,
        },
        string: struct {
            tag: TestUnionTag,
            mystr: []const u8,
        },

        const Mixin = DiscriminatedUnionMixin(@This(), "tag");
        pub const jsonStringify = Mixin.jsonStringify;
        pub const jsonParse = Mixin.jsonParse;
        pub const jsonParseFromValue = Mixin.jsonParseFromValue;
    };

    const twenty_input =
        \\{"tag":"int","myint":20}
    ;
    const foo_input =
        \\{"tag":"string","mystr":"foo"}
    ;
    const twenty_actual = try std.json.parseFromSlice(TestUnion, std.testing.allocator, twenty_input, .{});
    defer twenty_actual.deinit();
    const foo_actual = try std.json.parseFromSlice(TestUnion, std.testing.allocator, foo_input, .{});
    defer foo_actual.deinit();

    const twenty_expected: TestUnion = .{ .int = .{ .tag = .int, .myint = 20 } };
    const foo_expected: TestUnion = .{ .string = .{ .tag = .string, .mystr = "foo" } };

    try std.testing.expectEqual(twenty_expected, twenty_actual.value);
    try std.testing.expectEqualDeep(foo_expected, foo_actual.value);
}

test "discriminated union deserialization - with int for enum" {
    const TestUnionTag = enum {
        int,
        string,

        pub const jsonStringify = @import("./enums.zig").stringifyEnumAsInt;
    };
    const TestUnion = union(TestUnionTag) {
        int: struct {
            tag: TestUnionTag,
            myint: u64,
        },
        string: struct {
            tag: TestUnionTag,
            mystr: []const u8,
        },

        const Mixin = DiscriminatedUnionMixin(@This(), "tag");
        pub const jsonStringify = Mixin.jsonStringify;
        pub const jsonParse = Mixin.jsonParse;
        pub const jsonParseFromValue = Mixin.jsonParseFromValue;
    };

    const twenty_input =
        \\{"tag":0,"myint":20}
    ;
    const foo_input =
        \\{"tag":1,"mystr":"foo"}
    ;
    const twenty_actual = try std.json.parseFromSlice(TestUnion, std.testing.allocator, twenty_input, .{});
    defer twenty_actual.deinit();
    const foo_actual = try std.json.parseFromSlice(TestUnion, std.testing.allocator, foo_input, .{});
    defer foo_actual.deinit();

    const twenty_expected: TestUnion = .{ .int = .{ .tag = .int, .myint = 20 } };
    const foo_expected: TestUnion = .{ .string = .{ .tag = .string, .mystr = "foo" } };

    try std.testing.expectEqual(twenty_expected, twenty_actual.value);
    try std.testing.expectEqualDeep(foo_expected, foo_actual.value);
}

test "discriminated union deserialization - no tag in program representation (should work the same)" {
    const TestUnionTag = enum { int, string };
    const TestUnion = union(TestUnionTag) {
        int: struct { myint: u64 },
        string: struct { mystr: []const u8 },

        const Mixin = DiscriminatedUnionMixin(@This(), "tag");
        pub const jsonStringify = Mixin.jsonStringify;
        pub const jsonParse = Mixin.jsonParse;
        pub const jsonParseFromValue = Mixin.jsonParseFromValue;
    };

    const twenty_input =
        \\{"tag":0,"myint":20}
    ;
    const foo_input =
        \\{"tag":1,"mystr":"foo"}
    ;
    const twenty_actual = try std.json.parseFromSlice(TestUnion, std.testing.allocator, twenty_input, .{ .ignore_unknown_fields = true });
    defer twenty_actual.deinit();
    const foo_actual = try std.json.parseFromSlice(TestUnion, std.testing.allocator, foo_input, .{ .ignore_unknown_fields = true });
    defer foo_actual.deinit();

    const twenty_expected: TestUnion = .{ .int = .{ .myint = 20 } };
    const foo_expected: TestUnion = .{ .string = .{ .mystr = "foo" } };

    try std.testing.expectEqual(twenty_expected, twenty_actual.value);
    try std.testing.expectEqualDeep(foo_expected, foo_actual.value);
}

test "discriminated union deserialization - inside struct" {
    const TestUnionTag = enum { int, string };
    const TestUnion = union(TestUnionTag) {
        int: struct {
            tag: TestUnionTag,
            myint: u64,
        },
        string: struct {
            tag: TestUnionTag,
            mystr: []const u8,
        },

        const Mixin = DiscriminatedUnionMixin(@This(), "tag");
        pub const jsonStringify = Mixin.jsonStringify;
        pub const jsonParse = Mixin.jsonParse;
        pub const jsonParseFromValue = Mixin.jsonParseFromValue;
    };
    const TestStruct = struct {
        bar: []const u8,
        onion: TestUnion,
    };

    const twenty_input =
        \\{"bar":"bar","onion":{"tag":0,"myint":20}}
    ;
    const foo_input =
        \\{"bar":"bar","onion":{"tag":1,"mystr":"foo"}}
    ;

    const twenty_actual = try std.json.parseFromSlice(TestStruct, std.testing.allocator, twenty_input, .{});
    defer twenty_actual.deinit();
    const foo_actual = try std.json.parseFromSlice(TestStruct, std.testing.allocator, foo_input, .{});
    defer foo_actual.deinit();

    const twenty_expected: TestStruct = .{ .bar = "bar", .onion = .{ .int = .{ .tag = .int, .myint = 20 } } };
    const foo_expected: TestStruct = .{ .bar = "bar", .onion = .{ .string = .{ .tag = .string, .mystr = "foo" } } };

    try std.testing.expectEqualDeep(twenty_expected, twenty_actual.value);
    try std.testing.expectEqualDeep(foo_expected, foo_actual.value);
}
