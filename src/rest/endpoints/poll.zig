const deancord = @import("../../root.zig");
const std = @import("std");
const model = deancord.model;
const rest = deancord.rest;
const jconfig = deancord.jconfig;

pub fn getAnswerVoters(
    client: *rest.Client,
    channel_id: model.Snowflake,
    message_id: model.Snowflake,
    answer_id: model.Snowflake,
    query: GetAnswerVotersQuery,
) !rest.Client.Result(GetAnswerVotersResponse) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/polls/{}/answers/{}?{query}", .{ channel_id, message_id, answer_id, query });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(GetAnswerVotersResponse, .GET, uri);
}

pub fn endPoll(
    client: *rest.Client,
    channel_id: model.Snowflake,
    message_id: model.Snowflake,
) !rest.Client.Result(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/channels/{}/polls/{}/expire", .{ channel_id, message_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(model.Message, .POST, uri);
}

pub const GetAnswerVotersQuery = struct {
    after: ?model.Snowflake,
    limit: ?i64,

    pub usingnamespace rest.QueryStringFormatMixin(@This());
};

pub const GetAnswerVotersResponse = struct {
    users: []const model.User,
};
