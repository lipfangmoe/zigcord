const std = @import("std");
const model = @import("../model.zig");
const Snowflake = model.Snowflake;
const Omittable = model.deanson.Omittable;

id: ?Snowflake,
name: ?[]const u8,
roles: Omittable([]Snowflake) = .omit,
user: Omittable(Snowflake) = .omit,
require_colons: Omittable(bool) = .omit,
managed: Omittable(bool) = .omit,
animated: Omittable(bool) = .omit,
available: Omittable(bool) = .omit,

const Emoji = @This();

pub fn fromUnicode(emoji: []const u8) Emoji {
    return Emoji{ .id = null, .name = emoji };
}

pub const jsonStringify = model.deanson.stringifyWithOmit;
