const std = @import("std");
const deancord = @import("../root.zig");
const model = deancord.model;
const deanson = model.deanson;

id: model.Snowflake,
name: []const u8,
icon: ?[]const u8,
description: []const u8,
rpc_origins: deanson.Omittable([]const []const u8) = .omit,
bot_public: bool,
bot_require_code_grant: bool,
bot: deanson.Omittable(deanson.Partial(model.User)) = .omit,
terms_of_service_url: deanson.Omittable([]const u8) = .omit,
privacy_policy_url: deanson.Omittable([]const u8) = .omit,
owner: deanson.Omittable(deanson.Partial(model.User)) = .omit,
verify_key: []const u8,
team: ?Team,
guild_id: deanson.Omittable([]const u8) = .omit,
guild: deanson.Omittable(model.guild.PartialGuild) = .omit,
primary_sku_id: deanson.Omittable(model.Snowflake) = .omit,
slug: deanson.Omittable([]const u8) = .omit,
cover_image: deanson.Omittable([]const u8) = .omit,
flags: deanson.Omittable(Flags) = .omit,
approximate_guild_count: deanson.Omittable(i64) = .omit,
redirect_uris: deanson.Omittable([]const []const u8) = .omit,
interactions_endpoint_url: deanson.Omittable([]const u8) = .omit,
role_connections_verification_url: deanson.Omittable([]const u8) = .omit,
tags: deanson.Omittable([]const []const u8) = .omit,
install_params: deanson.Omittable(InstallParams) = .omit,
custom_install_url: deanson.Omittable([]const u8) = .omit,

pub const jsonStringify = deanson.stringifyWithOmit;

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

        pub const jsonStringify = deanson.stringifyEnumAsInt;
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

    usingnamespace model.PackedFlagsMixin(Flags);

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
