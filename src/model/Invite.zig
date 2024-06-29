const std = @import("std");
const model = @import("root").model;
const deanson = model.deanson;
const Omittable = deanson.Omittable;

type: Type,
code: []const u8,
guild: Omittable(model.guild.Guild) = .omit,
channel: ?model.channel.Channel,
inviter: Omittable(model.User) = .omit,
target_type: Omittable(i64) = .omit,
target_user: Omittable(model.User) = .omit,
target_application: Omittable(model.Application) = .omit,
approximate_presence_count: Omittable(i64) = .omit,
approximate_member_count: Omittable(i64) = .omit,
expires_at: Omittable(?[]const u8) = .omit,
stage_instance: Omittable(InviteStageInstance) = .omit, // deprecated
guild_scheduled_event: Omittable(model.guild.GuildScheduledEvent) = .omit,

pub const jsonStringify = deanson.stringifyWithOmit;

pub const Type = enum(u2) {
    guild = 0,
    group_dm = 1,
    friend = 2,

    pub const jsonStringify = deanson.stringifyEnumAsInt;
};

pub const InviteStageInstance = struct {
    members: []const model.guild.Member,
    participant_count: i64,
    speaker_count: i64,
    topic: []const u8,
};

pub const WithMetadata = struct {
    type: Type,
    code: []const u8,
    guild: Omittable(model.guild.Guild) = .omit,
    channel: ?model.channel.Channel,
    inviter: Omittable(model.User) = .omit,
    target_type: Omittable(i64) = .omit,
    target_user: Omittable(model.User) = .omit,
    target_application: Omittable(model.Application) = .omit,
    approximate_presence_count: Omittable(i64) = .omit,
    approximate_member_count: Omittable(i64) = .omit,
    expires_at: Omittable(?[]const u8) = .omit,
    stage_instance: Omittable(InviteStageInstance) = .omit, // deprecated
    guild_scheduled_event: Omittable(model.guild.GuildScheduledEvent) = .omit,

    // extra metadata fields provided by some endpoints
    uses: i64,
    max_uses: i64,
    max_age: i64,
    temporary: bool,
    created_at: []const u8,

    pub const jsonStringify = deanson.stringifyWithOmit;
};
