const std = @import("std");
const model = @import("model");
const jconfig = @import("jconfig");
const EndpointClient = @import("../EndpointClient.zig");
const RestClient = @import("../RestClient.zig");
const Result = RestClient.Result;
const allocDiscordUriStr = @import("../discord_uri.zig").allocDiscordUriStr;
const multipart = @import("../multipart.zig");
const query_strings = @import("../query_strings.zig");
const Upload = @import("../upload.zig").Upload;

pub fn createWebhook(
    client: *EndpointClient,
    channel_id: model.Snowflake,
    body: CreateWebhookBody,
    audit_log_reason: ?[]const u8,
) !Result(model.Webhook) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/webhooks", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(model.Webhook, .POST, uri, body, .{}, audit_log_reason);
}

pub fn getChannelWebhooks(
    client: *EndpointClient,
    channel_id: model.Snowflake,
) !Result([]const model.Webhook) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/webhooks", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const model.Webhook, .GET, uri);
}

pub fn getGuildWebhooks(
    client: *EndpointClient,
    guild_id: model.Snowflake,
) !Result([]const model.Webhook) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/webhooks", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const model.Webhook, .GET, uri);
}

pub fn getWebhook(
    client: *EndpointClient,
    webhook_id: model.Snowflake,
) !Result(model.Webhook) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{f}", .{webhook_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Webhook, .GET, uri);
}

pub fn getWebhookWithToken(
    client: *EndpointClient,
    webhook_id: model.Snowflake,
    webhook_token: []const u8,
) !Result(model.Webhook) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{f}/{s}", .{ webhook_id, webhook_token });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Webhook, .GET, uri);
}

pub fn modifyWebhook(
    client: *EndpointClient,
    webhook_id: model.Snowflake,
    body: ModifyWebhookBody,
    audit_log_reason: ?[]const u8,
) !Result(model.Webhook) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{f}", .{webhook_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(model.Webhook, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn modifyWebhookWithToken(
    client: *EndpointClient,
    webhook_id: model.Snowflake,
    webhook_token: []const u8,
    body: ModifyWebhookBody,
    audit_log_reason: ?[]const u8,
) !Result(model.Webhook) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{f}/{s}", .{ webhook_id, webhook_token });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(model.Webhook, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn deleteWebhook(
    client: *EndpointClient,
    webhook_id: model.Snowflake,
    audit_log_reason: ?[]const u8,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{f}", .{webhook_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithAuditLogReason(void, .DELETE, uri, audit_log_reason);
}

pub fn deleteWebhookWithToken(
    client: *EndpointClient,
    webhook_id: model.Snowflake,
    webhook_token: []const u8,
    audit_log_reason: ?[]const u8,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{f}/{s}", .{ webhook_id, webhook_token });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithAuditLogReason(void, .DELETE, uri, audit_log_reason);
}

pub fn executeWebhookWait(
    client: *EndpointClient,
    webhook_id: model.Snowflake,
    webhook_token: []const u8,
    query: ExecuteWebhookQuery,
    body: ExecuteWebhookJsonBody,
) !Result(model.Message) {
    var override_query = query;
    override_query.wait = true;
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{f}/{s}?{f}", .{ webhook_id, webhook_token, override_query });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return try client.rest_client.requestWithJsonBody(model.Message, .POST, uri, body, .{});
}

pub fn executeWebhookNoWait(
    client: *EndpointClient,
    webhook_id: model.Snowflake,
    webhook_token: []const u8,
    query: ExecuteWebhookQuery,
    body: ExecuteWebhookJsonBody,
) !Result(void) {
    var override_query = query;
    override_query.wait = true;
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{f}/{s}?{f}", .{ webhook_id, webhook_token, override_query });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return try client.rest_client.requestWithJsonBody(void, .POST, uri, body, .{});
}

pub fn executeWebhookWaitMultipart(
    client: *EndpointClient,
    webhook_id: model.Snowflake,
    webhook_token: []const u8,
    query: ExecuteWebhookQuery,
    body: ExecuteWebhookFormBody,
) !Result(model.Message) {
    var override_query = query;
    override_query.wait = true;
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{f}/{s}?{f}", .{ webhook_id, webhook_token, override_query });
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
    var pending_request = try client.rest_client.beginMultipartRequest(model.Message, .POST, uri, transfer_encoding, multipart.boundary, &buf);

    try pending_request.request.sendBodyComplete(aw.written());

    return pending_request.waitForResponse();
}

pub fn executeWebhookNoWaitMultipart(
    client: *EndpointClient,
    webhook_id: model.Snowflake,
    webhook_token: []const u8,
    query: ExecuteWebhookQuery,
    body: ExecuteWebhookFormBody,
) !Result(void) {
    var override_query = query;
    override_query.wait = true;
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{f}/{s}?{f}", .{ webhook_id, webhook_token, override_query });
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

    var header_buf: [1028]u8 = undefined;
    var pending_request = try client.rest_client.beginMultipartRequest(void, .POST, uri, transfer_encoding, multipart.boundary, &header_buf);

    try pending_request.request.sendBodyComplete(aw.written());

    return pending_request.waitForResponse();
}

// is there a point in supporting slack/github compatible webhook endpoints? i don't want to have to build entirely new models just to support them

pub fn getWebhookMessage(
    client: *EndpointClient,
    webhook_id: model.Snowflake,
    webhook_token: []const u8,
    message_id: model.Snowflake,
    query: PossiblyInThreadQuery,
) !Result(model.Message) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{f}/{s}/messages/{f}?{f}", .{ webhook_id, webhook_token, message_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Message, .GET, uri);
}

pub fn editWebhookMessage(
    client: *EndpointClient,
    webhook_id: model.Snowflake,
    webhook_token: []const u8,
    message_id: model.Snowflake,
    query: PossiblyInThreadQuery,
    body: EditWebhookMessageJsonBody,
) !Result(model.Message) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{f}/{s}/messages/{f}?{f}", .{ webhook_id, webhook_token, message_id, query });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return try client.rest_client.requestWithJsonBody(model.Message, .PATCH, uri, body, .{});
}

pub fn editWebhookMessageMultipart(
    client: *EndpointClient,
    webhook_id: model.Snowflake,
    webhook_token: []const u8,
    message_id: model.Snowflake,
    query: PossiblyInThreadQuery,
    body: EditWebhookMessageFormBody,
) !Result(model.Message) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{f}/{s}/messages/{f}?{f}", .{ webhook_id, webhook_token, message_id, query });
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

pub fn deleteWebhookMessage(
    client: *EndpointClient,
    webhook_id: model.Snowflake,
    webhook_token: []const u8,
    message_id: model.Snowflake,
    query: PossiblyInThreadQuery,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{f}/{s}/messages/{f}?{f}", .{ webhook_id, webhook_token, message_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub const CreateWebhookBody = struct {
    name: []const u8,
    avatar: jconfig.Omittable(?model.DataUri) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ModifyWebhookBody = struct {
    name: jconfig.Omittable([]const u8) = .omit,
    avatar: jconfig.Omittable(?model.DataUri) = .omit,
    channel_id: jconfig.Omittable(model.Snowflake) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ExecuteWebhookQuery = struct {
    thread_id: ?model.Snowflake = null,
    wait: ?bool = null,

    pub const format = query_strings.formatAsQueryString;
};

pub const ExecuteWebhookJsonBody = struct {
    content: jconfig.Omittable(?[]const u8) = .omit,
    username: jconfig.Omittable(?[]const u8) = .omit,
    avatar_url: jconfig.Omittable(?[]const u8) = .omit,
    tts: jconfig.Omittable(?bool) = .omit,
    embeds: jconfig.Omittable(?[]const model.Message.Embed) = .omit,
    allowed_mentions: jconfig.Omittable(?model.Message.AllowedMentions) = .omit,
    components: jconfig.Omittable(?[]const model.components.TopLevelMessageComponent) = .omit,
    attachments: jconfig.Omittable(?[]const EndpointClient.PartialAttachmentRequest) = .omit,
    flags: jconfig.Omittable(?model.Message.Flags) = .omit,
    thread_name: jconfig.Omittable(?[]const u8) = .omit,
    applied_tags: jconfig.Omittable(?[]const model.Snowflake) = .omit,
    poll: jconfig.Omittable(?model.Poll) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ExecuteWebhookFormBody = multipart.FormDataBody(?[]const ?Upload, ExecuteWebhookFormPayload);
pub const ExecuteWebhookFormPayload = struct {
    content: ?[]const u8 = null,
    username: ?[]const u8 = null,
    avatar_url: ?[]const u8 = null,
    tts: ?bool = null,
    embeds: ?[]const model.Message.Embed = null,
    allowed_mentions: ?model.Message.AllowedMentions = null,
    components: ?[]const model.components.TopLevelMessageComponent = null,
    attachments: ?[]const EndpointClient.PartialAttachmentRequest = null,
    flags: ?model.Message.Flags = null,
    thread_name: ?[]const u8 = null,
    applied_tags: ?[]const model.Snowflake = null,
    poll: ?model.Poll = null,
};

pub const PossiblyInThreadQuery = struct {
    thread_id: ?model.Snowflake = null,

    pub const format = query_strings.formatAsQueryString;
};

pub const EditWebhookMessageJsonBody = struct {
    content: jconfig.Omittable(?[]const u8) = .omit,
    embeds: jconfig.Omittable(?[]const model.Message.Embed) = .omit,
    flags: jconfig.Omittable(?model.Message.Flags) = .omit,
    allowed_mentions: jconfig.Omittable(?model.Message.AllowedMentions) = .omit,
    components: jconfig.Omittable(?[]const model.components.TopLevelMessageComponent) = .omit,
    attachments: jconfig.Omittable(?[]const EndpointClient.AttachmentRequest) = .omit,
    poll: jconfig.Omittable(?model.Poll) = .omit, // Polls can only be added when editing a deferred interaction response.

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const EditWebhookMessageFormBody = multipart.FormDataBody(?[]const ?Upload, EditWebhookMessageFormPayload);
pub const EditWebhookMessageFormPayload = struct {
    content: ?[]const u8 = null,
    embeds: ?[]const model.Message.Embed = null,
    flags: ?model.Message.Flags = null,
    allowed_mentions: ?model.Message.AllowedMentions = null,
    components: ?[]const model.components.TopLevelMessageComponent = null,
    attachments: ?[]const EndpointClient.AttachmentRequest = null,
    poll: ?model.Poll = null, // Polls can only be added when editing a deferred interaction response.
};
