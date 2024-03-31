const std = @import("std");
const model = @import("model");
const rest = @import("../../rest.zig");
const Snowflake = model.Snowflake;
const RestResult = rest.Client.Result;
const Client = rest.Client;
const AuditLog = model.AuditLog;

pub fn auditLogs(client: *Client, guild_id: Snowflake) !RestResult(AuditLog) {
    const path = try std.fmt.allocPrint(client.allocator, "/guilds/{d}/audit-logs", .{guild_id.asU64()});
    defer client.allocator.free(path);

    const url = try rest.discordApiCallUri(client.allocator, path, null);

    return client.request(AuditLog, .GET, url);
}
