const std = @import("std");
const model = @import("model");
const EndpointClient = @import("../EndpointClient.zig");
const RestClient = @import("../RestClient.zig");
const Result = RestClient.Result;
const discord_uri = @import("../discord_uri.zig");
const allocDiscordUriStr = discord_uri.allocDiscordUriStr;
const base_url = discord_uri.base_url;

pub fn getGateway(
    client: *EndpointClient,
) !Result(GetGatewayResponse) {
    const uri = std.Uri.parse(base_url ++ "/gateway?v=10&encoding=json") catch undefined;

    return try client.rest_client.request(GetGatewayResponse, .GET, uri);
}

pub fn getGatewayBot(
    client: *EndpointClient,
) !Result(GetGatewayBotResponse) {
    const uri = std.Uri.parse(base_url ++ "/gateway/bot") catch undefined;

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
