const std = @import("std");
const deancord = @import("../root.zig");
const model = deancord.model;
const rest = deancord.rest;

arena: std.heap.ArenaAllocator,
http_request: *std.http.Server.Request,
interaction: model.interaction.Interaction,

const Request = @This();

pub fn init(http_request: *std.http.Server.Request, alloc: std.mem.Allocator, application_public_key: std.crypto.sign.Ed25519.PublicKey) !Request {
    const body = verify(alloc, http_request, application_public_key) catch |err| {
        switch (err) {
            error.SignatureVerificationError => {
                http_request.respond("", .{ .status = .unauthorized }) catch |respond_err| {
                    std.log.warn("error occurred while responding to unauthorized request: {}", .{respond_err});
                };
                return error.ReceivedUnauthorizedRequest;
            },
            else => |narrow_err| return narrow_err,
        }
    };
    defer alloc.free(body);

    var arena = std.heap.ArenaAllocator.init(alloc);
    const interaction = try std.json.parseFromSliceLeaky(model.interaction.Interaction, arena.allocator(), body, .{ .allocate = .alloc_always });

    return Request{ .arena = arena, .http_request = http_request, .interaction = interaction };
}

pub fn deinit(self: Request) void {
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
    return try rest.endpoints.interaction.editOriginalInteractionResponse(client, self.interaction.application_id, self.interaction.token, body);
}

/// send a followup request which deletes the original message
pub fn followupDeleteOriginal(
    self: Request,
    client: *deancord.rest.Client,
) !rest.Client.Result(void) {
    return try rest.endpoints.interaction.deleteOriginalInteractionResponse(client, self.interaction.application_id, self.interaction.token);
}

/// send a followup request which sends a new message
pub fn followupNewMessage(
    self: Request,
    client: *deancord.rest.Client,
    body: rest.endpoints.webhook.ExecuteWebhookFormBody,
) !rest.Client.Result(model.Message) {
    return try rest.endpoints.interaction.createFollowupMessage(client, self.interaction.application_id, self.interaction.token, body);
}

/// send a followup request which edits a message that was previously sent with followupNewMessage()
pub fn followupEditNewMessage(
    self: Request,
    client: *deancord.rest.Client,
    message_id: model.Snowflake,
    body: rest.endpoints.webhook.EditWebhookMessageFormBody,
) !rest.Client.Result(model.Message) {
    return try rest.endpoints.interaction.editFollowupMessage(client, self.interaction.application_id, self.interaction.token, message_id, body);
}

fn verify(allocator: std.mem.Allocator, http_req: *std.http.Server.Request, application_public_key: std.crypto.sign.Ed25519.PublicKey) ![]const u8 {
    const signature_len = std.crypto.sign.Ed25519.Signature.encoded_length;

    var timestamp_buf: [100]u8 = undefined;
    var timestamp_opt: ?[]const u8 = null;
    var signature_buf: [signature_len]u8 = undefined;
    var signature_opt: ?[]const u8 = null;

    var headers = http_req.iterateHeaders();
    while (headers.next()) |header| {
        if (std.mem.eql(u8, header.name, "X-Signature-Ed25519")) {
            signature_opt = std.fmt.hexToBytes(&signature_buf, header.value) catch return error.InvalidHeader;
        }
        if (std.mem.eql(u8, header.name, "X-Signature-Timestamp")) {
            std.mem.copyForwards(u8, &timestamp_buf, header.value);
            timestamp_opt = timestamp_buf[0..header.value.len];
        }
    }
    const signature_header = signature_opt orelse return error.MissingHeader;
    const timestamp_header = timestamp_opt orelse return error.MissingHeader;

    const body_reader = try http_req.reader();
    const body = try body_reader.readAllAlloc(allocator, 1024 * 1024);

    std.log.debug("{s}", .{body});

    const message = try std.mem.concat(allocator, u8, &.{ timestamp_header, body });
    defer allocator.free(message);

    const signature = std.crypto.sign.Ed25519.Signature.fromBytes(signature_header[0..64].*);
    signature.verify(message, application_public_key) catch return error.SignatureVerificationError;

    return body;
}
