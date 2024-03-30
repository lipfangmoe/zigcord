const std = @import("std");
const model = @import("model");
const rest = @import("../../rest.zig");
const Snowflake = model.Snowflake;
const ApplicationRoleConnectionMetadata = model.ApplicationRoleConnectionMetadata;
const Client = rest.Client;
const RestResult = Client.Result;

pub fn getApplicationRoleConnectionMetadataRecords(ctx: *Client, applicationId: Snowflake) !RestResult([]ApplicationRoleConnectionMetadata) {
    const path = try std.fmt.allocPrint(ctx.allocator, "/applications/{d}/role-connections/metadata", .{applicationId.asU64()});
    defer ctx.allocator.free(path);

    const url = try rest.discordApiCallUri(ctx.allocator, path, null);

    return ctx.request([]ApplicationRoleConnectionMetadata, .GET, url);
}

pub fn updateApplicationRoleConnectionMetadataRecords(ctx: *Client, applicationId: Snowflake, new_records: []const ApplicationRoleConnectionMetadata) !RestResult([]ApplicationRoleConnectionMetadata) {
    const path = try std.fmt.allocPrint(ctx.allocator, "/applications/{d}/role-connections/metadata", .{applicationId.asU64()});
    defer ctx.allocator.free(path);

    const url = try rest.discordApiCallUri(ctx.allocator, path, null);

    return ctx.requestWithValueBody([]ApplicationRoleConnectionMetadata, .GET, url, new_records, .{});
}
