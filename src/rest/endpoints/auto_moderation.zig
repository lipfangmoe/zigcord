const std = @import("std");
const jconfig = @import("jconfig");
const model = @import("model");
const EndpointClient = @import("../EndpointClient.zig");
const RestClient = @import("../RestClient.zig");
const Result = RestClient.Result;
const allocDiscordUriStr = @import("../discord_uri.zig").allocDiscordUriStr;
const Snowflake = model.Snowflake;
const Omittable = jconfig.Omittable;

pub fn listAutoModerationRulesForGuild(
    client: *EndpointClient,
    guild_id: Snowflake,
) !Result([]const model.AutoModerationRule) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/auto-moderation/rules", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const model.AutoModerationRule, .GET, uri);
}

pub fn getAutoModerationRule(
    client: *EndpointClient,
    guild_id: Snowflake,
    rule_id: Snowflake,
) !Result(model.AutoModerationRule) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/auto-moderation/rules/{f}", .{ guild_id, rule_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.AutoModerationRule, .GET, uri);
}

pub fn createAutoModerationRule(
    client: *EndpointClient,
    guild_id: Snowflake,
    body: CreateParams,
    audit_log_reason: ?[]const u8,
) !Result(model.AutoModerationRule) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/auto-moderation/rules", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(model.AutoModerationRule, .POST, uri, body, .{}, audit_log_reason);
}

pub fn modifyAutoModerationRule(
    client: *EndpointClient,
    guild_id: Snowflake,
    rule_id: Snowflake,
    body: ModifyParams,
    audit_log_reason: ?[]const u8,
) !Result(model.AutoModerationRule) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/auto-moderation/rules/{f}", .{ guild_id, rule_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(model.AutoModerationRule, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn deleteAutoModerationRule(
    client: *EndpointClient,
    guild_id: Snowflake,
    rule_id: Snowflake,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/auto-moderation/rules/{f}", .{ guild_id, rule_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub const CreateParams = struct {
    name: []const u8,
    event_type: model.AutoModerationRule.EventType,
    trigger_type: model.AutoModerationRule.TriggerType,
    trigger_metadata: Omittable(model.AutoModerationRule.TriggerMetadata) = .omit,
    actions: []const model.AutoModerationAction,
    enabled: Omittable(bool) = .omit,
    exempt_roles: Omittable(Snowflake) = .omit,
    exempt_channels: Omittable(Snowflake) = .omit,
};

pub const ModifyParams = struct {
    name: Omittable([]const u8) = .omit,
    event_type: Omittable(model.AutoModerationRule.EventType) = .omit,
    trigger_type: Omittable(model.AutoModerationRule.TriggerType) = .omit,
    trigger_metadata: Omittable(model.AutoModerationRule.TriggerMetadata) = .omit,
    actions: Omittable([]const model.AutoModerationAction) = .omit,
    enabled: Omittable(bool) = .omit,
    exempt_roles: Omittable(Snowflake) = .omit,
    exempt_channels: Omittable(Snowflake) = .omit,
};
