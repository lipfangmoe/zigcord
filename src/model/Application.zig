const std = @import("std");
const deancord = @import("../root.zig");
const jconfig = @import("../root.zig").jconfig;
const model = deancord.model;

id: model.Snowflake,
name: []const u8,
icon: ?[]const u8,
description: []const u8,
rpc_origins: jconfig.Omittable([]const []const u8) = .omit,
bot_public: bool,
bot_require_code_grant: bool,
bot: jconfig.Omittable(jconfig.Partial(model.User)) = .omit,
terms_of_service_url: jconfig.Omittable([]const u8) = .omit,
privacy_policy_url: jconfig.Omittable([]const u8) = .omit,
owner: jconfig.Omittable(jconfig.Partial(model.User)) = .omit,
verify_key: []const u8,
team: ?Team,
guild_id: jconfig.Omittable([]const u8) = .omit,
guild: jconfig.Omittable(model.guild.PartialGuild) = .omit,
primary_sku_id: jconfig.Omittable(model.Snowflake) = .omit,
slug: jconfig.Omittable([]const u8) = .omit,
cover_image: jconfig.Omittable([]const u8) = .omit,
flags: jconfig.Omittable(Flags) = .omit,
approximate_guild_count: jconfig.Omittable(i64) = .omit,
redirect_uris: jconfig.Omittable([]const []const u8) = .omit,
interactions_endpoint_url: jconfig.Omittable([]const u8) = .omit,
role_connections_verification_url: jconfig.Omittable([]const u8) = .omit,
tags: jconfig.Omittable([]const []const u8) = .omit,
install_params: jconfig.Omittable(InstallParams) = .omit,
custom_install_url: jconfig.Omittable([]const u8) = .omit,

pub const jsonStringify = jconfig.stringifyWithOmit;

pub const Team = struct {
    icon: ?[]const u8,
    id: model.Snowflake,
    members: []TeamMember,
    name: []const u8,
    owner_user_id: model.Snowflake,
};

pub const TeamMember = struct {
    membership_state: State,
    team_id: model.Snowflake,
    user: model.User,
    role: []const u8,

    pub const State = enum(u8) {
        invited = 1,
        accepted,

        pub const jsonStringify = jconfig.stringifyEnumAsInt;
    };
};

pub const Flags = packed struct {
    _unused: u6 = 0,
    application_auto_moderation_rule_create_badge: bool = false, // 1 << 6
    _unused1: u5 = 0,
    gateway_presence: bool = false, // 1 << 12
    gateway_presence_limited: bool = false, // 1 << 13
    gateway_guild_members: bool = false, // 1 << 14
    gateway_guild_members_limited: bool = false, // 1 << 15
    verification_pending_guild_limit: bool = false, // 1 << 16
    embedded: bool = false, // 1 << 17
    gateway_message_content: bool = false, // 1 << 18
    gateway_message_content_limited: bool = false, // 1 << 19
    _unused2: u3 = 0,
    application_command_badge: bool = false, // 1 << 23

    pub usingnamespace model.PackedFlagsMixin(Flags);

    test "sanity tests" {
        const FlagsBackingT = @typeInfo(Flags).Struct.backing_integer orelse unreachable;
        try std.testing.expectEqual(
            @as(FlagsBackingT, 1 << 6),
            @as(FlagsBackingT, @bitCast(Flags{ .application_auto_moderation_rule_create_badge = true })),
        );
        try std.testing.expectEqual(
            @as(FlagsBackingT, 1 << 12),
            @as(FlagsBackingT, @bitCast(Flags{ .gateway_presence = true })),
        );
        try std.testing.expectEqual(
            @as(FlagsBackingT, 1 << 23),
            @as(FlagsBackingT, @bitCast(Flags{ .application_command_badge = true })),
        );
    }
};

pub const InstallParams = struct {
    scopes: []const []const u8,
    permissions: []const u8,
};

pub const IntegrationType = enum {
    guild_install,
    user_install,
};
