const std = @import("std");
const builtin = @import("builtin");
const deancord = @import("../root.zig");

const Client = @This();

allocator: std.mem.Allocator,
auth: Authorization,
client: std.http.Client,
config: Config,

/// Creates a discord http client with default configuration.
///
/// Cannot be used in tests, instead use `initWithConfig` and provide a mock response from the server.
pub fn init(allocator: std.mem.Allocator, auth: Authorization) Client {
    const config = Config{};
    return initWithConfig(allocator, auth, config);
}

/// Creates a discord http client based on a configuration
pub fn initWithConfig(allocator: std.mem.Allocator, auth: Authorization, config: Config) Client {
    const client = std.http.Client{ .allocator = allocator };
    return .{
        .allocator = allocator,
        .auth = auth,
        .client = client,
        .config = config,
    };
}

pub fn beginMultipartRequest(
    self: *Client,
    comptime ResponseT: type,
    method: std.http.Method,
    url: std.Uri,
    transfer_encoding: std.http.Client.RequestTransfer,
    boundary: []const u8,
    extra_headers: ?[]const std.http.Header,
) !PendingRequest(ResponseT) {
    var buf: [1028]u8 = undefined;
    var alloc = std.heap.FixedBufferAllocator.init(&buf);
    const content_type = try std.mem.concat(alloc.allocator(), u8, &.{ "multipart/form-data; boundary=", boundary });
    return try beginRequest(
        self,
        ResponseT,
        method,
        url,
        transfer_encoding,
        std.http.Client.Request.Headers{ .content_type = .{ .override = content_type } },
        extra_headers,
    );
}

pub fn beginRequest(
    self: *Client,
    comptime ResponseT: type,
    method: std.http.Method,
    url: std.Uri,
    transfer_encoding: std.http.Client.RequestTransfer,
    headers: ?std.http.Client.Request.Headers,
    extra_headers: ?[]const std.http.Header,
) !PendingRequest(ResponseT) {
    const authValue = try std.fmt.allocPrint(self.allocator, "{}", .{self.auth});
    defer self.allocator.free(authValue);

    var defaulted_headers = headers orelse std.http.Client.Request.Headers{};
    if (defaulted_headers.authorization == .default) {
        defaulted_headers.authorization = .{ .override = authValue };
    }
    if (defaulted_headers.content_type == .default) {
        defaulted_headers.content_type = .{ .override = "application/json" };
    }

    var server_header_buffer: [2048]u8 = undefined;
    var req = try self.client.open(method, url, std.http.Client.RequestOptions{
        .server_header_buffer = &server_header_buffer,
        .headers = defaulted_headers,
        .extra_headers = extra_headers orelse &.{},
    });
    errdefer req.deinit();

    req.transfer_encoding = transfer_encoding;

    try req.send();
    return PendingRequest(ResponseT){
        .allocator = self.allocator,
        .req = req,
        .config = self.config,
    };
}

/// Sends a request to the Discord REST API with the credentials stored in this context
pub fn request(self: *Client, comptime ResponseT: type, method: std.http.Method, url: std.Uri) !Result(ResponseT) {
    var pending = try self.beginRequest(ResponseT, method, url, .{ .none = void{} }, null, null);
    defer pending.deinit();

    return pending.waitForResponse();
}

/// Sends a request to the Discord REST API with the credentials stored in this context
pub fn requestWithAuditLogReason(self: *Client, comptime ResponseT: type, method: std.http.Method, url: std.Uri, audit_log_reason: ?[]const u8) !Result(ResponseT) {
    const extra_headers: []const std.http.Header = if (audit_log_reason) |reason|
        &.{std.http.Header{ .name = "X-Audit-Log-Reason", .value = reason }}
    else
        &.{};

    var pending = try self.beginRequest(ResponseT, method, url, .{ .none = void{} }, null, extra_headers);
    defer pending.deinit();

    return pending.waitForResponse();
}

/// Sends a request (with a body) to the Discord REST API with the credentials stored in this context.
pub fn requestWithBody(self: *Client, comptime ResponseT: type, method: std.http.Method, url: std.Uri, body: std.io.AnyReader) !Result(ResponseT) {
    var pending = try self.beginRequest(ResponseT, method, url, .{ .chunked = void{} }, null, null);
    defer pending.deinit();

    var fifo = std.fifo.LinearFifo([]u8, .{ .Static = 1000 }).init();
    try fifo.pump(body, pending.writer());

    return try pending.waitForResponse();
}

/// Sends a request (with a body) to the Discord REST API with the credentials stored in this context.
pub fn requestWithValueBody(self: *Client, comptime ResponseT: type, method: std.http.Method, url: std.Uri, body: anytype, stringifyOptions: std.json.StringifyOptions) !Result(ResponseT) {
    var pending = try self.beginRequest(ResponseT, method, url, .{ .chunked = void{} }, null, null);
    defer pending.deinit();

    var buffered_body_writer = std.io.bufferedWriter(pending.writer());

    try std.json.stringify(body, stringifyOptions, buffered_body_writer.writer());
    try buffered_body_writer.flush();

    std.log.debug("sending JSON request to path '{}':\n{}", .{ url, std.json.fmt(body, stringifyOptions) });

    return try pending.waitForResponse();
}

pub fn requestWithValueBodyAndAuditLogReason(
    self: *Client,
    comptime ResponseT: type,
    method: std.http.Method,
    url: std.Uri,
    body: anytype,
    stringifyOptions: std.json.StringifyOptions,
    audit_log_reason: ?[]const u8,
) !Result(ResponseT) {
    const extra_headers: []const std.http.Header = if (audit_log_reason) |reason|
        &.{std.http.Header{ .name = "X-Audit-Log-Reason", .value = reason }}
    else
        &.{};

    var pending = try self.beginRequest(ResponseT, method, url, .{ .chunked = void{} }, null, extra_headers);
    defer pending.deinit();

    var buffered_body_writer = std.io.bufferedWriter(pending.writer());

    try std.json.stringify(body, stringifyOptions, buffered_body_writer.writer());
    try buffered_body_writer.flush();

    return try pending.waitForResponse();
}

pub fn deinit(self: *Client) void {
    self.client.deinit();
}

pub const Config = struct {
    pub const default_user_agent = "DiscordBot (https://dean.day/deancord.zig, " ++ deancord.version ++ ")";

    /// 1mb seems fair since all discord api responses should be text, with urls for anything large.
    /// surely they don't respond with more than 1 million characters... Clueless
    max_response_length: usize = 1_000_000,

    /// Allows customizing the user agent string. You are advised to keep the default value as a prefix (see https://discord.com/developers/docs/reference#user-agent)
    user_agent: []const u8 = default_user_agent,
};

pub const Authorization = struct {
    token: union(enum) { bot: []const u8, bearer: []const u8 },

    pub fn format(self: Authorization, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        switch (self.token) {
            .bot => |token| try writer.print("Bot {s}", .{token}),
            .bearer => |token| try writer.print("Bearer {s}", .{token}),
        }
    }
};

pub fn PendingRequest(comptime T: type) type {
    return struct {
        allocator: std.mem.Allocator,
        req: std.http.Client.Request,
        config: Config,

        /// returns a writer that writes to the request body
        pub fn writer(self: *PendingRequest(T)) std.io.GenericWriter(*PendingRequest(T), std.http.Client.Request.WriteError, writeFn) {
            return std.io.GenericWriter(*PendingRequest(T), std.http.Client.Request.WriteError, writeFn){ .context = self };
        }

        fn writeFn(self: *PendingRequest(T), bytes: []const u8) std.http.Client.Request.WriteError!usize {
            return try self.req.write(bytes);
        }

        /// Waits for the server to return its response.
        pub fn waitForResponse(self: *PendingRequest(T)) !Result(T) {
            try self.req.finish();
            try self.req.wait();

            const status = self.req.response.status;
            const status_class = status.class();
            if (T == void and status_class == .success) {
                return Result(T){ .ok = .{ .status = status, .value = void{}, .parsed = null } };
            }

            const byte_reader = self.req.reader();
            var json_reader = std.json.reader(self.allocator, byte_reader);
            defer json_reader.deinit();

            const value = switch (status_class) {
                .success => blk: {
                    if (T != void) {
                        const parsed = try std.json.parseFromTokenSource(T, self.allocator, &json_reader, .{ .ignore_unknown_fields = true, .max_value_len = self.config.max_response_length });
                        break :blk Result(T){ .ok = .{ .status = status, .value = parsed.value, .parsed = parsed } };
                    } else {
                        // unreachable because we have a special case for `T == void and status_class == .success` earlier
                        unreachable;
                    }
                },
                else => blk: {
                    const parsed = try std.json.parseFromTokenSource(DiscordError, self.allocator, &json_reader, .{ .ignore_unknown_fields = true, .max_value_len = self.config.max_response_length });
                    break :blk Result(T){ .err = .{ .status = status, .value = parsed.value, .parsed = parsed } };
                },
            };

            return value;
        }

        pub fn deinit(self: *PendingRequest(T)) void {
            self.req.deinit();
        }
    };
}

pub fn Result(T: type) type {
    return union(enum) {
        ok: struct {
            status: std.http.Status,
            value: T,
            parsed: ?std.json.Parsed(T),
        },
        err: struct {
            status: std.http.Status,
            value: DiscordError,
            parsed: ?std.json.Parsed(DiscordError),
        },

        pub const Value = union(enum) {
            ok: T,
            err: DiscordError,
        };

        pub fn value(self: Result(T)) Value {
            return switch (self) {
                .ok => |ok| .{ .ok = ok.value },
                .err => |err| .{ .err = err.value },
            };
        }

        pub fn status(self: Result(T)) std.http.Status {
            return switch (self) {
                inline else => |either| either.status,
            };
        }

        pub fn deinit(self: Result(T)) void {
            switch (self) {
                inline else => |val| {
                    if (val.parsed) |parsed| {
                        parsed.deinit();
                    }
                },
            }
        }
    };
}

pub const DiscordError = struct {
    code: u64 = 0,
    message: []const u8 = "unknown message",
    errors: std.json.Value = std.json.Value{ .null = void{} },
    other_fields: std.json.ArrayHashMap(std.json.Value) = .{},

    pub fn jsonStringify(self: DiscordError, jw: anytype) !void {
        try jw.beginObject();

        try jw.objectField("code");
        try jw.write(self.code);
        try jw.objectField("message");
        try jw.write(self.message);
        try jw.objectField("errors");
        try jw.write(self.errors);

        var iter = self.other_fields.map.iterator();
        while (iter.next()) |json_field| {
            try jw.objectField(json_field.key_ptr.*);
            try jw.write(json_field.value_ptr.*);
        }

        try jw.endObject();
    }

    pub fn jsonParse(alloc: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !DiscordError {
        if (try source.next() != .object_begin) {
            return error.UnexpectedToken;
        }

        var discord_error = DiscordError{};

        while (true) {
            const token = try source.nextAlloc(alloc, options.allocate.?);
            switch (token) {
                inline .string, .allocated_string => |k| {
                    if (std.mem.eql(u8, k, "code")) {
                        discord_error.code = try std.json.innerParse(u64, alloc, source, options);
                    } else if (std.mem.eql(u8, k, "message")) {
                        discord_error.message = try std.json.innerParse([]const u8, alloc, source, options);
                    } else if (std.mem.eql(u8, k, "errors")) {
                        discord_error.errors = try std.json.innerParse(std.json.Value, alloc, source, options);
                    } else {
                        try discord_error.other_fields.map.put(alloc, k, try std.json.innerParse(std.json.Value, alloc, source, options));
                    }
                },
                .object_end => break,
                else => unreachable,
            }
        }

        return discord_error;
    }

    pub fn jsonParseFromValue(alloc: std.mem.Allocator, source: std.json.Value, options: std.json.ParseOptions) !DiscordError {
        const obj = switch (source) {
            .object => |obj| obj,
            else => return error.UnexpectedToken,
        };
        var discord_error = DiscordError{};
        var json_fields = obj.iterator();
        while (json_fields.next()) |json_field| {
            if (std.mem.eql(u8, json_field.key_ptr.*, "code")) {
                discord_error.code = try std.json.innerParseFromValue(u64, alloc, source, options);
            } else if (std.mem.eql(u8, json_field.key_ptr.*, "message")) {
                discord_error.message = try std.json.innerParseFromValue([]const u8, alloc, source, options);
            } else if (std.mem.eql(u8, json_field.key_ptr.*, "errors")) {
                discord_error.errors = try std.json.innerParseFromValue(std.json.Value, alloc, source, options);
            } else {
                try discord_error.other_fields.map.put(alloc, json_field.key_ptr.*, try std.json.innerParseFromValue(std.json.Value, alloc, source, options));
            }
        }
        return discord_error;
    }
};

pub const TestResponse = if (builtin.is_test) struct {
    status: std.http.Status,
    body: []const u8,
} else void;

// inspiration from `std/http/test.zig`
pub fn TestServer(S: type) type {
    comptime {
        std.debug.assert(builtin.is_test);
        std.debug.assert(@hasDecl(S, "onRequest"));
    }
    return struct {
        server_thread: std.Thread,
        net_server: std.net.Server,

        fn start(self: *TestServer(S)) !void {
            var header_buf: [2048]u8 = undefined;
            const conn = try self.net_server.accept();
            defer conn.stream.close();

            var server = std.http.Server.init(conn, &header_buf);
            while (server.state == .ready) {
                var req = server.receiveHead() catch |err| {
                    switch (err) {
                        error.HttpConnectionClosing => break,
                        else => |e| return e,
                    }
                };

                const response: TestResponse = try S.onRequest(&req);
                try req.respond(response.body, .{ .status = response.status });
            }
        }

        fn destroy(self: *TestServer(S)) void {
            self.net_server.deinit();
            self.server_thread.join();
            std.testing.allocator.destroy(self);
        }

        fn port(self: TestServer(S)) u16 {
            return self.net_server.listen_address.in.getPort();
        }
    };
}
fn createTestServer(S: type) !*TestServer(S) {
    if (builtin.single_threaded) return error.SkipZigTest;
    if (builtin.zig_backend == .stage2_llvm and builtin.cpu.arch.endian() == .big) {
        // https://github.com/ziglang/zig/issues/13782
        return error.SkipZigTest;
    }

    const address = try std.net.Address.parseIp("127.0.0.1", 0);
    var test_server = try std.testing.allocator.create(TestServer(S));
    test_server.net_server = try address.listen(.{ .reuse_address = true });
    test_server.server_thread = try std.Thread.spawn(.{}, TestServer(S).start, .{test_server});
    return test_server;
}

const SomeJsonObj = struct {
    str: []const u8,
    num: f64,
};

test "request parses response body" {
    const allocator = std.testing.allocator;

    const test_server = try createTestServer(struct {
        pub fn onRequest(req: *std.http.Server.Request) !TestResponse {
            const body_reader = try req.reader();
            const body = try body_reader.readAllAlloc(std.testing.allocator, 10);
            defer std.testing.allocator.free(body);
            try std.testing.expectEqual(.GET, req.head.method);
            try std.testing.expectEqualStrings("/api/v10/lol", req.head.target);
            try std.testing.expectEqualStrings("", body);

            try std.testing.expect(false);

            return TestResponse{
                .status = std.http.Status.ok,
                .body = "{\"str\":\"some string\",\"num\":123}",
            };
        }
    });
    defer test_server.destroy();

    var client = init(allocator, .{ .token = .{ .bot = "sometoken" } });
    defer client.deinit();

    const url = std.Uri{
        .host = .{ .raw = "127.0.0.1" },
        .path = .{ .raw = "/api/v10/lol" },
        .scheme = "http",
        .port = test_server.port(),
    };

    const result = try client.request(SomeJsonObj, .GET, url);
    defer result.deinit();

    const expected: SomeJsonObj = .{ .str = "some string", .num = 123 };
    try std.testing.expectEqualDeep(expected, result.value().ok);
    try std.testing.expectEqual(std.http.Status.ok, result.status());
}

test "requestWithValueBody stringifies struct request body" {
    const allocator = std.testing.allocator;

    const test_server = try createTestServer(struct {
        pub fn onRequest(req: *std.http.Server.Request) !TestResponse {
            const body_reader = try req.reader();
            const body = try body_reader.readBoundedBytes(100);

            try std.testing.expectEqual(.POST, req.head.method);
            try std.testing.expectEqualStrings("/api/v10/lol", req.head.target);
            try std.testing.expectEqualStrings("{\"str\":\"lol lmao\",\"num\":4.2e+01}", body.constSlice());

            return TestResponse{
                .status = std.http.Status.ok,
                .body = "{\"str\":\"some string\",\"num\":123}",
            };
        }
    });
    defer test_server.destroy();

    const obj = SomeJsonObj{
        .str = "lol lmao",
        .num = 42,
    };

    var client = init(allocator, .{ .token = .{ .bot = "sometoken" } });
    defer client.deinit();

    const url = std.Uri{
        .host = .{ .raw = "127.0.0.1" },
        .path = .{ .raw = "/api/v10/lol" },
        .scheme = "http",
        .port = test_server.port(),
    };
    const result = client.requestWithValueBody(SomeJsonObj, .POST, url, obj, .{ .emit_null_optional_fields = true }) catch undefined;
    defer result.deinit();

    switch (result.value()) {
        .ok => {},
        .err => unreachable,
    }
    std.testing.expectEqualStrings("some string", result.value().ok.str) catch unreachable;
    std.testing.expectEqual(123, result.value().ok.num) catch unreachable;
}
