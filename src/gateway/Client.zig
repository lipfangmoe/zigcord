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

    try json_ws_client.init(allocator, .{ .bot = token });
    try json_ws_client.authenticate(token, intents);

    return Client{
        .allocator = allocator,
        .token = token,
        .intents = intents,
        .json_ws_client = json_ws_client,
    };
}

pub const ReadEvent = struct {
    value: zigcord.gateway.ReadEventData,
    json_parsed_value: std.json.Parsed(zigcord.gateway.ReceiveEvent),

    pub fn deinit(self: ReadEvent) void {
        self.json_parsed_value.deinit();
    }
};

pub fn readEvent(self: *Client) error{ WebsocketError, JsonError }!ReadEvent {
    const json_parsed_value = self.json_ws_client.readEvent() catch |err| {
        const new_client = self.reconnect() catch return err;
        self.deinit();
        self.* = new_client;
        return try self.readEvent();
    };

    return ReadEvent{
        .value = json_parsed_value.value.d,
        .json_parsed_value = json_parsed_value,
    };
}

pub fn writeEvent(self: *Client, event: zigcord.gateway.SendEvent) error{ WebsocketError, JsonError }!void {
    try self.json_ws_client.writeEvent(event);
}

pub fn deinit(self: *Client) void {
    self.allocator.destroy(self.json_ws_client);
}

fn reconnect(self: Client) error{TooManyReconnects}!Client {
    var reconnects = self.reconnects + 1;
    var oldest_reconnect = self.oldest_tracked_reconnect;
    if (self.oldest_tracked_reconnect) |oldest| {
        const now = std.time.timestamp();
        if (oldest < now - 60) {
            oldest_reconnect = now;
            reconnects = 1;
        }
    }

    if (reconnects > 5) {
        return error.TooManyReconnects;
    }

    var client = try Client.init(self.allocator, self.token, self.intents);
    client.reconnects = reconnects;
    client.oldest_reconnect = oldest_reconnect;
}
