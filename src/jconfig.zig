//! helpers for common JSON parsers and stringifiers that I've encountered.

// TODO - publish this as a standalone package, might be nice!

// TODO - a declarative API for field-specific parsers/stringifiers, most notably for union-resolving.
// would be very nice to write types like the following:
// pub const ContainsUnion = struct {
//
//     type: MyUnionType,
//     data: MyUnion,
//     some_omittable: jconfig.Omittable(i64) = .omit,
//
//     pub usingnamespace jconfig.Mixin(@This());
//
//     pub const json_config = jconfig.StructConfig{
//          .omittable_fields = true,
//          .zigfields_to_jsonprops = std.StaticStringMap([]const u8).initComptime(.{
//              .{"some_omittable", "someOmittable"}, // declares that the "some_omittable" field will be named "someOmittable" in JSON
//          }),
//          .union_tags = std.StaticStringMap([]const u8).initComptime(.{
//              .{"data", "type"}, // declares that the "data" field's union-tag should be determined by the "type" field
//          }),
//     }
//
//     pub const MyUnionType = enum(u1) {
//         foo,
//         bar,
//     	   pub const json_config = jconfig.EnumConfig{
//             .representation = .integer, // declares that this enum should be represented as an integer
//         }
//     }
//     pub const MyUnion = union(MyUnionType) {
//         foo: SomeType,
//         bar: SomeOtherType,
//     }
// }

pub const stringifyUnionInline = @import("./jconfig/inline_union.zig").stringifyUnionInline;
pub const InlineUnionMixin = @import("./jconfig/inline_union.zig").InlineUnionJsonMixin;
pub const Omittable = @import("./jconfig/omit.zig").Omittable;
pub const stringifyWithOmit = @import("./jconfig/omit.zig").stringifyWithOmit;
pub const OmittableFieldsMixin = @import("./jconfig/omit.zig").OmittableFieldsMixin;
pub const Partial = @import("./jconfig/partial.zig").Partial;
pub const stringifyEnumAsInt = @import("./jconfig/enums.zig").stringifyEnumAsInt;
pub const InlineSingleStructFieldMixin = @import("./jconfig/inline_single_struct_field.zig").InlineSingleStructFieldMixin;
