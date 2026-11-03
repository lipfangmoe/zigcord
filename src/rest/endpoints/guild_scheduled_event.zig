const std = @import("std");
const model = @import("model");
const jconfig = @import("jconfig");
const EndpointClient = @import("../EndpointClient.zig");
const RestClient = @import("../RestClient.zig");
const Result = RestClient.Result;
const allocDiscordUriStr = @import("../discord_uri.zig").allocDiscordUriStr;
const query_strings = @import("../query_strings.zig");

pub fn listScheduledEventsForGuild(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    with_user_count: ?bool,
) !Result([]model.GuildScheduledEvent) {
    const query = WithUserCountQuery{ .with_user_count = with_user_count };
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/scheduled-events?{f}", .{ guild_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]model.GuildScheduledEvent, .GET, uri);
}

pub fn createGuildScheduledEvent(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    body: CreateGuildScheduledEventBody,
    audit_log_reason: ?[]const u8,
) !Result(model.GuildScheduledEvent) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/scheduled-events", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(model.GuildScheduledEvent, .POST, uri, body, .{}, audit_log_reason);
}

pub fn getGuildScheduledEvent(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    guild_scheduled_event_id: model.Snowflake,
    with_user_count: ?bool,
) !Result(model.GuildScheduledEvent) {
    const query = WithUserCountQuery{ .with_user_count = with_user_count };
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/scheduled-events/{f}?{f}", .{ guild_id, guild_scheduled_event_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.GuildScheduledEvent, .GET, uri);
}

pub fn modifyGuildScheduledEvent(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    guild_scheduled_event_id: model.Snowflake,
    body: ModifyGuildScheduledEventBody,
    audit_log_reason: ?[]const u8,
) !Result(model.GuildScheduledEvent) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/scheduled-events/{f}", .{ guild_id, guild_scheduled_event_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(model.GuildScheduledEvent, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn deleteGuildScheduledEvent(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    guild_scheduled_event_id: model.Snowflake,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/scheduled-events/{f}", .{ guild_id, guild_scheduled_event_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub fn getGuildScheduledEventUsers(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    guild_scheduled_event_id: model.Snowflake,
    query: GetGuildScheduledEventUsersQuery,
) !Result([]model.GuildScheduledEvent.EventUser) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/scheduled-events/{f}/users?{f}", .{ guild_id, guild_scheduled_event_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]model.GuildScheduledEvent.EventUser, .GET, uri);
}

pub const WithUserCountQuery = struct {
    with_user_count: ?bool = null,

    pub const format = query_strings.formatAsQueryString;
};

pub const CreateGuildScheduledEventBody = struct {
    channel_id: ?model.Snowflake = null,
    entity_metadata: ?model.GuildScheduledEvent.EntityMetadata = null,
    name: []const u8,
    privacy_level: model.GuildScheduledEvent.PrivacyLevel,
    scheduled_start_time: model.IsoTime,
    scheduled_end_time: model.IsoTime,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ModifyGuildScheduledEventBody = struct {
    channel_id: jconfig.Omittable(?model.Snowflake) = .omit,
    entity_metadata: jconfig.Omittable(?model.GuildScheduledEvent.EntityMetadata) = .omit,
    name: ?[]const u8 = null,
    privacy_level: ?model.GuildScheduledEvent.PrivacyLevel = null,
    scheduled_start_time: ?model.IsoTime = null,
    scheduled_end_time: ?model.IsoTime = null,
    description: jconfig.Omittable(?[]const u8) = .omit,
    entity_type: ?model.GuildScheduledEvent.EntityType = null,
    status: ?model.GuildScheduledEvent.EventStatus = null,
    image: ?model.DataUri = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const GetGuildScheduledEventUsersQuery = struct {
    limit: ?i64 = null,
    with_member: ?bool = null,
    before: ?model.Snowflake = null,
    after: ?model.Snowflake = null,

    pub const format = query_strings.formatAsQueryString;
};
