const std = @import("std");
const model = @import("model");
const jconfig = @import("jconfig");
const EndpointClient = @import("../EndpointClient.zig");
const RestClient = @import("../RestClient.zig");
const Result = RestClient.Result;
const allocDiscordUriStr = @import("../discord_uri.zig").allocDiscordUriStr;

pub fn listGuildEmoji(
    client: *EndpointClient,
    guild_id: model.Snowflake,
) !Result([]model.Emoji) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/emojis", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]model.Emoji, .GET, uri);
}

pub fn getGuildEmoji(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    emoji_id: model.Snowflake,
) !Result(model.Emoji) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/emojis/{f}", .{ guild_id, emoji_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Emoji, .GET, uri);
}

pub fn createGuildEmoji(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    body: CreateGuildEmojiBody,
    audit_log_reason: ?[]const u8,
) !Result(model.Emoji) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/emojis", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(model.Emoji, .POST, uri, body, .{}, audit_log_reason);
}

pub fn modifyGuildEmoji(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    emoji_id: model.Snowflake,
    body: CreateGuildEmojiBody,
    audit_log_reason: ?[]const u8,
) !Result(model.Emoji) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/emojis/{f}", .{ guild_id, emoji_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(model.Emoji, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn deleteGuildEmoji(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    emoji_id: model.Snowflake,
    audit_log_reason: ?[]const u8,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/emojis/{f}", .{ guild_id, emoji_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithAuditLogReason(void, .DELETE, uri, audit_log_reason);
}

pub fn listApplicationEmojis(client: *EndpointClient, application_id: model.Snowflake) !Result(ListApplicationEmojiResponse) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/applications/{f}/emojis", .{application_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(ListApplicationEmojiResponse, .GET, uri);
}

pub fn getApplicationEmoji(client: *EndpointClient, application_id: model.Snowflake, emoji_id: model.Snowflake) !Result(model.Emoji) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/applications/{f}/emojis/{f}", .{ application_id, emoji_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Emoji, .GET, uri);
}

pub fn modifyApplicationEmoji(
    client: *EndpointClient,
    application_id: model.Snowflake,
    emoji_id: model.Snowflake,
    body: ModifyApplicationEmojiBody,
) !Result(model.Emoji) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/applications/{f}/emojis/{f}", .{ application_id, emoji_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBody(model.Emoji, .PATCH, uri, body, .{});
}

pub fn deleteApplicationEmoji(client: *EndpointClient, application_id: model.Snowflake, emoji_id: model.Snowflake) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/applications/{f}/emojis/{f}", .{ application_id, emoji_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
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

pub const ListApplicationEmojiResponse = struct {
    items: []const model.Emoji,
};

pub const AuthoredEmoji = struct {
    emoji: model.Emoji,
    user: model.User,

    const Mixin = jconfig.InlineSingleStructFieldMixin(AuthoredEmoji, "emoji");
    pub const jsonStringify = Mixin.jsonStringify;
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;
};

pub const ModifyApplicationEmojiBody = struct {
    name: jconfig.Omittable([]const u8) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};
