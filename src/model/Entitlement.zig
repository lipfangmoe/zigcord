const std = @import("std");
const model = @import("../root.zig").model;
const jconfig = @import("../root.zig").jconfig;

id: model.Snowflake,
sku_id: model.Snowflake,
application_id: model.Snowflake,
user_id: jconfig.Omittable(model.Snowflake) = .omit,
type: Type,
deleted: bool,
starts_at: jconfig.Omittable([]const u8) = .omit,
ends_at: jconfig.Omittable([]const u8) = .omit,
guild_id: jconfig.Omittable(model.Snowflake) = .omit,
consumed: jconfig.Omittable(bool) = .omit,

pub const jsonStringify = jconfig.stringifyWithOmit;

pub const Type = enum(u8) {
    purchase = 1,
    premium_subscription = 2,
    developer_gift = 3,
    test_mode_purchase = 4,
    free_purchase = 5,
    user_gift = 6,
    premium_purchase = 7,
    application_subscription = 8,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};
