const std = @import("std");
const root = @import("root");
const model = root.model;
const rest = root.rest;
const Snowflake = model.Snowflake;
const RestResult = rest.Client.Result;
const Client = rest.Client;
const AuditLog = model;

pub fn getGuildAuditLog(client: *Client, guild_id: Snowflake) !RestResult(AuditLog) {
    const path = try std.fmt.allocPrint(client.allocator, "/guilds/{d}/audit-logs", .{guild_id.asU64()});
    defer client.allocator.free(path);

    const url = try rest.DiscordUri.init(client.allocator, path, null);
    defer url.deinit();

    return client.request(AuditLog, .GET, url);
}
