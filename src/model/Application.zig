const model = @import("../model.zig");
const Snowflake = model.Snowflake;
const User = model.User;
const deanson = @import("./deanson.zig");
const Guild = model.guild.Guild;
const stringifyWithOmit = deanson.stringifyWithOmit;
const Omittable = deanson.Omittable;

id: Snowflake,
name: []const u8,
icon: ?[]const u8,
description: []const u8,
rpc_origins: Omittable([]const []const u8) = .omit,
bot_public: bool,
bot_require_code_grant: bool,
bot: Omittable(User) = .omit, // TODO: partial user
terms_of_service_url: Omittable([]const u8) = .omit,
privacy_policy_url: Omittable([]const u8) = .omit,
owner: Omittable(User) = .omit, // TODO: partial user
verify_key: []const u8,
team: ?Team,
guild_id: Omittable([]const u8) = .omit,
guild: Omittable(Guild) = .omit, // TODO: partial guild
primary_sku_id: Omittable(Snowflake) = .omit,
slug: Omittable([]const u8) = .omit,
cover_image: Omittable([]const u8) = .omit,
flags: Omittable(Flags) = .omit,
approximate_guild_count: Omittable(i64) = .omit,
redirect_uris: Omittable([]const []const u8) = .omit,
interactions_endpoint_url: Omittable([]const u8) = .omit,
role_connections_verification_url: Omittable([]const u8) = .omit,
tags: Omittable([]const []const u8) = .omit,
install_params: Omittable(InstallParams) = .omit,
custom_install_url: Omittable([]const u8) = .omit,

pub const jsonStringify = stringifyWithOmit;

pub const Team = struct {
    icon: ?[]const u8,
    id: Snowflake,
    members: []TeamMember,
    name: []const u8,
    owner_user_id: Snowflake,
};

pub const TeamMember = struct {
    membership_state: State,
    team_id: Snowflake,
    user: User,
    role: []const u8,

    pub const State = enum(u8) {
        invited = 1,
        accepted,

        pub const jsonStringify = deanson.stringifyEnumAsInt;
    };
};

pub const Flags = model.Flags(enum(u6) {
    application_auto_moderation_rule_create_badge = 6,
    gateway_presence = 12,
    gateway_presence_limited = 13,
    gateway_guild_members = 14,
    gateway_guild_members_limited = 15,
    verification_pending_guild_limit = 16,
    embedded = 17,
    gateway_message_content = 18,
    gateway_message_content_limited = 19,
    application_command_badge = 23,
});

pub const InstallParams = struct {
    scopes: []const []const u8,
    permissions: []const u8,
};

pub const IntegrationType = enum {
    guild_install,
    user_install,
};
