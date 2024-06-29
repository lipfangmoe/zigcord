const model = @import("../model.zig");
const Snowflake = model.Snowflake;
const Omittable = model.deanson.Omittable;

id: Snowflake,
pack_id: Omittable(Snowflake) = .omit,
name: []const u8,
description: ?[]const u8,
tags: []const u8,
asset: Omittable([]const u8) = .omit,
type: Type,
format_type: Format,
available: Omittable(bool) = .omit,
guild_id: Omittable(Snowflake) = .omit,
user: Omittable(model.User) = .omit,
sort_value: Omittable(i64) = .omit,

pub const jsonStringify = model.deanson.stringifyWithOmit;

pub const Type = enum(u2) {
    standard = 1,
    guild = 2,

    pub const jsonStringify = model.deanson.stringifyEnumAsInt;
};

pub const Format = enum(u3) {
    png = 1,
    apng = 2,
    lottie = 3,
    gif = 4,

    pub const jsonStringify = model.deanson.stringifyEnumAsInt;
};

pub const Item = struct {
    id: Snowflake,
    name: []const u8,
    format_type: Format,
};
