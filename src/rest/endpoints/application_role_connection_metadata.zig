const std = @import("std");
const model = @import("model");
const rest = @import("../../rest.zig");
const Snowflake = model.Snowflake;
const ApplicationRoleConnectionMetadata = model.ApplicationRoleConnectionMetadata;
const Client = rest.Client;
const RestResult = Client.Result;

pub fn getApplicationRoleConnectionMetadataRecords(client: *Client, applicationId: Snowflake) !RestResult([]ApplicationRoleConnectionMetadata) {
    const path = try std.fmt.allocPrint(client.allocator, "/applications/{d}/role-connections/metadata", .{applicationId.asU64()});
    defer client.allocator.free(path);

    const url = try rest.discordApiCallUri(client.allocator, path, null);

    return client.request([]ApplicationRoleConnectionMetadata, .GET, url);
}

pub fn updateApplicationRoleConnectionMetadataRecords(client: *Client, applicationId: Snowflake, new_records: []const ApplicationRoleConnectionMetadata) !RestResult([]ApplicationRoleConnectionMetadata) {
    const path = try std.fmt.allocPrint(client.allocator, "/applications/{d}/role-connections/metadata", .{applicationId.asU64()});
    defer client.allocator.free(path);

    const url = try rest.discordApiCallUri(client.allocator, path, null);

    return client.requestWithValueBody([]ApplicationRoleConnectionMetadata, .GET, url, new_records, .{});
}
