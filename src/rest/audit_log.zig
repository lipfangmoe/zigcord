const std = @import("std");

const model = @import("../model.zig");
const rest = @import("../rest.zig");
const Snowflake = model.Snowflake;
const RestResult = rest.Context.Result;
const Context = rest.Context;
const AuditLog = model.AuditLog;

pub fn auditLogs(ctx: *Context, guild_id: Snowflake) !RestResult(AuditLog) {
    const path = try std.fmt.allocPrint(ctx.allocator, "/guilds/{d}/audit-logs", .{guild_id.asU64()});
    defer ctx.allocator.free(path);

    const url = try rest.discordApiCallUri(ctx.allocator, path, null);

    return ctx.request(AuditLog, .GET, url);
}
