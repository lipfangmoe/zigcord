const std = @import("std");
const model = @import("../model.zig");
const deanson = model.deanson;
const Omittable = deanson.Omittable;

id: model.Snowflake,
sku_id: model.Snowflake,
application_id: model.Snowflake,
user_id: Omittable(model.Snowflake) = .{ .omitted = void{} },
type: Type,
deleted: bool,
starts_at: Omittable([]const u8) = .{ .omitted = void{} },
ends_at: Omittable([]const u8) = .{ .omitted = void{} },
guild_id: Omittable(model.Snowflake) = .{ .omitted = void{} },
consumed: Omittable(bool) = .{ .omitted = void{} },

pub const jsonStringify = deanson.stringifyWithOmit;

pub const Type = enum(u8) {
    purchase = 1,
    premium_subscription = 2,
    developer_gift = 3,
    test_mode_purchase = 4,
    free_purchase = 5,
    user_gift = 6,
    premium_purchase = 7,
    application_subscription = 8,

    pub const jsonStringify = deanson.stringifyEnumAsInt;
};
