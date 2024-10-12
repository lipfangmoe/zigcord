//! Server which listens for Discord Interactions.
//! Only need to call `deinit()` if created via `init(Address)`.
//! If you have an existing `std.net.Address`, it is okay to create this struct via struct initialization.
//!
//! Currently does not really work since zig does not have a standard HTTPS library yet, and I don't like the pattern that current libraries use.

const std = @import("std");
const deancord = @import("../root.zig");
const Server = @This();
const InteractionRequest = @import("./InteractionRequest.zig");
const verify = @import("./verify.zig");

application_public_key: std.crypto.sign.Ed25519.PublicKey,
net_server: std.net.Server,

const application_public_key_bytes_len = std.crypto.sign.Ed25519.PublicKey.encoded_length;
const application_public_key_hex_len = application_public_key_bytes_len * 2; // requires 2 hex digits to represent 1 byte

pub fn init(address: std.net.Address, application_public_key_hex: [application_public_key_hex_len]u8) !Server {
    const net_server = try address.listen(.{});
    var application_public_key_bytes: [application_public_key_bytes_len]u8 = undefined;
    const slice = std.fmt.hexToBytes(&application_public_key_bytes, &application_public_key_hex) catch return error.InvalidApplicationKey;
    if (slice.len != application_public_key_bytes_len) {
        return error.InvalidApplicationKey;
    }
    return .{
        .net_server = net_server,
        .application_public_key = std.crypto.sign.Ed25519.PublicKey.fromBytes(application_public_key_bytes) catch return error.InvalidApplicationKey,
    };
}

/// Only need to call `deinit()` if created via `init(Address)`
pub fn deinit(self: *Server) void {
    self.net_server.deinit();
}

pub fn receiveInteraction(self: *Server, alloc: std.mem.Allocator) !InteractionRequest {
    var buf: [10000]u8 = undefined;

    while (true) {
        const conn = self.net_server.accept() catch |err| {
            std.log.warn("error occurred while accepting request: {}", .{err});
            continue;
        };

        var http_server = std.http.Server.init(conn, &buf);
        var http_req = http_server.receiveHead() catch |err| {
            std.log.warn("error occurred while receiving headers: {}", .{err});
            continue;
        };
        const signature_headers = verify.SignatureHeaders.initFromHttpRequest(&http_req) catch |err| {
            std.log.warn("error occurred while looking for signature headers: {}", .{err});
            http_req.respond("", .{ .status = .unauthorized }) catch |respond_err| {
                std.log.warn("IO error occurred while writing error response: {}", .{respond_err});
            };
            continue;
        };

        const body_reader = http_req.reader() catch |err| {
            std.log.err("http error occurred while writing a response to 100-continue: {}", .{err});
            http_req.respond("", .{ .status = .expectation_failed }) catch |respond_err| {
                std.log.warn("IO error occurred while writing error response: {}", .{respond_err});
            };
            return error.HttpError;
        };
        const body = body_reader.readAllAlloc(alloc, 1024 * 1024) catch |err| {
            std.log.err("error occurred while reading request body: {}", .{err});
            http_req.respond("", .{ .status = .internal_server_error }) catch |respond_err| {
                std.log.warn("IO error occurred while writing error response: {}", .{respond_err});
            };
            return error.BodyReadError;
        };

        verify.verify(signature_headers, body, self.application_public_key) catch |err| {
            switch (err) {
                error.InvalidPublicKey => {
                    std.log.err("Application Public Key is invalid: {}", .{self.application_public_key});
                    http_req.respond("", .{ .status = .internal_server_error }) catch |respond_err| {
                        std.log.warn("IO error occurred while writing error response: {}", .{respond_err});
                    };
                    return error.InvalidPublicKey;
                },
                error.SignatureVerificationError => {
                    std.log.warn("Signature verification failed, responding with 401", .{});
                    http_req.respond("", .{ .status = .unauthorized }) catch |respond_err| {
                        std.log.warn("IO error occurred while writing error response: {}", .{respond_err});
                    };
                    continue;
                },
            }
        };

        var req = InteractionRequest.init(alloc, body) catch |err| {
            std.log.err("error while parsing interaction: {}", .{err});
            return error.InteractionParseError;
        };
        if (req.interaction.type == .ping) {
            try req.respond(deancord.model.interaction.InteractionResponse{ .type = .pong });
            continue;
        }

        return req;
    }
}
