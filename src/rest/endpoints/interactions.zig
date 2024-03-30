const std = @import("std");
const model = @import("model");
const rest = @import("../../rest.zig");
const Client = rest.Client;
const Result = Client.Result;
const Snowflake = model.Snowflake;
const InteractionResponse = model.interaction.InteractionResponse;

pub fn createInteractionResponse(ctx: *Client, interaction_id: Snowflake, interaction_token: []const u8, body: InteractionResponse) !Result(void) {
    const path = try std.fmt.allocPrint(ctx.allocator, "/interactions/{}/{s}/callback", .{ interaction_id, interaction_token });
    defer ctx.allocator.free(path);

    const url = try rest.discordApiCallUri(ctx.allocator, path, null);

    return ctx.requestWithValueBody(void, .POST, url, body, .{});
}

pub fn createInteractionResponseMultipart(ctx: *Client, interaction_id: Snowflake, interaction_token: []const u8, transfer_encoding: std.http.Client.RequestTransfer) !rest.Client.PendingRequest(void) {
    const path = try std.fmt.allocPrint(ctx.allocator, "/interactions/{}/{s}/callback", .{ interaction_id, interaction_token });
    defer ctx.allocator.free(path);

    const url = try rest.discordApiCallUri(ctx.allocator, path, null);

    return ctx.beginRequest(void, .POST, url, transfer_encoding);
}

pub fn getOriginalInteractionResponse(ctx: *Client, application_id: Snowflake, interaction_token: []const u8) !Result(model.Message) {
    const path = try std.fmt.allocPrint(ctx.allocator, "/webhooks/{}/{s}/messages/@original", .{ application_id, interaction_token });
    defer ctx.allocator.free(path);

    const url = try rest.discordApiCallUri(ctx.allocator, path, null);

    return ctx.request(model.Message, .GET, url);
}
