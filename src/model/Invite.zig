const std = @import("std");
const model = @import("../root.zig").model;
const jconfig = @import("../root.zig").jconfig;
const Omittable = jconfig.Omittable;
const Partial = jconfig.Partial;

const Invite = @This();

// partial version of this object is included in `rest/endpoints/channel.zig`, changes here should be reflected in there.

type: Type,
code: []const u8,
guild: Omittable(model.guild.PartialGuild) = .omit,
channel: ?Partial(model.Channel),
inviter: Omittable(model.User) = .omit,
target_type: Omittable(i64) = .omit,
target_user: Omittable(model.User) = .omit,
target_application: Omittable(Partial(model.Application)) = .omit,
approximate_presence_count: Omittable(i64) = .omit,
approximate_member_count: Omittable(i64) = .omit,
expires_at: Omittable(?[]const u8) = .omit,
stage_instance: Omittable(InviteStageInstance) = .omit, // deprecated
guild_scheduled_event: Omittable(model.GuildScheduledEvent) = .omit,
flags: Omittable(Flags) = .omit,
roles: Omittable(PartialRole) = .omit,

pub const jsonStringify = jconfig.stringifyWithOmit;

pub const Type = enum(u2) {
    guild = 0,
    group_dm = 1,
    friend = 2,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};

pub const InviteStageInstance = struct {
    members: []const Partial(model.guild.Member),
    participant_count: i64,
    speaker_count: i64,
    topic: []const u8,
};

pub const WithMetadata = struct {
    invite: Invite,

    // extra metadata fields provided by some endpoints
    uses: i64,
    max_uses: i64,
    max_age: i64,
    temporary: bool,
    created_at: []const u8,

    const Mixin = jconfig.InlineSingleStructFieldMixin(@This(), "invite");
    pub const jsonStringify = Mixin.jsonStringify;
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;
};

pub const Flags = packed struct(u64) {
    is_guest_invite: bool = false,
    _padding: u63 = 0,

    const Mixin = model.PackedFlagsMixin(@This());
};

pub const PartialRole = struct {
    id: model.Snowflake,
    name: []const u8,
    position: i64,
    color: u64,
    colors: model.Role.Colors,
    icon: jconfig.Omittable(?[]const u8) = .omit,
    unicode_emoji: jconfig.Omittable(?[]const u8) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};
