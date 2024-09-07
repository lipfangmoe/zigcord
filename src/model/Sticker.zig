const deancord = @import("../root.zig");
const model = deancord.model;
const jconfig = deancord.jconfig;

const Sticker = @This();

id: model.Snowflake,
pack_id: jconfig.Omittable(model.Snowflake) = .omit,
name: []const u8,
description: ?[]const u8,
tags: []const u8,
asset: jconfig.Omittable([]const u8) = .omit,
type: Type,
format_type: Format,
available: jconfig.Omittable(bool) = .omit,
guild_id: jconfig.Omittable(model.Snowflake) = .omit,
user: jconfig.Omittable(model.User) = .omit,
sort_value: jconfig.Omittable(i64) = .omit,

pub const jsonStringify = jconfig.stringifyWithOmit;

pub const Type = enum(u2) {
    standard = 1,
    guild = 2,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};

pub const Format = enum(u3) {
    png = 1,
    apng = 2,
    lottie = 3,
    gif = 4,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};

pub const Item = struct {
    id: model.Snowflake,
    name: []const u8,
    format_type: Format,
};

pub const Pack = struct {
    id: model.Snowflake,
    stickers: []const Sticker,
    name: []const u8,
    sku_id: model.Snowflake,
    cover_sticker_id: jconfig.Omittable(model.Snowflake) = .omit,
    description: []const u8,
    banner_asset_id: jconfig.Omittable(model.Snowflake) = .omit,

    pub usingnamespace jconfig.OmittableFieldsMixin(@This());
};
