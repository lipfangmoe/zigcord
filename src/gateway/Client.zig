//! The standard zigcord websocket client.
//! Has a relatively simple API, automatic reconnecting and nice stuff like that!

const std = @import("std");
const zigcord = @import("../root.zig");
const Client = @This();

allocator: std.mem.Allocator,
token: []const u8,
intents: zigcord.model.Intents,
json_ws_client: *zigcord.gateway.JsonWSClient,

oldest_reconnect: ?i64 = null,
reconnects: u5 = 0,

const InitError = error{AuthError} || std.mem.Allocator.Error;

/// Create a Discord Websocket Client. the `token` must live as long as the struct is initialized.
pub fn init(allocator: std.mem.Allocator, token: []const u8, intents: zigcord.model.Intents) InitError!Client {
    const json_ws_client = try allocator.create(zigcord.gateway.JsonWSClient);
    errdefer allocator.destroy(json_ws_client);

    json_ws_client.* = zigcord.gateway.JsonWSClient.init(allocator, .{ .bot = token }) catch return error.AuthError;

    json_ws_client.authenticate(token, intents) catch return error.AuthError;

    return Client{
        .allocator = allocator,
        .token = token,
        .intents = intents,
        .json_ws_client = json_ws_client,
    };
}

/// Gets the ready event that initialized this bot
pub fn getReadyEvent(self: Client) zigcord.gateway.event_data.receive_events.Ready {
    return self.json_ws_client.ready_event.?.event;
}

pub const ReadEvent = struct {
    event: ?zigcord.gateway.ReadEventData,
    json_parsed_value: std.json.Parsed(zigcord.gateway.ReceiveEvent),

    pub fn deinit(self: ReadEvent) void {
        self.json_parsed_value.deinit();
    }
};

/// Reads an event over the gateway.
pub fn readEvent(self: *Client) error{ Disconnected, JsonError }!ReadEvent {
    const json_parsed_value = self.json_ws_client.readEvent() catch |err| {
        switch (err) {
            error.JsonError => return error.JsonError,
            error.WebsocketError => {
                zigcord.logger.err("WebsocketError encountered", .{});
                if (@errorReturnTrace()) |trace| {
                    zigcord.logger.err("{}", .{trace});
                }
                self.reconnect() catch return error.Disconnected;
                zigcord.logger.info("Successfully reconnected! Re-reading event", .{});
                return try self.readEvent();
            },
        }
    };

    if (json_parsed_value.value.op == .heartbeat) {
        defer json_parsed_value.deinit();
        self.writeEvent(zigcord.gateway.SendEvent.heartbeat(self.json_ws_client.sequence)) catch |err| switch (err) {
            error.JsonError => return error.JsonError,
            error.WebsocketError => {
                self.reconnect() catch return error.Disconnected;
                return try self.readEvent();
            },
        };
        return try self.readEvent();
    }

    if (json_parsed_value.value.op == .reconnect) {
        defer json_parsed_value.deinit();
        self.reconnect() catch return error.Disconnected;
        return try self.readEvent();
    }

    return ReadEvent{
        .event = json_parsed_value.value.d,
        .json_parsed_value = json_parsed_value,
    };
}

/// Sends an event over the gateway. This functionality is rarely needed.
pub fn writeEvent(self: *Client, event: zigcord.gateway.SendEvent) error{ WebsocketError, JsonError }!void {
    try self.json_ws_client.writeEvent(event);
}

/// Destroys the client.
pub fn deinit(self: Client) void {
    self.allocator.destroy(self.json_ws_client);
}

const ReinitError = error{ NotResumable, AuthError, WebsocketError, JsonError } || std.mem.Allocator.Error;
pub fn reinit(self: *Client) ReinitError!void {
    const ready = self.json_ws_client.ready_event orelse {
        return error.NotResumable;
    };
    const sequence = self.json_ws_client.sequence orelse {
        return error.NotResumable;
    };

    self.json_ws_client.ready_event = null; // keep `ready_event` from getting deinit'd
    self.json_ws_client.deinit();

    const json_ws_client = try self.allocator.create(zigcord.gateway.JsonWSClient);
    errdefer self.allocator.destroy(json_ws_client);

    json_ws_client.* = zigcord.gateway.JsonWSClient.initWithUri(self.allocator, .{ .bot = self.token }, ready.event.resume_gateway_url) catch return error.AuthError;
    errdefer json_ws_client.deinit();

    json_ws_client.@"resume"(self.token, sequence, ready) catch return error.AuthError;

    self.json_ws_client = json_ws_client;
}

fn reconnect(self: *Client) !void {
    zigcord.logger.info("Reconnecting...", .{});

    self.reconnects += 1;
    if (self.oldest_reconnect) |oldest| {
        const now = std.time.timestamp();
        if (oldest < now - 60) {
            self.oldest_reconnect = now;
            self.reconnects = 1;
        }
    }

    if (self.reconnects > 5) {
        return error.TooManyReconnects;
    }

    try self.reinit();

    zigcord.logger.info("Reconnected!", .{});
}
