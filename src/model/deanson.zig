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

pub fn OmittableJsonMixin(comptime T: type) type {
    return struct {
        pub fn jsonStringify(self: T, json_writer: anytype) @typeInfo(@TypeOf(json_writer)).Pointer.child.Error!void {
            return stringifyWithOmit(self, json_writer);
        }
    };
}

/// Utility function to enable `Omittable` to work on structs.
///
/// Intended usage: add a declaration in your container as `pub const jsonStringify = stringifyWithOmit`.
pub fn stringifyWithOmit(self: anytype, json_writer: anytype) @typeInfo(@TypeOf(json_writer)).Pointer.child.Error!void {
    const struct_info: std.builtin.Type.Struct = comptime blk: {
        const self_typeinfo = @typeInfo(@TypeOf(self));
        switch (self_typeinfo) {
            .Pointer => |ptr| {
                if (@typeInfo(ptr.child) != .Struct) {
                    @compileError("stringifyWithOmit may only be called on structs and pointers to structs. Found \"" ++ @typeName(@TypeOf(self)) ++ "\"");
                }
                break :blk @typeInfo(ptr.child).Struct;
            },
            .Struct => |strct| {
                break :blk strct;
            },
            else => @compileError("stringifyWithOmit may only be called on structs and pointers to structs. Found \"" ++ @typeName(@TypeOf(self)) ++ "\""),
        }
    };

    try json_writer.beginObject();

    inline for (struct_info.fields) |field| {
        const value = @field(self, field.name);
        try writePossiblyOmittableFieldToStream(field, value, json_writer);
    }

    try json_writer.endObject();
}

fn writePossiblyOmittableFieldToStream(field: std.builtin.Type.StructField, value: anytype, json_writer: anytype) !void {
    if (@typeInfo(field.type) != .Union) {
        try json_writer.objectField(field.name);
        try json_writer.write(value);
        return;
    }

    const field_names = std.meta.fieldNames(field.type);
    if (field_names.len == 2 and std.mem.eql(u8, field_names[0], "some") and std.mem.eql(u8, field_names[1], "omit")) {
        switch (value) {
            .some => |some| {
                try json_writer.objectField(field.name);
                try json_writer.write(some);
            },
            .omit => {},
        }
    } else {
        try json_writer.objectField(field.name);
        try json_writer.write(value);
    }
}

test "stringify with omit" {
    const OmittableTest = struct {
        omittable_omitted: Omittable(bool) = .omit,
        omittable_included: Omittable(bool) = .{ .some = true },
        nullable_omitted: Omittable(?bool) = .omit,
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
/// To properly represent an omitted field, define the field as `field: Omittable(T) = .omit`.
///
/// To properly use this alongside nullable fields, define the field as `field: Omittable(?T) = .omit`,
/// and a null field would then be represented as the value `.{ .some = null }`.
pub fn Omittable(comptime T: type) type {
    return union(enum(u1)) {
        some: T,
        omit: void,

        /// Turns Omittable(T) into a `?T`. If `T` is already an optional, `??T` is collapsed to `?T`.
        pub fn asSome(self: Omittable(T)) ?T {
            return switch (self) {
                .some => self.some,
                .omit => null,
            };
        }

        /// Returns true if either `self` is omitted, or if `self` is null.
        pub fn isNothing(self: Omittable(T)) bool {
            return switch (self) {
                .some => |some| if (@typeInfo(T) == .Optional) some == null else false,
                .omit => true,
            };
        }

        pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !Omittable(T) {
            return .{ .some = try std.json.innerParse(T, allocator, source, options) };
        }

        pub fn jsonParseFromValue(allocator: std.mem.Allocator, source: std.json.Value, options: std.json.ParseOptions) !Omittable(T) {
            return .{ .some = try std.json.innerParseFromValue(T, allocator, source, options) };
        }

        pub fn jsonStringify(_: Omittable(T), _: anytype) !void {
            @panic("make sure to use deanson.stringifyWithOmit or deanson.OmittableJsonMixin on any types that use Omittable");
        }
    };
}

/// Partial(T) takes a struct, and returns a similar struct but with all types set to be Omittable(T).
///
/// Noteworthy that due to language limitations, the returned struct has a single field, `partial`, which contains the
/// actual partial struct.
pub fn Partial(comptime T: type) type {
    const PartialType = switch (@typeInfo(T)) {
        .Struct => PartialStruct(T),
        else => @compileError("Only structs may be passed to Partial(T)"),
    };
    return struct {
        partial: PartialType,

        const Self = @This();

        pub fn jsonStringify(self: Self, json_writer: anytype) !void {
            try stringifyWithOmit(self.partial, json_writer);
        }

        pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !Self {
            return Self{ .partial = try std.json.innerParse(PartialType, allocator, source, options) };
        }

        pub fn jsonParseFromValue(allocator: std.mem.Allocator, source: std.json.Value, options: std.json.ParseOptions) !Self {
            return Self{ .partial = try std.json.innerParseFromValue(PartialType, allocator, source, options) };
        }
    };
}

fn PartialStruct(comptime T: type) type {
    const fields: []const std.builtin.Type.StructField = std.meta.fields(T);
    var new_fields: [fields.len]std.builtin.Type.StructField = undefined;
    inline for (0.., fields) |idx, field| {
        new_fields[idx] = switch (@typeInfo(field.type)) {
            .Union => blk: {
                const field_names = std.meta.fieldNames(field.type);
                if (field_names.len == 2 and std.mem.eql(u8, field_names[0], "some") and std.mem.eql(u8, field_names[1], "omit")) {
                    break :blk field;
                }
                const OmittableType = Omittable(field.type);
                break :blk std.builtin.Type.StructField{
                    .name = field.name,
                    .type = OmittableType,
                    .alignment = @alignOf(OmittableType),
                    .is_comptime = false,
                    .default_value = &@as(OmittableType, .omit),
                };
            },
            else => blk: {
                const OmittableType = Omittable(field.type);
                break :blk std.builtin.Type.StructField{
                    .name = field.name,
                    .type = OmittableType,
                    .alignment = @alignOf(OmittableType),
                    .is_comptime = false,
                    .default_value = &@as(OmittableType, .omit),
                };
            },
        };
    }

    return @Type(.{ .Struct = std.builtin.Type.Struct{
        .layout = .auto,
        .backing_integer = null,
        .is_tuple = @typeInfo(T).Struct.is_tuple,
        .fields = &new_fields,
        .decls = &.{},
    } });
}

test "Partial Stringify" {
    const MyPartial = Partial(struct {
        five: i64,
        something: []const u8,
        nested_type: struct { foo: i64 },
        omitted: u8,
        already_omittable: Omittable(u8) = .omit,
        already_omittable_omitted: Omittable(u8) = .omit,
    });

    const value = MyPartial{ .partial = .{
        .five = .{ .some = 5 },
        .something = .{ .some = "lol" },
        .nested_type = .{ .some = .{ .foo = 5 } },
        .already_omittable = .{ .some = 255 },
    } };

    const value_json = try std.json.stringifyAlloc(std.testing.allocator, value, .{});
    defer std.testing.allocator.free(value_json);

    try std.testing.expectEqualStrings(
        \\{"five":5,"something":"lol","nested_type":{"foo":5},"already_omittable":255}
    , value_json);
}

test "Partial Parse" {
    const MyPartial = Partial(struct {
        five: i64,
        something: []const u8,
        nested_type: struct { foo: i64 },
        omitted: u8,
        already_omittable: Omittable(u8) = .omit,
        already_omittable_omitted: Omittable(u8) = .omit,
    });

    const value = try std.json.parseFromSlice(MyPartial, std.testing.allocator,
        \\{"five":5,"something":"lol","nested_type":{"foo":5},"already_omittable":255}
    , .{});
    defer value.deinit();

    const my_partial = value.value;

    try std.testing.expectEqual(5, my_partial.partial.five.some);
    try std.testing.expectEqualStrings("lol", my_partial.partial.something.some);
    try std.testing.expectEqual(5, my_partial.partial.nested_type.some.foo);
    try std.testing.expectEqual(void{}, my_partial.partial.omitted.omit);
    try std.testing.expectEqual(255, my_partial.partial.already_omittable.some);
    try std.testing.expectEqual(void{}, my_partial.partial.already_omittable_omitted.omit);
}

/// For `struct{ field1: struct{ foo: i64 }, field2: struct{ bar: u64 }, pub usingnamespace InlineFieldJsonMixin(@This(), "field1"); }`,
/// returns a mixin which will JSON stringify and parse the struct into a `struct{ foo: i64, field2: struct{ bar: u64 }}`
pub fn InlineFieldJsonMixin(comptime T: type, comptime inline_field: []const u8) type {
    return struct {
        pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !T {
            // way too lazy to give this a more efficient implementation. maybe in the future.
            const json_value = try std.json.innerParse(std.json.Value, allocator, source, options);
            return jsonParseFromValue(allocator, json_value, options);
        }

        pub fn jsonParseFromValue(allocator: std.mem.Allocator, source: std.json.Value, options: std.json.ParseOptions) !T {
            const object = switch (source) {
                .object => |obj| obj,
                else => return error.UnexpectedToken,
            };

            // allow unknown fields
            var inner_options = options;
            inner_options.ignore_unknown_fields = true;

            var t: T = undefined;
            inline for (std.meta.fields(T)) |field| {
                @field(t, field.name) = blk: {
                    if (std.mem.eql(u8, field.name, inline_field)) {
                        const field_value = try std.json.innerParseFromValue(field.type, allocator, source, inner_options);
                        break :blk field_value;
                    } else {
                        if (object.get(field.name)) |value| {
                            const field_value = try std.json.innerParseFromValue(field.type, allocator, value, options);
                            break :blk field_value;
                        } else {
                            if (field.default_value) |default_value| {
                                break :blk @as(*const field.type, @alignCast(@ptrCast(default_value))).*;
                            } else {
                                return error.MissingField;
                            }
                        }
                    }
                };
            }

            return t;
        }

        pub fn jsonStringify(self: T, jw: anytype) !void {
            try jw.beginObject();
            inline for (std.meta.fields(T)) |outer_field| {
                const outer_field_value = @field(self, outer_field.name);
                if (std.mem.eql(u8, outer_field.name, inline_field)) {
                    if (std.meta.hasMethod(outer_field.type, "jsonStringify")) {
                        const jw_inline_obj = inlineFieldsJsonWriteStream(jw);
                        try outer_field_value.jsonStringify(jw_inline_obj);
                        continue;
                    }
                    inline for (std.meta.fields(outer_field.type)) |inner_field| {
                        const inner_field_value = @field(outer_field_value, inner_field.name);
                        try writePossiblyOmittableFieldToStream(inner_field, inner_field_value, jw);
                    }
                } else {
                    try writePossiblyOmittableFieldToStream(outer_field, outer_field_value, jw);
                }
            }
            try jw.endObject();
        }
    };
}

// not public because this should work for my specific use-case, but may be incorrect on other use-cases
fn inlineFieldsJsonWriteStream(jw: anytype) InlineFieldsJsonWriteStream(@TypeOf(jw)) {
    return .{ .underlying_write_stream = jw };
}
fn InlineFieldsJsonWriteStream(UnderlyingWriteStream: type) type {
    return struct {
        underlying_write_stream: UnderlyingWriteStream,
        nesting_level: u64 = 0,

        const Self = @This();

        // changed methods
        pub fn beginObject(self: *Self) !void {
            if (self.nesting_level > 0) {
                try self.underlying_write_stream.beginObject();
            }
            self.nesting_level += 1;
        }
        pub fn endObject(self: *Self) !void {
            if (self.nesting_level > 1) {
                try self.underlying_write_stream.endObject();
            }
            self.nesting_level -= 1;
        }
        pub fn beginArray(self: *Self) !void {
            if (self.nesting_level > 0) {
                try self.underlying_write_stream.beginArray();
            }
            self.nesting_level += 1;
        }
        pub fn endArray(self: *Self) !void {
            if (self.nesting_level > 1) {
                try self.underlying_write_stream.endArray();
            }
            self.nesting_level -= 1;
        }

        // unchanged methods
        pub fn print(self: *Self, comptime fmt: []const u8, args: anytype) !void {
            return self.underlying_write_stream.print(fmt, args);
        }
        pub fn write(self: *Self, value: anytype) !void {
            return self.underlying_write_stream.write(value);
        }
        pub fn objectField(self: *Self, name: []const u8) !void {
            return self.underlying_write_stream.objectField(name);
        }
        pub fn objectFieldRaw(self: *Self, name: []const u8) !void {
            return self.underlying_write_stream.objectFieldRaw(name);
        }
        pub fn deinit(self: *Self) void {
            self.underlying_write_stream.deinit();
        }
    };
}

test "InlineFieldJsonMixin - stringify" {
    const TestStruct = struct {
        field1: struct { foo: i64 },
        field2: struct { bar: u64 },

        pub usingnamespace InlineFieldJsonMixin(@This(), "field1");
    };

    const t = TestStruct{ .field1 = .{ .foo = 5 }, .field2 = .{ .bar = 100 } };
    var out = std.BoundedArray(u8, 100){};

    try std.json.stringify(t, .{}, out.writer());

    try std.testing.expectEqualStrings(
        \\{"foo":5,"field2":{"bar":100}}
    , out.constSlice());
}

test "InlineFieldJsonMixin - parse" {
    const TestStruct = struct {
        field1: struct { foo: i64 },
        field2: struct { bar: u64 },

        pub usingnamespace InlineFieldJsonMixin(@This(), "field1");
    };

    const str =
        \\{"foo":5,"field2":{"bar":100}}
    ;
    const actual = try std.json.parseFromSlice(TestStruct, std.testing.allocator, str, .{});
    defer actual.deinit();

    const expected = TestStruct{ .field1 = .{ .foo = 5 }, .field2 = .{ .bar = 100 } };
    try std.testing.expectEqual(expected, actual.value);
}
