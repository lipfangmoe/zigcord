const std = @import("std");
const jconfig = @import("jconfig");
const model = @import("../model.zig");

id: model.Snowflake,
guild_id: model.Snowflake,
channel_id: ?model.Snowflake,
creator_id: jconfig.Omittable(?model.Snowflake) = .omit,
name: []const u8,
description: jconfig.Omittable(?[]const u8) = .omit,
scheduled_start_time: model.IsoTime,
scheduled_end_time: ?model.IsoTime,
privacy_level: PrivacyLevel,
status: EventStatus,
entity_type: EntityType,
entity_id: ?model.Snowflake,
entity_metadata: ?EntityMetadata,
creator: ?model.User = null,
user_count: i64,
image: jconfig.Omittable(?[]const u8) = .omit,

pub const jsonStringify = jconfig.stringifyWithOmit;

pub const PrivacyLevel = enum(u2) {
    guild_only = 2,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};
pub const EventStatus = enum(u3) {
    scheduled = 1,
    active = 2,
    completed = 3,
    canceled = 4,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};
pub const EntityType = enum(u3) {
    stage_instance = 1,
    voice = 2,
    external = 3,
};
pub const EntityMetadata = struct {
    location: ?[]const u8 = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};
pub const EventUser = struct {
    guild_scheduled_event_id: model.Snowflake,
    user: model.User,
    member: ?model.guild.Member = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};
