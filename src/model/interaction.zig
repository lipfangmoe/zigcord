pub const command = @import("./interaction/command.zig");
pub const command_option = @import("./interaction/command_option.zig");
const std = @import("std");
const model = @import("../model.zig");
const Snowflake = model.Snowflake;
const ApplicationCommandType = model.interaction.command.ApplicationCommandType;
const User = model.User;
const Member = model.guild.Member;
const Role = model.guild.Role;
const channel = model.guild.channel;
const Omittable = model.deanson.Omittable;

// TODO - a lot of this file still doesn't use Omittable

pub const Interaction = struct {
    id: Snowflake,
    application_id: Snowflake,
    type: InteractionType,
    data: Omittable(InteractionData) = .{ .omitted = void{} },
    guild_id: Omittable(Snowflake) = .{ .omitted = void{} },
    channel: Omittable(PartialChannel) = .{ .omitted = void{} },
    channel_id: Omittable(Snowflake) = .{ .omitted = void{} },
    member: Omittable(Member) = .{ .omitted = void{} },
};

// TODO - discord says `channel` is a partial channel, but doesn't say what's included/excluded.
pub const PartialChannel = std.json.ObjectMap;

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
    users: ?std.AutoArrayHashMap(Snowflake, User),
    members: ?std.AutoArrayHashMap(Snowflake, InteractionMember),
    roles: ?std.AutoArrayHashMap(Snowflake, Role),
    channels: ?std.AutoArrayHashMap(Snowflake, InteractionChannel),
    // TODO - implement jsonparse because these don't use
};

pub const InteractionMember = struct {
    /// The nickname this user uses in this guild
    nick: ?[]const u8 = null,
    /// A guild-specific avatar hash
    avatar: ?[]const u8 = null,
    /// The role ids that this user has
    roles: []Snowflake,
    /// when the user joined the guild, ISO8601 timestamp
    joined_at: []const u8,
    /// when the user started boosting the guild, ISO8601 timestamp
    premium_since: ?[]const u8 = null,
    /// guild member flags
    flags: Member.Flags,
    /// true if the user has not passed the guild's membership screening requirements
    pending: ?bool = null,
    /// returned inside of interaction objects, permissions of the member in the interacted channel
    permissions: ?[]const u8 = null,
    /// when the user's timeout will expire. ISO8601 timestamp. may be in the past; if so, the user is not timed out.
    communication_disabled_until: ?[]const u8,
};

pub const InteractionChannel = struct {
    /// id of the channel
    id: Snowflake,
    /// name of the channel
    name: ?[]const u8,
    /// type of the channel
    type: channel.Type,
    /// permissions the authenticated user has on the channel
    permissions: ?[]const u8,
    /// metadata about the thread
    thread_metadata: ?channel.ThreadMetadata,
    /// channel id that the thread belongs to
    parent_id: ?Snowflake,
};

pub const InteractionResponse = struct {
    type: Type,
    data: Omittable(InteractionCallbackData) = .{ .omitted = void{} },

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
