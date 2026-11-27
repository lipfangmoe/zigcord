//! The standard zigcord websocket client.
//! Has a relatively simple API, automatic reconnecting and nice stuff like that!

const std = @import("std");
const model = @import("model");
const logger = @import("shared").logger;
const JsonWSClient = @import("./JsonWSClient.zig");
const event_data = @import("./event_data.zig");
const ReceiveEvent = @import("./ReceiveEvent.zig");
const SendEvent = @import("./SendEvent.zig");
const Client = @This();

io: std.Io,
allocator: std.mem.Allocator,
token: []const u8,
intents: model.Intents,
json_ws_client: *JsonWSClient,

oldest_recent_reconnect: ?std.Io.Timestamp = null,
recent_reconnects: u5 = 0,

const InitError = error{AuthError} || std.mem.Allocator.Error;

/// Create a Discord Websocket Client. The `token` string must live as for as long as this bot is active.
pub fn init(io: std.Io, allocator: std.mem.Allocator, token: []const u8, intents: model.Intents) InitError!Client {
    const json_ws_client = try allocator.create(JsonWSClient);
    errdefer allocator.destroy(json_ws_client);

    json_ws_client.* = JsonWSClient.init(io, allocator, .{ .bot = token }) catch return error.AuthError;
    errdefer json_ws_client.deinit();

    json_ws_client.authenticate(token, intents) catch return error.AuthError;

    return .{
        .io = io,
        .allocator = allocator,
        .token = token,
        .intents = intents,
        .json_ws_client = json_ws_client,
    };
}

/// Gets the ready event which initialized this bot
pub fn getReadyEvent(self: Client) event_data.receive_events.Ready {
    return self.json_ws_client.ready_event.?.event;
}

pub const ReadEvent = struct {
    arena: *std.heap.ArenaAllocator,
    raw: std.json.Value,
    data: event_data.ReceiveEventData,

    pub fn deinit(self: ReadEvent) void {
        const gpa = self.arena.child_allocator;
        self.arena.deinit();
        gpa.destroy(self.arena);
    }
};

/// Reads an event from the gateway. The returned object is owned by the caller, so remember to call `.deinit()` on the event.
pub fn readEvent(self: *Client) error{ OutOfMemory, Canceled, Disconnected, JsonError, ResponseTooLong }!ReadEvent {
    const json_parsed_value = self.json_ws_client.readEvent() catch |err| {
        switch (err) {
            error.OutOfMemory => return error.OutOfMemory,
            error.Canceled => return error.Canceled,
            error.JsonError => return error.JsonError,
            error.ResponseTooLong => return error.ResponseTooLong,
            error.WebsocketError => {
                logger.err("WebsocketError encountered", .{});
                if (@errorReturnTrace()) |trace| {
                    var err_trace: std.Io.Writer.Allocating = .init(self.allocator);
                    defer err_trace.deinit();
                    std.debug.writeErrorReturnTrace(trace, .{ .writer = &err_trace.writer, .mode = .no_color }) catch |err2| {
                        logger.err("error writing error return trace: {}", .{err2});
                    };

                    logger.err("trace: {s}", .{err_trace.written()});
                }
                self.reconnect() catch return error.Disconnected;
                return try self.readEvent();
            },
            error.ServerClosed => {
                self.reconnect() catch return error.Disconnected;
                return try self.readEvent();
            },
        }
    };

    // if self_owned, we should not call json_parsed_value.deinit() because we will call `.deinit()` in a `defer` instead of this `errdefer`
    var self_owned: bool = false;
    errdefer {
        if (!self_owned) {
            json_parsed_value.deinit();
        }
    }

    if (json_parsed_value.value.op == .heartbeat) {
        defer json_parsed_value.deinit();
        self_owned = true;

        logger.debug("received heartbeat event. responding!", .{});
        self.writeEvent(SendEvent.heartbeat(self.json_ws_client.sequence)) catch |err| switch (err) {
            error.Canceled => return error.Canceled,
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
        self_owned = true;

        self.reconnect() catch return error.Disconnected;
        return try self.readEvent();
    }

    return .{
        .arena = json_parsed_value.arena,
        .raw = json_parsed_value.raw,
        .data = json_parsed_value.value.d,
    };
}

/// Easier-to-use version of `readEvent` which logs for non-critical errors, and logs + returns null for critical errors.
pub fn nextEvent(self: *Client) ?ReadEvent {
    while (true) {
        const event = self.readEvent() catch |err| switch (err) {
            error.JsonError, error.ResponseTooLong => {
                logger.warn("recieved an invalid response from discord {}", .{err});
                continue;
            },
            error.OutOfMemory, error.Disconnected, error.Canceled => {
                logger.err("{}", .{err});
                return null;
            },
        };

        return event;
    }
}

/// Sends an event over the gateway. This functionality is rarely needed, you may be looking for REST API (located under `zigcord.rest`).
pub fn writeEvent(self: *Client, event: SendEvent) error{ Canceled, WebsocketError, JsonError }!void {
    try self.json_ws_client.writeEvent(event);
}

/// Destroys the client.
pub fn deinit(self: Client) void {
    self.json_ws_client.deinit();
    self.allocator.destroy(self.json_ws_client);
}

pub const ReinitError = error{ NotResumable, AuthError, WebsocketError, JsonError } || std.mem.Allocator.Error;
/// Reconnects the websocket connection, following the RESUME flow if able.
pub fn reinit(self: *Client) ReinitError!void {
    const ready_event = self.json_ws_client.ready_event orelse {
        return error.NotResumable;
    };
    const sequence = self.json_ws_client.sequence orelse {
        return error.NotResumable;
    };

    self.json_ws_client.ready_event = null;
    self.json_ws_client.deinit();

    self.json_ws_client.* = JsonWSClient.initWithUri(
        self.io,
        self.allocator,
        .{ .bot = self.token },
        ready_event.event.resume_gateway_url,
    ) catch return error.AuthError;
    errdefer self.json_ws_client.deinit();

    self.json_ws_client.@"resume"(self.token, sequence, ready_event) catch return error.AuthError;
}

fn reconnect(self: *Client) !void {
    if (self.oldest_recent_reconnect) |oldest| {
        const now = std.Io.Clock.awake.now(self.io);
        if (oldest.durationTo(now).toSeconds() > 60) {
            self.oldest_recent_reconnect = now;
            self.recent_reconnects = 0;
        }
    } else {
        const now = std.Io.Clock.awake.now(self.io);
        self.oldest_recent_reconnect = now;
        self.recent_reconnects = 0;
    }

    if (self.recent_reconnects > 5) {
        return error.TooManyReconnects;
    }

    self.recent_reconnects += 1;
    try self.reinit();
    logger.debug("reconnected!", .{});
}
