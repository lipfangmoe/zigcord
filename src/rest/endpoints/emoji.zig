const std = @import("std");
const deancord = @import("../../root.zig");
const model = deancord.model;
const rest = deancord.rest;
const jconfig = deancord.jconfig;

pub fn listGuildEmoji(
    client: *rest.Client,
    guild_id: model.Snowflake,
) !rest.Client.Result([]model.Emoji) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/emojis", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request([]model.Emoji, .GET, uri);
}

pub fn getGuildEmoji(
    client: *rest.Client,
    guild_id: model.Snowflake,
    emoji_id: model.Snowflake,
) !rest.Client.Result(model.Emoji) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/emojis/{}", .{ guild_id, emoji_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(model.Emoji, .GET, uri);
}

pub fn createGuildEmoji(
    client: *rest.Client,
    guild_id: model.Snowflake,
    body: CreateGuildEmojiBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(model.Emoji) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/emojis", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndAuditLogReason(model.Emoji, .POST, uri, body, .{}, audit_log_reason);
}

pub fn modifyGuildEmoji(
    client: *rest.Client,
    guild_id: model.Snowflake,
    emoji_id: model.Snowflake,
    body: CreateGuildEmojiBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(model.Emoji) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/emojis/{}", .{ guild_id, emoji_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndAuditLogReason(model.Emoji, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn deleteGuildEmoji(
    client: *rest.Client,
    guild_id: model.Snowflake,
    emoji_id: model.Snowflake,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/emojis/{}", .{ guild_id, emoji_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithAuditLogReason(void, .DELETE, uri, audit_log_reason);
}

pub const CreateGuildEmojiBody = struct {
    name: []const u8,
    /// https://discord.com/developers/docs/reference#image-data
    image: []const u8,
    roles: []const model.Snowflake,
};

pub const ModifyGuildEmojiBody = struct {
    name: jconfig.Omittable([]const u8) = .omit,
    roles: jconfig.Omittable(?[]const model.Snowflake) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};
