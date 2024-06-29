const std = @import("std");
const root = @import("root");
const model = root.model;
const rest = root.rest;
const Snowflake = model.Snowflake;
const RestResult = rest.Client.Result;
const Client = rest.Client;
const deanson = model.deanson;
const Omittable = deanson.Omittable;
const Channel = model.Channel;

const auditLogHeaders = rest.auditLogHeaders;

pub fn getChannel(client: *Client, channel_id: Snowflake) !RestResult(Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}", .{channel_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(Channel, .GET, uri);
}

pub fn modifyChannel(client: *Client, channel_id: Snowflake, audit_log_reason: ?[]const u8) !RestResult(Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}", .{channel_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithExtraHeaders(Channel, .PATCH, uri, auditLogHeaders(audit_log_reason));
}

pub fn deleteChannel(client: *Client, channel_id: Snowflake, audit_log_reason: ?[]const u8) !RestResult(Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}", .{channel_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithExtraHeaders(Channel, .DELETE, uri, auditLogHeaders(audit_log_reason));
}

pub fn getChannelMessages(client: *Client, channel_id: Snowflake, query: GetChannelMessagesQuery) !RestResult([]const model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}?{query}", .{ channel_id, query });
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.request([]const model.Message, .GET, uri);
}

pub fn getChannelMessage(client: *Client, channel_id: Snowflake, message_id: Snowflake) !RestResult(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/messages/{}", .{ channel_id, message_id });
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.request(model.Message, .GET, uri);
}

/// Note - the CreateMessageParams type has several helpers for creating messages easily
pub fn createMessage(client: *Client, channel_id: Snowflake, body: CreateMessage) !RestResult(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/messages", .{channel_id});
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    var pending_request = client.beginRequest(model.Message, .POST, uri, .chunked, .{});
    defer pending_request.deinit();

    try std.fmt.format(pending_request.writer(), "{form}", .{body});

    return pending_request.waitForResponse();
}

pub fn crosspostMessage(client: *Client, channel_id: Snowflake, message_id: Snowflake) !RestResult(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/messages/{}/crosspost", .{ channel_id, message_id });
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.request(model.Message, .POST, uri);
}

pub fn createReaction(client: *Client, channel_id: Snowflake, message_id: Snowflake, emoji: ReactionEmoji) !RestResult(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/messages/{}/reactions/{}/@me", .{ channel_id, message_id, emoji });
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.request(model.Message, .PUT, uri);
}

pub fn deleteOwnReaction(client: *Client, channel_id: Snowflake, message_id: Snowflake, emoji: ReactionEmoji) !RestResult(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/messages/{}/reactions/{}/@me", .{ channel_id, message_id, emoji });
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.request(void, .DELETE, uri);
}

pub fn deleteUserReaction(client: *Client, channel_id: Snowflake, message_id: Snowflake, emoji: ReactionEmoji, user_id: Snowflake) !RestResult(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/messages/{}/reactions/{}/{}", .{ channel_id, message_id, emoji, user_id });
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.request(void, .DELETE, uri);
}

pub fn getReactions(client: *Client, channel_id: Snowflake, message_id: Snowflake, emoji: ReactionEmoji, query: GetEmojiQuery) !RestResult([]const model.User) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/messages/{}/reactions/{}?{query}", .{ channel_id, message_id, emoji, query });
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.request([]const model.User, .GET, uri);
}

pub fn deleteAllReactions(client: *Client, channel_id: Snowflake, message_id: Snowflake) !RestResult(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/messages/{}/reactions", .{ channel_id, message_id });
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.request(void, .DELETE, uri);
}

pub fn deleteAllReactionsForEmoji(client: *Client, channel_id: Snowflake, message_id: Snowflake, emoji: ReactionEmoji) !RestResult(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/messages/{}/reactions/{}", .{ channel_id, message_id, emoji });
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.request(void, .DELETE, uri);
}

pub fn editMessage(client: *Client, channel_id: Snowflake, message_id: Snowflake, body: EditMessage) !RestResult(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/messages/{}", .{ channel_id, message_id });
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    var pending_request = client.beginRequest(model.Message, .PATCH, uri, .chunked, .{});
    defer pending_request.deinit();

    try std.fmt.format(pending_request.writer(), "{form}", .{body});

    return pending_request.waitForResponse();
}

pub fn deleteMessage(client: *Client, channel_id: Snowflake, message_id: Snowflake, audit_log_reason: ?[]const u8) !RestResult(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/messages/{}", .{ channel_id, message_id });
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.requestWithExtraHeaders(void, .DELETE, uri, auditLogHeaders(audit_log_reason));
}

pub fn bulkDeleteMessages(client: *Client, channel_id: Snowflake, message_ids: []const Snowflake, audit_log_reason: ?[]const u8) !RestResult(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/messages/bulk-delete", .{channel_id});
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndExtraHeaders(void, .POST, uri, message_ids, .{}, auditLogHeaders(audit_log_reason));
}

pub fn editChannelPermissions(client: *Client, channel_id: Snowflake, overwrite_id: Snowflake, body: EditChannelPermissions, audit_log_reason: ?[]const u8) !RestResult(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/permissions/{}", .{ channel_id, overwrite_id });
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndExtraHeaders(void, .PUT, uri, body, .{}, auditLogHeaders(audit_log_reason));
}

pub fn getChannelInvites(client: *Client, channel_id: Snowflake) !RestResult([]const model.Invite.WithMetadata) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/invites", .{channel_id});
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.request([]const model.Invite.WithMetadata, .PUT, uri);
}

pub fn createChannelInvite(client: *Client, channel_id: Snowflake, body: CreateChannelInvite, audit_log_reason: ?[]const u8) !RestResult(model.Invite) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/invites", .{channel_id});
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndExtraHeaders(model.Invite, .PUT, uri, body, .{ .emit_null_optional_fields = false }, auditLogHeaders(audit_log_reason));
}

pub fn deleteChannelPermission(client: *Client, channel_id: Snowflake, overwrite_id: Snowflake, audit_log_reason: ?[]const u8) !RestResult(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/permissions/{}", .{ channel_id, overwrite_id });
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.requestWithExtraHeaders(void, .DELETE, uri, auditLogHeaders(audit_log_reason));
}

pub fn followAnnouncementChannel(client: *Client, channel_to_follow_id: Snowflake, target_channel_id: Snowflake, audit_log_reason: ?[]const u8) !RestResult(Channel.Followed) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/followers", .{channel_to_follow_id});
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    const Body = struct { webhook_channel_id: Snowflake };
    const body = Body{ .webhook_channel_id = target_channel_id };

    return client.requestWithValueBodyAndExtraHeaders(void, .POST, uri, body, .{}, auditLogHeaders(audit_log_reason));
}

pub fn triggerTypingIndicator(client: *Client, channel_id: Snowflake) !RestResult(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/typing", .{channel_id});
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.request(void, .POST, uri);
}

pub fn getPinnedMessages(client: *Client, channel_id: Snowflake) !RestResult([]const model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/pins", .{channel_id});
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.request([]const model.Message, .GET, uri);
}

pub fn pinMessage(client: *Client, channel_id: Snowflake, message_id: Snowflake, audit_log_reason: ?[]const u8) !RestResult(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/pins/{}", .{ channel_id, message_id });
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.requestWithExtraHeaders(void, .PUT, uri, auditLogHeaders(audit_log_reason));
}

pub fn unpinMessage(client: *Client, channel_id: Snowflake, message_id: Snowflake, audit_log_reason: ?[]const u8) !RestResult(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/pins/{}", .{ channel_id, message_id });
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.requestWithExtraHeaders(void, .DELETE, uri, auditLogHeaders(audit_log_reason));
}

pub fn groupDmAddRecipient(client: *Client, channel_id: Snowflake, user_id: Snowflake, access_token: []const u8, nick: []const u8) !RestResult(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/recipients/{}", .{ channel_id, user_id });
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    const Body = struct { access_token: []const u8, nick: []const u8 };
    const body = Body{ .access_token = access_token, .nick = nick };

    return client.requestWithValueBody(void, .PUT, uri, body, .{});
}

pub fn groupDmRemoveRecipient(client: *Client, channel_id: Snowflake, user_id: Snowflake) !RestResult(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/recipients/{}", .{ channel_id, user_id });
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.request(void, .DELETE, uri);
}

pub fn startThreadFromMessage(client: *Client, channel_id: Snowflake, message_id: Snowflake, body: StartThreadFromMessage, audit_log_reason: ?[]const u8) !RestResult(Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/messages/{}/threads", .{ channel_id, message_id });
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndExtraHeaders(Channel, .POST, uri, body, .{}, auditLogHeaders(audit_log_reason));
}

pub fn startThreadWithoutMessage(client: *Client, channel_id: Snowflake, body: StartThreadWithoutMessage, audit_log_reason: ?[]const u8) !RestResult(Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/threads", .{channel_id});
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndExtraHeaders(Channel, .POST, uri, body, .{}, auditLogHeaders(audit_log_reason));
}

pub fn startTreadInForumOrMediaChannel(client: *Client, channel_id: Snowflake, body: StartThreadInForumOrMediaChannel, audit_log_reason: ?[]const u8) !RestResult(Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/threads", .{channel_id});
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    var pending_request = client.beginRequest(Channel, .PATCH, uri, .chunked, auditLogHeaders(audit_log_reason));
    defer pending_request.deinit();

    try std.fmt.format(pending_request.writer(), "{form}", .{body});

    return pending_request.waitForResponse();
}

pub fn joinThread(client: *Client, channel_id: Snowflake) !RestResult(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/thread-members/@me", .{channel_id});
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.request(void, .PUT, uri);
}

pub fn addThreadMember(client: *Client, channel_id: Snowflake, user_id: Snowflake) !RestResult(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/thread-members/{}", .{ channel_id, user_id });
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.request(void, .PUT, uri);
}

pub fn leaveThread(client: *Client, channel_id: Snowflake) !RestResult(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/thread-members/@me", .{channel_id});
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.request(void, .DELETE, uri);
}

pub fn removeThreadMember(client: *Client, channel_id: Snowflake, user_id: Snowflake) !RestResult(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/thread-members/{}", .{ channel_id, user_id });
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.request(void, .DELETE, uri);
}

pub fn getThreadMember(client: *Client, channel_id: Snowflake, user_id: Snowflake, with_member: ?bool) !RestResult(Channel.ThreadMember) {
    const Query = struct {
        with_member: ?bool = null,

        pub const format = rest.formatAsQueryString;
    };

    const query = Query{ .with_member = with_member };
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/thread-members/{}?{query}", .{ channel_id, user_id, query });
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.request(Channel.ThreadMember, .GET, uri);
}

pub fn listThreadMembers(client: *Client, channel_id: Snowflake, query: ListThreadMembersQuery) !RestResult([]const Channel.ThreadMember) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/thread-members?{query}", .{ channel_id, query });
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.request([]const Channel.ThreadMember, .GET, uri);
}

pub fn listPublicArchivedThreads(client: *Client, channel_id: Snowflake, query: ListThreadsQuery) !RestResult(ListThreadsResponse) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/threads/archived/public?{query}", .{ channel_id, query });
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.request(ListThreadsResponse, .GET, uri);
}

pub fn listPrivateArchivedThreads(client: *Client, channel_id: Snowflake, query: ListThreadsQuery) !RestResult(ListThreadsResponse) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/threads/archived/private?{query}", .{ channel_id, query });
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.request(ListThreadsResponse, .GET, uri);
}

pub fn listJoinedPrivateArchivedThreads(client: *Client, channel_id: Snowflake, query: ListThreadsQuery) !RestResult(ListThreadsResponse) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/users/@me/threads/archived/private?{query}", .{ channel_id, query });
    defer client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.request(ListThreadsResponse, .GET, uri);
}

// ==== ENDPOINT-SPECIFIC TYPES ====

pub const ModifyChannelParams = union(enum) {
    group_dm: struct {
        name: Omittable([]const u8) = .omit,
        icon: Omittable([]const u8) = .omit,

        pub const jsonStringify = deanson.stringifyWithOmit;
    },
    guild: struct {
        name: Omittable([]const u8) = .omit,
        type: Omittable(Channel.Type) = .omit,
        position: Omittable(?i64) = .omit,
        topic: Omittable(?[]const u8) = .omit,
        nsfw: Omittable(?bool) = .omit,
        rate_limit_per_user: Omittable(?i64) = .omit,
        bitrate: Omittable(?i64) = .omit,
        user_limit: Omittable(?i64) = .omit,
        permission_overwrites: Omittable(?[]const Channel.PermissionOverwrite) = .omit,
        parent_id: Omittable(?Snowflake) = .omit,
        rtc_region: Omittable(?[]const u8) = .omit,
        video_quality_mode: Omittable(?Channel.VideoQualityMode) = .omit,
        default_auto_archive_duration: Omittable(?i64) = .omit,
        flags: Omittable(Channel.Flags) = .omit,
        available_tags: Omittable([]const Channel.Tag) = .omit,
        default_reaction_emoji: Omittable(?Channel.DefaultReaction) = .omit,
        default_thread_rate_limit_per_user: Omittable(i64) = .omit,
        default_sort_order: Omittable(?i64) = .omit,
        default_forum_layout: Omittable(i64) = .omit,

        pub const jsonStringify = deanson.stringifyWithOmit;
    },
    thread: struct {
        name: Omittable([]const u8) = .omit,
        archived: Omittable(bool) = .omit,
        auto_archive_duration: Omittable(i64) = .omit,
        locked: Omittable(bool) = .omit,
        invitable: Omittable(bool) = .omit,
        rate_limit_per_user: Omittable(?i64) = .omit,
        flags: Omittable(Channel.Flags) = .omit,
        applied_tags: Omittable([]const Snowflake) = .omit,

        pub const jsonStringify = deanson.stringifyWithOmit;
    },

    pub const jsonStringify = deanson.stringifyUnionInline;
};

pub const GetChannelMessagesQuery = struct {
    timeframe: ?union(enum) {
        around: Snowflake,
        before: Snowflake,
        after: Snowflake,
    } = null,
    limit: ?i64 = null,

    pub const format = rest.formatAsQueryString;
};

// note to maintainers: top-level properties are encoded as form parameters, although the
// properties themselves (except files) will be encoded as JSON
pub const CreateMessage = struct {
    content: ?[]const u8 = null,
    nonce: ?union(enum) { int: i64, str: []const u8 } = null,
    tts: ?bool = null,
    embeds: ?[]const model.Message.Embed = null,
    allowed_mentions: ?AllowedMentions = null,
    message_reference: ?model.Message.Reference = null,
    components: ?[]const model.MessageComponent = null,
    sticker_ids: ?[]const Snowflake = null,
    files: ?std.AutoArrayHashMap(i64, std.io.AnyReader) = null,
    payload_json: ?[]const u8 = null,
    attachments: ?[]const model.Message.Attachment = null,
    flags: ?model.Message.Flags = null,
    enforce_nonce: ?bool = null,
    poll: ?model.Message.Poll = null,

    /// Creates a text-only message
    pub fn initTextOnly(message: []const u8) CreateMessage {
        return CreateMessage{ .content = message };
    }

    /// Creates a text message with a file upload. The length of `files` and `attachments` must be equal.
    pub fn initMessageWithFiles(
        message: ?[]const u8,
        files: []const std.io.AnyReader,
        attachments: []const model.Message.Attachment,
    ) CreateMessage {
        std.debug.assert(files.len == attachments.len);
        return CreateMessage{ .content = message, .files = files, .attachments = attachments };
    }

    pub fn initMessageWithEmbeds(message: ?[]const u8, embeds: []const model.Message.Embed) CreateMessage {
        return CreateMessage{ .content = message, .embeds = embeds };
    }

    pub fn initMessageWithStickers(message: ?[]const u8, sticker_ids: []const Snowflake) CreateMessage {
        return CreateMessage{ .content = message, .sticker_ids = sticker_ids };
    }

    pub fn initMessageWithComponents(message: ?[]const u8, components: []const model.MessageComponent) CreateMessage {
        return CreateMessage{ .content = message, .components = components };
    }

    pub fn initMessageWithPoll(message: ?[]const u8, poll: model.Message.Poll) CreateMessage {
        return CreateMessage{ .content = message, .poll = poll };
    }

    const boundary = "f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2";
    const HttpBodyWriter = std.http.Client.Connection.Writer;

    pub const format = rest.formatAsMultipartFormData;

    pub const AllowedMentions = struct {
        parse: []const AllowedMentionsType,
        roles: []const Snowflake,
        users: []const Snowflake,
        replied_user: bool,

        pub const AllowedMentionsType = enum {
            roles,
            users,
            everyone,
        };
    };
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
            .custom => |emoji| try std.fmt.format(writer, "{s}:{d}", .{ emoji.name, emoji.id }),
        }
    }
};

pub const GetEmojiQuery = struct {
    type: ?GetEmojiQueryType = null,
    after: ?Snowflake = null,
    limit: ?i64 = null,

    pub const format = rest.formatAsQueryString;

    pub const GetEmojiQueryType = enum(u1) {
        normal = 0,
        burst = 1,
    };
};

pub const EditMessage = struct {
    content: ?[]const u8 = null,
    embeds: ?[]const model.Message.Embed = null,
    flags: ?[]model.Message.Flags = null,
    allowed_mentions: ?CreateMessage.AllowedMentions = null,
    /// set a file to `null` to not affect it
    files: ?[]const ?std.io.AnyReader = null,
    /// must also include already-uploaded files
    attachments: ?[]const model.Message.Attachment = null,

    const boundary = "f89767726a7827c6f785b40aee1ca2ade74d951d6a2d50e27cc0f0e5072a12b2";
    const HttpBodyWriter = std.http.Client.Connection.Writer;

    pub const format = rest.formatAsMultipartFormData;
};

pub const EditChannelPermissions = struct {
    allow: Omittable(?model.Permissions) = .omit,
    deny: Omittable(?model.Permissions) = .omit,
    type: enum(u2) {
        role = 0,
        member = 1,

        pub const jsonStringify = model.deanson.stringifyEnumAsInt;
    },

    pub const jsonStringify = model.deanson.stringifyWithOmit;
};

pub const CreateChannelInvite = struct {
    max_age: Omittable(i64) = .omit,
    max_uses: Omittable(i64) = .omit,
    temporary: Omittable(bool) = .omit,
    unique: Omittable(bool) = .omit,
    target_tpe: Omittable(i64) = .omit,
    target_user_id: Omittable(Snowflake) = .omit,
    target_application_id: Omittable(Snowflake) = .omit,

    pub const jsonStringify = model.deanson.stringifyWithOmit;
};

pub const StartThreadFromMessage = struct {
    name: []const u8,
    auto_archive_duration: Omittable(i64) = .omit,
    rate_limit_per_user: Omittable(?i64) = .omit,

    pub const jsonStringify = deanson.stringifyWithOmit;
};

pub const StartThreadWithoutMessage = struct {
    name: []const u8,
    auto_archive_duration: Omittable(i64) = .omit,
    type: Channel.Type,
    invitable: Omittable(bool) = .omit,
    rate_limit_per_user: Omittable(?i64) = .omit,

    pub const jsonStringify = deanson.stringifyWithOmit;
};

pub const StartThreadInForumOrMediaChannel = struct {
    name: []const u8,
    auto_archive_duration: ?i64 = null,
    rate_limit_per_user: ?i64 = null,
    message: ForumAndMediaThreadMessage,
    applied_tags: ?[]const Snowflake = null,
    files: ?[]const std.io.AnyReader = null,

    pub const ForumAndMediaThreadMessage = struct {
        content: Omittable([]const u8) = .omit,
        embeds: Omittable([]const model.Message.Embed) = .omit,
        allowed_mentions: Omittable([]const CreateMessage.AllowedMentions) = .omit,
        components: Omittable([]const model.MessageComponent) = .omit,
        sticker_ids: Omittable([]const Snowflake) = .omit,
        attachments: Omittable([]const model.Message.Attachment) = .omit,
        flags: Omittable(model.Message.Flags) = .omit,
    };
};

pub const ListThreadMembersQuery = struct {
    with_member: ?bool = null,
    after: ?Snowflake = null,
    limit: ?i64 = null,

    pub const format = rest.formatAsQueryString;
};

pub const ListThreadsQuery = struct {
    before: ?[]const u8 = null,
    limit: ?i64 = null,

    pub const format = rest.formatAsQueryString;
};

pub const ListThreadsResponse = struct {
    threads: []const Channel,
    members: []const Channel.ThreadMember,
    has_more: bool,
};
