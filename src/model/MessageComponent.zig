const std = @import("std");
const model = @import("../root.zig").model;
const jconfig = @import("../root.zig").jconfig;
const omittable_util = @import("../jconfig/omit.zig");

const MessageComponent = @This();

type: Type,
id: jconfig.Omittable(u64) = .omit,
other_props: TypedProps,

pub fn initActionRow(id: ?u64, action_row: ActionRow) MessageComponent {
    return .{ .type = .action_row, .id = .initNullable(id), .other_props = .{ .action_row = action_row } };
}

pub fn initButton(id: ?u64, button: Button) MessageComponent {
    return .{ .type = .button, .id = .initNullable(id), .other_props = .{ .button = button } };
}

pub fn initStringSelect(id: ?u64, string_select: StringSelect) MessageComponent {
    return .{ .type = .string_select, .id = .initNullable(id), .other_props = .{ .string_select = string_select } };
}

pub fn initTextInput(id: ?u64, text_input: TextInput) MessageComponent {
    return .{ .type = .text_input, .id = .initNullable(id), .other_props = .{ .text_input = text_input } };
}

pub fn initUserSelect(id: ?u64, user_select: GenericSelect) MessageComponent {
    return .{ .type = .user_select, .id = .initNullable(id), .other_props = .{ .user_select = user_select } };
}

pub fn initRoleSelect(id: ?u64, role_select: GenericSelect) MessageComponent {
    return .{ .type = .role_select, .id = .initNullable(id), .other_props = .{ .role_select = role_select } };
}

pub fn initMentionableSelect(id: ?u64, mentionable_select: GenericSelect) MessageComponent {
    return .{ .type = .mentionable_select, .id = .initNullable(id), .other_props = .{ .mentionable_select = mentionable_select } };
}

pub fn initChannelSelect(id: ?u64, channel_select: ChannelSelect) MessageComponent {
    return .{ .type = .channel_select, .id = .initNullable(id), .other_props = .{ .channel_select = channel_select } };
}

pub fn initSection(id: ?u64, section: Section) MessageComponent {
    return .{ .type = .section, .id = .initNullable(id), .other_props = .{ .section = section } };
}

pub fn initTextDisplay(id: ?u64, text_display: TextDisplay) MessageComponent {
    return .{ .type = .text_display, .id = .initNullable(id), .other_props = .{ .text_display = text_display } };
}

pub fn initThumbnail(id: ?u64, thumbnail: Thumbnail) MessageComponent {
    return .{ .type = .thumbnail, .id = .initNullable(id), .other_props = .{ .thumbnail = thumbnail } };
}

pub fn initMediaGallery(id: ?u64, media_gallery: MediaGallery) MessageComponent {
    return .{ .type = .media_gallery, .id = .initNullable(id), .other_props = .{ .media_gallery = media_gallery } };
}

pub fn initFile(id: ?u64, file: File) MessageComponent {
    return .{ .type = .file, .id = .initNullable(id), .other_props = .{ .file = file } };
}

pub fn initSeparator(id: ?u64, separator: Separator) MessageComponent {
    return .{ .type = .separator, .id = .initNullable(id), .other_props = .{ .separator = separator } };
}

pub fn initContainer(id: ?u64, container: Container) MessageComponent {
    return .{ .type = .container, .id = .initNullable(id), .other_props = .{ .container = container } };
}

pub fn initLabel(id: ?u64, label: Label) MessageComponent {
    return .{ .type = .label, .id = .initNullable(id), .other_props = .{ .label = label } };
}

pub fn initFileUpload(id: ?u64, file_upload: FileUpload) MessageComponent {
    return .{ .type = .file_upload, .id = .initNullable(id), .other_props = .{ .file_upload = file_upload } };
}

pub fn jsonStringify(self: MessageComponent, jw: *std.json.Stringify) !void {
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

    new.id = if (root_obj.get("id")) |id_value| .initSome(try std.json.innerParseFromValue(u64, allocator, id_value, options)) else .omit;

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
    label = 18,
    file_upload = 19,

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
    label: Label,
    file_upload: FileUpload,
};

pub const ActionRow = struct {
    components: []const MessageComponent,
};

pub const Button = struct {
    custom_id: jconfig.Omittable([]const u8) = .omit,
    style: ButtonStyle,
    label: jconfig.Omittable([]const u8) = .omit,
    emoji: jconfig.Omittable(jconfig.Partial(model.Emoji)) = .omit,
    sku_id: jconfig.Omittable(model.Snowflake) = .omit,
    url: jconfig.Omittable([]const u8) = .omit,
    disabled: jconfig.Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub fn initPrimaryButton(custom_id: []const u8, options: InitButtonOptions) Button {
        return .{
            .custom_id = .initSome(custom_id),
            .style = .primary,
            .label = .initNullable(options.label),
            .emoji = .initNullable(options.emoji),
            .disabled = .initNullable(options.disabled),
        };
    }

    pub fn initSecondaryButton(custom_id: []const u8, options: InitButtonOptions) Button {
        return .{
            .custom_id = .initSome(custom_id),
            .style = .secondary,
            .label = .initNullable(options.label),
            .emoji = .initNullable(options.emoji),
            .disabled = .initNullable(options.disabled),
        };
    }

    pub fn initSuccessButton(custom_id: []const u8, options: InitButtonOptions) Button {
        return .{
            .custom_id = .initSome(custom_id),
            .style = .success,
            .label = .initNullable(options.label),
            .emoji = .initNullable(options.emoji),
            .disabled = .initNullable(options.disabled),
        };
    }

    pub fn initDangerButton(custom_id: []const u8, options: InitButtonOptions) Button {
        return .{
            .custom_id = .initSome(custom_id),
            .style = .danger,
            .label = .initNullable(options.label),
            .emoji = .initNullable(options.emoji),
            .disabled = .initNullable(options.disabled),
        };
    }

    pub fn initLinkButton(url: []const u8, options: InitButtonOptions) Button {
        return .{
            .url = .initSome(url),
            .style = .link,
            .label = .initNullable(options.label),
            .emoji = .initNullable(options.emoji),
            .disabled = .initNullable(options.disabled),
        };
    }

    pub fn initPremiumButton(sku_id: model.Snowflake, options: InitButtonOptions) Button {
        return .{
            .sku_id = .initSome(sku_id),
            .style = .premium,
            .label = .initNullable(options.label),
            .emoji = .initNullable(options.emoji),
            .disabled = .initNullable(options.disabled),
        };
    }

    pub const InitButtonOptions = struct {
        label: ?[]const u8 = null,
        emoji: ?jconfig.Partial(model.Emoji) = null,
        disabled: ?bool = null,
    };

    // https://discord.com/developers/docs/interactions/message-components#button-object-button-styles
    pub const ButtonStyle = enum(u8) {
        primary = 1,
        secondary = 2,
        success = 3,
        danger = 4,
        link = 5,
        premium = 6,

        pub const jsonStringify = jconfig.stringifyEnumAsInt;
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
    options: []const Option,
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

        const Mixin = jconfig.InlineUnionMixin(@This());
        pub const jsonStringify = Mixin.jsonStringify;
        pub const jsonParse = Mixin.jsonParse;
        pub const jsonParseFromValue = Mixin.jsonParseFromValue;
    };
};

/// Message.Flag.is_components_v2 must be set to use this
pub const TextDisplay = struct {
    content: []const u8,
};

/// Message.Flag.is_components_v2 must be set to use this
pub const Thumbnail = struct {
    media: UnfurledMediaItem,
    description: jconfig.Omittable(?[]const u8) = .omit,
    spoiler: jconfig.Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.OmittableFieldsMixin(@This()).jsonStringify;
};

/// Message.Flag.is_components_v2 must be set to use this
pub const MediaGallery = struct {
    items: []const Item,

    pub const Item = struct {
        media: UnfurledMediaItem,
        description: jconfig.Omittable(?[]const u8) = .omit,
        spoiler: jconfig.Omittable(bool) = .omit,

        pub const jsonStringify = jconfig.OmittableFieldsMixin(@This()).jsonStringify;
    };
};

/// Message.Flag.is_components_v2 must be set to use this
pub const File = struct {
    file: UnfurledMediaItem,
    spoiler: jconfig.Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.OmittableFieldsMixin(@This()).jsonStringify;
};

/// Message.Flag.is_components_v2 must be set to use this
pub const Separator = struct {
    divider: jconfig.Omittable(bool) = .omit,
    spacing: jconfig.Omittable(i64) = .omit,

    pub const jsonStringify = jconfig.OmittableFieldsMixin(@This()).jsonStringify;
};

/// Message.Flag.is_components_v2 must be set to use this
pub const Container = struct {
    components: []const MessageComponent,
    accent_color: jconfig.Omittable(?i64) = .omit,
    spoiler: jconfig.Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.OmittableFieldsMixin(@This()).jsonStringify;
};

pub const Label = struct {
    label: []const u8,
    description: jconfig.Omittable([]const u8) = .omit,
    /// must be one of text_input, string_select, user_select, role_select, mentionable_select, channel_select, file_upload.
    component: *const MessageComponent,

    pub const jsonStringify = jconfig.OmittableFieldsMixin(@This()).jsonStringify;
};

pub const FileUpload = struct {
    custom_id: []const u8,
    min_values: jconfig.Omittable(i64) = .omit,
    max_values: jconfig.Omittable(i64) = .omit,
    required: jconfig.Omittable(bool) = .omit,
};

pub const UnfurledMediaItem = struct {
    url: []const u8,
    proxy_url: jconfig.Omittable([]const u8) = .omit,
    height: jconfig.Omittable(?i64) = .omit,
    width: jconfig.Omittable(?i64) = .omit,
    content_type: jconfig.Omittable([]const u8) = .omit,
    attachment_id: jconfig.Omittable(model.Snowflake) = .omit,

    pub const jsonStringify = jconfig.OmittableFieldsMixin(@This()).jsonStringify;
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

    const expected: []const MessageComponent = &.{
        .initTextDisplay(null, .{ .content = "This is a message with components." }),
        .initActionRow(null, .{ .components = &.{
            .initButton(null, .{
                .label = .initSome("Click me!"),
                .style = .primary,
                .custom_id = .initSome("click_one"),
            }),
        } }),
    };

    const actual = try std.json.parseFromSlice([]const MessageComponent, std.testing.allocator, input, .{});
    defer actual.deinit();
    try std.testing.expectEqualDeep(expected, actual.value);
}

test "actual example" {
    const input = @embedFile("./test/components.test.json");
    try expectParsedSuccessfully(MessageComponent, std.testing.allocator, input, .{});
}

fn expectParsedSuccessfully(comptime T: type, allocator: std.mem.Allocator, input: []const u8, options: std.json.ParseOptions) !void {
    var reader: std.Io.Reader = .fixed(input);
    var json_reader: std.json.Reader = .init(allocator, &reader);
    defer json_reader.deinit();

    var diag: std.json.Diagnostics = .{};
    json_reader.enableDiagnostics(&diag);

    const parsed = std.json.parseFromTokenSource(T, allocator, &json_reader, options) catch |err| {
        std.debug.print("error while parsing json: {} (at {d}:{d})\n", .{ err, diag.getLine(), diag.getColumn() });
        std.debug.print("surrounding json at parse error:\n", .{});

        const surroundings = 10;
        const start = if (diag.getByteOffset() > surroundings) diag.getByteOffset() - 10 else 0;
        const end = if (diag.getByteOffset() < input.len - 10) diag.getByteOffset() + 10 else input.len;
        std.debug.print("{s}\n", .{input[start..end]});

        const padding = @min(start, surroundings);
        for (0..padding) |_| {
            std.debug.print(" ", .{});
        }
        std.debug.print("^", .{});

        return err;
    };
    defer parsed.deinit();
}
