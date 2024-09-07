const std = @import("std");

/// A jsonStringify function which inlines the current enum
pub fn stringifyEnumAsInt(self: anytype, json_writer: anytype) !void {
    comptime {
        const self_typeinfo = @typeInfo(@TypeOf(self));
        if (self_typeinfo != .Pointer) {
            @compileError("stringifyEnumAsInt may only be called on *const <enumT>, found \"" ++ @typeName(@TypeOf(self)) ++ "\"");
        }
        if (!self_typeinfo.Pointer.is_const) {
            @compileError("stringifyEnumAsInt may only be called on *const <enumT>, found \"" ++ @typeName(@TypeOf(self)) ++ "\"");
        }
        if (@typeInfo(self_typeinfo.Pointer.child) != .Enum) {
            @compileError("stringifyEnumAsInt may only be called on *const <enumT>, found \"" ++ @typeName(@TypeOf(self)) ++ "\"");
        }
    }
    try json_writer.write(@intFromEnum(self.*));
}

test "enum as int - regular" {
    const TestEnum = enum(u8) {
        zero,
        one,
        two,
        five = 5,

        pub const jsonStringify = stringifyEnumAsInt;
    };

    const actual_one_str = try std.json.stringifyAlloc(std.testing.allocator, TestEnum.one, .{});
    defer std.testing.allocator.free(actual_one_str);
    const actual_five_str = try std.json.stringifyAlloc(std.testing.allocator, TestEnum.five, .{});
    defer std.testing.allocator.free(actual_five_str);

    try std.testing.expectEqualStrings("1", actual_one_str);
    try std.testing.expectEqualStrings("5", actual_five_str);
}

test "enum as int - inside struct" {
    const TestEnum = enum(u8) {
        zero,
        one,
        two,
        five = 5,

        pub const jsonStringify = stringifyEnumAsInt;
    };
    const TestStruct = struct {
        foo: []const u8,
        nomnom: TestEnum,
    };

    const actual_one_str = try std.json.stringifyAlloc(std.testing.allocator, TestStruct{ .foo = "foo", .nomnom = .one }, .{});
    defer std.testing.allocator.free(actual_one_str);
    const actual_five_str = try std.json.stringifyAlloc(std.testing.allocator, TestStruct{ .foo = "foo", .nomnom = .five }, .{});
    defer std.testing.allocator.free(actual_five_str);

    try std.testing.expectEqualStrings("{\"foo\":\"foo\",\"nomnom\":1}", actual_one_str);
    try std.testing.expectEqualStrings("{\"foo\":\"foo\",\"nomnom\":5}", actual_five_str);
}
