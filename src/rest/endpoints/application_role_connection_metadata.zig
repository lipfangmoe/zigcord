const std = @import("std");
const model = @import("model");
const EndpointClient = @import("../EndpointClient.zig");
const RestClient = @import("../RestClient.zig");
const allocDiscordUriStr = @import("../discord_uri.zig").allocDiscordUriStr;
const Result = RestClient.Result;
const Snowflake = model.Snowflake;
const ApplicationRoleConnectionMetadata = model.ApplicationRoleConnectionMetadata;

pub fn getApplicationRoleConnectionMetadataRecords(
    client: *EndpointClient,
    application_id: Snowflake,
) !Result([]ApplicationRoleConnectionMetadata) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/applications/{f}/role-connections/metadata", .{application_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]ApplicationRoleConnectionMetadata, .GET, uri);
}

pub fn updateApplicationRoleConnectionMetadataRecords(
    client: *EndpointClient,
    application_id: Snowflake,
    new_records: []const ApplicationRoleConnectionMetadata,
) !Result([]ApplicationRoleConnectionMetadata) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/applications/{f}/role-connections/metadata", .{application_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBody([]ApplicationRoleConnectionMetadata, .PUT, uri, new_records, .{});
}
