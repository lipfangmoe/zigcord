const std = @import("std");
const model = @import("model");
const EndpointClient = @import("../EndpointClient.zig");
const RestClient = @import("../RestClient.zig");
const Result = RestClient.Result;
const allocDiscordUriStr = @import("../discord_uri.zig").allocDiscordUriStr;
const jconfig = @import("jconfig");

pub fn sendSoundboardSound(client: *EndpointClient, channel_id: model.Snowflake, body: SendSoundboardSoundBody) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/send-soundboard-sound", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBody(void, .POST, uri, body, .{});
}

pub fn listDefaultSoundboardSounds(client: *EndpointClient) !Result([]model.SoundboardSound) {
    const uri = try std.Uri.parse("/soundboard-default-sounds");

    return client.rest_client.request([]model.SoundboardSound, .GET, uri);
}

pub fn listGuildSoundboardSounds(client: *EndpointClient, guild_id: model.Snowflake) !Result([]model.SoundboardSound) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/soundboard-sounds", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]model.SoundboardSound, .GET, uri);
}

pub fn getGuildSoundboardSound(client: *EndpointClient, guild_id: model.Snowflake, sound_id: model.Snowflake) !Result(model.SoundboardSound) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/soundboard-sounds/{f}", .{ guild_id, sound_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.SoundboardSound, .GET, uri);
}

pub fn createGuildSoundboardSound(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    body: CreateGuildSoundboardSoundBody,
    audit_log_reason: ?[]const u8,
) !Result(model.SoundboardSound) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/soundboard-sounds", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(model.SoundboardSound, .POST, uri, body, .{}, audit_log_reason);
}

pub fn modifyGuildSoundboardSound(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    sound_id: model.Snowflake,
    body: ModifyGuildSoundboardSoundBody,
    audit_log_reason: ?[]const u8,
) !Result(model.SoundboardSound) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/soundboard-sounds/{f}", .{ guild_id, sound_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(model.SoundboardSound, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn deleteGuildSoundboardSound(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    sound_id: model.Snowflake,
    audit_log_reason: ?[]const u8,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/soundboard-sounds/{f}", .{ guild_id, sound_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithAuditLogReason(void, .DELETE, uri, audit_log_reason);
}

pub const SendSoundboardSoundBody = struct {
    sound_id: model.Snowflake,
    source_guild_id: jconfig.Omittable(model.Snowflake) = .omit,

    pub const jsonStringify = jconfig.OmittableFieldsMixin(@This()).jsonStringify;
};

pub const CreateGuildSoundboardSoundBody = struct {
    name: []const u8,
    sound: model.DataUri,
    volume: jconfig.Omittable(?f64) = .omit,
    emoji_id: jconfig.Omittable(?model.Snowflake) = .omit,
    emoji_name: jconfig.Omittable(?[]const u8) = .omit,

    pub const jsonStringify = jconfig.OmittableFieldsMixin(@This()).jsonStringify;
};

pub const ModifyGuildSoundboardSoundBody = struct {
    name: jconfig.Omittable([]const u8) = .omit,
    volume: jconfig.Omittable(?f64) = .omit,
    emoji_id: jconfig.Omittable(?model.Snowflake) = .omit,
    emoji_name: jconfig.Omittable(?[]const u8) = .omit,

    pub const jsonStringify = jconfig.OmittableFieldsMixin(@This()).jsonStringify;
};
