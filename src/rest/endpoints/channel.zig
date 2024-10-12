const std = @import("std");
const deancord = @import("../../root.zig");
const model = deancord.model;
const rest = deancord.rest;
const Snowflake = model.Snowflake;
const jconfig = deancord.jconfig;
const Channel = model.Channel;

pub fn getChannel(client: *rest.ApiClient, channel_id: Snowflake) !rest.Client.Result(Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(Channel, .GET, uri);
}

pub fn modifyChannel(
    client: *rest.ApiClient,
    channel_id: Snowflake,
    body: ModifyChannelBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBodyAndAuditLogReason(Channel, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn deleteChannel(
    client: *rest.ApiClient,
    channel_id: Snowflake,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithAuditLogReason(Channel, .DELETE, uri, audit_log_reason);
}

pub fn getChannelMessages(
    client: *rest.ApiClient,
    channel_id: Snowflake,
    query: GetChannelMessagesQuery,
) !rest.Client.Result([]const model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}?{query}", .{ channel_id, query });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const model.Message, .GET, uri);
}

pub fn getChannelMessage(
    client: *rest.ApiClient,
    channel_id: Snowflake,
    message_id: Snowflake,
) !rest.Client.Result(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/messages/{}", .{ channel_id, message_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Message, .GET, uri);
}

/// Note - the CreateMessageParams type has several helpers for creating messages easily
pub fn createMessage(
    client: *rest.ApiClient,
    channel_id: Snowflake,
    body: CreateMessageFormBody,
) !rest.Client.Result(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/messages", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    var pending_request = try client.rest_client.beginMultipartRequest(model.Message, .PATCH, uri, .chunked, rest.multipart_boundary, null);
    defer pending_request.deinit();

    try std.fmt.format(pending_request.writer(), "{form}", .{body});

    return pending_request.waitForResponse();
}

pub fn crosspostMessage(
    client: *rest.ApiClient,
    channel_id: Snowflake,
    message_id: Snowflake,
) !rest.Client.Result(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/messages/{}/crosspost", .{ channel_id, message_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Message, .POST, uri);
}

pub fn createReaction(
    client: *rest.ApiClient,
    channel_id: Snowflake,
    message_id: Snowflake,
    emoji: ReactionEmoji,
) !rest.Client.Result(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/messages/{}/reactions/{}/@me", .{ channel_id, message_id, emoji });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Message, .PUT, uri);
}

pub fn deleteOwnReaction(
    client: *rest.ApiClient,
    channel_id: Snowflake,
    message_id: Snowflake,
    emoji: ReactionEmoji,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/messages/{}/reactions/{}/@me", .{ channel_id, message_id, emoji });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub fn deleteUserReaction(
    client: *rest.ApiClient,
    channel_id: Snowflake,
    message_id: Snowflake,
    emoji: ReactionEmoji,
    user_id: Snowflake,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/messages/{}/reactions/{}/{}", .{ channel_id, message_id, emoji, user_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub fn getReactions(
    client: *rest.ApiClient,
    channel_id: Snowflake,
    message_id: Snowflake,
    emoji: ReactionEmoji,
    query: GetEmojiQuery,
) !rest.Client.Result([]const model.User) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/messages/{}/reactions/{}?{query}", .{ channel_id, message_id, emoji, query });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const model.User, .GET, uri);
}

pub fn deleteAllReactions(
    client: *rest.ApiClient,
    channel_id: Snowflake,
    message_id: Snowflake,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/messages/{}/reactions", .{ channel_id, message_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub fn deleteAllReactionsForEmoji(
    client: *rest.ApiClient,
    channel_id: Snowflake,
    message_id: Snowflake,
    emoji: ReactionEmoji,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/messages/{}/reactions/{}", .{ channel_id, message_id, emoji });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub fn editMessage(
    client: *rest.ApiClient,
    channel_id: Snowflake,
    message_id: Snowflake,
    body: EditMessageFormBody,
) !rest.Client.Result(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/messages/{}", .{ channel_id, message_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    var pending_request = try client.rest_client.beginMultipartRequest(model.Message, .PATCH, uri, .chunked, rest.multipart_boundary, null);
    defer pending_request.deinit();

    try std.fmt.format(pending_request.writer(), "{form}", .{body});

    return pending_request.waitForResponse();
}

pub fn deleteMessage(
    client: *rest.ApiClient,
    channel_id: Snowflake,
    message_id: Snowflake,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/messages/{}", .{ channel_id, message_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithAuditLogReason(void, .DELETE, uri, audit_log_reason);
}

pub fn bulkDeleteMessages(
    client: *rest.ApiClient,
    channel_id: Snowflake,
    message_ids: []const Snowflake,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/messages/bulk-delete", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBodyAndAuditLogReason(void, .POST, uri, message_ids, .{}, audit_log_reason);
}

pub fn editChannelPermissions(
    client: *rest.ApiClient,
    channel_id: Snowflake,
    overwrite_id: Snowflake,
    body: EditChannelPermissions,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/permissions/{}", .{ channel_id, overwrite_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBodyAndAuditLogReason(void, .PUT, uri, body, .{}, audit_log_reason);
}

pub fn getChannelInvites(client: *rest.ApiClient, channel_id: Snowflake) !rest.Client.Result([]const model.Invite.WithMetadata) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/invites", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const model.Invite.WithMetadata, .PUT, uri);
}

pub fn createChannelInvite(
    client: *rest.ApiClient,
    channel_id: Snowflake,
    body: CreateChannelInvite,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(model.Invite) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/invites", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBodyAndAuditLogReason(model.Invite, .PUT, uri, body, .{ .emit_null_optional_fields = false }, audit_log_reason);
}

pub fn deleteChannelPermission(
    client: *rest.ApiClient,
    channel_id: Snowflake,
    overwrite_id: Snowflake,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/permissions/{}", .{ channel_id, overwrite_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithAuditLogReason(void, .DELETE, uri, audit_log_reason);
}

pub fn followAnnouncementChannel(
    client: *rest.ApiClient,
    channel_to_follow_id: Snowflake,
    target_channel_id: Snowflake,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(Channel.Followed) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/followers", .{channel_to_follow_id});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    const Body = struct { webhook_channel_id: Snowflake };
    const body = Body{ .webhook_channel_id = target_channel_id };

    return client.rest_client.requestWithValueBodyAndAuditLogReason(Channel.Followed, .POST, uri, body, .{}, audit_log_reason);
}

pub fn triggerTypingIndicator(
    client: *rest.ApiClient,
    channel_id: Snowflake,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/typing", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .POST, uri);
}

pub fn getPinnedMessages(
    client: *rest.ApiClient,
    channel_id: Snowflake,
) !rest.Client.Result([]const model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/pins", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const model.Message, .GET, uri);
}

pub fn pinMessage(
    client: *rest.ApiClient,
    channel_id: Snowflake,
    message_id: Snowflake,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/pins/{}", .{ channel_id, message_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithAuditLogReason(void, .PUT, uri, audit_log_reason);
}

pub fn unpinMessage(
    client: *rest.ApiClient,
    channel_id: Snowflake,
    message_id: Snowflake,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/pins/{}", .{ channel_id, message_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithAuditLogReason(void, .DELETE, uri, audit_log_reason);
}

pub fn groupDmAddRecipient(
    client: *rest.ApiClient,
    channel_id: Snowflake,
    user_id: Snowflake,
    access_token: []const u8,
    nick: []const u8,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/recipients/{}", .{ channel_id, user_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    const Body = struct { access_token: []const u8, nick: []const u8 };
    const body = Body{ .access_token = access_token, .nick = nick };

    return client.rest_client.requestWithValueBody(void, .PUT, uri, body, .{});
}

pub fn groupDmRemoveRecipient(
    client: *rest.ApiClient,
    channel_id: Snowflake,
    user_id: Snowflake,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/recipients/{}", .{ channel_id, user_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub fn startThreadFromMessage(
    client: *rest.ApiClient,
    channel_id: Snowflake,
    message_id: Snowflake,
    body: StartThreadFromMessage,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/messages/{}/threads", .{ channel_id, message_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBodyAndAuditLogReason(Channel, .POST, uri, body, .{}, audit_log_reason);
}

pub fn startThreadWithoutMessage(
    client: *rest.ApiClient,
    channel_id: Snowflake,
    body: StartThreadWithoutMessage,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/threads", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBodyAndAuditLogReason(Channel, .POST, uri, body, .{}, audit_log_reason);
}

pub fn startTreadInForumOrMediaChannel(
    client: *rest.ApiClient,
    channel_id: Snowflake,
    body: StartThreadInForumOrMediaChannelFormBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/threads", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    const headers: []const std.http.Header = if (audit_log_reason) |reason|
        &.{std.http.Header{ .name = "X-Audit-Log-Reason", .value = reason }}
    else
        &.{};

    var pending_request = try client.rest_client.beginMultipartRequest(Channel, .PATCH, uri, .chunked, rest.multipart_boundary, headers);
    defer pending_request.deinit();

    try std.fmt.format(pending_request.writer(), "{form}", .{body});

    return pending_request.waitForResponse();
}

pub fn joinThread(client: *rest.ApiClient, channel_id: Snowflake) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/thread-members/@me", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .PUT, uri);
}

pub fn addThreadMember(client: *rest.ApiClient, channel_id: Snowflake, user_id: Snowflake) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/thread-members/{}", .{ channel_id, user_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .PUT, uri);
}

pub fn leaveThread(client: *rest.ApiClient, channel_id: Snowflake) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/thread-members/@me", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub fn removeThreadMember(client: *rest.ApiClient, channel_id: Snowflake, user_id: Snowflake) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/thread-members/{}", .{ channel_id, user_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub fn getThreadMember(client: *rest.ApiClient, channel_id: Snowflake, user_id: Snowflake, with_member: ?bool) !rest.Client.Result(Channel.ThreadMember) {
    const Query = struct {
        with_member: ?bool = null,

        pub usingnamespace rest.QueryStringFormatMixin(@This());
    };

    const query = Query{ .with_member = with_member };
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/thread-members/{}?{query}", .{ channel_id, user_id, query });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(Channel.ThreadMember, .GET, uri);
}

pub fn listThreadMembers(client: *rest.ApiClient, channel_id: Snowflake, query: ListThreadMembersQuery) !rest.Client.Result([]const Channel.ThreadMember) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/thread-members?{query}", .{ channel_id, query });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const Channel.ThreadMember, .GET, uri);
}

pub fn listPublicArchivedThreads(client: *rest.ApiClient, channel_id: Snowflake, query: ListThreadsQuery) !rest.Client.Result(ListThreadsResponse) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/threads/archived/public?{query}", .{ channel_id, query });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(ListThreadsResponse, .GET, uri);
}

pub fn listPrivateArchivedThreads(client: *rest.ApiClient, channel_id: Snowflake, query: ListThreadsQuery) !rest.Client.Result(ListThreadsResponse) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/threads/archived/private?{query}", .{ channel_id, query });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(ListThreadsResponse, .GET, uri);
}

pub fn listJoinedPrivateArchivedThreads(client: *rest.ApiClient, channel_id: Snowflake, query: ListThreadsQuery) !rest.Client.Result(ListThreadsResponse) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/users/@me/threads/archived/private?{query}", .{ channel_id, query });
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

    pub usingnamespace jconfig.InlineUnionMixin(@This());
};

pub const GetChannelMessagesQuery = struct {
    timeframe: ?union(enum) {
        around: Snowflake,
        before: Snowflake,
        after: Snowflake,
    } = null,
    limit: ?i64 = null,

    pub usingnamespace rest.QueryStringFormatMixin(GetChannelMessagesQuery);
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
    files: ?[]const std.io.AnyReader = null,
    attachments: ?[]const jconfig.Partial(model.Message.Attachment) = null,
    flags: ?model.Message.Flags = null,
    enforce_nonce: ?bool = null,
    poll: ?model.Poll = null,

    pub fn format(self: CreateMessageFormBody, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        if (comptime !std.mem.eql(u8, fmt, "form")) {
            @compileError("CreateMessageFormBody.format should only be called with fmt string {form}");
        }

        try rest.writeMultipartFormDataBody(self, "files", writer);
    }

    /// Creates a text-only message
    pub fn initTextOnly(message: []const u8) CreateMessageFormBody {
        return CreateMessageFormBody{ .content = message };
    }

    /// Creates a text message with a file upload. The length of `files` and `attachments` must be equal.
    pub fn initMessageWithFiles(
        message: ?[]const u8,
        files: []const std.io.AnyReader,
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

    pub fn initMessageWithPoll(message: ?[]const u8, poll: model.Poll) CreateMessageFormBody {
        return CreateMessageFormBody{ .content = message, .poll = poll };
    }
};

pub const ReactionEmoji = union(enum) {
    unicode: []const u8,
    custom: model.Emoji,

    pub fn format(self: ReactionEmoji, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        switch (self) {
            .unicode => |emoji| {
                for (emoji) |byte| {
                    try std.fmt.format(writer, "%{x:0>2}", .{byte});
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

    pub usingnamespace rest.QueryStringFormatMixin(@This());

    pub const GetEmojiQueryType = enum(u1) {
        normal = 0,
        burst = 1,
    };
};

pub const EditMessageFormBody = struct {
    content: ?[]const u8 = null,
    embeds: ?[]const model.Message.Embed = null,
    flags: ?[]model.Message.Flags = null,
    allowed_mentions: ?model.Message.AllowedMentions = null,
    /// set a file to `null` to not affect it
    files: ?[]const ?std.io.AnyReader = null,
    /// must also include already-uploaded files
    attachments: ?[]const model.Message.Attachment = null,

    pub fn format(self: EditMessageFormBody, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        if (comptime !std.mem.eql(u8, fmt, "form")) {
            @compileError("EditMessageFormBody.format should only be called with fmt string {form}");
        }

        try rest.writeMultipartFormDataBody(self, "files", writer);
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

pub const StartThreadInForumOrMediaChannelFormBody = struct {
    name: []const u8,
    auto_archive_duration: ?i64 = null,
    rate_limit_per_user: ?i64 = null,
    message: ForumAndMediaThreadMessage,
    applied_tags: ?[]const Snowflake = null,
    files: ?[]const std.io.AnyReader = null,

    pub fn format(self: StartThreadInForumOrMediaChannelFormBody, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        if (comptime !std.mem.eql(u8, fmt, "form")) {
            @compileError("StartThreadInForumOrMediaChannelFormBody.format should only be called with fmt string {form}");
        }

        try rest.writeMultipartFormDataBody(self, "files", writer);
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

pub const ListThreadMembersQuery = struct {
    with_member: ?bool = null,
    after: ?Snowflake = null,
    limit: ?i64 = null,

    pub usingnamespace rest.QueryStringFormatMixin(@This());
};

pub const ListThreadsQuery = struct {
    before: ?[]const u8 = null,
    limit: ?i64 = null,

    pub usingnamespace rest.QueryStringFormatMixin(@This());
};

pub const ListThreadsResponse = struct {
    threads: []const Channel,
    members: []const Channel.ThreadMember,
    has_more: bool,
};
