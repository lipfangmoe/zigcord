const std = @import("std");
const model = @import("model");
const jconfig = @import("jconfig");
const EndpointClient = @import("../EndpointClient.zig");
const RestClient = @import("../RestClient.zig");
const Result = RestClient.Result;
const allocDiscordUriStr = @import("../discord_uri.zig").allocDiscordUriStr;
const Upload = @import("../upload.zig").Upload;
const multipart = @import("../multipart.zig");
const query_strings = @import("../query_strings.zig");

pub fn createInteractionResponse(
    client: *EndpointClient,
    interaction_id: model.Snowflake,
    interaction_token: []const u8,
    body: model.interaction.InteractionCallback,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/interactions/{f}/{s}/callback", .{ interaction_id, interaction_token });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBody(void, .POST, uri, body, .{});
}

pub fn createInteractionResponseMultipart(
    client: *EndpointClient,
    interaction_id: model.Snowflake,
    interaction_token: []const u8,
    form: CreateInteractionResponseFormBody,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/interactions/{f}/{s}/callback", .{ interaction_id, interaction_token });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    const transfer_encoding = try multipart.getTransferEncoding(form, "files");

    // https://codeberg.org/ziglang/zig/issues/30623 - for now, we will write the file
    // to an allocatingwriter and send it all in one shot. once streaming to body_writer is fixed,
    // this should be updated to write directly to body_writer instead of allocating the entire file.
    var aw: std.Io.Writer.Allocating = switch (transfer_encoding) {
        .content_length => |len| try .initCapacity(client.rest_client.allocator, len),
        .chunked => .init(client.rest_client.allocator),
        .none => unreachable,
    };
    defer aw.deinit();

    try aw.writer.print("{f}", .{form.fmt("files")});

    var buf: [1028]u8 = undefined;
    var pending_request = try client.rest_client.beginMultipartRequest(void, .POST, uri, transfer_encoding, multipart.boundary, &buf);

    try pending_request.request.sendBodyComplete(aw.written());

    return pending_request.waitForResponse();
}

pub fn getOriginalInteractionResponse(
    client: *EndpointClient,
    application_id: model.Snowflake,
    interaction_token: []const u8,
) !Result(model.Message) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{f}/{s}/messages/@original", .{ application_id, interaction_token });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Message, .GET, uri);
}

pub fn editOriginalInteractionResponse(
    client: *EndpointClient,
    application_id: model.Snowflake,
    interaction_token: []const u8,
    body: EndpointClient.webhook.EditWebhookMessageJsonBody,
) !Result(model.Message) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{f}/{s}/messages/@original", .{ application_id, interaction_token });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBody(model.Message, .PATCH, uri, body, .{});
}

pub fn editOriginalInteractionResponseMultipart(
    client: *EndpointClient,
    application_id: model.Snowflake,
    interaction_token: []const u8,
    body: EndpointClient.webhook.EditWebhookMessageFormBody,
) !Result(model.Message) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{f}/{s}/messages/@original", .{ application_id, interaction_token });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    const transfer_encoding = try multipart.getTransferEncoding(body, "files");

    // https://codeberg.org/ziglang/zig/issues/30623 - for now, we will write the file
    // to an allocatingwriter and send it all in one shot. once streaming to body_writer is fixed,
    // this should be updated to write directly to body_writer instead of allocating the entire file.
    var aw: std.Io.Writer.Allocating = switch (transfer_encoding) {
        .content_length => |len| try .initCapacity(client.rest_client.allocator, len),
        .chunked => .init(client.rest_client.allocator),
        .none => unreachable,
    };
    defer aw.deinit();

    try aw.writer.print("{f}", .{body.fmt("files")});

    var buf: [1028]u8 = undefined;
    var pending_request = try client.rest_client.beginMultipartRequest(model.Message, .PATCH, uri, transfer_encoding, multipart.boundary, &buf);

    try pending_request.request.sendBodyComplete(aw.written());

    return pending_request.waitForResponse();
}

pub fn deleteOriginalInteractionResponse(
    client: *EndpointClient,
    application_id: model.Snowflake,
    interaction_token: []const u8,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{f}/{s}/messages/@original", .{ application_id, interaction_token });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub fn createFollowupMessage(
    client: *EndpointClient,
    application_id: model.Snowflake,
    interaction_token: []const u8,
    body: EndpointClient.webhook.ExecuteWebhookJsonBody,
) !Result(model.Message) {
    return client.executeWebhookWait(application_id, interaction_token, .{}, body);
}

pub fn createFollowupMessageMultipart(
    client: *EndpointClient,
    application_id: model.Snowflake,
    interaction_token: []const u8,
    body: EndpointClient.webhook.ExecuteWebhookFormBody,
) !Result(model.Message) {
    return client.executeWebhookWaitMultipart(application_id, interaction_token, .{}, body);
}

pub fn getFollowupMessage(
    client: *EndpointClient,
    application_id: model.Snowflake,
    interaction_token: []const u8,
    message_id: model.Snowflake,
) !Result(model.Message) {
    return client.getWebhookMessage(application_id, interaction_token, message_id, .{});
}

pub fn editFollowupMessage(
    client: *EndpointClient,
    application_id: model.Snowflake,
    interaction_token: []const u8,
    message_id: model.Snowflake,
    body: EndpointClient.webhook.EditWebhookMessageJsonBody,
) !Result(model.Message) {
    return client.editWebhookMessage(application_id, interaction_token, message_id, .{}, body);
}

pub fn editFollowupMessageMultipart(
    client: *EndpointClient,
    application_id: model.Snowflake,
    interaction_token: []const u8,
    message_id: model.Snowflake,
    body: EndpointClient.webhook.EditWebhookMessageFormBody,
) !Result(model.Message) {
    return client.editWebhookMessageMultipart(application_id, interaction_token, message_id, .{}, body);
}

pub fn deleteFollowupMessage(
    client: *EndpointClient,
    application_id: model.Snowflake,
    interaction_token: []const u8,
    message_id: model.Snowflake,
) !Result(void) {
    return client.deleteWebhookMessage(application_id, interaction_token, message_id, .{});
}

pub const CreateInteractionResponseFormBody = multipart.FormDataBody(?[]const Upload, model.interaction.InteractionCallback);
