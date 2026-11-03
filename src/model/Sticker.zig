const jconfig = @import("jconfig");
const model = @import("../model.zig");

const Sticker = @This();

id: model.Snowflake,
pack_id: ?model.Snowflake = null,
name: []const u8,
description: ?[]const u8,
tags: []const u8,
asset: ?[]const u8 = null,
type: Type,
format_type: Format,
available: ?bool = null,
guild_id: ?model.Snowflake = null,
user: ?model.User = null,
sort_value: ?i64 = null,

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
    cover_sticker_id: ?model.Snowflake = null,
    description: []const u8,
    banner_asset_id: ?model.Snowflake = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};
