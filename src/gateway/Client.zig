const std = @import("std");
const ws = @import("weebsocket");
const deancord = @import("../root.zig");
const rest = deancord.rest;
const gateway = deancord.gateway;
const send_events = gateway.event_data.send_events;
const receive_events = gateway.event_data.receive_events;
const Client = @This();

allocator: std.mem.Allocator,
reconnect_uri_str: []const u8,
reconnect_uri: std.Uri,
ws_client: *ws.Client,
ws_conn: *ws.Connection,
state: State,

/// Initializes a Gateway Client
pub fn init(allocator: std.mem.Allocator, auth: rest.Client.Authorization) !Client {
    var rest_client = rest.Client.init(allocator, auth);
    defer rest_client.deinit();

    return try initWithRestClient(allocator, &rest_client);
}

/// Initializes a Gateway Client from an existing Rest Client. The rest client only needs to live as long as this method call, but the
/// allocator should live as long as the returned Gateway Client.
pub fn initWithRestClient(allocator: std.mem.Allocator, rest_client: *rest.Client) !Client {
    const gateway_resp = try rest.endpoints.gateway.getGateway(rest_client);
    defer gateway_resp.deinit();

    const url = switch (gateway_resp.value()) {
        .ok => |value| value.url,
        .err => |err| {
            std.log.err("Error while opening gateway response: {}", .{err});
            return error.GetGatwayError;
        },
    };

    return try initWithUri(allocator, rest_client.auth, url);
}

/// Initializes a Gateway Client from an existing Rest Client. The provided URI is copied by the allocator.
pub fn initWithUri(allocator: std.mem.Allocator, auth: rest.Client.Authorization, uri: []const u8) !Client {
    const dupe_url = try allocator.dupe(u8, uri);
    errdefer allocator.free(dupe_url);

    var client = Client{
        .allocator = allocator,
        .reconnect_uri_str = dupe_url,
        .state = State{ .running = .{ .sequence = null } },
        .reconnect_uri = try std.Uri.parse(dupe_url),
        .ws_client = try allocator.create(ws.Client),
        .ws_conn = try allocator.create(ws.Connection),
    };
    client.ws_client.* = ws.Client.init(allocator);
    errdefer client.ws_client.deinit();

    var auth_header = std.BoundedArray(u8, 256){};
    try std.fmt.format(auth_header.writer(), "{}", .{auth});

    client.ws_conn.* = try client.ws_client.handshake(client.reconnect_uri, &.{.{ .name = "Authorization", .value = auth_header.constSlice() }});

    return client;
}

pub fn readEvent(self: *Client) !std.json.Parsed(gateway.ReceiveEvent) {
    var message = try self.ws_conn.readMessage();
    const payload = message.payloadReader();
    var json_reader = std.json.reader(self.allocator, payload);
    const payload_json_parsed = try std.json.parseFromTokenSource(gateway.ReceiveEvent, self.allocator, &json_reader, .{});
    return payload_json_parsed;
}

pub fn writeEvent(self: *Client, event: gateway.SendEvent) !void {
    var payload = std.BoundedArray(u8, 4096){}; // discord only accepts payloads shorter than 4096 bytes
    try std.json.stringify(event, .{}, payload.writer());

    try self.ws_conn.writeMessage(.text, payload.constSlice());
}

pub fn startHeartbeatThread(self: *Client, hello: gateway.event_data.receive_events.Hello) !void {
    const t = try std.Thread.spawn(.{}, defaultHeartbeatHandler, .{ self, hello.heartbeat_interval });
    t.detach();
}

fn defaultHeartbeatHandler(self: *Client, interval: u64) !void {
    var prng = std.Random.DefaultPrng.init(@bitCast(std.time.milliTimestamp()));
    const interval_with_jitter = prng.random().intRangeAtMostBiased(u64, 0, std.math.cast(u64, interval) orelse return error.Overflow);

    std.time.sleep(interval_with_jitter * std.time.ns_per_ms);

    var buf: [8096]u8 = undefined;
    var buf_allocator = std.heap.FixedBufferAllocator.init(&buf);
    while (self.state != .closing) {
        const sequence = switch (self.state) {
            .running => |state| state.sequence,
            .closing => unreachable,
        };
        const heartbeat = gateway.SendEvent.heartbeat(sequence);

        try self.writeEvent(heartbeat);
        buf_allocator.reset();

        std.time.sleep(interval * std.time.ns_per_ms);
    }
}

pub const State = union(enum) {
    running: struct {
        sequence: ?i64 = null,
    },
    closing: struct {},
};
