const std = @import("std");
const zigcord = @import("../../root.zig");
const model = zigcord.model;
const rest = zigcord.rest;
const Snowflake = model.Snowflake;
const jconfig = zigcord.jconfig;
const Channel = model.Channel;

pub fn getChannel(client: *rest.EndpointClient, channel_id: Snowflake) !rest.RestClient.Result(Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(Channel, .GET, uri);
}

pub fn modifyChannel(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    body: ModifyChannelBody,
    audit_log_reason: ?[]const u8,
) !rest.RestClient.Result(Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBodyAndAuditLogReason(Channel, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn deleteChannel(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    audit_log_reason: ?[]const u8,
) !rest.RestClient.Result(Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithAuditLogReason(Channel, .DELETE, uri, audit_log_reason);
}

pub fn getChannelMessages(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    query: GetChannelMessagesQuery,
) !rest.RestClient.Result([]const model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}?{f}", .{ channel_id, query });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const model.Message, .GET, uri);
}

pub fn getChannelMessage(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    message_id: Snowflake,
) !rest.RestClient.Result(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/messages/{f}", .{ channel_id, message_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Message, .GET, uri);
}

/// Note - the CreateMessageJsonBody type has several helpers for creating messages easily
pub fn createMessage(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    body: CreateMessageJsonBody,
) !rest.RestClient.Result(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/messages", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBody(model.Message, .POST, uri, body, .{});
}

/// Note - the CreateMessageFormBody type has several helpers for creating messages easily
pub fn createMessageMultipart(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    body: CreateMessageFormBody,
) !rest.RestClient.Result(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/messages", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    var buf: [1028]u8 = undefined;
    var pending_request = try client.rest_client.beginMultipartRequest(model.Message, .POST, uri, .chunked, rest.multipart_boundary, null, &buf);

    var body_writer = try pending_request.request.sendBodyUnflushed("");
    try body_writer.writer.print("{f}", .{body});
    try body_writer.end();

    return pending_request.waitForResponse();
}

pub fn crosspostMessage(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    message_id: Snowflake,
) !rest.RestClient.Result(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/messages/{f}/crosspost", .{ channel_id, message_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBody(model.Message, .POST, uri, .{}, .{});
}

pub fn createReaction(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    message_id: Snowflake,
    emoji: ReactionEmoji,
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/messages/{f}/reactions/{f}/@me", .{ channel_id, message_id, emoji });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBody(void, .PUT, uri, .{}, .{});
}

pub fn deleteOwnReaction(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    message_id: Snowflake,
    emoji: ReactionEmoji,
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/messages/{f}/reactions/{f}/@me", .{ channel_id, message_id, emoji });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub fn deleteUserReaction(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    message_id: Snowflake,
    emoji: ReactionEmoji,
    user_id: Snowflake,
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/messages/{f}/reactions/{f}/{f}", .{ channel_id, message_id, emoji, user_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub fn getReactions(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    message_id: Snowflake,
    emoji: ReactionEmoji,
    query: GetEmojiQuery,
) !rest.RestClient.Result([]const model.User) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/messages/{f}/reactions/{f}?{f}", .{ channel_id, message_id, emoji, query });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const model.User, .GET, uri);
}

pub fn deleteAllReactions(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    message_id: Snowflake,
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/messages/{f}/reactions", .{ channel_id, message_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub fn deleteAllReactionsForEmoji(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    message_id: Snowflake,
    emoji: ReactionEmoji,
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/messages/{f}/reactions/{f}", .{ channel_id, message_id, emoji });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub fn editMessage(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    message_id: Snowflake,
    body: EditMessageJsonBody,
) !rest.RestClient.Result(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/messages/{f}", .{ channel_id, message_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return try client.rest_client.requestWithValueBody(model.Message, .PATCH, uri, body, .{});
}

pub fn editMessageMultipart(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    message_id: Snowflake,
    body: EditMessageFormBody,
) !rest.RestClient.Result(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/messages/{f}", .{ channel_id, message_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    var buf: [1028]u8 = undefined;
    var pending_request = try client.rest_client.beginMultipartRequest(model.Message, .PATCH, uri, .chunked, rest.multipart_boundary, null, &buf);

    var body_writer = try pending_request.request.sendBodyUnflushed("");
    try body_writer.writer.print("{f}", .{body});
    try body_writer.end();

    return pending_request.waitForResponse();
}

pub fn deleteMessage(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    message_id: Snowflake,
    audit_log_reason: ?[]const u8,
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/messages/{f}", .{ channel_id, message_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithAuditLogReason(void, .DELETE, uri, audit_log_reason);
}

pub fn bulkDeleteMessages(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    message_ids: []const Snowflake,
    audit_log_reason: ?[]const u8,
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/messages/bulk-delete", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBodyAndAuditLogReason(void, .POST, uri, message_ids, .{}, audit_log_reason);
}

pub fn getChannelPins(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    query: GetChannelPinsQuery,
) !rest.RestClient.Result([]const model.Channel.MessagePin) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/messages/pins?{f}", .{ channel_id, query });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const model.Channel.MessagePin, .GET, uri);
}

pub fn editChannelPermissions(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    overwrite_id: Snowflake,
    body: EditChannelPermissions,
    audit_log_reason: ?[]const u8,
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/permissions/{f}", .{ channel_id, overwrite_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBodyAndAuditLogReason(void, .PUT, uri, body, .{}, audit_log_reason);
}

pub fn getChannelInvites(client: *rest.EndpointClient, channel_id: Snowflake) !rest.RestClient.Result([]const model.Invite.WithMetadata) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/invites", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const model.Invite.WithMetadata, .GET, uri);
}

pub fn createChannelInvite(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    body: CreateChannelInvite,
    audit_log_reason: ?[]const u8,
) !rest.RestClient.Result(model.Invite) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/invites", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBodyAndAuditLogReason(model.Invite, .PUT, uri, body, .{ .emit_null_optional_fields = false }, audit_log_reason);
}

pub fn deleteChannelPermission(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    overwrite_id: Snowflake,
    audit_log_reason: ?[]const u8,
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/permissions/{f}", .{ channel_id, overwrite_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithAuditLogReason(void, .DELETE, uri, audit_log_reason);
}

pub fn followAnnouncementChannel(
    client: *rest.EndpointClient,
    channel_to_follow_id: Snowflake,
    target_channel_id: Snowflake,
    audit_log_reason: ?[]const u8,
) !rest.RestClient.Result(Channel.Followed) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/followers", .{channel_to_follow_id});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    const Body = struct { webhook_channel_id: Snowflake };
    const body = Body{ .webhook_channel_id = target_channel_id };

    return client.rest_client.requestWithValueBodyAndAuditLogReason(Channel.Followed, .POST, uri, body, .{}, audit_log_reason);
}

pub fn triggerTypingIndicator(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/typing", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBody(void, .POST, uri, .{}, .{});
}

pub fn pinMessage(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    message_id: Snowflake,
    audit_log_reason: ?[]const u8,
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/messages/pins/{f}", .{ channel_id, message_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBodyAndAuditLogReason(void, .PUT, uri, .{}, .{}, audit_log_reason);
}

pub fn unpinMessage(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    message_id: Snowflake,
    audit_log_reason: ?[]const u8,
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/messages/pins/{f}", .{ channel_id, message_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithAuditLogReason(void, .DELETE, uri, audit_log_reason);
}

pub fn groupDmAddRecipient(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    user_id: Snowflake,
    access_token: []const u8,
    nick: []const u8,
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/recipients/{f}", .{ channel_id, user_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    const Body = struct { access_token: []const u8, nick: []const u8 };
    const body = Body{ .access_token = access_token, .nick = nick };

    return client.rest_client.requestWithValueBody(void, .PUT, uri, body, .{});
}

pub fn groupDmRemoveRecipient(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    user_id: Snowflake,
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/recipients/{f}", .{ channel_id, user_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub fn startThreadFromMessage(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    message_id: Snowflake,
    body: StartThreadFromMessage,
    audit_log_reason: ?[]const u8,
) !rest.RestClient.Result(Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/messages/{f}/threads", .{ channel_id, message_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBodyAndAuditLogReason(Channel, .POST, uri, body, .{}, audit_log_reason);
}

pub fn startThreadWithoutMessage(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    body: StartThreadWithoutMessage,
    audit_log_reason: ?[]const u8,
) !rest.RestClient.Result(Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/threads", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBodyAndAuditLogReason(Channel, .POST, uri, body, .{}, audit_log_reason);
}

pub fn startThreadInForumOrMediaChannel(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    body: StartThreadInForumOrMediaChannelJsonBody,
    audit_log_reason: ?[]const u8,
) !rest.RestClient.Result(Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/threads", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return try client.rest_client.requestWithValueBodyAndAuditLogReason(Channel, .POST, uri, body, .{}, audit_log_reason);
}

pub fn startThreadInForumOrMediaChannelMultipart(
    client: *rest.EndpointClient,
    channel_id: Snowflake,
    body: StartThreadInForumOrMediaChannelFormBody,
    audit_log_reason: ?[]const u8,
) !rest.RestClient.Result(Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/threads", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    const headers: []const std.http.Header = if (audit_log_reason) |reason|
        &.{std.http.Header{ .name = "X-Audit-Log-Reason", .value = reason }}
    else
        &.{};

    var buf: [1028]u8 = undefined;
    var pending_request = try client.rest_client.beginMultipartRequest(Channel, .POST, uri, .chunked, rest.multipart_boundary, headers, &buf);

    var body_writer = try pending_request.request.sendBodyUnflushed("");
    try body_writer.writer.print("{f}", .{body});
    try body_writer.end();

    return pending_request.waitForResponse();
}

pub fn joinThread(client: *rest.EndpointClient, channel_id: Snowflake) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/thread-members/@me", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBody(void, .PUT, uri, .{}, .{});
}

pub fn addThreadMember(client: *rest.EndpointClient, channel_id: Snowflake, user_id: Snowflake) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/thread-members/{f}", .{ channel_id, user_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBody(void, .PUT, uri, .{}, .{});
}

pub fn leaveThread(client: *rest.EndpointClient, channel_id: Snowflake) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/thread-members/@me", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub fn removeThreadMember(client: *rest.EndpointClient, channel_id: Snowflake, user_id: Snowflake) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/thread-members/{f}", .{ channel_id, user_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub fn getThreadMember(client: *rest.EndpointClient, channel_id: Snowflake, user_id: Snowflake, with_member: ?bool) !rest.RestClient.Result(Channel.ThreadMember) {
    const Query = struct {
        with_member: ?bool = null,

        pub const format = rest.QueryStringFormatMixin(@This()).format;
    };

    const query = Query{ .with_member = with_member };
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/thread-members/{f}?{f}", .{ channel_id, user_id, query });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(Channel.ThreadMember, .GET, uri);
}

pub fn listThreadMembers(client: *rest.EndpointClient, channel_id: Snowflake, query: ListThreadMembersQuery) !rest.RestClient.Result([]const Channel.ThreadMember) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/thread-members?{f}", .{ channel_id, query });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const Channel.ThreadMember, .GET, uri);
}

pub fn listPublicArchivedThreads(client: *rest.EndpointClient, channel_id: Snowflake, query: ListThreadsQuery) !rest.RestClient.Result(ListThreadsResponse) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/threads/archived/public?{f}", .{ channel_id, query });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(ListThreadsResponse, .GET, uri);
}

pub fn listPrivateArchivedThreads(client: *rest.EndpointClient, channel_id: Snowflake, query: ListThreadsQuery) !rest.RestClient.Result(ListThreadsResponse) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/threads/archived/private?{f}", .{ channel_id, query });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(ListThreadsResponse, .GET, uri);
}

pub fn listJoinedPrivateArchivedThreads(client: *rest.EndpointClient, channel_id: Snowflake, query: ListThreadsQuery) !rest.RestClient.Result(ListThreadsResponse) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/users/@me/threads/archived/private?{f}", .{ channel_id, query });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(ListThreadsResponse, .GET, uri);
}

// ==== ENDPOINT-SPECIFIC TYPES ====

pub const ModifyChannelBody = union(enum) {
    group_dm: struct {
        name: jconfig.Omittable([]const u8) = .omit,
        icon: jconfig.Omittable([]const u8) = .omit,

        pub const jsonStringify = jconfig.stringifyWithOmit;
    },
    guild: struct {
        name: jconfig.Omittable([]const u8) = .omit,
        type: jconfig.Omittable(Channel.Type) = .omit,
        position: jconfig.Omittable(?i64) = .omit,
        topic: jconfig.Omittable(?[]const u8) = .omit,
        nsfw: jconfig.Omittable(?bool) = .omit,
        rate_limit_per_user: jconfig.Omittable(?i64) = .omit,
        bitrate: jconfig.Omittable(?i64) = .omit,
        user_limit: jconfig.Omittable(?i64) = .omit,
        permission_overwrites: jconfig.Omittable(?[]const jconfig.Partial(Channel.PermissionOverwrite)) = .omit,
        parent_id: jconfig.Omittable(?Snowflake) = .omit,
        rtc_region: jconfig.Omittable(?[]const u8) = .omit,
        video_quality_mode: jconfig.Omittable(?Channel.VideoQualityMode) = .omit,
        default_auto_archive_duration: jconfig.Omittable(?i64) = .omit,
        flags: jconfig.Omittable(Channel.Flags) = .omit,
        available_tags: jconfig.Omittable([]const Channel.Tag) = .omit,
        default_reaction_emoji: jconfig.Omittable(?Channel.DefaultReaction) = .omit,
        default_thread_rate_limit_per_user: jconfig.Omittable(i64) = .omit,
        default_sort_order: jconfig.Omittable(?i64) = .omit,
        default_forum_layout: jconfig.Omittable(i64) = .omit,

        pub const jsonStringify = jconfig.stringifyWithOmit;
    },
    thread: struct {
        name: jconfig.Omittable([]const u8) = .omit,
        archived: jconfig.Omittable(bool) = .omit,
        auto_archive_duration: jconfig.Omittable(i64) = .omit,
        locked: jconfig.Omittable(bool) = .omit,
        invitable: jconfig.Omittable(bool) = .omit,
        rate_limit_per_user: jconfig.Omittable(?i64) = .omit,
        flags: jconfig.Omittable(Channel.Flags) = .omit,
        applied_tags: jconfig.Omittable([]const Snowflake) = .omit,

        pub const jsonStringify = jconfig.stringifyWithOmit;
    },

    const Mixin = jconfig.InlineUnionMixin(@This());
    pub const jsonStringify = Mixin.jsonStringify;
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;
};

pub const GetChannelMessagesQuery = struct {
    timeframe: ?union(enum) {
        around: Snowflake,
        before: Snowflake,
        after: Snowflake,
    } = null,
    limit: ?i64 = null,

    pub const format = rest.QueryStringFormatMixin(@This()).format;
};

pub const CreateMessageJsonBody = struct {
    content: jconfig.Omittable([]const u8) = .omit,
    nonce: jconfig.Omittable(Nonce) = .omit,
    tts: jconfig.Omittable(bool) = .omit,
    embeds: jconfig.Omittable([]const model.Message.Embed) = .omit,
    allowed_mentions: jconfig.Omittable(model.Message.AllowedMentions) = .omit,
    message_reference: jconfig.Omittable(model.Message.Reference) = .omit,
    components: jconfig.Omittable([]const model.MessageComponent) = .omit,
    sticker_ids: jconfig.Omittable([]const Snowflake) = .omit,
    attachments: jconfig.Omittable([]const jconfig.Partial(model.Message.Attachment)) = .omit,
    flags: jconfig.Omittable(model.Message.Flags) = .omit,
    enforce_nonce: jconfig.Omittable(bool) = .omit,
    poll: jconfig.Omittable(model.Poll) = .omit,

    pub const Nonce = union(enum) {
        int: u64,
        str: []const u8,

        const Mixin = jconfig.InlineUnionMixin(@This());
        pub const jsonStringify = Mixin.jsonStringify;
        pub const jsonParse = Mixin.jsonParse;
        pub const jsonParseFromValue = Mixin.jsonParseFromValue;
    };

    pub const jsonStringify = jconfig.OmittableFieldsMixin(@This()).jsonStringify;

    /// Creates a text-only message
    pub fn initTextOnly(message: []const u8) CreateMessageJsonBody {
        return CreateMessageJsonBody{ .content = .initSome(message) };
    }

    pub fn initMessageWithEmbeds(message: ?[]const u8, embeds: []const model.Message.Embed) CreateMessageJsonBody {
        return CreateMessageJsonBody{ .content = .initNullable(message), .embeds = .initSome(embeds) };
    }

    pub fn initMessageWithStickers(message: ?[]const u8, sticker_ids: []const Snowflake) CreateMessageJsonBody {
        return CreateMessageJsonBody{ .content = .initNullable(message), .sticker_ids = .initSome(sticker_ids) };
    }

    pub fn initMessageWithComponents(message: ?[]const u8, components: []const model.MessageComponent) CreateMessageJsonBody {
        return CreateMessageJsonBody{ .content = .initNullable(message), .components = .initSome(components) };
    }

    pub fn initMessageWithComponentsV2(components: []const model.MessageComponent) CreateMessageJsonBody {
        return CreateMessageJsonBody{ .components = .initSome(components), .flags = .initSome(model.Message.Flags{ .is_components_v2 = true }) };
    }

    pub fn initMessageWithPoll(message: ?[]const u8, poll: model.Poll) CreateMessageJsonBody {
        return CreateMessageJsonBody{ .content = .initNullable(message), .poll = .initSome(poll) };
    }
};

// note to maintainers: top-level properties are encoded as form parameters, although the
// properties themselves (except files) will be encoded as JSON
pub const CreateMessageFormBody = struct {
    content: ?[]const u8 = null,
    nonce: ?union(enum) { int: i64, str: []const u8 } = null,
    tts: ?bool = null,
    embeds: ?[]const model.Message.Embed = null,
    allowed_mentions: ?model.Message.AllowedMentions = null,
    message_reference: ?model.Message.Reference = null,
    components: ?[]const model.MessageComponent = null,
    sticker_ids: ?[]const Snowflake = null,
    files: ?[]const *std.Io.Reader = null,
    attachments: ?[]const jconfig.Partial(model.Message.Attachment) = null,
    flags: ?model.Message.Flags = null,
    enforce_nonce: ?bool = null,
    poll: ?model.Poll = null,

    pub fn format(self: CreateMessageFormBody, writer: anytype) !void {
        rest.writeMultipartFormDataBody(self, "files", writer) catch return error.WriteFailed;
    }

    /// Creates a text-only message
    pub fn initTextOnly(message: []const u8) CreateMessageFormBody {
        return CreateMessageFormBody{ .content = message };
    }

    /// Creates a text message with a file upload. The length of `files` and `attachments` must be equal.
    pub fn initMessageWithFiles(
        message: ?[]const u8,
        files: []const *std.Io.Reader,
        attachments: []const jconfig.Partial(model.Message.Attachment),
    ) CreateMessageFormBody {
        std.debug.assert(files.len == attachments.len);
        return CreateMessageFormBody{ .content = message, .files = files, .attachments = attachments };
    }

    pub fn initMessageWithEmbeds(message: ?[]const u8, embeds: []const model.Message.Embed) CreateMessageFormBody {
        return CreateMessageFormBody{ .content = message, .embeds = embeds };
    }

    pub fn initMessageWithStickers(message: ?[]const u8, sticker_ids: []const Snowflake) CreateMessageFormBody {
        return CreateMessageFormBody{ .content = message, .sticker_ids = sticker_ids };
    }

    pub fn initMessageWithComponents(message: ?[]const u8, components: []const model.MessageComponent) CreateMessageFormBody {
        return CreateMessageFormBody{ .content = message, .components = components };
    }

    pub fn initMessageWithComponentsV2(components: []const model.MessageComponent) CreateMessageFormBody {
        return CreateMessageFormBody{ .components = components, .flags = model.Message.Flags{ .is_components_v2 = true } };
    }

    pub fn initMessageWithPoll(message: ?[]const u8, poll: model.Poll) CreateMessageFormBody {
        return CreateMessageFormBody{ .content = message, .poll = poll };
    }
};

pub const ReactionEmoji = union(enum) {
    unicode: []const u8,
    custom: model.Emoji,

    pub fn format(self: ReactionEmoji, writer: *std.Io.Writer) !void {
        switch (self) {
            .unicode => |emoji| {
                for (emoji) |byte| {
                    try writer.print("%{x:0>2}", .{byte});
                }
            },
            .custom => |emoji| {
                try writer.print("{?s}:{?d}", .{ emoji.name, emoji.id });
            },
        }
    }
};

pub const GetEmojiQuery = struct {
    type: ?GetEmojiQueryType = null,
    after: ?Snowflake = null,
    limit: ?i64 = null,

    pub const format = rest.QueryStringFormatMixin(@This()).format;

    pub const GetEmojiQueryType = enum(u1) {
        normal = 0,
        burst = 1,
    };
};

pub const EditMessageJsonBody = struct {
    content: jconfig.Omittable(?[]const u8) = .omit,
    embeds: jconfig.Omittable(?[]const model.Message.Embed) = .omit,
    flags: jconfig.Omittable(?model.Message.Flags) = .omit,
    allowed_mentions: jconfig.Omittable(?model.Message.AllowedMentions) = .omit,
    /// must also include already-uploaded files
    attachments: jconfig.Omittable(?[]const model.Message.Attachment) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const EditMessageFormBody = struct {
    content: ?[]const u8 = null,
    embeds: ?[]const model.Message.Embed = null,
    flags: ?model.Message.Flags = null,
    allowed_mentions: ?model.Message.AllowedMentions = null,
    /// set a file to `null` to not affect it
    files: ?[]const ?*std.io.Reader = null,
    /// must also include already-uploaded files
    attachments: ?[]const model.Message.Attachment = null,

    pub fn format(self: EditMessageFormBody, writer: anytype) !void {
        rest.writeMultipartFormDataBody(self, "files", writer) catch return error.WriteFailed;
    }
};

pub const EditChannelPermissions = struct {
    allow: jconfig.Omittable(?model.Permissions) = .omit,
    deny: jconfig.Omittable(?model.Permissions) = .omit,
    type: enum(u2) {
        role = 0,
        member = 1,

        pub const jsonStringify = jconfig.stringifyEnumAsInt;
    },

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const CreateChannelInvite = struct {
    max_age: jconfig.Omittable(i64) = .omit,
    max_uses: jconfig.Omittable(i64) = .omit,
    temporary: jconfig.Omittable(bool) = .omit,
    unique: jconfig.Omittable(bool) = .omit,
    target_tpe: jconfig.Omittable(i64) = .omit,
    target_user_id: jconfig.Omittable(Snowflake) = .omit,
    target_application_id: jconfig.Omittable(Snowflake) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const StartThreadFromMessage = struct {
    name: []const u8,
    auto_archive_duration: jconfig.Omittable(i64) = .omit,
    rate_limit_per_user: jconfig.Omittable(?i64) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const StartThreadWithoutMessage = struct {
    name: []const u8,
    auto_archive_duration: jconfig.Omittable(i64) = .omit,
    type: Channel.Type,
    invitable: jconfig.Omittable(bool) = .omit,
    rate_limit_per_user: jconfig.Omittable(?i64) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const StartThreadInForumOrMediaChannelJsonBody = struct {
    name: []const u8,
    message: ForumAndMediaThreadMessage,
    auto_archive_duration: jconfig.Omittable(?i64) = .omit,
    rate_limit_per_user: jconfig.Omittable(?i64) = .omit,
    applied_tags: jconfig.Omittable(?[]const Snowflake) = .omit,
    files: jconfig.Omittable(?[]const *std.Io.Reader) = .omit,

    pub const ForumAndMediaThreadMessage = struct {
        content: jconfig.Omittable([]const u8) = .omit,
        embeds: jconfig.Omittable([]const model.Message.Embed) = .omit,
        allowed_mentions: jconfig.Omittable([]const model.Message.AllowedMentions) = .omit,
        components: jconfig.Omittable([]const model.MessageComponent) = .omit,
        sticker_ids: jconfig.Omittable([]const Snowflake) = .omit,
        attachments: jconfig.Omittable([]const jconfig.Partial(model.Message.Attachment)) = .omit,
        flags: jconfig.Omittable(model.Message.Flags) = .omit,

        pub const jsonStringify = jconfig.stringifyWithOmit;
    };
};

pub const StartThreadInForumOrMediaChannelFormBody = struct {
    name: []const u8,
    auto_archive_duration: ?i64 = null,
    rate_limit_per_user: ?i64 = null,
    message: ForumAndMediaThreadMessage,
    applied_tags: ?[]const Snowflake = null,
    files: ?[]const *std.Io.Reader = null,

    pub fn format(self: StartThreadInForumOrMediaChannelFormBody, writer: anytype) !void {
        rest.writeMultipartFormDataBody(self, "files", writer) catch return error.WriteFailed;
    }

    pub const ForumAndMediaThreadMessage = struct {
        content: jconfig.Omittable([]const u8) = .omit,
        embeds: jconfig.Omittable([]const model.Message.Embed) = .omit,
        allowed_mentions: jconfig.Omittable([]const model.Message.AllowedMentions) = .omit,
        components: jconfig.Omittable([]const model.MessageComponent) = .omit,
        sticker_ids: jconfig.Omittable([]const Snowflake) = .omit,
        attachments: jconfig.Omittable([]const jconfig.Partial(model.Message.Attachment)) = .omit,
        flags: jconfig.Omittable(model.Message.Flags) = .omit,

        pub const jsonStringify = jconfig.stringifyWithOmit;
    };
};

pub const StartThreadInForumOrMediaChannelResponse = struct {
    thread: zigcord.model.Channel,
    message: zigcord.model.Message,

    const Mixin = jconfig.InlineSingleStructFieldMixin(@This(), "thread");
    pub const jsonStringify = Mixin.jsonStringify;
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;
};

pub const ListThreadMembersQuery = struct {
    with_member: ?bool = null,
    after: ?Snowflake = null,
    limit: ?i64 = null,

    pub const format = rest.QueryStringFormatMixin(@This()).format;
};

pub const ListThreadsQuery = struct {
    before: ?[]const u8 = null,
    limit: ?i64 = null,

    pub const format = rest.QueryStringFormatMixin(@This()).format;
};

pub const ListThreadsResponse = struct {
    threads: []const Channel,
    members: []const Channel.ThreadMember,
    has_more: bool,
};

pub const GetChannelPinsQuery = struct {
    before: ?model.IsoTime = null,
    limit: ?i64 = null,

    pub const format = rest.QueryStringFormatMixin(@This()).format;
};
