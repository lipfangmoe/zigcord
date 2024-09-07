const std = @import("std");
const model = @import("../root.zig").model;
const jconfig = @import("../root.zig").jconfig;
const Omittable = jconfig.Omittable;
const Partial = jconfig.Partial;

// partial version of this object is included in `rest/endpoints/guild.zig` (GetGuildVanityUrlResponse), changes here should be reflected in changes there.

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
    type: Type,
    code: []const u8,
    guild: Omittable(model.guild.Guild) = .omit,
    channel: ?model.Channel,
    inviter: Omittable(model.User) = .omit,
    target_type: Omittable(i64) = .omit,
    target_user: Omittable(model.User) = .omit,
    target_application: Omittable(model.Application) = .omit,
    approximate_presence_count: Omittable(i64) = .omit,
    approximate_member_count: Omittable(i64) = .omit,
    expires_at: Omittable(?[]const u8) = .omit,
    stage_instance: Omittable(InviteStageInstance) = .omit, // deprecated
    guild_scheduled_event: Omittable(model.GuildScheduledEvent) = .omit,

    // extra metadata fields provided by some endpoints
    uses: i64,
    max_uses: i64,
    max_age: i64,
    temporary: bool,
    created_at: []const u8,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};
