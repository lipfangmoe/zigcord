const std = @import("std");
const model = @import("../model.zig");
const Omittable = model.deanson.Omittable;
const Partial = model.deanson.Partial;

/// This user's snowflake
id: model.Snowflake,
/// This user's username
username: []const u8,
/// This user's discriminator. May likely be #0 after the username update.
discriminator: []const u8,
/// This user's display name. This should be used where possible.
global_name: ?[]const u8,
/// This user's avatar hash. See https://discord.com/developers/docs/reference#image-formatting
avatar: ?[]const u8,
/// true if this user is a bot.
bot: Omittable(bool) = .omit,
/// true if this user is a system user (ie, part of the urgent message system, whatever that is)
system: Omittable(bool) = .omit,
/// true if this user has MFA enabled
mfa_enabled: Omittable(bool) = .omit,
/// This user's banner hash. See https://discord.com/developers/docs/reference#image-formatting
banner: Omittable(?[]const u8) = .omit,
/// This user's banner color encoded as an integer.
accent_color: Omittable(?i64) = .omit,
/// The user's chosen language. See https://discord.com/developers/docs/reference#locales
locale: Omittable([]const u8) = .omit,
/// true if this user's email is verified.
verified: Omittable(bool) = .omit,
/// The user's email
email: Omittable(?[]const u8) = .omit,
/// The user's account flags
flags: Omittable(Flags) = .omit,
/// What kind of nitro this user has
premium_type: Omittable(NitroType) = .omit,
/// The user's public flags
public_flags: Omittable(Flags) = .omit,
/// The user's avatar decoration data.
avatar_decoration_data: Omittable(?AvatarDecorationData) = .omit,

pub const Flags = model.Flags(enum(u6) {
    /// discord employee
    staff,
    /// partnered server owner
    partner,
    /// hypesquad events member
    hypesquad,
    /// bug hunter level 1
    bug_hunter_level_1,
    /// house of bravery member
    hypesquad_online_house_1 = 6,
    /// house of brilliance member
    hypesquad_online_house_2,
    /// house of balance member
    hypesquad_online_house_3,
    /// early nitro supporter
    premium_early_supporter,
    /// user is actually a team. see https://discord.com/developers/docs/topics/teams
    team_pseudo_user,
    /// bug hunter level 2
    bug_hunter_level_2 = 14,
    /// set if this user is a verified bot
    verified_bot = 16,
    /// early verified bot developer
    verified_developer,
    /// moderator programs alumnus
    certified_moderator,
    /// bot uses only http interactions, and is shown in the online member list
    bot_http_interactions,
    /// active developer
    active_developer = 22,
});

pub const NitroType = enum(u8) {
    none,
    nitro_classic,
    nitro,
    nitro_basic,
};

pub const AvatarDecorationData = struct {
    asset: []const u8,
    sku_id: model.Snowflake,
};

pub const Connection = struct {
    id: []const u8,
    name: []const u8,
    type: []const u8,
    revoked: Omittable(bool) = .omit,
    integrations: Omittable([]const Partial(model.guild.Integration)) = .omit,
    verified: bool,
    friend_sync: bool,
    show_activity: bool,
    two_way_link: bool,
    visibility: Visibility,

    pub const jsonStringify = model.deanson.stringifyWithOmit;

    pub const Visibility = enum(u1) {
        none = 0,
        everyone = 1,

        pub const jsonStringify = model.deanson.stringifyEnumAsInt;
    };
};

pub const ApplicationRoleConnection = struct {
    platform_name: Omittable([]const u8) = .omit,
    platform_username: Omittable([]const u8) = .omit,
    metadata: std.json.ArrayHashMap([]const u8),

    pub const jsonStringify = model.deanson.stringifyWithOmit;
};
