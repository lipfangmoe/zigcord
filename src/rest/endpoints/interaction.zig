const std = @import("std");
const deancord = @import("../../root.zig");
const model = deancord.model;
const rest = deancord.rest;

pub fn createInteractionResponse(
    client: *rest.Client,
    interaction_id: model.Snowflake,
    interaction_token: []const u8,
    body: model.interaction.InteractionResponse,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/interactions/{}/{s}/callback", .{ interaction_id, interaction_token });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBody(void, .POST, uri, body, .{});
}

pub fn createInteractionResponseMultipart(
    client: *rest.Client,
    interaction_id: model.Snowflake,
    interaction_token: []const u8,
    form: CreateInteractionResponseFormBody,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/interactions/{}/{s}/callback", .{ interaction_id, interaction_token });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    var pending_request = try client.beginMultipartRequest(void, .POST, uri, .chunked, rest.multipart_boundary, null);
    defer pending_request.deinit();

    try std.fmt.format(pending_request.writer(), "{form}", .{form});

    return pending_request.waitForResponse();
}

pub fn getOriginalInteractionResponse(
    client: *rest.Client,
    application_id: model.Snowflake,
    interaction_token: []const u8,
) !rest.Client.Result(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/webhooks/{}/{s}/messages/@original", .{ application_id, interaction_token });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(model.Message, .GET, uri);
}

pub fn editOriginalInteractionResponse(
    client: *rest.Client,
    application_id: model.Snowflake,
    interaction_token: []const u8,
    body: rest.endpoints.webhook.EditWebhookMessageFormBody,
) !rest.Client.Result(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/webhooks/{}/{s}/messages/@original", .{ application_id, interaction_token });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    var pending_request = try client.beginMultipartRequest(model.Message, .PATCH, uri, .chunked, rest.multipart_boundary, null);
    defer pending_request.deinit();

    try std.fmt.format(pending_request.writer(), "{form}", .{body});

    return pending_request.waitForResponse();
}

pub fn deleteOriginalInteractionResponse(
    client: *rest.Client,
    application_id: model.Snowflake,
    interaction_token: []const u8,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/webhooks/{}/{s}/messages/@original", .{ application_id, interaction_token });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(void, .DELETE, uri);
}

pub fn createFollowupMessage(
    client: *rest.Client,
    application_id: model.Snowflake,
    interaction_token: []const u8,
    body: rest.endpoints.webhook.ExecuteWebhookFormBody,
) !rest.Client.Result(model.Message) {
    return rest.endpoints.webhook.executeWebhookWait(client, application_id, interaction_token, .{}, body);
}

pub fn getFollowupMessage(
    client: *rest.Client,
    application_id: model.Snowflake,
    interaction_token: []const u8,
    message_id: model.Snowflake,
) !rest.Client.Result(model.Message) {
    return rest.endpoints.webhook.getWebhookMessage(client, application_id, interaction_token, message_id, .{});
}

pub fn editFollowupMessage(
    client: *rest.Client,
    application_id: model.Snowflake,
    interaction_token: []const u8,
    message_id: model.Snowflake,
    body: rest.endpoints.webhook.EditWebhookMessageFormBody,
) !rest.Client.Result(model.Message) {
    return rest.endpoints.webhook.editWebhookMessage(client, application_id, interaction_token, message_id, .{}, body);
}

pub fn deleteFollowupMessage(
    client: *rest.Client,
    application_id: model.Snowflake,
    interaction_token: []const u8,
    message_id: model.Snowflake,
) !rest.Client.Result(void) {
    return rest.endpoints.webhook.deleteWebhookMessage(client, application_id, interaction_token, message_id, .{});
}

pub const CreateInteractionResponseFormBody = struct {
    type: model.interaction.InteractionResponse.Type,
    data: ?model.interaction.InteractionCallbackData = null,
    files: ?[]const ?std.io.AnyReader = null,

    pub fn format(self: CreateInteractionResponseFormBody, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        if (comptime !std.mem.eql(u8, fmt, "form")) {
            @compileError("CreateInteractionResponseFormBody.format should only be called with fmt string {form}");
        }

        try rest.writeMultipartFormDataBody(self, "files", writer);
    }
};
