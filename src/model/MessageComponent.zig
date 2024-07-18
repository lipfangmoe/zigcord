const model = @import("../root.zig").model;
const deanson = model.deanson;
const Omittable = deanson.Omittable;

const MessageComponent = @This();

type: Type,
components: []const MessageComponent,
typed_props: TypedProps,

pub const Type = enum(u8) {
    action_row = 1,
    button = 2,
    string_select = 3,
    text_input = 4,
    user_select = 5,
    role_select = 6,
    mentionable_select = 7,
    channel_select = 8,

    pub const jsonStringify = deanson.stringifyEnumAsInt;
};

pub const TypedProps = union(Type) {
    action_row: struct {}, // normally i would use void here, but void cannot be stringified
    button: Button,
    string_select: StringSelect,
    text_input: TextInput,
    user_select: Select,
    role_select: Select,
    mentionable_select: Select,
    channel_select: ChannelSelect,

    pub const jsonStringify = deanson.stringifyUnionInline;

    pub const Button = struct {
        custom_id: Omittable([]const u8) = .omit,
        style: ButtonStyle,
        label: Omittable([]const u8) = .omit,
        emoji: Omittable(model.Emoji) = .omit,
        sku_id: Omittable(model.Snowflake) = .omit,
        url: Omittable([]const u8) = .omit,
        disabled: Omittable(bool) = .omit,

        pub const jsonStringify = deanson.stringifyWithOmit;

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

    pub const Select = struct {
        custom_id: []const u8,
        placeholder: Omittable([]const u8) = .omit,
        default_values: Omittable(DefaultValue) = .omit,
        min_values: Omittable(i64) = .omit,
        max_values: Omittable(i64) = .omit,
        disabled: Omittable(bool) = .omit,

        pub const jsonStringify = deanson.stringifyWithOmit;

        pub const DefaultValue = struct {
            id: model.Snowflake,
            type: enum { user, role, channel },
        };
    };

    pub const ChannelSelect = struct {
        custom_id: []const u8,
        channel_types: Omittable([]const model.Channel.Type) = .omit,
        placeholder: Omittable([]const u8) = .omit,
        default_values: Omittable(DefaultValue) = .omit,
        min_values: Omittable(i64) = .omit,
        max_values: Omittable(i64) = .omit,
        disabled: Omittable(bool) = .omit,

        pub const jsonStringify = deanson.stringifyWithOmit;

        pub const DefaultValue = struct {
            id: model.Snowflake,
            type: enum { user, role, channel },
        };
    };

    pub const StringSelect = struct {
        custom_id: []const u8,
        options: Option,
        placeholder: Omittable([]const u8) = .omit,
        min_values: Omittable(i64) = .omit,
        max_values: Omittable(i64) = .omit,
        disabled: Omittable(bool) = .omit,

        pub const Option = struct {
            label: []const u8,
            value: []const u8,
            description: Omittable([]const u8) = .omit,
            emoji: Omittable(model.Emoji) = .omit,
            default: Omittable(bool) = .omit,

            pub const jsonStringify = deanson.stringifyWithOmit;
        };

        pub const jsonStringify = deanson.stringifyWithOmit;
    };

    pub const TextInput = struct {};
};
