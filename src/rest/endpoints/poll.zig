const zigcord = @import("../../root.zig");
const std = @import("std");
const model = zigcord.model;
const rest = zigcord.rest;
const jconfig = zigcord.jconfig;

pub fn getAnswerVoters(
    client: *rest.EndpointClient,
    channel_id: model.Snowflake,
    message_id: model.Snowflake,
    answer_id: model.Snowflake,
    query: GetAnswerVotersQuery,
) !rest.RestClient.Result(GetAnswerVotersResponse) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/polls/{f}/answers/{f}?{f}", .{ channel_id, message_id, answer_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(GetAnswerVotersResponse, .GET, uri);
}

pub fn endPoll(
    client: *rest.EndpointClient,
    channel_id: model.Snowflake,
    message_id: model.Snowflake,
) !rest.RestClient.Result(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/channels/{f}/polls/{f}/expire", .{ channel_id, message_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBody(model.Message, .POST, uri, .{}, .{});
}

pub const GetAnswerVotersQuery = struct {
    after: ?model.Snowflake,
    limit: ?i64,

    pub const format = rest.QueryStringFormatMixin(@This()).format;
};

pub const GetAnswerVotersResponse = struct {
    users: []const model.User,
};
