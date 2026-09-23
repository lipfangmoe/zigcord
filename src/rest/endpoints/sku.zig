const std = @import("std");
const model = @import("model");
const EndpointClient = @import("../EndpointClient.zig");
const RestClient = @import("../RestClient.zig");
const Result = RestClient.Result;
const allocDiscordUriStr = @import("../discord_uri.zig").allocDiscordUriStr;
const jconfig = @import("jconfig");

pub fn listSkus(client: *EndpointClient, application_id: model.Snowflake) !Result([]model.Sku) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/applications/{f}/skus", .{application_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]model.Sku, .GET, uri);
}
