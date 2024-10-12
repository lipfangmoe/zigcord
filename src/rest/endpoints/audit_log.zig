const std = @import("std");
const deancord = @import("../../root.zig");
const model = deancord.model;
const rest = deancord.rest;
const Snowflake = model.Snowflake;
const AuditLog = model;

pub fn getGuildAuditLog(client: *rest.ApiClient, guild_id: Snowflake) !rest.Client.Result(AuditLog) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{d}/audit-logs", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(AuditLog, .GET, uri);
}
