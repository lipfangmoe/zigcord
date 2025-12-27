const std = @import("std");
const zigcord = @import("../../root.zig");
const model = zigcord.model;
const rest = zigcord.rest;

pub fn createInteractionResponse(
    client: *rest.EndpointClient,
    interaction_id: model.Snowflake,
    interaction_token: []const u8,
    body: model.interaction.InteractionResponse,
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/interactions/{f}/{s}/callback", .{ interaction_id, interaction_token });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBody(void, .POST, uri, body, .{});
}

pub fn createInteractionResponseMultipart(
    client: *rest.EndpointClient,
    interaction_id: model.Snowflake,
    interaction_token: []const u8,
    form: CreateInteractionResponseFormBody,
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/interactions/{f}/{s}/callback", .{ interaction_id, interaction_token });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    var buf: [1028]u8 = undefined;
    var pending_request = try client.rest_client.beginMultipartRequest(void, .POST, uri, .chunked, rest.multipart_boundary, null, &buf);

    var body_writer = try pending_request.request.sendBodyUnflushed("");
    try body_writer.writer.print("{f}", .{form});
    try body_writer.end();

    return pending_request.waitForResponse();
}

pub fn getOriginalInteractionResponse(
    client: *rest.EndpointClient,
    application_id: model.Snowflake,
    interaction_token: []const u8,
) !rest.RestClient.Result(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{f}/{s}/messages/@original", .{ application_id, interaction_token });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Message, .GET, uri);
}

pub fn editOriginalInteractionResponse(
    client: *rest.EndpointClient,
    application_id: model.Snowflake,
    interaction_token: []const u8,
    body: rest.EndpointClient.webhook.EditWebhookMessageFormBody,
) !rest.RestClient.Result(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{f}/{s}/messages/@original", .{ application_id, interaction_token });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    var buf: [1028]u8 = undefined;
    var pending_request = try client.rest_client.beginMultipartRequest(model.Message, .PATCH, uri, .chunked, rest.multipart_boundary, null, &buf);

    var body_writer = try pending_request.request.sendBodyUnflushed("");
    try body_writer.writer.print("{f}", .{body});
    try body_writer.end();

    return pending_request.waitForResponse();
}

pub fn deleteOriginalInteractionResponse(
    client: *rest.EndpointClient,
    application_id: model.Snowflake,
    interaction_token: []const u8,
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{f}/{s}/messages/@original", .{ application_id, interaction_token });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub fn createFollowupMessage(
    client: *rest.EndpointClient,
    application_id: model.Snowflake,
    interaction_token: []const u8,
    body: rest.EndpointClient.webhook.ExecuteWebhookJsonBody,
) !rest.RestClient.Result(model.Message) {
    return client.executeWebhookWait(application_id, interaction_token, .{}, body);
}

pub fn createFollowupMessageMultipart(
    client: *rest.EndpointClient,
    application_id: model.Snowflake,
    interaction_token: []const u8,
    body: rest.EndpointClient.webhook.ExecuteWebhookFormBody,
) !rest.RestClient.Result(model.Message) {
    return client.executeWebhookWaitMultipart(application_id, interaction_token, .{}, body);
}

pub fn getFollowupMessage(
    client: *rest.EndpointClient,
    application_id: model.Snowflake,
    interaction_token: []const u8,
    message_id: model.Snowflake,
) !rest.RestClient.Result(model.Message) {
    return client.getWebhookMessage(application_id, interaction_token, message_id, .{});
}

pub fn editFollowupMessage(
    client: *rest.EndpointClient,
    application_id: model.Snowflake,
    interaction_token: []const u8,
    message_id: model.Snowflake,
    body: rest.EndpointClient.webhook.EditWebhookMessageJsonBody,
) !rest.RestClient.Result(model.Message) {
    return client.editWebhookMessage(application_id, interaction_token, message_id, .{}, body);
}

pub fn editFollowupMessageMultipart(
    client: *rest.EndpointClient,
    application_id: model.Snowflake,
    interaction_token: []const u8,
    message_id: model.Snowflake,
    body: rest.EndpointClient.webhook.EditWebhookMessageFormBody,
) !rest.RestClient.Result(model.Message) {
    return client.editWebhookMessageMultipart(application_id, interaction_token, message_id, .{}, body);
}

pub fn deleteFollowupMessage(
    client: *rest.EndpointClient,
    application_id: model.Snowflake,
    interaction_token: []const u8,
    message_id: model.Snowflake,
) !rest.RestClient.Result(void) {
    return client.deleteWebhookMessage(application_id, interaction_token, message_id, .{});
}

pub const CreateInteractionResponseFormBody = struct {
    type: model.interaction.InteractionResponse.Type,
    data: ?model.interaction.InteractionCallbackData = null,
    files: ?[]const *std.Io.Reader = null,

    pub fn format(self: CreateInteractionResponseFormBody, writer: *std.Io.Writer) !void {
        rest.writeMultipartFormDataBody(self, "files", writer) catch return error.WriteFailed;
    }
};
