//! A client useful for if you want lower-level access to websocket messages

const std = @import("std");
const ws = @import("weebsocket");
const zigcord = @import("../root.zig");
const rest = zigcord.rest;
const gateway = zigcord.gateway;
const model = zigcord.model;
const send_events = gateway.event_data.send_events;
const receive_events = gateway.event_data.receive_events;
const JsonWSClient = @This();

allocator: std.mem.Allocator,
ws_client: *ws.Client,
ws_conn: *ws.Connection,
write_message_mutex: std.Thread.Mutex,
is_closing: std.Thread.ResetEvent,
is_closed: std.Thread.ResetEvent,

sequence: ?i64,
ready_event: ?ReadyEvent,

pub const ReadyEvent = struct {
    json_parsed: std.json.Parsed(gateway.ReceiveEvent),
    event: gateway.event_data.receive_events.Ready,
};

const InitError = error{};

/// Initializes a Gateway Client
pub fn init(allocator: std.mem.Allocator, auth: zigcord.Authorization) !JsonWSClient {
    var api_client = zigcord.EndpointClient.init(allocator, auth);
    defer api_client.deinit();

    return try initWithRestClient(allocator, &api_client);
}

/// Initializes a Gateway Client from an existing Rest Client. The rest client only needs to live as long as this method call, but the
/// allocator should live as long as the returned Gateway Client.
pub fn initWithRestClient(allocator: std.mem.Allocator, client: *zigcord.EndpointClient) !JsonWSClient {
    const gateway_resp = try client.getGateway();
    defer gateway_resp.deinit();

    const url = switch (gateway_resp.value()) {
        .ok => |value| value.url,
        .err => |err| {
            zigcord.logger.err("Error while opening gateway response: {f}", .{err});
            return error.GetGatwayError;
        },
    };

    return try initWithUri(allocator, client.rest_client.auth, url);
}

/// Initializes a Gateway Client from an existing Rest Client. The provided URI is copied by the allocator.
pub fn initWithUri(allocator: std.mem.Allocator, auth: zigcord.Authorization, uri: []const u8) !JsonWSClient {
    const ws_client = try allocator.create(ws.Client);
    errdefer allocator.destroy(ws_client);
    const ws_conn = try allocator.create(ws.Connection);
    errdefer allocator.destroy(ws_conn);
    var client = JsonWSClient{
        .allocator = allocator,
        .sequence = null,
        .ws_client = ws_client,
        .ws_conn = ws_conn,
        .write_message_mutex = std.Thread.Mutex{},
        .is_closing = std.Thread.ResetEvent{},
        .is_closed = std.Thread.ResetEvent{},
        .ready_event = null,
    };

    client.ws_client.* = ws.Client.init(allocator);
    errdefer client.ws_client.deinit();

    var auth_header_buf: [512]u8 = undefined;
    var auth_header = std.Io.Writer.fixed(&auth_header_buf);
    try auth_header.print("{f}", .{auth});

    zigcord.logger.info("attempting connection to {s}", .{uri});
    client.ws_conn.* = try client.ws_client.handshake(try std.Uri.parse(uri), &.{.{ .name = "Authorization", .value = auth_header.buffered() }});

    return client;
}

pub fn deinit(self: *JsonWSClient) void {
    // first, stop heartbeat thread
    self.is_closing.set();
    self.is_closed.wait();

    // now we can do our normal deiniting stuff
    self.ws_conn.deinit(ws.Connection.ClosePayload{ .status = .normal, .reason = &.{} });
    self.ws_client.deinit();
    self.allocator.destroy(self.ws_client);
    self.allocator.destroy(self.ws_conn);
    if (self.ready_event) |ready| {
        ready.json_parsed.deinit();
    }
    zigcord.logger.info("websocket client destroyed", .{});
}

pub fn readEvent(self: *JsonWSClient) error{ WebsocketError, JsonError }!std.json.Parsed(gateway.ReceiveEvent) {
    var message = self.ws_conn.receiveMessage() catch return error.WebsocketError;

    // normally i would avoid allocating here, but it's useful for error logging
    const payload_data = message.reader().allocRemaining(self.allocator, .limited(10_000_000)) catch return error.JsonError;
    defer self.allocator.free(payload_data);

    const payload_json_parsed = std.json.parseFromSlice(gateway.ReceiveEvent, self.allocator, payload_data, .{ .ignore_unknown_fields = true, .allocate = .alloc_always }) catch {
        zigcord.logger.err("json deserialization error for input: {s}", .{payload_data});
        return error.JsonError;
    };
    errdefer payload_json_parsed.deinit();

    if (payload_json_parsed.value.s) |sequence| {
        self.sequence = sequence;
    }
    return payload_json_parsed;
}

pub fn writeEvent(self: *JsonWSClient, event: gateway.SendEvent) error{ WebsocketError, JsonError }!void {
    self.write_message_mutex.lock();
    defer self.write_message_mutex.unlock();

    var payload: [4096]u8 = undefined; // discord only accepts payloads shorter than 4096 bytes
    var payload_writer = std.Io.Writer.fixed(&payload);
    std.json.Stringify.value(event, .{}, &payload_writer) catch return error.JsonError;
    self.ws_conn.sendMessage(.text, payload_writer.buffered()) catch return error.WebsocketError;
}

pub fn authenticate(self: *JsonWSClient, token: []const u8, intents: model.Intents) error{ WebsocketError, JsonError, HeartbeatStartError }!void {
    const heartbeat_interval = while (true) {
        const event = try self.readEvent();
        defer event.deinit();

        switch (event.value.d) {
            .hello => |hello| break hello.heartbeat_interval,
            else => {
                zigcord.logger.warn("unexpected event while waiting for hello: {}", .{event});
                continue;
            },
        }

        break;
    };
    zigcord.logger.debug("hello event received (heartbeat interval = {d}ms)", .{heartbeat_interval});

    self.startHeartbeatThread(heartbeat_interval) catch return error.HeartbeatStartError;

    const identify_event = gateway.SendEvent.identify(gateway.event_data.send_events.Identify{
        .token = token,
        .properties = .{ .browser = "zigcord", .device = "zigcord", .os = @tagName(@import("builtin").os.tag) },
        .intents = intents,
    });
    try self.writeEvent(identify_event);

    const first_heartbeat = gateway.SendEvent.heartbeat(self.sequence);
    try self.writeEvent(first_heartbeat);

    zigcord.logger.debug("identify event sent, waiting for Ready event", .{});
    while (true) {
        const event = try self.readEvent();
        errdefer event.deinit();

        switch (event.value.d) {
            .ready => |ready| {
                self.ready_event = .{
                    .json_parsed = event,
                    .event = ready,
                };
                zigcord.logger.info("authentication complete", .{});
                return;
            },
            .heartbeat_ack => {
                event.deinit();
            },
            else => {
                zigcord.logger.warn("unexpected event while waiting for ready: {}", .{event.value});
                event.deinit();
            },
        }
    }
}

pub fn @"resume"(self: *JsonWSClient, token: []const u8, seq: i64, ready: ReadyEvent) error{ WebsocketError, JsonError, HeartbeatStartError }!void {
    self.ready_event = ready;

    const heartbeat_interval = while (true) {
        const event = try self.readEvent();
        defer event.deinit();

        switch (event.value.d) {
            .hello => |hello| break hello.heartbeat_interval,
            else => {
                zigcord.logger.warn("unexpected event while waiting for hello event: {}", .{event});
                continue;
            },
        }

        break;
    };

    self.startHeartbeatThread(heartbeat_interval) catch return error.HeartbeatStartError;

    const resume_event = gateway.SendEvent.@"resume"(gateway.event_data.send_events.Resume{
        .token = token,
        .session_id = ready.event.session_id,
        .seq = seq,
    });
    try self.writeEvent(resume_event);
}

pub fn startHeartbeatThread(self: *JsonWSClient, heartbeat_interval: u64) !void {
    const t = try std.Thread.spawn(.{}, defaultHeartbeatHandler, .{ self, heartbeat_interval });
    t.detach();
}

fn defaultHeartbeatHandler(self: *JsonWSClient, interval_ms: u64) !void {
    const interval = interval_ms * std.time.ns_per_ms;
    var prng = std.Random.DefaultPrng.init(@bitCast(std.time.milliTimestamp()));
    const interval_with_jitter = prng.random().intRangeAtMostBiased(u64, 0, interval);

    defer self.is_closed.set();

    {
        // expect a timeout
        if (self.is_closing.timedWait(interval_with_jitter)) {
            return;
        } else |err| switch (err) {
            error.Timeout => {},
            else => return,
        }
    }

    var buf: [8096]u8 = undefined;
    var buf_allocator = std.heap.FixedBufferAllocator.init(&buf);
    while (true) {
        const sequence = self.sequence;
        const heartbeat = gateway.SendEvent.heartbeat(sequence);

        try self.writeEvent(heartbeat);
        buf_allocator.reset();

        // expect a timeout
        self.is_closing.timedWait(interval) catch |err| switch (err) {
            error.Timeout => continue,
        };
        return;
    }
}
