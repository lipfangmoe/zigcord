//! A client useful for if you want lower-level access to websocket messages

const std = @import("std");
const ws = @import("weebsocket");
const zigcord = @import("../root.zig");
const rest = zigcord.rest;
const gateway = zigcord.gateway;
const model = zigcord.model;
const send_events = gateway.event_data.send_events;
const receive_events = gateway.event_data.receive_events;
const Client = @This();

allocator: std.mem.Allocator,
reconnect_uri_str: []const u8,
reconnect_uri: std.Uri,
ws_client: *ws.Client,
ws_conn: *ws.Connection,
write_message_mutex: std.Thread.Mutex,
is_closing: std.Thread.ResetEvent,
is_closed: std.Thread.ResetEvent,
sequence: ?i64,

const InitError = error{};

/// Initializes a Gateway Client
pub fn init(allocator: std.mem.Allocator, auth: zigcord.Authorization) !Client {
    var api_client = zigcord.EndpointClient.init(allocator, auth);
    defer api_client.deinit();

    return try initWithRestClient(allocator, &api_client);
}

/// Initializes a Gateway Client from an existing Rest Client. The rest client only needs to live as long as this method call, but the
/// allocator should live as long as the returned Gateway Client.
pub fn initWithRestClient(allocator: std.mem.Allocator, client: *zigcord.EndpointClient) !Client {
    const gateway_resp = try client.getGateway();
    defer gateway_resp.deinit();

    const url = switch (gateway_resp.value()) {
        .ok => |value| value.url,
        .err => |err| {
            std.log.err("Error while opening gateway response: {}", .{err});
            return error.GetGatwayError;
        },
    };

    std.log.info("attempting connection to {s}", .{url});

    return try initWithUri(allocator, client.rest_client.auth, url);
}

/// Initializes a Gateway Client from an existing Rest Client. The provided URI is copied by the allocator.
pub fn initWithUri(allocator: std.mem.Allocator, auth: zigcord.Authorization, uri: []const u8) !Client {
    const dupe_url = try allocator.dupe(u8, uri);
    errdefer allocator.free(dupe_url);

    var client = Client{
        .allocator = allocator,
        .reconnect_uri_str = dupe_url,
        .sequence = null,
        .next_heartbeat = null,
        .reconnect_uri = try std.Uri.parse(dupe_url),
        .ws_client = try allocator.create(ws.Client),
        .ws_conn = try allocator.create(ws.Connection),
        .write_message_mutex = std.Thread.Mutex{},
        .is_closing = std.Thread.ResetEvent{},
        .is_closed = std.Thread.ResetEvent{},
    };
    errdefer {
        allocator.destroy(client.ws_client);
        allocator.destroy(client.ws_conn);
    }

    client.ws_client.* = ws.Client.init(allocator);
    errdefer client.ws_client.deinit();

    var auth_header = std.BoundedArray(u8, 256){};
    try std.fmt.format(auth_header.writer(), "{}", .{auth});

    client.ws_conn.* = try client.ws_client.handshake(client.reconnect_uri, &.{.{ .name = "Authorization", .value = auth_header.constSlice() }});

    return client;
}

pub fn deinit(self: *Client) void {
    // first, stop heartbeat thread
    self.is_closing.set();
    self.is_closed.wait();

    // now we can do our normal deiniting stuff
    self.ws_conn.deinit(null);
    self.ws_client.deinit();
    self.allocator.destroy(self.ws_client);
    self.allocator.destroy(self.ws_conn);
    self.allocator.free(self.reconnect_uri_str);
}

pub fn readEvent(self: *Client) error{ WebsocketError, JsonError }!std.json.Parsed(gateway.ReceiveEvent) {
    var message = self.ws_conn.readMessage() catch return error.WebsocketError;
    const payload = message.payloadReader();
    var json_reader = std.json.reader(self.allocator, payload);
    defer json_reader.deinit();
    const payload_json_parsed = std.json.parseFromTokenSource(gateway.ReceiveEvent, self.allocator, &json_reader, .{ .ignore_unknown_fields = true }) catch return error.JsonError;
    if (payload_json_parsed.value.s) |sequence| {
        self.sequence = sequence;
    }
    return payload_json_parsed;
}

pub fn writeEvent(self: *Client, event: gateway.SendEvent) error{ WebsocketError, JsonError }!void {
    self.write_message_mutex.lock();
    defer self.write_message_mutex.unlock();

    var payload = std.BoundedArray(u8, 4096){}; // discord only accepts payloads shorter than 4096 bytes
    try std.json.stringify(event, .{}, payload.writer()) catch return error.JsonError;
    try self.ws_conn.writeMessage(.text, payload.constSlice()) catch return error.WebsocketError;
}

pub fn authenticate(self: *Client, token: []const u8, intents: model.Intents) !std.json.Parsed(gateway.ReceiveEvent) {
    const heartbeat_interval = while (true) {
        const event = try self.readEvent();
        defer event.deinit();

        switch (event.value.d orelse continue) {
            .Hello => |hello| break hello.heartbeat_interval,
            else => {
                std.log.warn("unexpected event while waiting for ready: {}", .{event});
                continue;
            },
        }

        break;
    };

    try self.startHeartbeatThread(heartbeat_interval);

    return self.waitUntilReady(token, intents);
}

pub fn waitUntilReady(self: *Client, token: []const u8, intents: model.Intents) !std.json.Parsed(gateway.ReceiveEvent) {
    const identify_event = gateway.SendEvent.identify(gateway.event_data.send_events.Identify{
        .token = token,
        .properties = .{ .browser = "zigcord", .device = "zigcord", .os = @tagName(@import("builtin").os.tag) },
        .intents = intents,
    });
    try self.writeEvent(identify_event);

    while (true) {
        const event = try self.readEvent();
        errdefer event.deinit();

        const gateway_url = switch (event.value.d orelse continue) {
            .Ready => |ready| ready.resume_gateway_url,
            else => {
                event.deinit();
                std.log.warn("unexpected event while waiting for ready: {}", .{event});
                continue;
            },
        };

        self.allocator.free(self.reconnect_uri_str);
        self.reconnect_uri_str = try self.allocator.dupe(u8, gateway_url);
        self.reconnect_uri = try std.Uri.parse(self.reconnect_uri_str);

        return event;
    }
}

pub fn startHeartbeatThread(self: *Client, heartbeat_interval: u64) !void {
    const t = try std.Thread.spawn(.{}, defaultHeartbeatHandler, .{ self, heartbeat_interval });
    t.detach();
}

fn defaultHeartbeatHandler(self: *Client, interval: u64) !void {
    var prng = std.Random.DefaultPrng.init(@bitCast(std.time.milliTimestamp()));
    const interval_with_jitter = prng.random().intRangeAtMostBiased(u64, 0, interval / 5);

    {
        // expect a timeout
        const timeout = self.is_closing.timedWait(interval_with_jitter * std.time.ns_per_ms);
        if (timeout != error.Timeout) {
            self.is_closed.set();
            return;
        }
    }

    var buf: [8096]u8 = undefined;
    var buf_allocator = std.heap.FixedBufferAllocator.init(&buf);
    while (true) {
        const sequence = switch (self.state) {
            .running => |state| state.sequence,
        };
        const heartbeat = gateway.SendEvent.heartbeat(sequence);

        try self.writeEvent(heartbeat);
        buf_allocator.reset();

        // expect a timeout
        const timeout = self.is_closing.timedWait(interval * std.time.ns_per_ms);
        if (timeout != error.Timeout) {
            self.is_closed.set();
            return;
        }
    }
}
