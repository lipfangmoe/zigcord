const deancord = @import("../../root.zig");
const std = @import("std");
const model = deancord.model;
const rest = deancord.rest;
const jconfig = deancord.jconfig;

pub fn getAnswerVoters(
    client: *rest.EndpointClient,
    channel_id: model.Snowflake,
    message_id: model.Snowflake,
    answer_id: model.Snowflake,
    query: GetAnswerVotersQuery,
) !rest.RestClient.Result(GetAnswerVotersResponse) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/polls/{}/answers/{}?{query}", .{ channel_id, message_id, answer_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(GetAnswerVotersResponse, .GET, uri);
}

pub fn endPoll(
    client: *rest.EndpointClient,
    channel_id: model.Snowflake,
    message_id: model.Snowflake,
) !rest.RestClient.Result(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{}/polls/{}/expire", .{ channel_id, message_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Message, .POST, uri);
}

pub const GetAnswerVotersQuery = struct {
    after: ?model.Snowflake,
    limit: ?i64,

    pub usingnamespace rest.QueryStringFormatMixin(@This());
};

pub const GetAnswerVotersResponse = struct {
    users: []const model.User,
};
