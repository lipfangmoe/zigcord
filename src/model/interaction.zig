const std = @import("std");
const deancord = @import("../root.zig");
const model = deancord.model;
const rest = deancord.rest;
const zigtime = @import("zig-time");
const Snowflake = model.Snowflake;
const ApplicationCommandType = model.interaction.command.ApplicationCommandType;
const User = model.User;
const Member = model.guild.Member;
const Role = model.guild.Role;
const Omittable = model.deanson.Omittable;

pub const command = @import("./interaction/command.zig");
pub const command_option = @import("./interaction/command_option.zig");

// TODO - a lot of this file still doesn't use Omittable

pub const Interaction = struct {
    id: Snowflake,
    application_id: Snowflake,
    type: InteractionType,
    data: Omittable(InteractionData) = .omit,
    guild_id: Omittable(Snowflake) = .omit,
    channel: Omittable(PartialChannel) = .omit,
    channel_id: Omittable(Snowflake) = .omit,
    member: Omittable(Member) = .omit,
};

// TODO - discord says `channel` is a partial channel, but doesn't say what's included/excluded.
pub const PartialChannel = std.json.Value;

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
    type: ApplicationCommandType,
    resolved: ResolvedData,
};

pub const ResolvedData = struct {
    users: Omittable(std.json.ArrayHashMap(User)) = .omit,
    members: Omittable(std.json.ArrayHashMap(InteractionMember)) = .omit,
    roles: Omittable(std.json.ArrayHashMap(Role)) = .omit,
    channels: Omittable(std.json.ArrayHashMap(InteractionChannel)) = .omit,
    messages: Omittable(std.json.ArrayHashMap(model.Message)) = .omit,
    attachments: Omittable(std.json.ArrayHashMap(model.Message.Attachment)) = .omit,

    pub const jsonStringify = model.deanson.stringifyWithOmit;
};

pub const InteractionMember = struct {
    /// The nickname this user uses in this guild
    nick: ?[]const u8 = null,
    /// A guild-specific avatar hash
    avatar: ?[]const u8 = null,
    /// The role ids that this user has
    roles: []Snowflake,
    /// when the user joined the guild
    joined_at: []zigtime.DateTime,
    /// when the user started boosting the guild
    premium_since: ?[]zigtime.DateTime = null,
    /// guild member flags
    flags: Member.Flags,
    /// true if the user has not passed the guild's membership screening requirements
    pending: ?bool = null,
    /// returned inside of interaction objects, permissions of the member in the interacted channel
    permissions: ?[]const u8 = null,
    /// when the user's timeout will expire. may be in the past; if so, the user is not timed out.
    communication_disabled_until: ?[]zigtime.DateTime,
};

pub const InteractionChannel = struct {
    /// id of the channel
    id: Snowflake,
    /// name of the channel
    name: ?[]const u8,
    /// type of the channel
    type: model.Channel.Type,
    /// permissions the authenticated user has on the channel
    permissions: ?[]const u8,
    /// metadata about the thread
    thread_metadata: ?model.Channel.ThreadMetadata,
    /// channel id that the thread belongs to
    parent_id: ?Snowflake,
};

pub const InteractionResponse = struct {
    type: Type,
    data: Omittable(InteractionCallbackData) = .omit,

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

// TODO
pub const InteractionCallbackData = struct {};
