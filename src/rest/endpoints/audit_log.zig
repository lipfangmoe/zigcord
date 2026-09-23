const std = @import("std");
const model = @import("model");
const EndpointClient = @import("../EndpointClient.zig");
const RestClient = @import("../RestClient.zig");
const allocDiscordUriStr = @import("../discord_uri.zig").allocDiscordUriStr;
const Result = RestClient.Result;
const Snowflake = model.Snowflake;
const AuditLog = model.AuditLog;

pub fn getGuildAuditLog(client: *EndpointClient, guild_id: Snowflake) !Result(AuditLog) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/audit-logs", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(AuditLog, .GET, uri);
}
