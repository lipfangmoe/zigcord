const std = @import("std");
const model = @import("model");
const jconfig = @import("jconfig");
const EndpointClient = @import("../EndpointClient.zig");
const RestClient = @import("../RestClient.zig");
const Result = RestClient.Result;
const allocDiscordUriStr = @import("../discord_uri.zig").allocDiscordUriStr;
const query_strings = @import("../query_strings.zig");

pub fn listSkuSubscriptions(client: *EndpointClient, sku_id: model.Snowflake, query: ListSkuSubscriptionsQuery) !Result([]model.Subscription) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/skus/{f}/subscriptions?{f}", .{ sku_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]model.Subscription, .GET, uri);
}

pub fn getSkuSubscription(client: *EndpointClient, sku_id: model.Snowflake, subscription_id: model.Snowflake) !Result(model.Subscription) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/skus/{f}/subscriptions/{f}", .{ sku_id, subscription_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Subscription, .GET, uri);
}

pub const ListSkuSubscriptionsQuery = struct {
    before: ?model.Snowflake = null,
    after: ?model.Snowflake = null,
    limit: ?u7 = null,
    user_id: ?model.Snowflake = null,

    pub const format = query_strings.formatAsQueryString;
};
