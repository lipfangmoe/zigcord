const std = @import("std");
const jsonconfig = @import("../jsonconfig.zig");

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
            try jsonconfig.stringifyWithOmit(self.partial, json_writer);
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
                const OmittableType = jsonconfig.Omittable(field.type);
                break :blk std.builtin.Type.StructField{
                    .name = field.name,
                    .type = OmittableType,
                    .alignment = @alignOf(OmittableType),
                    .is_comptime = false,
                    .default_value = &@as(OmittableType, .omit),
                };
            },
            else => blk: {
                const OmittableType = jsonconfig.Omittable(field.type);
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
        already_omittable: jsonconfig.Omittable(u8) = .omit,
        already_omittable_omitted: jsonconfig.Omittable(u8) = .omit,
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
        already_omittable: jsonconfig.Omittable(u8) = .omit,
        already_omittable_omitted: jsonconfig.Omittable(u8) = .omit,
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
