const std = @import("std");
const model = @import("../model.zig");
const jconfig = @import("../root.zig").jconfig;
const Snowflake = model.Snowflake;
const Emoji = @This();

id: ?Snowflake,
name: ?[]const u8,
roles: jconfig.Omittable([]Snowflake) = .omit,
user: jconfig.Omittable(Snowflake) = .omit,
require_colons: jconfig.Omittable(bool) = .omit,
managed: jconfig.Omittable(bool) = .omit,
animated: jconfig.Omittable(bool) = .omit,
available: jconfig.Omittable(bool) = .omit,

pub const jsonStringify = jconfig.stringifyWithOmit;

pub fn fromUnicode(emoji: []const u8) Emoji {
    return Emoji{ .id = null, .name = emoji };
}
