const std = @import("std");
const model = @import("../root.zig").model;
const jconfig = @import("../root.zig").jconfig;

const Role = @This();

/// role id
id: model.Snowflake,
/// role name
name: []const u8,
/// Deprecated: use `.colors` instead
color: u64,
/// the role's colors
colors: Colors,
/// true if this role is shown separately in the member listing sidebar
hoist: bool,
/// role icon hash, see https://discord.com/developers/docs/reference#image-formatting
icon: jconfig.Omittable(?[]const u8) = .omit,
/// unicode representing this role's emoji
unicode_emoji: jconfig.Omittable(?[]const u8) = .omit,
/// position of this role
position: i64,
/// permission bitset... why is this a string?
permissions: []const u8,
/// true if this role is managed by an integration
managed: bool,
/// true if this role is mentionable by everyone
mentionable: bool,
/// the tags which this role has. for some reason it is plural although it seems that it should be singular?
tags: jconfig.Omittable(Tags) = .omit,
/// role flags as a bitfield
flags: Flags,

pub const jsonStringify = jconfig.stringifyWithOmit;

pub const Tags = struct {
    bot_id: jconfig.Omittable(model.Snowflake) = .omit,
    integration_id: jconfig.Omittable(model.Snowflake) = .omit,
    premium_subscriber: jconfig.Omittable(?u0) = .omit,
    subscription_listing_id: jconfig.Omittable(model.Snowflake) = .omit,
    available_for_purchase: jconfig.Omittable(?u0) = .omit,
    guild_connections: jconfig.Omittable(?u0) = .omit,

    pub const stringifyWithOmit = jconfig.stringifyWithOmit;
};

pub const Flags = packed struct(u64) {
    in_prompt: bool = false,
    _overflow: u63 = 0,

    const Mixin = model.PackedFlagsMixin(@This());
    pub const format = Mixin.format;
    pub const jsonStringify = Mixin.jsonStringify;
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;
};

pub const Colors = struct {
    primary_color: u64,
    secondary_color: ?u63,
    tertiary_color: ?u63,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

test "api example" {
    const input =
        \\{"id": "41771983423143936","name": "WE DEM BOYZZ!!!!!!","color": 3447003,"colors": {  "primary_color": 3447003,  "secondary_color": null,  "tertiary_color": null},"hoist": true,"icon": "cf3ced8600b777c9486c6d8d84fb4327","unicode_emoji": null,"position": 1,"permissions": "66321471","managed": false,"mentionable": false,"flags": 0}
    ;

    const parsed = try std.json.parseFromSlice(Role, std.testing.allocator, input, .{});
    defer parsed.deinit();
}
