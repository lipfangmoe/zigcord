const std = @import("std");
const deancord = @import("../root.zig");
const model = deancord.model;
const rest = deancord.rest;

arena: std.heap.ArenaAllocator,
http_request: *std.http.Server.Request,
interaction: model.interaction.Interaction,

const Request = @This();

pub fn init(http_request: *std.http.Server.Request) !Request {
    const body_reader = try http_request.reader();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

    const json_reader = std.json.reader(arena.allocator(), body_reader);
    const interaction = try std.json.parseFromTokenSource(model.interaction.Interaction, arena.allocator(), json_reader, .{});

    return Request{ .arena = arena, .http_request = http_request, .interaction = interaction };
}

pub fn deinit(self: Request) !void {
    self.arena.deinit();
}

/// should be called extremely quickly after receiving the request. if you
/// need more time to respond, respond quickly with a deferred InteractionResponse type, then use a followup message when you're ready to respond.
pub fn respond(self: *Request, response: model.interaction.InteractionResponse) !void {
    const response_json = try std.json.stringifyAlloc(self.arena.allocator(), response, .{});
    try self.http_request.respond(response_json, .{});
}

/// send a followup request which edits the original message
pub fn followupEditOriginal(
    self: Request,
    client: *deancord.rest.Client,
    body: rest.endpoints.webhook.EditWebhookMessageFormBody,
) !rest.Client.Result(model.Message) {
    try rest.endpoints.interaction.editOriginalInteractionResponse(client, self.interaction.application_id, self.interaction.token, body);
}

/// send a followup request which deletes the original message
pub fn followupDeleteOriginal(
    self: Request,
    client: *deancord.rest.Client,
) !void {
    try rest.endpoints.interaction.deleteOriginalInteractionResponse(client, self.interaction.application_id, self.interaction.token);
}

/// send a followup request which sends a new message
pub fn followupNewMessage(
    self: Request,
    client: *deancord.rest.Client,
    body: rest.endpoints.webhook.ExecuteWebhookFormBody,
) !void {
    try rest.endpoints.interaction.createFollowupMessage(client, self.interaction.application_id, self.interaction.token, body);
}

/// send a followup request which edits a message that was previously sent with followupNewMessage()
pub fn followupEditNewMessage(
    self: Request,
    client: *deancord.rest.Client,
    body: rest.endpoints.webhook.EditWebhookMessageFormBody,
) !void {
    try rest.endpoints.interaction.editFollowupMessage(client, self.interaction.application_id, self.interaction.token, body);
}
