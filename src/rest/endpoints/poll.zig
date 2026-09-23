const std = @import("std");
const model = @import("model");
const jconfig = @import("jconfig");
const EndpointClient = @import("../EndpointClient.zig");
const RestClient = @import("../RestClient.zig");
const Result = RestClient.Result;
const allocDiscordUriStr = @import("../discord_uri.zig").allocDiscordUriStr;
const query_strings = @import("../query_strings.zig");

pub fn getAnswerVoters(
    client: *EndpointClient,
    channel_id: model.Snowflake,
    message_id: model.Snowflake,
    answer_id: model.Snowflake,
    query: GetAnswerVotersQuery,
) !Result(GetAnswerVotersResponse) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/polls/{f}/answers/{f}?{f}", .{ channel_id, message_id, answer_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(GetAnswerVotersResponse, .GET, uri);
}

pub fn endPoll(
    client: *EndpointClient,
    channel_id: model.Snowflake,
    message_id: model.Snowflake,
) !Result(model.Message) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/polls/{f}/expire", .{ channel_id, message_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Message, .POST, uri);
}

pub const GetAnswerVotersQuery = struct {
    after: ?model.Snowflake,
    limit: ?i64,

    pub const format = query_strings.formatAsQueryString;
};

pub const GetAnswerVotersResponse = struct {
    users: []const model.User,
};
