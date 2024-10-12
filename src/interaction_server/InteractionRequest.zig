const std = @import("std");
const deancord = @import("../root.zig");
const model = deancord.model;
const rest = deancord.rest;

arena: std.heap.ArenaAllocator,
interaction: model.interaction.Interaction,
http_request: std.http.Server.Request,

const InteractionRequest = @This();

pub fn init(alloc: std.mem.Allocator, body: []const u8, http_request: std.http.Server.Request) !InteractionRequest {
    var arena = std.heap.ArenaAllocator.init(alloc);
    const interaction = try std.json.parseFromSliceLeaky(model.interaction.Interaction, arena.allocator(), body, .{ .allocate = .alloc_always });

    return InteractionRequest{ .arena = arena, .interaction = interaction, .http_request = http_request };
}

pub fn deinit(self: InteractionRequest) void {
    self.arena.deinit();
}

/// should be called extremely quickly after receiving the request. if you
/// need more time to respond, respond quickly with a deferred InteractionResponse type,
/// then use one of the .followup* methods when you're ready to respond.
pub fn respond(self: *InteractionRequest, response_body: model.interaction.InteractionResponse) !void {
    const response_body_json = try std.json.stringifyAlloc(self.arena.allocator(), response_body, .{});
    try self.http_request.respond(response_body_json, .{});
}

/// send a followup request which edits the original message
pub fn followupEditOriginal(
    self: InteractionRequest,
    client: *deancord.EndpointClient,
    body: rest.endpoints.EditWebhookMessageFormBody,
) !rest.RestClient.Result(model.Message) {
    return try client.editOriginalInteractionResponse(self.interaction.application_id, self.interaction.token, body);
}

/// send a followup request which deletes the original message
pub fn followupDeleteOriginal(
    self: InteractionRequest,
    client: *deancord.EndpointClient,
) !rest.RestClient.Result(void) {
    return try client.deleteOriginalInteractionResponse(self.interaction.application_id, self.interaction.token);
}

/// send a followup request which sends a new message
pub fn followupNewMessage(
    self: InteractionRequest,
    client: *deancord.EndpointClient,
    body: rest.endpoints.ExecuteWebhookFormBody,
) !rest.RestClient.Result(model.Message) {
    return try client.createFollowupMessage(self.interaction.application_id, self.interaction.token, body);
}

/// send a followup request which edits a message that was previously sent with followupNewMessage()
pub fn followupEditNewMessage(
    self: InteractionRequest,
    client: *deancord.EndpointClient,
    message_id: model.Snowflake,
    body: rest.endpoints.EditWebhookMessageFormBody,
) !rest.RestClient.Result(model.Message) {
    return try client.editFollowupMessage(self.interaction.application_id, self.interaction.token, message_id, body);
}
