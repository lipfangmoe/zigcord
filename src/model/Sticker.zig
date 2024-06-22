const model = @import("../model.zig");
const Snowflake = model.Snowflake;
const Omittable = model.deanson.Omittable;

id: Snowflake,
pack_id: Omittable(Snowflake) = .{ .omitted = void{} },
name: []const u8,
description: ?[]const u8,
tags: []const u8,
asset: Omittable([]const u8) = .{ .omitted = void{} },
type: Type,
format_type: Format,
available: Omittable(bool) = .{ .omitted = void{} },
guild_id: Omittable(Snowflake) = .{ .omitted = void{} },
user: Omittable(model.User) = .{ .omitted = void{} },
sort_value: Omittable(i64) = .{ .omitted = void{} },

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
