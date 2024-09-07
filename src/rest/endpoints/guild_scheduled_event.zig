const std = @import("std");
const deancord = @import("../../root.zig");
const model = deancord.model;
const rest = deancord.rest;
const Omittable = model.jconfig.Omittable;

pub fn listScheduledEventsForGuild(
    client: *rest.Client,
    guild_id: model.Snowflake,
    with_user_count: ?bool,
) !rest.Client.Result([]model.GuildScheduledEvent) {
    const query = WithUserCountQuery{ .with_user_count = with_user_count };
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/scheduled-events?{query}", .{ guild_id, query });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request([]model.GuildScheduledEvent, .GET, uri);
}

pub fn createGuildScheduledEvent(
    client: *rest.Client,
    guild_id: model.Snowflake,
    body: CreateGuildScheduledEventBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(model.GuildScheduledEvent) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/scheduled-events", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndAuditLogReason(model.GuildScheduledEvent, .POST, uri, body, .{}, audit_log_reason);
}

pub fn getGuildScheuledEvent(
    client: *rest.Client,
    guild_id: model.Snowflake,
    guild_scheduled_Event_id: model.Snowflake,
    with_user_count: ?bool,
) !rest.Client.Result(model.GuildScheduledEvent) {
    const query = WithUserCountQuery{ .with_user_count = with_user_count };
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/scheduled-events/{}?{query}", .{ guild_id, guild_scheduled_Event_id, query });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(model.GuildScheduledEvent, .GET, uri);
}

pub fn modifyGuildScheduledEvent(
    client: *rest.Client,
    guild_id: model.Snowflake,
    guild_scheduled_Event_id: model.Snowflake,
    body: ModifyGuildScheduledEventBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(model.GuildScheduledEvent) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/scheduled-events/{}", .{ guild_id, guild_scheduled_Event_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndAuditLogReason(model.GuildScheduledEvent, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn deleteGuildScheduledEvent(
    client: *rest.Client,
    guild_id: model.Snowflake,
    guild_scheduled_Event_id: model.Snowflake,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/scheduled-events/{}", .{ guild_id, guild_scheduled_Event_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(void, .DELETE, uri);
}

pub fn getGuildScheuledEventUsers(
    client: *rest.Client,
    guild_id: model.Snowflake,
    guild_scheduled_Event_id: model.Snowflake,
    query: GetGuildScheduledEventUsersQuery,
) !rest.Client.Result([]model.GuildScheduledEvent.EventUser) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/scheduled-events/{}/users?{query}", .{ guild_id, guild_scheduled_Event_id, query });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request([]model.GuildScheduledEvent.EventUser, .GET, uri);
}

pub const WithUserCountQuery = struct {
    with_user_count: ?bool = null,

    pub usingnamespace rest.QueryStringFormatMixin(@This());
};

pub const CreateGuildScheduledEventBody = struct {
    channel_id: Omittable(model.Snowflake) = .omit,
    entity_metadata: Omittable(model.GuildScheduledEvent.EntityMetadata) = .omit,
    name: []const u8,
    privacy_level: model.GuildScheduledEvent.PrivacyLevel,
    scheduled_start_time: model.IsoTime,
    scheduled_end_time: model.IsoTime,

    pub usingnamespace model.jconfig.OmittableJsonMixin(@This());
};

pub const ModifyGuildScheduledEventBody = struct {
    channel_id: Omittable(?model.Snowflake) = .omit,
    entity_metadata: Omittable(?model.GuildScheduledEvent.EntityMetadata) = .omit,
    name: Omittable([]const u8) = .omit,
    privacy_level: Omittable(model.GuildScheduledEvent.PrivacyLevel) = .omit,
    scheduled_start_time: Omittable(model.IsoTime) = .omit,
    scheduled_end_time: Omittable(model.IsoTime) = .omit,
    description: Omittable(?[]const u8) = .omit,
    entity_type: Omittable(model.GuildScheduledEvent.EntityType) = .omit,
    status: Omittable(model.GuildScheduledEvent.EventStatus) = .omit,
    image: Omittable(model.ImageData) = .omit,

    pub usingnamespace model.jconfig.OmittableJsonMixin(@This());
};

pub const GetGuildScheduledEventUsersQuery = struct {
    limit: ?i64 = null,
    with_member: ?bool = null,
    before: ?model.Snowflake = null,
    after: ?model.Snowflake = null,

    pub usingnamespace rest.QueryStringFormatMixin(@This());
};
