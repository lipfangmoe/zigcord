const std = @import("std");
const deancord = @import("../../root.zig");
const model = deancord.model;
const rest = deancord.rest;
const jconfig = deancord.jconfig;

pub fn listScheduledEventsForGuild(
    client: *rest.EndpointClient,
    guild_id: model.Snowflake,
    with_user_count: ?bool,
) !rest.RestClient.Result([]model.GuildScheduledEvent) {
    const query = WithUserCountQuery{ .with_user_count = with_user_count };
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{}/scheduled-events?{query}", .{ guild_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]model.GuildScheduledEvent, .GET, uri);
}

pub fn createGuildScheduledEvent(
    client: *rest.EndpointClient,
    guild_id: model.Snowflake,
    body: CreateGuildScheduledEventBody,
    audit_log_reason: ?[]const u8,
) !rest.RestClient.Result(model.GuildScheduledEvent) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{}/scheduled-events", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBodyAndAuditLogReason(model.GuildScheduledEvent, .POST, uri, body, .{}, audit_log_reason);
}

pub fn getGuildScheuledEvent(
    client: *rest.EndpointClient,
    guild_id: model.Snowflake,
    guild_scheduled_Event_id: model.Snowflake,
    with_user_count: ?bool,
) !rest.RestClient.Result(model.GuildScheduledEvent) {
    const query = WithUserCountQuery{ .with_user_count = with_user_count };
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{}/scheduled-events/{}?{query}", .{ guild_id, guild_scheduled_Event_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.GuildScheduledEvent, .GET, uri);
}

pub fn modifyGuildScheduledEvent(
    client: *rest.EndpointClient,
    guild_id: model.Snowflake,
    guild_scheduled_Event_id: model.Snowflake,
    body: ModifyGuildScheduledEventBody,
    audit_log_reason: ?[]const u8,
) !rest.RestClient.Result(model.GuildScheduledEvent) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{}/scheduled-events/{}", .{ guild_id, guild_scheduled_Event_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBodyAndAuditLogReason(model.GuildScheduledEvent, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn deleteGuildScheduledEvent(
    client: *rest.EndpointClient,
    guild_id: model.Snowflake,
    guild_scheduled_Event_id: model.Snowflake,
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{}/scheduled-events/{}", .{ guild_id, guild_scheduled_Event_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub fn getGuildScheuledEventUsers(
    client: *rest.EndpointClient,
    guild_id: model.Snowflake,
    guild_scheduled_Event_id: model.Snowflake,
    query: GetGuildScheduledEventUsersQuery,
) !rest.RestClient.Result([]model.GuildScheduledEvent.EventUser) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{}/scheduled-events/{}/users?{query}", .{ guild_id, guild_scheduled_Event_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]model.GuildScheduledEvent.EventUser, .GET, uri);
}

pub const WithUserCountQuery = struct {
    with_user_count: ?bool = null,

    pub usingnamespace rest.QueryStringFormatMixin(@This());
};

pub const CreateGuildScheduledEventBody = struct {
    channel_id: jconfig.Omittable(model.Snowflake) = .omit,
    entity_metadata: jconfig.Omittable(model.GuildScheduledEvent.EntityMetadata) = .omit,
    name: []const u8,
    privacy_level: model.GuildScheduledEvent.PrivacyLevel,
    scheduled_start_time: model.IsoTime,
    scheduled_end_time: model.IsoTime,

    pub usingnamespace jconfig.OmittableFieldsMixin(@This());
};

pub const ModifyGuildScheduledEventBody = struct {
    channel_id: jconfig.Omittable(?model.Snowflake) = .omit,
    entity_metadata: jconfig.Omittable(?model.GuildScheduledEvent.EntityMetadata) = .omit,
    name: jconfig.Omittable([]const u8) = .omit,
    privacy_level: jconfig.Omittable(model.GuildScheduledEvent.PrivacyLevel) = .omit,
    scheduled_start_time: jconfig.Omittable(model.IsoTime) = .omit,
    scheduled_end_time: jconfig.Omittable(model.IsoTime) = .omit,
    description: jconfig.Omittable(?[]const u8) = .omit,
    entity_type: jconfig.Omittable(model.GuildScheduledEvent.EntityType) = .omit,
    status: jconfig.Omittable(model.GuildScheduledEvent.EventStatus) = .omit,
    image: jconfig.Omittable(model.ImageData) = .omit,

    pub usingnamespace jconfig.OmittableFieldsMixin(@This());
};

pub const GetGuildScheduledEventUsersQuery = struct {
    limit: ?i64 = null,
    with_member: ?bool = null,
    before: ?model.Snowflake = null,
    after: ?model.Snowflake = null,

    pub usingnamespace rest.QueryStringFormatMixin(@This());
};
