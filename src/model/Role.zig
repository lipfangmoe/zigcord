const std = @import("std");
const model = @import("../root.zig").model;
const Omittable = model.deanson.Omittable;

/// role id
id: model.Snowflake,
/// role name
name: []const u8,
/// integer representing hex color code
color: u64,
/// true if this role is shown separately in the member listing sidebar
hoist: bool,
/// role icon hash, see https://discord.com/developers/docs/reference#image-formatting
icon: Omittable(?[]const u8) = .omit,
/// unicode representing this role's emoji
unicode_emoji: Omittable(?[]const u8) = .omit,
/// position of this role
position: i64,
/// permission bitset... why is this a string?
permissions: []const u8,
/// true if this role is managed by an integration
managed: bool,
/// true if this role is mentionable by everyone
mentionable: bool,
/// the tags which this role has. for some reason it is plural although it seems that it should be singular?
tags: Omittable(Tags) = .omit,
/// role flags as a bitfield
flags: Flags,

pub const jsonStringify = model.deanson.stringifyWithOmit;

pub const Tags = struct {
    bot_id: Omittable(model.Snowflake) = .omit,
    integration_id: Omittable(model.Snowflake) = .omit,
    premium_subscriber: Omittable(?u0) = .omit,
    subscription_listing_id: Omittable(model.Snowflake) = .omit,
    available_for_purchase: Omittable(?u0) = .omit,
    guild_connections: Omittable(?u0) = .omit,

    pub const stringifyWithOmit = model.deanson.stringifyWithOmit;
};

pub const Flags = packed struct {
    in_prompt: bool = false,

    pub usingnamespace model.PackedFlagsMixin(@This());
};
