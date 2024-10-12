const std = @import("std");
const deancord = @import("../root.zig");
const model = deancord.model;
const rest = deancord.rest;

arena: std.heap.ArenaAllocator,
interaction: model.interaction.Interaction,

const Request = @This();

pub const SignatureHeaders = struct {
    signature_bytes: [signature_len]u8,
    timestamp: std.BoundedArray(u8, 64),

    const signature_len = std.crypto.sign.Ed25519.Signature.encoded_length;

    pub fn initFromHttpRequest(http_request: *std.http.Server.Request) error{ InvalidHeader, MissingHeader }!SignatureHeaders {
        var timestamp = std.BoundedArray(u8, 64){};
        var signature_buf: [signature_len]u8 = undefined;
        var signature_set = false;

        var headers = http_request.iterateHeaders();
        while (headers.next()) |header| {
            if (std.mem.eql(u8, header.name, "X-Signature-Ed25519")) {
                const slice = std.fmt.hexToBytes(&signature_buf, header.value) catch return error.InvalidHeader;
                if (slice.len != signature_len) {
                    return error.InvalidHeader;
                }
                signature_set = true;
            }
            if (std.mem.eql(u8, header.name, "X-Signature-Timestamp")) {
                timestamp.appendSlice(header.value) catch return error.InvalidHeader;
            }
        }
        if (timestamp.len == 0 or !signature_set) {
            return error.MissingHeader;
        }
        return SignatureHeaders{
            .signature_bytes = signature_buf,
            .timestamp = timestamp,
        };
    }
};

pub fn init(alloc: std.mem.Allocator, application_public_key: std.crypto.sign.Ed25519.PublicKey, headers: SignatureHeaders, request_body: std.io.AnyReader) !Request {
    const request_body_bytes = try verify(alloc, headers, request_body, application_public_key);
    defer alloc.free(request_body_bytes);

    var arena = std.heap.ArenaAllocator.init(alloc);
    const interaction = try std.json.parseFromSliceLeaky(model.interaction.Interaction, arena.allocator(), request_body_bytes, .{ .allocate = .alloc_always });

    return Request{ .arena = arena, .interaction = interaction };
}

pub fn deinit(self: Request) void {
    self.arena.deinit();
}

/// should be called extremely quickly after receiving the request. if you
/// need more time to respond, respond quickly with a deferred InteractionResponse type, then use a followup message when you're ready to respond.
pub fn respondHttp(self: *Request, http_request: std.http.Server.Request, response_body: model.interaction.InteractionResponse) !void {
    const response_body_json = try std.json.stringifyAlloc(self.arena.allocator(), response_body, .{});
    try http_request.respond(response_body_json, .{});
}

/// send a followup request which edits the original message
pub fn followupEditOriginal(
    self: Request,
    client: *deancord.rest.Client,
    body: rest.endpoints.EditWebhookMessageFormBody,
) !rest.Client.Result(model.Message) {
    return try rest.endpoints.editOriginalInteractionResponse(client, self.interaction.application_id, self.interaction.token, body);
}

/// send a followup request which deletes the original message
pub fn followupDeleteOriginal(
    self: Request,
    client: *deancord.rest.Client,
) !rest.Client.Result(void) {
    return try rest.endpoints.deleteOriginalInteractionResponse(client, self.interaction.application_id, self.interaction.token);
}

/// send a followup request which sends a new message
pub fn followupNewMessage(
    self: Request,
    client: *deancord.rest.Client,
    body: rest.endpoints.ExecuteWebhookFormBody,
) !rest.Client.Result(model.Message) {
    return try rest.endpoints.createFollowupMessage(client, self.interaction.application_id, self.interaction.token, body);
}

/// send a followup request which edits a message that was previously sent with followupNewMessage()
pub fn followupEditNewMessage(
    self: Request,
    client: *deancord.rest.Client,
    message_id: model.Snowflake,
    body: rest.endpoints.EditWebhookMessageFormBody,
) !rest.Client.Result(model.Message) {
    return try rest.endpoints.editFollowupMessage(client, self.interaction.application_id, self.interaction.token, message_id, body);
}

fn verify(allocator: std.mem.Allocator, headers: SignatureHeaders, body: std.io.AnyReader, application_public_key: std.crypto.sign.Ed25519.PublicKey) ![]const u8 {
    const body_bytes = try body.readAllAlloc(allocator, 1024 * 1024);

    const message = try std.mem.concat(allocator, u8, &.{ headers.timestamp.constSlice(), body_bytes });
    defer allocator.free(message);

    const signature = std.crypto.sign.Ed25519.Signature.fromBytes(headers.signature_bytes);
    signature.verify(message, application_public_key) catch return error.SignatureVerificationError;

    return body_bytes;
}
