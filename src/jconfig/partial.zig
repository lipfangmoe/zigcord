const std = @import("std");
const jconfig = @import("../jconfig.zig");

/// Partial(T) takes a struct, and returns a similar struct but with all types set to be Omittable(T).
///
/// Noteworthy that due to language limitations, the returned struct has a single field, `partial`, which contains the
/// actual partial struct.
pub fn Partial(comptime T: type) type {
    const PartialType = switch (@typeInfo(T)) {
        .@"struct" => PartialStruct(T),
        else => @compileError("Only structs may be passed to Partial(T)"),
    };
    return struct {
        partial: PartialType,

        const Self = @This();

        pub fn jsonStringify(self: Self, json_writer: *std.json.Stringify) !void {
            try jconfig.stringifyWithOmit(self.partial, json_writer);
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
    const field_names: []const []const u8 = @typeInfo(T).@"struct".field_names;
    const old_field_types: []const type = @typeInfo(T).@"struct".field_types;
    const old_field_attributes = @typeInfo(T).@"struct".field_attrs;

    var new_field_types: [old_field_types.len]type = undefined;
    var new_field_attributes: [old_field_attributes.len]std.builtin.Type.Struct.FieldAttributes = undefined;

    inline for (old_field_types, old_field_attributes, &new_field_types, &new_field_attributes) |OldType, old_attrs, *new_type_ptr, *new_attrs| {
        if (comptime jconfig.omit.isOmittable(OldType)) {
            new_type_ptr.* = OldType;
            new_attrs.* = old_attrs;
        } else {
            const NewType = jconfig.Omittable(OldType);
            new_type_ptr.* = NewType;
            new_attrs.* = .{
                .@"align" = old_attrs.@"align",
                .@"comptime" = old_attrs.@"comptime",
                .default_value_ptr = &@as(NewType, .omit),
            };
        }
    }

    return @Struct(.auto, null, field_names, &new_field_types, &new_field_attributes);
}

test "Partial Stringify" {
    const MyPartial = Partial(struct {
        five: i64,
        something: []const u8,
        nested_type: struct { foo: i64 },
        omitted: u8,
        already_omittable: jconfig.Omittable(u8) = .omit,
        already_omittable_omitted: jconfig.Omittable(u8) = .omit,
    });

    const value = MyPartial{ .partial = .{
        .five = .initSome(5),
        .something = .initSome("lol"),
        .nested_type = .initSome(.{ .foo = 5 }),
        .already_omittable = .initSome(255),
    } };

    const value_json = try std.json.Stringify.valueAlloc(std.testing.allocator, value, .{});
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
        already_omittable: jconfig.Omittable(u8) = .omit,
        already_omittable_omitted: jconfig.Omittable(u8) = .omit,
    });

    const value = try std.json.parseFromSlice(MyPartial, std.testing.allocator,
        \\{"five":5,"something":"lol","nested_type":{"foo":5},"already_omittable":255}
    , .{});
    defer value.deinit();

    const my_partial = value.value;

    try std.testing.expectEqual(5, my_partial.partial.five.some);
    try std.testing.expectEqualStrings("lol", my_partial.partial.something.some);
    try std.testing.expectEqual(5, my_partial.partial.nested_type.some.foo);
    try std.testing.expectEqual(my_partial.partial.omitted, .omit);
    try std.testing.expectEqual(255, my_partial.partial.already_omittable.some);
    try std.testing.expectEqual(my_partial.partial.already_omittable_omitted, .omit);
}
