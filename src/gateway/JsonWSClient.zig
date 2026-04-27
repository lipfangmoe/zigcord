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

io: std.Io,
allocator: std.mem.Allocator,
ws_client: *ws.Client,
ws_conn: *ws.Connection,
heartbeat_future: ?std.Io.Future(void),
writer_mutex: std.Io.Mutex,

sequence: ?i64,
ready_event: ?ReadyEvent,

pub const ReadyEvent = struct {
    json_parsed: std.json.Parsed(gateway.ReceiveEvent),
    event: gateway.event_data.receive_events.Ready,
};

const InitError = error{};

/// Initializes a Gateway Client
pub fn init(io: std.Io, allocator: std.mem.Allocator, auth: zigcord.Authorization) !JsonWSClient {
    var api_client = zigcord.EndpointClient.init(io, allocator, auth);
    defer api_client.deinit();

    return try initWithRestClient(io, allocator, &api_client);
}

/// Initializes a Gateway Client from an existing Rest Client. The rest client only needs to live as long as this method call, but the
/// allocator should live as long as the returned Gateway Client.
pub fn initWithRestClient(io: std.Io, allocator: std.mem.Allocator, client: *zigcord.EndpointClient) !JsonWSClient {
    const gateway_resp = try client.getGateway();
    defer gateway_resp.deinit();

    const url = switch (gateway_resp.value()) {
        .ok => |value| value.url,
        .err => |err| {
            zigcord.logger.err("Error while opening gateway response: {f}", .{err});
            return error.GetGatwayError;
        },
    };

    return try initWithUri(io, allocator, client.rest_client.auth, url);
}

/// Initializes a Gateway Client from an existing Rest Client. The provided URI is copied by the allocator.
pub fn initWithUri(io: std.Io, allocator: std.mem.Allocator, auth: zigcord.Authorization, uri: []const u8) !JsonWSClient {
    const ws_client = try allocator.create(ws.Client);
    errdefer allocator.destroy(ws_client);
    const ws_conn = try allocator.create(ws.Connection);
    errdefer allocator.destroy(ws_conn);
    var client = JsonWSClient{
        .io = io,
        .allocator = allocator,
        .sequence = null,
        .ws_client = ws_client,
        .ws_conn = ws_conn,
        .writer_mutex = .init,
        .heartbeat_future = null,
        .ready_event = null,
    };

    client.ws_client.* = ws.Client.init(io, allocator);
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
    if (self.heartbeat_future) |*hbf| {
        hbf.cancel(self.io);
    }

    // now we can do our normal deiniting stuff
    self.ws_conn.deinit(self.io, ws.Connection.ClosePayload{ .status = .normal, .reason = &.{} });
    self.ws_client.deinit();
    self.allocator.destroy(self.ws_client);
    self.allocator.destroy(self.ws_conn);
    zigcord.logger.info("json_parsed", .{});
    if (self.ready_event) |ready| {
        ready.json_parsed.deinit();
    }
}

pub const ReadEventError = error{ ResponseTooLong, WebsocketError, JsonError, ServerClosed } || std.Io.Cancelable;
pub fn readEvent(self: *JsonWSClient) ReadEventError!std.json.Parsed(gateway.ReceiveEvent) {
    var buf: [1000]u8 = undefined;
    var message = self.ws_conn.receiveMessage(&buf);

    // normally i would avoid allocating here, but it's useful for error logging
    const payload_data = message.interface.allocRemaining(self.allocator, .limited(10_000_000)) catch |err| return switch (err) {
        error.OutOfMemory, error.StreamTooLong => error.ResponseTooLong,
        error.ReadFailed => switch (message.state.err) {
            error.Canceled => error.Canceled,
            error.ReceivedCloseFrame => error.ServerClosed,
            error.EndOfStream,
            error.InvalidMessage,
            error.InvalidUtf8,
            error.UnderlyingControlFrameWriteFailed,
            error.UnderlyingReadFailed,
            error.UnderlyingWriteFailed,
            error.EndOfFrame,
            => error.WebsocketError,
            error.PayloadTooLong => error.ResponseTooLong,
        },
    };
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

pub fn writeEvent(self: *JsonWSClient, event: gateway.SendEvent) error{ Canceled, WebsocketError }!void {
    try self.writer_mutex.lock(self.io);
    defer self.writer_mutex.unlock(self.io);

    var payload: [4096]u8 = undefined; // discord only accepts payloads shorter than 4096 bytes
    var payload_writer = std.Io.Writer.fixed(&payload);
    std.json.Stringify.value(event, .{}, &payload_writer) catch return error.WebsocketError;
    self.ws_conn.sendMessage(.text, payload_writer.buffered()) catch return error.WebsocketError;
}

pub const AuthenticateError = error{HeartbeatStartError} || ReadEventError;
pub fn authenticate(self: *JsonWSClient, token: []const u8, intents: model.Intents) AuthenticateError!void {
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

    const identify_event = gateway.SendEvent.identify(gateway.event_data.send_events.Identify{
        .token = token,
        .properties = .{ .browser = "zigcord", .device = "zigcord", .os = @tagName(@import("builtin").os.tag) },
        .intents = intents,
    });
    try self.writeEvent(identify_event);

    try self.writeEvent(gateway.SendEvent.heartbeat(self.sequence));
    self.startHeartbeatListener(heartbeat_interval) catch return error.HeartbeatStartError;

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

pub fn @"resume"(self: *JsonWSClient, token: []const u8, seq: i64, ready: ReadyEvent) AuthenticateError!void {
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

    self.startHeartbeatListener(heartbeat_interval) catch return error.HeartbeatStartError;

    const resume_event = gateway.SendEvent.@"resume"(gateway.event_data.send_events.Resume{
        .token = token,
        .session_id = ready.event.session_id,
        .seq = seq,
    });
    try self.writeEvent(resume_event);
}

pub fn startHeartbeatListener(self: *JsonWSClient, heartbeat_interval: u64) error{ConcurrencyUnavailable}!void {
    if (self.heartbeat_future) |*fut| {
        fut.cancel(self.io);
    }
    self.heartbeat_future = try self.io.concurrent(defaultHeartbeatHandler, .{ self, std.math.lossyCast(i64, heartbeat_interval) });
}

fn defaultHeartbeatHandler(self: *JsonWSClient, interval_ms: i64) void {
    var prng = std.Random.DefaultPrng.init(@bitCast(std.Io.Clock.real.now(self.io).toMilliseconds()));
    const interval_ms_with_jitter = prng.random().intRangeAtMostBiased(i64, 0, interval_ms);

    std.Io.sleep(self.io, .fromMilliseconds(interval_ms_with_jitter), .awake) catch return;

    var buf: [8096]u8 = undefined;
    var buf_allocator = std.heap.FixedBufferAllocator.init(&buf);
    while (true) {
        const sequence = self.sequence;
        const heartbeat = gateway.SendEvent.heartbeat(sequence);

        self.writeEvent(heartbeat) catch |err| {
            zigcord.logger.warn("failed to write heartbeat: {}", .{err});
            if (@errorReturnTrace()) |trace| {
                var err_trace: std.Io.Writer.Allocating = .init(self.allocator);
                defer err_trace.deinit();
                std.debug.writeErrorReturnTrace(trace, .{ .writer = &err_trace.writer, .mode = .no_color }) catch |err2| {
                    zigcord.logger.err("error writing error return trace: {}", .{err2});
                };

                zigcord.logger.err("trace: {s}", .{err_trace.written()});
            }
        };
        buf_allocator.reset();

        std.Io.sleep(self.io, .fromMilliseconds(interval_ms), .awake) catch return;
    }
}
