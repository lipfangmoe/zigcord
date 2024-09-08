const std = @import("std");
const deancord = @import("../../root.zig");
const model = deancord.model;
const rest = deancord.rest;
const Snowflake = model.Snowflake;
const ApplicationRoleConnectionMetadata = model.ApplicationRoleConnectionMetadata;
const Client = rest.Client;

pub fn getApplicationRoleConnectionMetadataRecords(
    client: *Client,
    application_id: Snowflake,
) !Client.Result([]ApplicationRoleConnectionMetadata) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/applications/{d}/role-connections/metadata", .{application_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request([]ApplicationRoleConnectionMetadata, .GET, uri);
}

pub fn updateApplicationRoleConnectionMetadataRecords(
    client: *Client,
    application_id: Snowflake,
    new_records: []const ApplicationRoleConnectionMetadata,
) !Client.Result([]ApplicationRoleConnectionMetadata) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/applications/{d}/role-connections/metadata", .{application_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBody([]ApplicationRoleConnectionMetadata, .GET, uri, new_records, .{});
}
