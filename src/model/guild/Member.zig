const std = @import("std");
const model = @import("../../model.zig");
const Snowflake = model.Snowflake;
const User = model.User;
const Omittable = model.deanson.Omittable;

/// The User object for this guild member
user: Omittable(User) = .{ .omitted = void{} },
/// The nickname this user uses in this guild
nick: Omittable(?[]const u8) = .{ .omitted = void{} },
/// A guild-specific avatar hash
avatar: Omittable(?[]const u8) = .{ .omitted = void{} },
/// The role ids that this user has
roles: []Snowflake,
/// when the user joined the guild, ISO8601 timestamp
joined_at: []const u8,
/// when the user started boosting the guild, ISO8601 timestamp
premium_since: Omittable(?[]const u8) = .{ .omitted = void{} },
/// true if this user is deafened in voice channels
deaf: bool,
/// true if this user is muted in voice channels
mute: bool,
/// guild member flags
flags: Flags,
/// true if the user has not passed the guild's membership screening requirements
pending: Omittable(bool) = .{ .omitted = void{} },
/// returned inside of interaction objects, permissions of the member in the interacted channel
permissions: Omittable([]const u8) = .{ .omitted = void{} },
/// when the user's timeout will expire. ISO8601 timestamp. may be in the past; if so, the user is not timed out.
communication_disabled_until: Omittable(?[]const u8) = .{ .omitted = void{} },

pub const jsonStringify = model.deanson.stringifyWithOmit;

pub const Flags = model.Flags(enum {
    did_rejoin,
    completed_onboarding,
    bypasses_verification,
    started_onboarding,
});
