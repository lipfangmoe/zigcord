const std = @import("std");
const model = @import("../root.zig").model;
const jconfig = @import("../root.zig").jconfig;
const Omittable = jconfig.Omittable;
const Partial = jconfig.Partial;
const User = @This();

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

pub const Flags = packed struct {
    /// discord employee, 1 << 0
    staff: bool = false,
    /// partnered server owner, 1 << 1
    partner: bool = false,
    /// hypesquad events member, 1 << 2
    hypesquad: bool = false,
    /// bug hunter level 1, 1 << 3
    bug_hunter_level_1: bool = false,

    _unused: u2 = 0,

    /// house of bravery member, 1 << 6
    hypesquad_online_house_1: bool = false,
    /// house of brilliance member, 1 << 7
    hypesquad_online_house_2: bool = false,
    /// house of balance member, 1 << 8
    hypesquad_online_house_3: bool = false,
    /// early nitro supporter, 1 << 9
    premium_early_supporter: bool = false,
    /// user is actually a team. see https://discord.com/developers/docs/topics/teams, 1 << 10
    team_pseudo_user: bool = false,

    _unused2: u3 = 0,

    /// bug hunter level 2, 1 << 14
    bug_hunter_level_2: bool = false,

    _unused3: u1 = 0,

    /// set if this user is a verified bot, 1 << 16
    verified_bot: bool = false,
    /// early verified bot developer, 1 << 17
    verified_developer: bool = false,
    /// moderator programs alumnus, 1 << 18
    certified_moderator: bool = false,
    /// bot uses only http interactions, and is shown in the online member list, 1 << 19
    bot_http_interactions: bool = false,

    _unused4: u2 = 0,

    /// active developer, 1 << 22
    active_developer: bool = false,

    pub usingnamespace model.PackedFlagsMixin(@This());
};

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

    pub const jsonStringify = model.jconfig.stringifyWithOmit;

    pub const Visibility = enum(u1) {
        none = 0,
        everyone = 1,

        pub const jsonStringify = model.jconfig.stringifyEnumAsInt;
    };
};

pub const ApplicationRoleConnection = struct {
    platform_name: Omittable([]const u8) = .omit,
    platform_username: Omittable([]const u8) = .omit,
    metadata: std.json.ArrayHashMap([]const u8),

    pub const jsonStringify = model.jconfig.stringifyWithOmit;
};

test "idk some websocket response" {
    const str =
        \\{"verified":true,"username":"deancord.zig test bot","mfa_enabled":true,"id":"1277009867730845787","global_name":null,"flags":0,"email":null,"discriminator":"0175","clan":null,"bot":true,"avatar":"be737e5512e505a791c5437f9a3d2c29"}
    ;
    const value = try std.json.parseFromSlice(User, std.testing.allocator, str, .{ .ignore_unknown_fields = true });
    defer value.deinit();
}
