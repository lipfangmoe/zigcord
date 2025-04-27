const std = @import("std");
const model = @import("../root.zig").model;
const jconfig = @import("../root.zig").jconfig;
const omittable_util = @import("../jconfig/omit.zig");

const MessageComponent = @This();

type: Type,
id: jconfig.Omittable(i32) = .omit,
other_props: TypedProps,

pub fn jsonStringify(self: MessageComponent, jw: anytype) !void {
    try jw.beginObject();
    try jw.objectField("type");
    try jw.write(self.type);
    if (self.id.asSome()) |id| {
        try jw.objectField("id");
        try jw.write(id);
    }

    switch (self.other_props) {
        inline else => |union_value| {
            const S = @TypeOf(union_value);
            if (@typeInfo(S) != .@"struct") {
                @compileError("all branches must be structs");
            }

            inline for (std.meta.fields(S)) |struct_field| {
                const field_value = @field(union_value, struct_field.name);
                try omittable_util.writePossiblyOmittableFieldToStream(struct_field, field_value, jw);
            }
        },
    }

    try jw.endObject();
}

pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !MessageComponent {
    const json_value = try std.json.innerParse(std.json.Value, allocator, source, options);
    return try jsonParseFromValue(allocator, json_value, options);
}

pub fn jsonParseFromValue(allocator: std.mem.Allocator, source: std.json.Value, options: std.json.ParseOptions) std.json.ParseFromValueError!MessageComponent {
    var new: MessageComponent = undefined;

    const root_obj = switch (source) {
        .object => |obj| obj,
        else => return error.UnexpectedToken,
    };

    const type_value = root_obj.get("type") orelse return error.MissingField;
    new.type = try std.json.innerParseFromValue(Type, allocator, type_value, options);

    new.id = if (root_obj.get("id")) |id_value| .{ .some = try std.json.innerParseFromValue(i32, allocator, id_value, options) } else .omit;

    switch (new.type) {
        inline else => |tag| {
            const BranchT = @FieldType(TypedProps, @tagName(tag));
            var inner_options = options;
            inner_options.ignore_unknown_fields = true;
            const value = try std.json.innerParseFromValue(BranchT, allocator, source, inner_options);
            new.other_props = @unionInit(TypedProps, @tagName(tag), value);
        },
    }

    return new;
}

pub const Type = enum(u8) {
    action_row = 1,
    button = 2,
    string_select = 3,
    text_input = 4,
    user_select = 5,
    role_select = 6,
    mentionable_select = 7,
    channel_select = 8,
    section = 9,
    text_display = 10,
    thumbnail = 11,
    media_gallery = 12,
    file = 13,
    separator = 14,
    container = 17,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};

pub const TypedProps = union(Type) {
    action_row: ActionRow,
    button: Button,
    string_select: StringSelect,
    text_input: TextInput,
    user_select: GenericSelect,
    role_select: GenericSelect,
    mentionable_select: GenericSelect,
    channel_select: ChannelSelect,
    section: Section,
    text_display: TextDisplay,
    thumbnail: Thumbnail,
    media_gallery: MediaGallery,
    file: File,
    separator: Separator,
    container: Container,
};

pub const ActionRow = struct {
    components: []const MessageComponent,
};

pub const Button = struct {
    custom_id: jconfig.Omittable([]const u8) = .omit,
    style: ButtonStyle,
    label: jconfig.Omittable([]const u8) = .omit,
    emoji: jconfig.Omittable(model.Emoji) = .omit,
    sku_id: jconfig.Omittable(model.Snowflake) = .omit,
    url: jconfig.Omittable([]const u8) = .omit,
    disabled: jconfig.Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    // https://discord.com/developers/docs/interactions/message-components#button-object-button-styles
    pub const ButtonStyle = enum(u8) {
        primary = 1,
        secondary = 2,
        success = 3,
        danger = 4,
        link = 5,
        premium = 6,
    };
};

pub const GenericSelect = struct {
    custom_id: []const u8,
    placeholder: jconfig.Omittable([]const u8) = .omit,
    default_values: jconfig.Omittable(DefaultValue) = .omit,
    min_values: jconfig.Omittable(i64) = .omit,
    max_values: jconfig.Omittable(i64) = .omit,
    disabled: jconfig.Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const DefaultValue = struct {
        id: model.Snowflake,
        type: enum { user, role, channel },
    };
};

pub const ChannelSelect = struct {
    custom_id: []const u8,
    channel_types: jconfig.Omittable([]const model.Channel.Type) = .omit,
    placeholder: jconfig.Omittable([]const u8) = .omit,
    default_values: jconfig.Omittable(DefaultValue) = .omit,
    min_values: jconfig.Omittable(i64) = .omit,
    max_values: jconfig.Omittable(i64) = .omit,
    disabled: jconfig.Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const DefaultValue = struct {
        id: model.Snowflake,
        type: enum { user, role, channel },
    };
};

pub const StringSelect = struct {
    custom_id: []const u8,
    options: Option,
    placeholder: jconfig.Omittable([]const u8) = .omit,
    min_values: jconfig.Omittable(i64) = .omit,
    max_values: jconfig.Omittable(i64) = .omit,
    disabled: jconfig.Omittable(bool) = .omit,

    pub const Option = struct {
        label: []const u8,
        value: []const u8,
        description: jconfig.Omittable([]const u8) = .omit,
        emoji: jconfig.Omittable(model.Emoji) = .omit,
        default: jconfig.Omittable(bool) = .omit,

        pub const jsonStringify = jconfig.stringifyWithOmit;
    };

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const TextInput = struct {
    custom_id: []const u8,
    style: Style,
    label: []const u8,
    min_length: jconfig.Omittable(u12) = .omit,
    max_length: jconfig.Omittable(u12) = .omit,
    required: jconfig.Omittable(bool) = .omit,
    value: jconfig.Omittable([]const u8) = .omit,
    placeholder: jconfig.Omittable([]const u8) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const Style = enum(u2) {
        short = 1,
        paragraph = 2,

        pub const jsonStringify = jconfig.stringifyEnumAsInt;
    };
};

/// Message.Flag.is_components_v2 must be set to use this
pub const Section = struct {
    components: TextDisplay,
    accessory: Accessory,

    pub const Accessory = union(enum) {
        thumbnail: Thumbnail,
        button: []const Button,

        pub usingnamespace jconfig.InlineUnionMixin(@This());
    };
};

/// Message.Flag.is_components_v2 must be set to use this
pub const TextDisplay = struct {
    content: []const u8,
};

/// Message.Flag.is_components_v2 must be set to use this
pub const Thumbnail = struct {
    media: UnfurledMediaItem,
    description: jconfig.Omittable([]const u8) = .omit,
    spoiler: jconfig.Omittable(bool) = .omit,

    pub usingnamespace jconfig.OmittableFieldsMixin(@This());
};

/// Message.Flag.is_components_v2 must be set to use this
pub const MediaGallery = struct {
    items: []const Item,

    pub const Item = struct {
        media: UnfurledMediaItem,
        description: jconfig.Omittable([]const u8) = .omit,
        spoiler: jconfig.Omittable(bool) = .omit,

        pub usingnamespace jconfig.OmittableFieldsMixin(@This());
    };
};

/// Message.Flag.is_components_v2 must be set to use this
pub const File = struct {
    file: UnfurledMediaItem,
    spoiler: jconfig.Omittable(bool) = .omit,

    pub usingnamespace jconfig.OmittableFieldsMixin(@This());
};

/// Message.Flag.is_components_v2 must be set to use this
pub const Separator = struct {
    divider: jconfig.Omittable(bool) = .omit,
    spacing: jconfig.Omittable(i64) = .omit,

    pub usingnamespace jconfig.OmittableFieldsMixin(@This());
};

/// Message.Flag.is_components_v2 must be set to use this
pub const Container = struct {
    components: []const MessageComponent,
    accent_color: jconfig.Omittable(?i64) = .omit,
    spoiler: jconfig.Omittable(bool) = .omit,

    pub usingnamespace jconfig.OmittableFieldsMixin(@This());
};

pub const UnfurledMediaItem = struct {
    url: []const u8,
    proxy_url: jconfig.Omittable([]const u8) = .omit,
    height: jconfig.Omittable(?i64) = .omit,
    width: jconfig.Omittable(?i64) = .omit,
    content_type: jconfig.Omittable(?i64) = .omit,

    pub usingnamespace jconfig.OmittableFieldsMixin(@This());
};

test "discord example" {
    const input =
        \\[
        \\    {
        \\      "type": 10,
        \\      "content": "This is a message with components."
        \\    },
        \\    {
        \\        "type": 1,
        \\        "components": [
        \\            {
        \\                "type": 2,
        \\                "label": "Click me!",
        \\                "style": 1,
        \\                "custom_id": "click_one"
        \\            }
        \\        ]
        \\    }
        \\]
    ;

    const expected = &.{
        MessageComponent{
            .type = .text_display,
            .other_props = .{ .text_display = .{ .content = "This is a message with components." } },
        },
        MessageComponent{
            .type = .action_row,
            .other_props = .{ .action_row = .{ .components = &.{
                MessageComponent{
                    .type = .button,
                    .other_props = .{ .button = Button{ .label = .{ .some = "Click me!" }, .style = .primary, .custom_id = .{ .some = "click_one" } } },
                },
            } } },
        },
    };

    const actual = try std.json.parseFromSlice([]const MessageComponent, std.testing.allocator, input, .{});
    defer actual.deinit();
    try std.testing.expectEqualDeep(expected, actual.value);
}
