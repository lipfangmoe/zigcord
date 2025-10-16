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

        pub fn initSome(val: T) Omittable(T) {
            return .{ .some = val };
        }

        pub fn initNullable(val: ?T) Omittable(T) {
            return if (val) |nn| .{ .some = nn } else .omit;
        }

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
                .some => |some| if (@typeInfo(T) == .optional) some == null else false,
                .omit => true,
            };
        }

        pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !Omittable(T) {
            return .initSome(try std.json.innerParse(T, allocator, source, options));
        }

        pub fn jsonParseFromValue(allocator: std.mem.Allocator, source: std.json.Value, options: std.json.ParseOptions) !Omittable(T) {
            return .initSome(try std.json.innerParseFromValue(T, allocator, source, options));
        }

        pub fn jsonStringify(_: Omittable(T), _: anytype) !void {
            std.debug.panic("make sure to use jconfig.stringifyWithOmit or jconfig.OmittableFieldsMixin on any types that use Omittable. (problematic type {s})", .{@typeName(T)});
        }
    };
}

pub fn OmittableFieldsMixin(comptime T: type) type {
    return struct {
        pub fn jsonStringify(self: T, json_writer: anytype) @typeInfo(@TypeOf(json_writer)).pointer.child.Error!void {
            return stringifyWithOmit(self, json_writer);
        }
    };
}

/// Utility function to enable `Omittable` to work on structs.
///
/// Intended usage: add a declaration in your container as `pub const jsonStringify = stringifyWithOmit`.
pub fn stringifyWithOmit(self: anytype, json_writer: anytype) @typeInfo(@TypeOf(json_writer)).pointer.child.Error!void {
    const struct_info: std.builtin.Type.Struct = comptime blk: {
        const self_typeinfo = @typeInfo(@TypeOf(self));
        switch (self_typeinfo) {
            .pointer => |ptr| {
                if (@typeInfo(ptr.child) != .@"struct") {
                    @compileError("stringifyWithOmit may only be called on structs and pointers to structs. Found \"" ++ @typeName(@TypeOf(self)) ++ "\"");
                }
                break :blk @typeInfo(ptr.child).@"struct";
            },
            .@"struct" => |strct| {
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
    const is_omittable = comptime blk: {
        if (@typeInfo(field.type) != .@"union") {
            break :blk false;
        }
        const field_names = std.meta.fieldNames(field.type);
        break :blk field_names.len == 2 and std.mem.eql(u8, field_names[0], "some") and std.mem.eql(u8, field_names[1], "omit");
    };

    if (is_omittable) {
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
        omittable_included: Omittable(bool) = .initSome(true),
        nullable_omitted: Omittable(?bool) = .omit,
        nullable_null: Omittable(?bool) = .initSome(null),
        nullable_null_initnullable: Omittable(?bool) = .initNullable(@as(?bool, null)),
        nullable_omit_initnullable: Omittable(?bool) = .initNullable(@as(??bool, null)),
        nullable_nonnull: Omittable(?bool) = .initSome(true),

        pub const jsonStringify = stringifyWithOmit;
    };

    const value = OmittableTest{};

    const valueAsStr = try std.json.Stringify.valueAlloc(std.testing.allocator, value, .{});
    defer std.testing.allocator.free(valueAsStr);

    const expected =
        \\{"omittable_included":true,"nullable_null":null,"nullable_null_initnullable":null,"nullable_nonnull":true}
    ;
    try std.testing.expectEqualStrings(expected, valueAsStr);
}
