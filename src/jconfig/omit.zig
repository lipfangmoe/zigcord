const std = @import("std");

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
            const inner_value = std.json.innerParseFromValue(T, allocator, source, options) catch |err| {
                std.log.err("Error occurred while parsing {s}: {}", .{ @typeName(Omittable(T)), err });
                return err;
            };
            return .{ .some = inner_value };
        }

        pub fn jsonStringify(_: Omittable(T), _: anytype) !void {
            @panic("make sure to use deanson.stringifyWithOmit or deanson.OmittableJsonMixin on any types that use Omittable");
        }
    };
}

pub fn OmittableFieldsMixin(comptime T: type) type {
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

pub fn writePossiblyOmittableFieldToStream(field: std.builtin.Type.StructField, value: anytype, json_writer: anytype) !void {
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
