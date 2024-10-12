const std = @import("std");
const deancord = @import("../../root.zig");
const model = deancord.model;
const rest = deancord.rest;
const Snowflake = model.Snowflake;
const ApplicationRoleConnectionMetadata = model.ApplicationRoleConnectionMetadata;

pub fn getApplicationRoleConnectionMetadataRecords(
    client: *rest.ApiClient,
    application_id: Snowflake,
) !rest.Client.Result([]ApplicationRoleConnectionMetadata) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/applications/{d}/role-connections/metadata", .{application_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]ApplicationRoleConnectionMetadata, .GET, uri);
}

pub fn updateApplicationRoleConnectionMetadataRecords(
    client: *rest.ApiClient,
    application_id: Snowflake,
    new_records: []const ApplicationRoleConnectionMetadata,
) !rest.Client.Result([]ApplicationRoleConnectionMetadata) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/applications/{d}/role-connections/metadata", .{application_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBody([]ApplicationRoleConnectionMetadata, .GET, uri, new_records, .{});
}
