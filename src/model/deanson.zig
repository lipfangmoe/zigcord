//! just some utils for defining common things i'll need for type-safety with json

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

/// A jsonStringify function which inlines the value in a tagged union
pub fn stringifyUnionInline(self: anytype, json_writer: anytype) !void {
    comptime {
        const self_typeinfo = @typeInfo(@TypeOf(self));
        if (self_typeinfo != .Pointer) {
            @compileError("stringifyUnionInline may only be called on *const <unionT>, found \"" ++ @typeName(@TypeOf(self)) ++ "\"");
        }
        if (!self_typeinfo.Pointer.is_const) {
            @compileError("stringifyUnionInline may only be called on *const <unionT>, found \"" ++ @typeName(@TypeOf(self)) ++ "\"");
        }
        if (@typeInfo(self_typeinfo.Pointer.child) != .Union) {
            @compileError("stringifyUnionInline may only be called on *const <unionT>, found \"" ++ @typeName(@TypeOf(self)) ++ "\"");
        }
    }

    switch (self.*) {
        inline else => |value| try json_writer.write(value),
    }
}

test "union inline - regular" {
    const TestUnion = union(enum) {
        number: i64,
        string: []const u8,

        pub const jsonStringify = stringifyUnionInline;
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

        pub const jsonStringify = stringifyUnionInline;
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

/// Utility function to enable `Omittable` to work on structs.
///
/// Intended usage: add a declaration in your container as `pub const jsonStringify = stringifyWithOmit`.
pub fn stringifyWithOmit(self: anytype, json_writer: anytype) !void {
    const struct_info = comptime blk: {
        const self_typeinfo = @typeInfo(@TypeOf(self));
        if (self_typeinfo != .Pointer) {
            @compileError("stringifyWithOmit may only be called on *const <structT>, found \"" ++ @typeName(@TypeOf(self)) ++ "\"");
        }
        if (!self_typeinfo.Pointer.is_const) {
            @compileError("stringifyWithOmit may only be called on *const <structT>, found \"" ++ @typeName(@TypeOf(self)) ++ "\"");
        }
        if (@typeInfo(self_typeinfo.Pointer.child) != .Struct) {
            @compileError("stringifyWithOmit may only be called on *const <structT>, found \"" ++ @typeName(@TypeOf(self)) ++ "\"");
        }
        break :blk @typeInfo(self_typeinfo.Pointer.child).Struct;
    };

    try json_writer.beginObject();

    inline for (struct_info.fields) |field| {
        const rawValue = @field(self, field.name);

        if (@typeInfo(field.type) != .Union) {
            try json_writer.objectField(field.name);
            try json_writer.write(rawValue);
            continue;
        }

        const field_names = std.meta.fieldNames(field.type);
        if (field_names.len == 2 and std.mem.eql(u8, field_names[0], "some") and std.mem.eql(u8, field_names[1], "omitted")) {
            switch (rawValue) {
                .some => |some| {
                    try json_writer.objectField(field.name);
                    try json_writer.write(some);
                },
                .omitted => {},
            }
        } else {
            try json_writer.objectField(field.name);
            try json_writer.write(rawValue);
        }
    }

    try json_writer.endObject();
}

test "stringify with omit" {
    const OmittableTest = struct {
        omittable_omitted: Omittable(bool) = .{ .omitted = void{} },
        omittable_included: Omittable(bool) = .{ .some = true },
        nullable_omitted: Omittable(?bool) = .{ .omitted = void{} },
        nullable_null: Omittable(?bool) = .{ .some = null },
        nullable_nonnull: Omittable(?bool) = .{ .some = true },

        pub const jsonStringify = stringifyWithOmit;
    };

    const value = OmittableTest{};

    const valueAsStr = try std.json.stringifyAlloc(std.testing.allocator, value, .{});
    defer std.testing.allocator.free(valueAsStr);
    try std.testing.expectEqualStrings("{\"omittable_included\":true,\"nullable_null\":null,\"nullable_nonnull\":true}", valueAsStr);
}

/// Represents a value that can be omitted, and provides utilities for handling omittable+nullable JSON properties (ie, `prop?: ?string` in the Discord documentation).
///
/// In order for this to work properly, you must declare `pub const jsonStringify = stringifyWithOmit`
///
/// To properly represent an omitted field, define the field as `field: Omittable(T) = .{ .omitted = void{} }`.
///
/// To properly use this alongside nullable fields, define the field as `field: Omittable(?T) = .{ .omitted = void{} }`,
/// and a null field would then be represented as the value `Omittable(T){ .some = null }`.
pub fn Omittable(comptime T: type) type {
    return union(enum) {
        some: T,
        omitted: void,

        /// Turns Omittable(T) into a `?T`. If `T` is already an optional, `??T` is collapsed to `?T`.
        pub fn asSome(self: Omittable(T)) ?T {
            return switch (self) {
                .some => self.some,
                .null => null,
            };
        }

        /// Returns true if either `self` is omitted, or if `self` is null.
        pub fn isNothing(self: Omittable(T)) bool {
            return switch (self) {
                .some => |some| if (@typeInfo(T) == .Optional) some == null else false,
                .omitted => true,
            };
        }

        pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !Omittable(T) {
            return .{ .some = try std.json.innerParse(T, allocator, source, options) };
        }

        pub fn jsonStringify(_: Omittable(T), _: anytype) !void {
            @panic("make sure to use deanson.stringifyWithOmit on any types that use Omittable");
        }
    };
}

/// Combines two types together, such that their fields will be on the same level.
/// Especially useful for Discord's pesky "Returns T but with the following extra fields" types.
///
/// Duplicate fields will throw a compile-time error.
/// The declarations of the resultant struct will be the same as `Extension` type's declarations.
pub fn Extend(comptime Base: type, comptime Extension: type) type {
    const StructField = std.builtin.Type.StructField;

    const a_fields: []const StructField = std.meta.fields(Base);
    const b_fields: []const StructField = std.meta.fields(Extension);

    const all_fields = a_fields ++ b_fields;

    return @Type(.{ .Struct = std.builtin.Type.Struct{
        .layout = .auto,
        .fields = all_fields,
        .decls = std.meta.declarations(Extension),
        .is_tuple = false,
    } });
}
