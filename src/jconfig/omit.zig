const std = @import("std");

/// Represents a value that can be omitted, and provides utilities for handling omittable+nullable JSON properties (ie, `prop?: ?string` in the Discord documentation).
///
/// In order for this to work properly, you must declare `pub const jsonStringify = stringifyWithOmit`
///
/// To properly represent an omittable field that is not nullable, do not use this utility.
/// instead, define the field as `field: ?T = null`, and be sure to still add the above jsonStringify.
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

        pub fn jsonStringify(_: Omittable(T), _: *std.json.Stringify) !void {
            std.debug.panic("make sure to use jconfig.stringifyWithOmit on any types that use Omittable. (defined on something containing Omittable({s}))", .{@typeName(T)});
        }
    };
}

pub fn stringifyWithOmit(self: anytype, json_writer: *std.json.Stringify) std.json.Stringify.Error!void {
    try json_writer.beginObject();

    const struct_info = switch (@typeInfo(@TypeOf(self))) {
        .@"struct" => |s| s,
        .pointer => |p| @typeInfo(p.child).@"struct",
        else => @compileError("invalid type"),
    };

    inline for (struct_info.field_names, struct_info.field_types, struct_info.field_attrs) |field_name, FieldType, field_attrs| {
        const value = @field(self, field_name);
        if (comptime isOmittableField(FieldType, field_attrs)) {
            try writeOmittableFieldToStream(field_name, FieldType, value, json_writer);
        } else {
            try json_writer.objectField(field_name);
            try json_writer.write(value);
        }
    }

    try json_writer.endObject();
}

pub fn isOmittableField(comptime FieldType: type, comptime field_attrs: std.lang.Type.Struct.FieldAttributes) bool {
    return switch (@typeInfo(FieldType)) {
        .@"union" => |u| std.mem.eql(u8, u.field_names[0], "some") and std.mem.eql(u8, u.field_names[1], "omit"),
        .optional => field_attrs.default_value_ptr != null,
        else => false,
    };
}

/// assumes `isOmittableField` returned true
pub fn writeOmittableFieldToStream(
    comptime field_name: []const u8,
    comptime FieldType: type,
    value: anytype,
    json_writer: *std.json.Stringify,
) !void {
    switch (@typeInfo(FieldType)) {
        .@"union" => {
            switch (value) {
                .some => |some| {
                    try json_writer.objectField(field_name);
                    try json_writer.write(some);
                },
                .omit => {},
            }
        },
        .optional => {
            if (value) |some| {
                try json_writer.objectField(field_name);
                try json_writer.write(some);
            }
        },
        else => {
            @compileLog("writeOmittableFieldToStream called on incompatible field `{s}: {s}`", .{ field_name, @typeName(FieldType) });
        },
    }
}

test "stringify with omit" {
    const OmittableTest = struct {
        omittable_omitted: ?bool = null,
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
