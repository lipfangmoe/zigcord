const model = @import("../../model.zig");
const User = @import("../User.zig");
const Snowflake = model.Snowflake;
const Omittable = model.deanson.Omittable;

id: Snowflake,
pack_id: Omittable(Snowflake) = .omit,
name: []const u8,
description: ?[]const u8,
tags: []const u8,
asset: Omittable([]const u8) = .omit,
type: Type,
format_type: FormatType,
/// may be false due to loss of server boosts
available: Omittable(bool) = .omit,
guild_id: Omittable(Snowflake) = .omit,
user: Omittable(User) = .omit,
sort_value: Omittable(i64) = .omit,

pub const jsonStringify = model.deanson.stringifyWithOmit;

pub const Type = enum(u8) {
    standard = 1,
    guild,
};

pub const FormatType = enum(u8) {
    png = 1,
    apng,
    lottie,
    gif,
};
