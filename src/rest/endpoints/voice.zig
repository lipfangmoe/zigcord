const zigcord = @import("../../root.zig");
const std = @import("std");
const model = zigcord.model;
const rest = zigcord.rest;
const jconfig = zigcord.jconfig;

pub fn listVoiceRegions(
    client: *rest.EndpointClient,
) !rest.RestClient.Result([]const model.voice.Region) {
    const url = try std.Uri.parse(rest.base_url ++ "/voice/regions");

    return client.rest_client.request([]const model.voice.Region, .GET, url);
}

pub fn getCurrentUserVoiceState(client: *rest.EndpointClient, guild_id: model.Snowflake) !rest.RestClient.Result(model.voice.VoiceState) {
    const url_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/voice-states/@me", .{guild_id});
    defer client.rest_client.allocator.free(url_str);
    const url = try std.Uri.parse(url_str);

    return client.rest_client.request(model.voice.VoiceState, .GET, url);
}

pub fn getUserVoiceState(client: *rest.EndpointClient, guild_id: model.Snowflake, user_id: model.Snowflake) !rest.RestClient.Result(model.voice.VoiceState) {
    const url_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/voice-states/{f}", .{ guild_id, user_id });
    defer client.rest_client.allocator.free(url_str);
    const url = try std.Uri.parse(url_str);

    return client.rest_client.request(model.voice.VoiceState, .GET, url);
}

pub fn modifyCurrentUserVoiceState(
    client: *rest.EndpointClient,
    guild_id: model.Snowflake,
    body: ModifyCurrentUserVoiceStateBody,
) !rest.RestClient.Result(void) {
    const url_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/voice-states/@me", .{guild_id});
    defer client.rest_client.allocator.free(url_str);
    const url = try std.Uri.parse(url_str);

    return client.rest_client.requestWithJsonBody(void, .PATCH, url, body, .{});
}

pub fn modifyUserVoiceState(
    client: *rest.EndpointClient,
    guild_id: model.Snowflake,
    user_id: model.Snowflake,
    body: ModifyCurrentUserVoiceStateBody,
) !rest.RestClient.Result(void) {
    const url_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/voice-states/{f}", .{ guild_id, user_id });
    defer client.rest_client.allocator.free(url_str);
    const url = try std.Uri.parse(url_str);

    return client.rest_client.requestWithJsonBody(void, .PATCH, url, body, .{});
}

pub const ModifyCurrentUserVoiceStateBody = struct {
    channel_id: jconfig.Omittable(model.Snowflake) = .omit,
    suppress: jconfig.Omittable(bool) = .omit,
    request_to_speak_timestamp: jconfig.Omittable(?model.IsoTime) = .omit,

    pub const jsonStringify = jconfig.OmittableFieldsMixin(@This()).jsonStringify;
};

pub const ModifyUserVoiceStateBody = struct {
    channel_id: jconfig.Omittable(model.Snowflake) = .omit,
    suppress: jconfig.Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.OmittableFieldsMixin(@This()).jsonStringify;
};
