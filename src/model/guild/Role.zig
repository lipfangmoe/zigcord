const std = @import("std");
const model = @import("../../model.zig");
const Snowflake = model.Snowflake;
const Omittable = model.deanson.Omittable;

/// role id
id: Snowflake,
/// role name
name: []const u8,
/// integer representing hex color code
color: u64,
/// true if this role is shown separately in the member listing sidebar
hoist: bool,
/// role icon hash, see https://discord.com/developers/docs/reference#image-formatting
icon: Omittable(?[]const u8) = .{ .omitted = void{} },
/// unicode representing this role's emoji
unicode_emoji: Omittable(?[]const u8) = .{ .omitted = void{} },
/// position of this role
position: i64,
/// permission bitset... why is this a string?
permissions: []const u8,
/// true if this role is managed by an integration
managed: bool,
/// true if this role is mentionable by everyone
mentionable: bool,
/// the tags which this role has. for some reason it is plural although it seems that it should be singular?
tags: Omittable(Tags) = .{ .omitted = void{} },
/// role flags as a bitfield
flags: Flags,

pub const jsonStringify = model.deanson.stringifyWithOmit;

pub const Tags = struct {
    bot_id: Omittable(Snowflake) = .{ .omitted = void{} },
    integration_id: Omittable(Snowflake) = .{ .omitted = void{} },
    premium_subscriber: Omittable(?enum {}) = .{ .omitted = void{} },
    subscription_listing_id: Omittable(Snowflake) = .{ .omitted = void{} },
    available_for_purchase: Omittable(?enum {}) = .{ .omitted = void{} },
    guild_connections: Omittable(?enum {}) = .{ .omitted = void{} },

    pub const stringifyWithOmit = model.deanson.stringifyWithOmit;
};

pub const Flags = model.Flags(enum {
    in_prompt,
});
