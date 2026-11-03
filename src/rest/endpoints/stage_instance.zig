const std = @import("std");
const model = @import("model");
const jconfig = @import("jconfig");
const EndpointClient = @import("../EndpointClient.zig");
const RestClient = @import("../RestClient.zig");
const Result = RestClient.Result;
const allocDiscordUriStr = @import("../discord_uri.zig").allocDiscordUriStr;

pub fn createStageInstance(
    client: *EndpointClient,
    body: CreateStageInstanceBody,
    audit_log_reason: ?[]const u8,
) !Result(model.StageInstance) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/stage-instances", .{});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(model.StageInstance, .POST, uri, body, .{}, audit_log_reason);
}

pub fn getStageInstance(
    client: *EndpointClient,
    channel_id: model.Snowflake,
) !Result(model.StageInstance) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/stage-instances/{f}", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.StageInstance, .GET, uri);
}

pub fn modifyStageInstance(
    client: *EndpointClient,
    channel_id: model.Snowflake,
    body: ModifyStageInstanceBody,
    audit_log_reason: ?[]const u8,
) !Result(model.StageInstance) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/stage-instances/{f}", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(model.StageInstance, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn deleteStageInstance(
    client: *EndpointClient,
    channel_id: model.Snowflake,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/stage-instances/{f}", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub const CreateStageInstanceBody = struct {
    channel_id: model.Snowflake,
    topic: []const u8,
    privacy_level: ?model.StageInstance.PrivacyLevel = null,
    send_start_notification: ?bool = null,
    guild_scheduled_event_id: ?model.Snowflake = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ModifyStageInstanceBody = struct {
    topic: ?[]const u8 = null,
    privacy_level: ?i64 = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};
