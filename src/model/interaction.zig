const std = @import("std");
const deancord = @import("../root.zig");
const jconfig = deancord.jconfig;
const model = deancord.model;
const rest = deancord.rest;
const Snowflake = model.Snowflake;

pub const command = @import("./interaction/command.zig");
pub const command_option = @import("./interaction/command_option.zig");

pub const Interaction = struct {
    id: Snowflake,
    application_id: Snowflake,
    type: InteractionType,
    data: jconfig.Omittable(InteractionData) = .omit,
    guild: jconfig.Omittable(model.guild.PartialGuild) = .omit,
    guild_id: jconfig.Omittable(Snowflake) = .omit,
    channel: jconfig.Omittable(jconfig.Partial(model.Channel)) = .omit,
    channel_id: jconfig.Omittable(Snowflake) = .omit,
    member: jconfig.Omittable(model.guild.Member) = .omit,
    user: jconfig.Omittable(model.User) = .omit,
    token: []const u8,
    version: i64,
    message: jconfig.Omittable(model.Message) = .omit,
    app_permissions: model.Permissions,
    locale: jconfig.Omittable([]const u8) = .omit,
    guild_locale: jconfig.Omittable([]const u8) = .omit,
    entitlements: []const model.Entitlement,
    authorizing_integration_owners: std.json.Value, // TODO: https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-authorizing-integration-owners-object
    context: jconfig.Omittable(Context) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const InteractionType = enum(u8) {
    application_command = 2,
    message_component = 3,
    application_command_autocomplete = 4,
    modal_submit = 5,
    ping = 1, // see InteractionData.ping as to why this is at the end

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};

pub const InteractionData = union(InteractionType) {
    application_command: ApplicationCommandInteractionData,
    message_component: MessageComponentData,
    application_command_autocomplete: ApplicationCommandAutocompleteInteractionData,
    modal_submit: ModalSubmitData,
    ping: void, // ping at the end because otherwise InlineUnionMixin will always deserialize into `void`

    pub usingnamespace jconfig.InlineUnionMixin(@This());
};

pub const ApplicationCommandInteractionData = struct {
    id: Snowflake,
    name: []const u8,
    type: command.ApplicationCommandType,
    resolved: jconfig.Omittable(ResolvedData) = .omit,
    options: jconfig.Omittable([]const ApplicationCommandInteractionDataOption) = .omit,
    guild_id: jconfig.Omittable(model.Snowflake) = .omit,
    target_id: jconfig.Omittable(model.Snowflake) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ApplicationCommandInteractionDataOption = struct {
    name: []const u8,
    type: command.ApplicationCommandType,
    value: jconfig.Omittable(Value) = .omit,
    options: jconfig.Omittable([]const ApplicationCommandInteractionDataOption) = .omit,
    focused: jconfig.Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const Value = union(enum) {
        string: []const u8,
        int: i64,
        double: f64,
        boolean: bool,

        pub usingnamespace jconfig.InlineUnionMixin(@This());
    };
};

pub const MessageComponentData = struct {
    custom_id: []const u8,
    component_type: model.MessageComponent.Type,
    values: jconfig.Omittable(model.MessageComponent.TypedProps.StringSelect.Option) = .omit,
    resolved: jconfig.Omittable(ResolvedData) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ModalSubmitData = struct {
    custom_id: []const u8,
    components: []const model.MessageComponent,
};

pub const ApplicationCommandAutocompleteInteractionData = struct {
    name: []const u8,
    type: command_option.ApplicationCommandOptionType,
    value: jconfig.Omittable(Value) = .omit,
    options: jconfig.Omittable([]const jconfig.Partial(ApplicationCommandInteractionData)) = .omit,
    focused: jconfig.Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const Value = union(enum) {
        string: []const u8,
        int: i64,
        double: f64,
        boolean: bool,

        pub usingnamespace jconfig.InlineUnionMixin(@This());
    };
};

pub const ResolvedData = struct {
    users: jconfig.Omittable(std.json.ArrayHashMap(model.User)) = .omit,
    members: jconfig.Omittable(std.json.ArrayHashMap(InteractionMember)) = .omit,
    roles: jconfig.Omittable(std.json.ArrayHashMap(model.Role)) = .omit,
    channels: jconfig.Omittable(std.json.ArrayHashMap(jconfig.Partial(model.Channel))) = .omit,
    messages: jconfig.Omittable(std.json.ArrayHashMap(model.Message)) = .omit,
    attachments: jconfig.Omittable(std.json.ArrayHashMap(model.Message.Attachment)) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const InteractionMember = struct {
    nick: jconfig.Omittable(?[]const u8) = .omit,
    avatar: jconfig.Omittable(?[]const u8) = .omit,
    roles: []Snowflake,
    joined_at: model.IsoTime,
    premium_since: jconfig.Omittable(?model.IsoTime) = .omit,
    flags: model.guild.Member.Flags,
    pending: jconfig.Omittable(bool) = .omit,
    permissions: jconfig.Omittable([]const u8) = .omit,
    communication_disabled_until: jconfig.Omittable(?model.IsoTime) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const InteractionResponse = struct {
    type: Type,
    data: jconfig.Omittable(InteractionCallbackData) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const Type = enum(u8) {
        pong = 1,
        channel_message_with_source = 4,
        deferred_channel_message_with_source = 5,
        deferred_update_mesasge = 6,
        update_message = 7,
        application_command_autocomplete_result = 8,
        modal = 9,
        premium_required = 10,

        pub const jsonStringify = jconfig.stringifyEnumAsInt;
    };
};

pub const InteractionCallbackData = struct {
    tts: jconfig.Omittable(bool) = .omit,
    content: jconfig.Omittable([]const u8) = .omit,
    embeds: jconfig.Omittable([]const model.Message.Embed) = .omit,
    allowed_mentions: jconfig.Omittable(model.Message.AllowedMentions) = .omit,
    flags: jconfig.Omittable(model.Message.Flags) = .omit,
    components: jconfig.Omittable([]const model.MessageComponent) = .omit,
    attachments: jconfig.Omittable([]const jconfig.Partial(model.Message.Attachment)) = .omit,
    poll: jconfig.Omittable(model.Poll) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const Context = enum(u2) {
    guil = 0,
    bot_dm = 1,
    private_channel = 2,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};
