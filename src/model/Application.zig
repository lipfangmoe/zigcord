const std = @import("std");
const zigcord = @import("../root.zig");
const jconfig = @import("../root.zig").jconfig;
const model = zigcord.model;

const Application = @This();

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
approximate_user_install_count: jconfig.Omittable(i64) = .omit,
redirect_uris: jconfig.Omittable([]const []const u8) = .omit,
interactions_endpoint_url: jconfig.Omittable(?[]const u8) = .omit,
role_connections_verification_url: jconfig.Omittable(?[]const u8) = .omit,
event_webhooks_url: jconfig.Omittable(?[]const u8) = .omit,
event_webhooks_status: jconfig.Omittable(ApplicationEventWebhookStatus) = .omit,
event_webhooks_types: jconfig.Omittable([]const u8) = .omit,
tags: jconfig.Omittable([]const []const u8) = .omit,
install_params: jconfig.Omittable(InstallParams) = .omit,
integration_types_config: jconfig.Omittable(IntegrationTypeConfigurationDict) = .omit,
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
    user: jconfig.Partial(model.User),
    role: []const u8,
    permissions: jconfig.Omittable([]const []const u8) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const State = enum(u8) {
        invited = 1,
        accepted,

        pub const jsonStringify = jconfig.stringifyEnumAsInt;
    };
};

pub const Flags = packed struct(u64) {
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
    _overflow: u40 = 0,

    const Mixin = model.PackedFlagsMixin(@This());
    pub const format = Mixin.format;
    pub const jsonStringify = Mixin.jsonStringify;
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;

    test "sanity tests" {
        const FlagsBackingT = @typeInfo(Flags).@"struct".backing_integer orelse unreachable;
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

pub const ApplicationEventWebhookStatus = enum(u8) {
    disabled = 1,
    enabled = 2,
    disabled_by_discord = 3,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};

pub const InstallParams = struct {
    scopes: []const []const u8,
    permissions: []const u8,
};

pub const IntegrationType = enum {
    guild_install,
    user_install,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};

pub const IntegrationTypeConfigurationDict = struct {
    guild_install: jconfig.Omittable(IntegrationTypeConfiguration) = .omit,
    user_install: jconfig.Omittable(IntegrationTypeConfiguration) = .omit,

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !IntegrationTypeConfigurationDict {
        const obj_token = try source.nextAlloc(allocator, options.allocate orelse .alloc_if_needed);
        switch (obj_token) {
            .object_begin => {},
            else => return error.UnexpectedToken,
        }

        var result: IntegrationTypeConfigurationDict = .{};

        while (true) {
            const field_name_token = try source.nextAlloc(allocator, options.allocate orelse .alloc_if_needed);
            const field_name = switch (field_name_token) {
                .string => |str| str,
                .allocated_string => |str| str,
                .object_end => {
                    return result;
                },
                else => return error.UnexpectedToken,
            };
            const field_value: jconfig.Omittable(IntegrationTypeConfiguration) =
                .initSome(try std.json.innerParse(IntegrationTypeConfiguration, allocator, source, options));

            if (std.mem.eql(u8, field_name, "0")) {
                result.guild_install = field_value;
            } else if (std.mem.eql(u8, field_name, "1")) {
                result.user_install = field_value;
            }
        }
    }

    pub fn jsonParseByValue(allocator: std.mem.Allocator, source: std.json.Value, options: std.json.ParseOptions) !IntegrationTypeConfigurationDict {
        var obj = switch (source) {
            .object => |obj| obj,
            else => return error.UnexpectedToken,
        };

        var result: IntegrationTypeConfigurationDict = .{};
        if (obj.get("0")) |guild_install_value| {
            result.guild_install = .initSome(try std.json.innerParseFromValue(IntegrationTypeConfiguration, allocator, guild_install_value, options));
        }
        if (obj.get("1")) |user_install_value| {
            result.user_install = .initSome(try std.json.innerParseFromValue(IntegrationTypeConfiguration, allocator, user_install_value, options));
        }
        return result;
    }

    pub fn jsonStringify(self: IntegrationTypeConfigurationDict, jw: *std.json.Stringify) !void {
        try jw.beginObject();
        if (self.guild_install.asSome()) |config| {
            try jw.objectField("0");
            try jw.write(config);
        }
        if (self.user_install.asSome()) |config| {
            try jw.objectField("1");
            try jw.write(config);
        }
        try jw.endObject();
    }
};

pub const IntegrationTypeConfiguration = struct {
    oauth2_install_params: InstallParams,
};

// from https://discord.com/developers/docs/resources/application#application-object-example-application-object
test "redacted enkafang" {
    const input = @embedFile("./test/application.test.json");
    try jconfig.testing.expectParsedSuccessfully(Application, std.testing.allocator, input, .{ .ignore_unknown_fields = true });
}
