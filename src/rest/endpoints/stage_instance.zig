const deancord = @import("../../root.zig");
const std = @import("std");
const model = deancord.model;
const rest = deancord.rest;
const jconfig = deancord.jconfig;

pub fn createStageInstance(
    client: *rest.EndpointClient,
    body: CreateStageInstanceBody,
    audit_log_reason: ?[]const u8,
) !rest.RestClient.Result(model.StageInstance) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/stage-instances", .{});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBodyAndAuditLogReason(model.StageInstance, .POST, uri, body, .{}, audit_log_reason);
}

pub fn getStageInstance(
    client: *rest.EndpointClient,
    channel_id: model.Snowflake,
) !rest.RestClient.Result(model.StageInstance) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/stage-instances/{}", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.StageInstance, .GET, uri);
}

pub fn modifyStageInstance(
    client: *rest.EndpointClient,
    channel_id: model.Snowflake,
    body: ModifyStageInstanceBody,
    audit_log_reason: ?[]const u8,
) !rest.RestClient.Result(model.StageInstance) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/stage-instances/{}", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBodyAndAuditLogReason(model.StageInstance, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn deleteStageInstance(
    client: *rest.EndpointClient,
    channel_id: model.Snowflake,
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/stage-instances/{}", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub const CreateStageInstanceBody = struct {
    channel_id: model.Snowflake,
    topic: []const u8,
    privacy_level: jconfig.Omittable(model.StageInstance.PrivacyLevel) = .omit,
    send_start_notification: jconfig.Omittable(bool) = .omit,
    guild_scheduled_event_id: jconfig.Omittable(model.Snowflake) = .omit,

    pub usingnamespace jconfig.OmittableFieldsMixin(@This());
};

pub const ModifyStageInstanceBody = struct {
    topic: jconfig.Omittable([]const u8) = .omit,
    privacy_level: jconfig.Omittable(i64) = .omit,

    pub usingnamespace jconfig.OmittableFieldsMixin(@This());
};
