const zigcord = @import("../../root.zig");
const std = @import("std");
const model = zigcord.model;
const rest = zigcord.rest;
const jconfig = zigcord.jconfig;

pub fn sendSoundboardSound(client: *rest.EndpointClient, channel_id: model.Snowflake, body: SendSoundboardSoundBody) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/send-soundboard-sound", .{channel_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBody(void, .POST, uri, body, .{});
}

pub fn listDefaultSoundboardSounds(client: *rest.EndpointClient) !rest.RestClient.Result([]model.SoundboardSound) {
    const uri = try std.Uri.parse("/soundboard-default-sounds");

    return client.rest_client.request([]model.SoundboardSound, .GET, uri);
}

pub fn listGuildSoundboardSounds(client: *rest.EndpointClient, guild_id: model.Snowflake) !rest.RestClient.Result([]model.SoundboardSound) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/soundboard-sounds", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]model.SoundboardSound, .GET, uri);
}

pub fn getGuildSoundboardSound(client: *rest.EndpointClient, guild_id: model.Snowflake, sound_id: model.Snowflake) !rest.RestClient.Result(model.SoundboardSound) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/soundboard-sounds/{f}", .{ guild_id, sound_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.SoundboardSound, .GET, uri);
}

pub fn createGuildSoundboardSound(
    client: *rest.EndpointClient,
    guild_id: model.Snowflake,
    body: CreateGuildSoundboardSoundBody,
    audit_log_reason: ?[]const u8,
) !rest.RestClient.Result(model.SoundboardSound) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/soundboard-sounds", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(model.SoundboardSound, .POST, uri, body, .{}, audit_log_reason);
}

pub fn modifyGuildSoundboardSound(
    client: *rest.EndpointClient,
    guild_id: model.Snowflake,
    sound_id: model.Snowflake,
    body: ModifyGuildSoundboardSoundBody,
    audit_log_reason: ?[]const u8,
) !rest.RestClient.Result(model.SoundboardSound) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/soundboard-sounds/{f}", .{ guild_id, sound_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(model.SoundboardSound, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn deleteGuildSoundboardSound(
    client: *rest.EndpointClient,
    guild_id: model.Snowflake,
    sound_id: model.Snowflake,
    audit_log_reason: ?[]const u8,
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/soundboard-sounds/{f}", .{ guild_id, sound_id });
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
