const std = @import("std");
const jconfig = @import("jconfig");
const model = @import("../model.zig");
const Snowflake = model.Snowflake;
const User = @import("User.zig");
const Emoji = @This();

id: ?Snowflake,
name: ?[]const u8,
roles: ?[]Snowflake = null,
user: ?User = null,
require_colons: ?bool = null,
managed: ?bool = null,
animated: ?bool = null,
available: ?bool = null,

pub const Partial = struct {
    id: jconfig.Omittable(?Snowflake) = .omit,
    name: jconfig.Omittable(?[]const u8) = .omit,
    roles: ?[]Snowflake = null,
    user: ?User = null,
    require_colons: ?bool = null,
    managed: ?bool = null,
    animated: ?bool = null,
    available: ?bool = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const jsonStringify = jconfig.stringifyWithOmit;

pub fn fromUnicode(emoji: []const u8) Emoji {
    return Emoji{ .id = null, .name = emoji };
}
