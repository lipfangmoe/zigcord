const std = @import("std");
const deancord = @import("../../root.zig");
const model = deancord.model;
const rest = deancord.rest;
const Snowflake = model.Snowflake;
const RestResult = rest.Client.Result;
const Client = rest.Client;
const AuditLog = model;

pub fn getGuildAuditLog(client: *Client, guild_id: Snowflake) !RestResult(AuditLog) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{d}/audit-logs", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(AuditLog, .GET, uri);
}
