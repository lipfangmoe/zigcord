const std = @import("std");
const model = @import("model");
const rest = @import("../../rest.zig");
const Client = rest.Client;
const Result = Client.Result;
const Snowflake = model.Snowflake;
const InteractionResponse = model.interaction.InteractionResponse;

pub fn createInteractionResponse(client: *Client, interaction_id: Snowflake, interaction_token: []const u8, body: InteractionResponse) !Result(void) {
    const path = try std.fmt.allocPrint(client.allocator, "/interactions/{}/{s}/callback", .{ interaction_id, interaction_token });
    defer client.allocator.free(path);

    const url = try rest.discordApiCallUri(client.allocator, path, null);

    return client.requestWithValueBody(void, .POST, url, body, .{});
}

pub fn createInteractionResponseMultipart(client: *Client, interaction_id: Snowflake, interaction_token: []const u8, transfer_encoding: std.http.Client.RequestTransfer) !rest.Client.PendingRequest(void) {
    const path = try std.fmt.allocPrint(client.allocator, "/interactions/{}/{s}/callback", .{ interaction_id, interaction_token });
    defer client.allocator.free(path);

    const url = try rest.discordApiCallUri(client.allocator, path, null);

    return client.beginRequest(void, .POST, url, transfer_encoding);
}

pub fn getOriginalInteractionResponse(client: *Client, application_id: Snowflake, interaction_token: []const u8) !Result(model.Message) {
    const path = try std.fmt.allocPrint(client.allocator, "/webhooks/{}/{s}/messages/@original", .{ application_id, interaction_token });
    defer client.allocator.free(path);

    const url = try rest.discordApiCallUri(client.allocator, path, null);

    return client.request(model.Message, .GET, url);
}
