const std = @import("std");
const zigtime = @import("zig-time");
const deancord = @import("../../root.zig");
const model = deancord.model;
const rest = deancord.rest;
const Omittable = model.deanson.Omittable;

pub fn listScheduledEventsForGuild(
    client: *rest.Client,
    guild_id: model.Snowflake,
    query: ListScheduledEventsForGuildQuery,
) !rest.Client.Result([]model.GuildScheduledEvent) {
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

pub const ListScheduledEventsForGuildQuery = struct {
    with_user_count: ?bool = null,

    usingnamespace rest.QueryStringFormatMixin(@This());
};

pub const CreateGuildScheduledEventBody = struct {
    channel_id: Omittable(model.Snowflake) = .omit,
    entity_metadata: Omittable(model.GuildScheduledEvent.EntityMetadata) = .omit,
    name: []const u8,
    privacy_level: model.GuildScheduledEvent.PrivacyLevel,
    scheduled_start_time: []zigtime.DateTime,
    scheduled_end_time: []zigtime.DateTime,
};
