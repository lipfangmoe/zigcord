const std = @import("std");
const deancord = @import("../../root.zig");
const model = deancord.model;
const rest = deancord.rest;

pub fn getGateway(
    client: *rest.ApiClient,
) !rest.Client.Result(GetGatewayResponse) {
    const uri = std.Uri.parse(rest.base_url ++ "/gateway?v=10&encoding=json") catch undefined;

    return try client.rest_client.request(GetGatewayResponse, .GET, uri);
}

pub fn getGatewayBot(
    client: *rest.ApiClient,
) !rest.Client.Result(GetGatewayBotResponse) {
    const uri = std.Uri.parse(rest.base_url ++ "/gateway/bot") catch undefined;

    return try client.rest_client.request(GetGatewayBotResponse, .GET, uri);
}

pub const GetGatewayResponse = struct {
    url: []const u8,
};

pub const GetGatewayBotResponse = struct {
    url: []const u8,
    shards: i64,
    session_start_limit: SessionStartLimit,

    pub const SessionStartLimit = struct {
        total: i64,
        remaining: i64,
        reset_after: i64,
        max_concurrency: i64,
    };
};
