const zigcord = @import("../../root.zig");
const std = @import("std");
const model = zigcord.model;
const rest = zigcord.rest;
const jconfig = zigcord.jconfig;

pub fn listSkuSubscriptions(client: *rest.EndpointClient, sku_id: model.Snowflake, query: ListSkuSubscriptionsQuery) !rest.RestClient.Result([]model.Subscription) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/skus/{}/subscriptions?{query}", .{ sku_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]model.Subscription, .GET, uri);
}

pub fn getSkuSubscription(client: *rest.EndpointClient, sku_id: model.Snowflake, subscription_id: model.Snowflake) !rest.RestClient.Result(model.Subscription) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/skus/{}/subscriptions/{}", .{ sku_id, subscription_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Subscription, .GET, uri);
}

pub const ListSkuSubscriptionsQuery = struct {
    before: ?model.Snowflake = null,
    after: ?model.Snowflake = null,
    limit: ?u7 = null,
    user_id: ?model.Snowflake = null,

    pub usingnamespace rest.QueryStringFormatMixin(@This());
};
