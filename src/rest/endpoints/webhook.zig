const deancord = @import("../../root.zig");
const std = @import("std");
const model = deancord.model;
const rest = deancord.rest;
const jconfig = deancord.jconfig;

pub fn createWebhook(
    client: *rest.ApiClient,
    channel_id: model.Snowflake,
    body: CreateWebhookBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(model.Webhook) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/webhooks", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBodyAndAuditLogReason(model.Webhook, .POST, uri, body, .{}, audit_log_reason);
}

pub fn getChannelWebhooks(
    client: *rest.ApiClient,
    channel_id: model.Snowflake,
) !rest.Client.Result([]const model.Webhook) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/webhooks", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const model.Webhook, .GET, uri);
}

pub fn getGuildWebhooks(
    client: *rest.ApiClient,
    guild_id: model.Snowflake,
) !rest.Client.Result([]const model.Webhook) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{}/webhooks", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const model.Webhook, .GET, uri);
}

pub fn getWebhook(
    client: *rest.ApiClient,
    webhook_id: model.Snowflake,
) !rest.Client.Result(model.Webhook) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{}", .{webhook_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Webhook, .GET, uri);
}

pub fn getWebhookWithToken(
    client: *rest.ApiClient,
    webhook_id: model.Snowflake,
    webhook_token: []const u8,
) !rest.Client.Result(model.Webhook) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{}/{s}", .{ webhook_id, webhook_token });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Webhook, .GET, uri);
}

pub fn modifyWebhook(
    client: *rest.ApiClient,
    webhook_id: model.Snowflake,
    body: ModifyWebhookBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(model.Webhook) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{}", .{webhook_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBodyAndAuditLogReason(model.Webhook, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn modifyWebhookWithToken(
    client: *rest.ApiClient,
    webhook_id: model.Snowflake,
    webhook_token: []const u8,
    body: ModifyWebhookBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(model.Webhook) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{}/{s}", .{ webhook_id, webhook_token });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBodyAndAuditLogReason(model.Webhook, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn deleteWebhook(
    client: *rest.ApiClient,
    webhook_id: model.Snowflake,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{}", .{webhook_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithAuditLogReason(void, .PATCH, uri, audit_log_reason);
}

pub fn deleteWebhookWithToken(
    client: *rest.ApiClient,
    webhook_id: model.Snowflake,
    webhook_token: []const u8,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{}/{s}", .{ webhook_id, webhook_token });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithAuditLogReason(void, .PATCH, uri, audit_log_reason);
}

pub fn executeWebhookWait(
    client: *rest.ApiClient,
    webhook_id: model.Snowflake,
    webhook_token: []const u8,
    query: ExecuteWebhookQuery,
    body: ExecuteWebhookFormBody,
) !rest.Client.Result(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{}/{s}?{query}", .{ webhook_id, webhook_token, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    var pending_request = try client.rest_client.beginMultipartRequest(model.Message, .POST, uri, .chunked, rest.multipart_boundary, null);
    defer pending_request.deinit();

    try std.fmt.format(pending_request.writer(), "{form}", .{body});

    return pending_request.waitForResponse();
}

pub fn executeWebhookNoWait(
    client: *rest.ApiClient,
    webhook_id: model.Snowflake,
    webhook_token: []const u8,
    query: ExecuteWebhookQuery,
    body: ExecuteWebhookFormBody,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{}/{s}?{query}", .{ webhook_id, webhook_token, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    var pending_request = try client.rest_client.beginMultipartRequest(void, .POST, uri, .chunked, rest.multipart_boundary, null);
    defer pending_request.deinit();

    try std.fmt.format(pending_request.writer(), "{form}", .{body});

    return pending_request.waitForResponse();
}

// is there a point in supporting slack/github compatible webhook endpoints? i don't want to have to build entirely new models just to support them

pub fn getWebhookMessage(
    client: *rest.ApiClient,
    webhook_id: model.Snowflake,
    webhook_token: []const u8,
    message_id: model.Snowflake,
    query: PossiblyInThreadQuery,
) !rest.Client.Result(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{}/{s}/messages/{}?{query}", .{ webhook_id, webhook_token, message_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Message, .GET, uri);
}

pub fn editWebhookMessage(
    client: *rest.ApiClient,
    webhook_id: model.Snowflake,
    webhook_token: []const u8,
    message_id: model.Snowflake,
    query: PossiblyInThreadQuery,
    body: EditWebhookMessageFormBody,
) !rest.Client.Result(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{}/{s}/messages/{}?{query}", .{ webhook_id, webhook_token, message_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    var pending_request = try client.rest_client.beginMultipartRequest(model.Message, .PATCH, uri, .chunked, rest.multipart_boundary, null);
    defer pending_request.deinit();

    try std.fmt.format(pending_request.writer(), "{form}", .{body});

    return pending_request.waitForResponse();
}

pub fn deleteWebhookMessage(
    client: *rest.ApiClient,
    webhook_id: model.Snowflake,
    webhook_token: []const u8,
    message_id: model.Snowflake,
    query: PossiblyInThreadQuery,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/webhooks/{}/{s}/messages/{}?{query}", .{ webhook_id, webhook_token, message_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub const CreateWebhookBody = struct {
    name: []const u8,
    avatar: jconfig.Omittable(?model.ImageData) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ModifyWebhookBody = struct {
    name: jconfig.Omittable([]const u8) = .omit,
    avatar: jconfig.Omittable(?model.ImageData) = .omit,
    channel_id: jconfig.Omittable(model.Snowflake) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ExecuteWebhookQuery = struct {
    thread_id: ?model.Snowflake = null,

    pub usingnamespace rest.QueryStringFormatMixin(@This());
};
pub const ExecuteWebhookFormBody = struct {
    content: ?[]const u8 = null,
    username: ?[]const u8 = null,
    avatar_url: ?[]const u8 = null,
    tts: ?bool = null,
    embeds: ?[]const model.Message.Embed = null,
    allowed_mentions: ?model.Message.AllowedMentions = null,
    components: ?[]const model.MessageComponent = null,
    files: ?[]const ?std.io.AnyReader = null,
    attachments: ?[]const jconfig.Partial(model.Message.Attachment) = null,
    flags: ?model.Message.Flags = null,
    thread_name: ?[]const u8 = null,
    applied_tags: ?[]const model.Snowflake = null,
    poll: ?model.Poll = null,

    pub fn format(self: ExecuteWebhookFormBody, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        if (comptime !std.mem.eql(u8, fmt, "form")) {
            @compileError("ExecuteWebhookFormBody.format should only be called with fmt string {form}");
        }
        try rest.writeMultipartFormDataBody(self, "files", writer);
    }
};

pub const PossiblyInThreadQuery = struct {
    thread_id: ?model.Snowflake = null,

    pub usingnamespace rest.QueryStringFormatMixin(@This());
};

pub const EditWebhookMessageFormBody = struct {
    content: ?[]const u8 = null,
    embeds: ?[]const model.Message.Embed = null,
    allowed_mentions: ?model.Message.AllowedMentions = null,
    components: ?[]const model.MessageComponent = null,
    files: ?[]const ?std.io.AnyReader = null,
    attachments: ?[]const jconfig.Partial(model.Message.Attachment) = null,

    pub fn format(self: EditWebhookMessageFormBody, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        if (comptime !std.mem.eql(u8, fmt, "form")) {
            @compileError("ExecuteWebhookFormBody.format should only be called with fmt string {form}");
        }
        try rest.writeMultipartFormDataBody(self, "files", writer);
    }
};
