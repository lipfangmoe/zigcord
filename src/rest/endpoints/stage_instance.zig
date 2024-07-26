const deancord = @import("../../root.zig");
const std = @import("std");
const model = deancord.model;
const rest = deancord.rest;
const deanson = model.deanson;

pub fn createStageInstance(
    client: *rest.Client,
    body: CreateStageInstanceBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(model.StageInstance) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/stage-instances", .{});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndAuditLogReason(model.StageInstance, .POST, uri, body, .{}, audit_log_reason);
}

pub fn getStageInstance(
    client: *rest.Client,
    channel_id: model.Snowflake,
) !rest.Client.Result(model.StageInstance) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/stage-instances/{}", .{channel_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(model.StageInstance, .GET, uri);
}

pub fn modifyStageInstance(
    client: *rest.Client,
    channel_id: model.Snowflake,
    body: ModifyStageInstanceBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(model.StageInstance) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/stage-instances/{}", .{channel_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndAuditLogReason(model.StageInstance, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn deleteStageInstance(
    client: *rest.Client,
    channel_id: model.Snowflake,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/stage-instances/{}", .{channel_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(void, .DELETE, uri);
}

pub const CreateStageInstanceBody = struct {
    channel_id: model.Snowflake,
    topic: []const u8,
    privacy_level: deanson.Omittable(model.StageInstance.PrivacyLevel) = .omit,
    send_start_notification: deanson.Omittable(bool) = .omit,
    guild_scheduled_event_id: deanson.Omittable(model.Snowflake) = .omit,

    pub usingnamespace deanson.OmittableJsonMixin(@This());
};

pub const ModifyStageInstanceBody = struct {
    topic: deanson.Omittable([]const u8) = .omit,
    privacy_level: deanson.Omittable(i64) = .omit,

    pub usingnamespace deanson.OmittableJsonMixin(@This());
};
