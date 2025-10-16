const zigcord = @import("../../root.zig");
const std = @import("std");
const model = zigcord.model;
const rest = zigcord.rest;
const jconfig = zigcord.jconfig;

pub fn listSkus(client: *rest.EndpointClient, application_id: model.Snowflake) !rest.RestClient.Result([]model.Sku) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/applications/{f}/skus", .{application_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]model.Sku, .GET, uri);
}
