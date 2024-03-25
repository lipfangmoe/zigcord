const std = @import("std");
const model = @import("../model.zig");
const rest = @import("../rest.zig");
const Snowflake = model.Snowflake;
const ApplicationRoleConnectionMetadata = model.ApplicationRoleConnectionMetadata;
const Context = rest.Context;
const RestResult = Context.Result;

pub fn getApplicationRoleConnectionMetadataRecords(ctx: *Context, applicationId: Snowflake) !RestResult([]ApplicationRoleConnectionMetadata) {
    const path = try std.fmt.allocPrint(ctx.allocator, "/applications/{d}/role-connections/metadata", .{applicationId.asU64()});
    defer ctx.allocator.free(path);

    const url = try rest.discordApiCallUri(ctx.allocator, path, null);

    return ctx.request([]ApplicationRoleConnectionMetadata, .GET, url);
}

pub fn updateApplicationRoleConnectionMetadataRecords(ctx: *Context, applicationId: Snowflake, new_records: []const ApplicationRoleConnectionMetadata) !RestResult([]ApplicationRoleConnectionMetadata) {
    const path = try std.fmt.allocPrint(ctx.allocator, "/applications/{d}/role-connections/metadata", .{applicationId.asU64()});
    defer ctx.allocator.free(path);

    const url = try rest.discordApiCallUri(ctx.allocator, path, null);

    return ctx.requestWithValueBody([]ApplicationRoleConnectionMetadata, .GET, url, new_records, .{});
}
