const std = @import("std");
const model = @import("../root.zig").model;
const jconfig = @import("../root.zig").jconfig;

id: model.Snowflake,
user_id: model.Snowflake,
sku_ids: []const model.Snowflake,
entitlement_ids: []const model.Snowflake,
renewal_sku_ids: ?[]const model.Snowflake,
current_period_start: model.IsoTime,
current_period_end: model.IsoTime,
status: Status,
canceled_at: ?model.IsoTime,
country: jconfig.Omittable([]const u8) = .omit,

pub const jsonStringify = jconfig.OmittableFieldsMixin(@This()).jsonStringify;

pub const Status = enum(u8) {
    active = 0,
    ending = 1,
    inactive = 2,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};
