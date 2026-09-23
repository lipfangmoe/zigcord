const std = @import("std");
const model = @import("model");
const jconfig = @import("jconfig");
const EndpointClient = @import("../EndpointClient.zig");
const RestClient = @import("../RestClient.zig");
const Result = RestClient.Result;
const discord_uri = @import("../discord_uri.zig");
const base_url = discord_uri.base_url;
const allocDiscordUriStr = discord_uri.allocDiscordUriStr;

pub fn listVoiceRegions(
    client: *EndpointClient,
) !Result([]const model.voice.Region) {
    const url = try std.Uri.parse(base_url ++ "/voice/regions");

    return client.rest_client.request([]const model.voice.Region, .GET, url);
}

pub fn getCurrentUserVoiceState(client: *EndpointClient, guild_id: model.Snowflake) !Result(model.voice.VoiceState) {
    const url_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/voice-states/@me", .{guild_id});
    defer client.rest_client.allocator.free(url_str);
    const url = try std.Uri.parse(url_str);

    return client.rest_client.request(model.voice.VoiceState, .GET, url);
}

pub fn getUserVoiceState(client: *EndpointClient, guild_id: model.Snowflake, user_id: model.Snowflake) !Result(model.voice.VoiceState) {
    const url_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/voice-states/{f}", .{ guild_id, user_id });
    defer client.rest_client.allocator.free(url_str);
    const url = try std.Uri.parse(url_str);

    return client.rest_client.request(model.voice.VoiceState, .GET, url);
}

pub fn modifyCurrentUserVoiceState(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    body: ModifyCurrentUserVoiceStateBody,
) !Result(void) {
    const url_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/voice-states/@me", .{guild_id});
    defer client.rest_client.allocator.free(url_str);
    const url = try std.Uri.parse(url_str);

    return client.rest_client.requestWithJsonBody(void, .PATCH, url, body, .{});
}

pub fn modifyUserVoiceState(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    user_id: model.Snowflake,
    body: ModifyCurrentUserVoiceStateBody,
) !Result(void) {
    const url_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/voice-states/{f}", .{ guild_id, user_id });
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
