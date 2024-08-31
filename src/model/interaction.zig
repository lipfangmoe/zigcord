const std = @import("std");
const deancord = @import("../root.zig");
const model = deancord.model;
const rest = deancord.rest;
const Snowflake = model.Snowflake;
const deanson = model.deanson;

pub const command = @import("./interaction/command.zig");
pub const command_option = @import("./interaction/command_option.zig");

pub const Interaction = struct {
    id: Snowflake,
    application_id: Snowflake,
    type: InteractionType,
    data: deanson.Omittable(InteractionData) = .omit,
    guild: deanson.Omittable(model.guild.Guild) = .omit,
    guild_id: deanson.Omittable(Snowflake) = .omit,
    channel: deanson.Omittable(deanson.Partial(model.Channel)) = .omit,
    channel_id: deanson.Omittable(Snowflake) = .omit,
    member: deanson.Omittable(model.guild.Member) = .omit,
    user: deanson.Omittable(model.User) = .omit,
    token: []const u8,
    version: i64,
    message: deanson.Omittable(model.Message) = .omit,
    app_permissions: model.Permissions,
    locale: deanson.Omittable([]const u8) = .omit,
    guild_locale: deanson.Omittable([]const u8) = .omit,
    entitlements: []const model.Entitlement,
    authorizing_integration_owners: std.json.Value, // TODO: https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-authorizing-integration-owners-object
    context: deanson.Omittable(Context) = .omit,

    pub const jsonStringify = deanson.stringifyWithOmit;
};

pub const InteractionType = enum(u8) {
    ping = 1,
    application_command,
    message_component,
    application_command_autocomplete,
    modal_submit,
};

pub const InteractionData = union(enum) {
    ping: void,
    application_command: ApplicationCommandData,
};

pub const ApplicationCommandData = struct {
    id: Snowflake,
    name: []const u8,
    type: command.ApplicationCommandType,
    resolved: ResolvedData,
};

pub const ResolvedData = struct {
    users: deanson.Omittable(std.json.ArrayHashMap(model.User)) = .omit,
    members: deanson.Omittable(std.json.ArrayHashMap(InteractionMember)) = .omit,
    roles: deanson.Omittable(std.json.ArrayHashMap(model.Role)) = .omit,
    channels: deanson.Omittable(std.json.ArrayHashMap(deanson.Partial(model.Channel))) = .omit,
    messages: deanson.Omittable(std.json.ArrayHashMap(model.Message)) = .omit,
    attachments: deanson.Omittable(std.json.ArrayHashMap(model.Message.Attachment)) = .omit,

    pub const jsonStringify = deanson.stringifyWithOmit;
};

pub const InteractionMember = struct {
    nick: deanson.Omittable(?[]const u8) = .omit,
    avatar: deanson.Omittable(?[]const u8) = .omit,
    roles: []Snowflake,
    joined_at: model.IsoTime,
    premium_since: deanson.Omittable(?[]model.IsoTime) = .omit,
    flags: model.guild.Member.Flags,
    pending: deanson.Omittable(bool) = .omit,
    permissions: deanson.Omittable([]const u8) = .omit,
    communication_disabled_until: deanson.Omittable(?[]model.IsoTime) = .omit,

    pub const jsonStringify = deanson.stringifyWithOmit;
};

pub const InteractionResponse = struct {
    type: Type,
    data: deanson.Omittable(InteractionCallbackData) = .omit,

    pub const Type = enum(u8) {
        pong = 1,
        channel_message_with_source = 4,
        deferred_channel_message_with_source = 5,
        deferred_update_mesasge = 6,
        update_message = 7,
        application_command_autocomplete_result = 8,
        modal = 9,
        premium_required = 10,
    };
};

pub const InteractionCallbackData = struct {
    tts: deanson.Omittable(bool) = .omit,
    content: deanson.Omittable([]const u8) = .omit,
    embeds: deanson.Omittable([]const model.Message.Embed) = .omit,
    allowed_mentions: deanson.Omittable([]const model.Message.AllowedMentions) = .omit,
    flags: deanson.Omittable(model.Message.Flags) = .omit,
    components: deanson.Omittable([]const model.MessageComponent) = .omit,
    attachments: deanson.Omittable([]const deanson.Partial(model.Message.Attachment)) = .omit,
    poll: deanson.Omittable(model.Poll) = .omit,

    pub const jsonStringify = deanson.stringifyWithOmit;
};

pub const Context = enum(u2) {
    guil = 0,
    bot_dm = 1,
    private_channel = 2,

    pub const jsonStringify = deanson.stringifyEnumAsInt;
};
