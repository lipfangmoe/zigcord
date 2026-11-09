const std = @import("std");
const jconfig = @import("jconfig");
const model = @import("../model.zig");

const Invite = @This();

type: Type,
code: []const u8,
guild: ?model.guild.PartialGuild = null,
channel: ?model.Channel.Partial,
inviter: ?model.User = null,
target_type: ?i64 = null,
target_user: ?model.User = null,
target_application: ?model.Application.Partial = null,
approximate_presence_count: ?i64 = null,
approximate_member_count: ?i64 = null,
expires_at: jconfig.Omittable(?[]const u8) = .omit,
stage_instance: ?InviteStageInstance = null, // deprecated
guild_scheduled_event: ?model.GuildScheduledEvent = null,
flags: ?Flags = null,
roles: ?PartialRole = null,

pub const jsonStringify = jconfig.stringifyWithOmit;

pub const Partial = struct {
    type: ?Type = null,
    code: ?[]const u8 = null,
    guild: ?model.guild.PartialGuild = null,
    channel: jconfig.Omittable(?model.Channel.Partial) = .omit,
    inviter: ?model.User = null,
    target_type: ?i64 = null,
    target_user: ?model.User = null,
    target_application: ?model.Application.Partial = null,
    approximate_presence_count: ?i64 = null,
    approximate_member_count: ?i64 = null,
    expires_at: jconfig.Omittable(?[]const u8) = .omit,
    stage_instance: ?InviteStageInstance = null, // deprecated
    guild_scheduled_event: ?model.GuildScheduledEvent = null,
    flags: ?Flags = null,
    roles: ?PartialRole = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    test "is partial invite" {
        try jconfig.testing.expectIsPartialOfStrict(Invite.Partial, Invite);
    }
};

pub const Type = enum(u2) {
    guild = 0,
    group_dm = 1,
    friend = 2,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};

pub const InviteStageInstance = struct {
    members: []const model.guild.Member.Partial,
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
    pub const format = Mixin.format;
    pub const formatNumber = Mixin.formatNumber;
    pub const jsonStringify = Mixin.jsonStringify;
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;
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

    test "is partial role (loose)" {
        try jconfig.testing.expectIsPartialOfLoose(PartialRole, model.Role);
    }
};
