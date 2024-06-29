const std = @import("std");
const root = @import("root");
const model = root.model;
const rest = root.rest;
const Client = rest.Client;
const Result = Client.Result;
const Snowflake = model.Snowflake;
const InteractionResponse = model.interaction.InteractionResponse;

pub fn createInteractionResponse(client: *Client, interaction_id: Snowflake, interaction_token: []const u8, body: InteractionResponse) !Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/interactions/{}/{s}/callback", .{ interaction_id, interaction_token });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBody(void, .POST, uri, body, .{});
}

pub fn createInteractionResponseMultipart(client: *Client, interaction_id: Snowflake, interaction_token: []const u8, transfer_encoding: std.http.Client.RequestTransfer) !rest.Client.PendingRequest(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/interactions/{}/{s}/callback", .{ interaction_id, interaction_token });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.beginRequest(void, .POST, uri, transfer_encoding);
}

pub fn getOriginalInteractionResponse(client: *Client, application_id: Snowflake, interaction_token: []const u8) !Result(model.Message) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/interactions/{}/{s}/messages/@original", .{ application_id, interaction_token });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(model.Message, .GET, uri);
}
