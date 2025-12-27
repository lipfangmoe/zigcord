//! rest.Client is a wrapper around an http.Client which contains methods that call Discord API endpoints.

const std = @import("std");
const builtin = @import("builtin");
const zigcord = @import("../root.zig");
const ErrorCode = @import("./JsonErrorCodes.zig").ErrorCode;

const RestClient = @This();

allocator: std.mem.Allocator,
auth: zigcord.Authorization,
client: std.http.Client,
config: Config,

/// Creates a discord http client with default configuration.
///
/// Cannot be used in tests, instead use `initWithConfig` and provide a mock response from the server.
pub fn init(allocator: std.mem.Allocator, auth: zigcord.Authorization) RestClient {
    const config = Config{};
    return initWithConfig(allocator, auth, config);
}

/// Creates a discord http client based on a configuration
pub fn initWithConfig(allocator: std.mem.Allocator, auth: zigcord.Authorization, config: Config) RestClient {
    const client = std.http.Client{ .allocator = allocator };
    return .{
        .allocator = allocator,
        .auth = auth,
        .client = client,
        .config = config,
    };
}

pub const BeginRequestError = error{ OutOfMemory, OpenError, RequestSendBodyError };
pub const WaitForResponseError = error{ OutOfMemory, RequestFinishError, ResponseReceiveHeadError, ResponseReadError, ResponseJsonParseError };
pub const RequestError = BeginRequestError || WaitForResponseError;

fn setupRequest(
    self: *RestClient,
    auth_value_buf: *[200]u8,
    method: std.http.Method,
    url: std.Uri,
    transfer_encoding: std.http.Client.Request.TransferEncoding,
    headers: ?std.http.Client.Request.Headers,
    extra_headers: ?[]const std.http.Header,
) BeginRequestError!std.http.Client.Request {
    var auth_value = std.Io.Writer.fixed(auth_value_buf);
    auth_value.print("{f}", .{self.auth}) catch return error.OutOfMemory;

    var defaulted_headers = headers orelse std.http.Client.Request.Headers{};
    if (defaulted_headers.authorization == .default) {
        defaulted_headers.authorization = .{ .override = auth_value.buffered() };
    }
    if (defaulted_headers.content_type == .default) {
        defaulted_headers.content_type = .{ .override = "application/json" };
    }

    var req = self.client.request(method, url, std.http.Client.RequestOptions{
        .headers = defaulted_headers,
        .extra_headers = extra_headers orelse &.{},
    }) catch return error.OpenError;
    errdefer req.deinit();

    req.transfer_encoding = transfer_encoding;

    return req;
}

fn handleResponse(
    allocator: std.mem.Allocator,
    config: Config,
    comptime ResponseT: type,
    response: *std.http.Client.Response,
) WaitForResponseError!Result(ResponseT) {
    const status = response.head.status;
    const status_class = status.class();
    if (ResponseT == void and status_class == .success) {
        return Result(ResponseT){ .ok = .{ .status = status, .value = void{}, .parsed = null } };
    }
    if (ResponseT != void and status == .no_content) {
        return error.ResponseJsonParseError;
    }

    var buf: [2000]u8 = undefined;
    var decompress: std.http.Decompress = undefined;
    const decompress_buffer: []u8 = switch (response.head.content_encoding) {
        .identity => &.{},
        .zstd => try allocator.alloc(u8, std.compress.zstd.default_window_len),
        .deflate, .gzip => try allocator.alloc(u8, std.compress.flate.max_window_len),
        .compress => return error.ResponseReadError,
    };
    const body_reader = response.readerDecompressing(&buf, &decompress, decompress_buffer);
    var json_reader = std.json.Reader.init(allocator, body_reader);
    defer json_reader.deinit();

    const value = switch (status_class) {
        .success => blk: {
            if (ResponseT != void) {
                const parsed = std.json.parseFromTokenSource(ResponseT, allocator, &json_reader, .{ .ignore_unknown_fields = true, .max_value_len = config.max_response_length }) catch |err| return reduceJsonParseError(err);
                break :blk Result(ResponseT){ .ok = .{ .status = status, .value = parsed.value, .parsed = parsed } };
            } else {
                // unreachable because we have a special case for `T == void and status_class == .success` earlier
                unreachable;
            }
        },
        else => blk: {
            const parsed = std.json.parseFromTokenSource(DiscordError, allocator, &json_reader, .{ .ignore_unknown_fields = true, .max_value_len = config.max_response_length }) catch |err| return reduceJsonParseError(err);
            break :blk Result(ResponseT){ .err = .{ .status = status, .value = parsed.value, .parsed = parsed } };
        },
    };

    return value;
}

pub fn beginMultipartRequest(
    self: *RestClient,
    comptime ResponseT: type,
    method: std.http.Method,
    url: std.Uri,
    transfer_encoding: std.http.Client.Request.TransferEncoding,
    boundary: []const u8,
    extra_headers: ?[]const std.http.Header,
    buf: *[1028]u8,
) BeginRequestError!PendingRequest(ResponseT) {
    var fba: std.heap.FixedBufferAllocator = .init(buf);
    var content_type: std.Io.Writer.Allocating = .init(fba.allocator());
    content_type.writer.print("multipart/form-data; boundary={s}", .{boundary}) catch return std.mem.Allocator.Error.OutOfMemory;

    const http_request = try self.setupRequest(
        try fba.allocator().create([200]u8),
        method,
        url,
        transfer_encoding,
        std.http.Client.Request.Headers{ .content_type = .{ .override = content_type.written() } },
        extra_headers,
    );

    return PendingRequest(ResponseT){ .allocator = self.allocator, .request = http_request, .config = self.config };
}

/// Sends a request to the Discord REST API with the credentials stored in this context
pub fn request(self: *RestClient, comptime ResponseT: type, method: std.http.Method, url: std.Uri) RequestError!Result(ResponseT) {
    var buf: [200]u8 = undefined;
    var http_request = try self.setupRequest(&buf, method, url, .{ .none = void{} }, null, null);
    defer http_request.deinit();

    switch (method) {
        .GET, .DELETE => http_request.sendBodiless() catch return error.RequestSendBodyError,
        .POST, .PUT, .PATCH => http_request.sendBodyComplete("") catch return error.RequestSendBodyError,
        else => return error.RequestSendBodyError, // unsupported http method
    }

    var response = http_request.receiveHead(&.{}) catch return error.ResponseReceiveHeadError;

    return try handleResponse(self.allocator, self.config, ResponseT, &response);
}

/// Sends a request to the Discord REST API with the credentials stored in this context
pub fn requestWithAuditLogReason(self: *RestClient, comptime ResponseT: type, method: std.http.Method, url: std.Uri, audit_log_reason: ?[]const u8) RequestError!Result(ResponseT) {
    const extra_headers: []const std.http.Header = if (audit_log_reason) |reason|
        &.{std.http.Header{ .name = "X-Audit-Log-Reason", .value = reason }}
    else
        &.{};

    var buf: [200]u8 = undefined;
    var http_request = try self.setupRequest(&buf, method, url, .{ .none = void{} }, null, extra_headers);
    defer http_request.deinit();

    http_request.sendBodiless() catch return error.RequestSendBodyError;
    var response = http_request.receiveHead(&.{}) catch return error.ResponseReceiveHeadError;

    return try handleResponse(self.allocator, self.config, ResponseT, &response);
}

pub const JsonRequestError = BeginRequestError || WaitForResponseError || error{RequestJsonStringifyError};

/// Sends a request (with a body) to the Discord REST API with the credentials stored in this context.
pub fn requestWithValueBody(self: *RestClient, comptime ResponseT: type, method: std.http.Method, url: std.Uri, body: anytype, stringify_options: std.json.Stringify.Options) JsonRequestError!Result(ResponseT) {
    const stringified_body = std.json.Stringify.valueAlloc(self.allocator, body, stringify_options) catch return error.RequestJsonStringifyError;
    defer self.allocator.free(stringified_body);

    var buf: [200]u8 = undefined;
    var http_request = try self.setupRequest(&buf, method, url, .{ .content_length = stringified_body.len }, null, null);
    defer http_request.deinit();

    http_request.sendBodyComplete(stringified_body) catch return error.RequestSendBodyError;
    var response = http_request.receiveHead(&.{}) catch return error.ResponseReceiveHeadError;

    return try handleResponse(self.allocator, self.config, ResponseT, &response);
}

pub fn requestWithValueBodyAndAuditLogReason(
    self: *RestClient,
    comptime ResponseT: type,
    method: std.http.Method,
    url: std.Uri,
    body: anytype,
    stringify_options: std.json.Stringify.Options,
    audit_log_reason: ?[]const u8,
) JsonRequestError!Result(ResponseT) {
    const extra_headers: []const std.http.Header = if (audit_log_reason) |reason|
        &.{std.http.Header{ .name = "X-Audit-Log-Reason", .value = reason }}
    else
        &.{};

    const stringified_body = std.json.Stringify.valueAlloc(self.allocator, body, stringify_options) catch return error.RequestJsonStringifyError;
    defer self.allocator.free(stringified_body);

    var buf: [200]u8 = undefined;
    var http_request = try self.setupRequest(&buf, method, url, .{ .content_length = stringified_body.len }, null, extra_headers);
    defer http_request.deinit();

    http_request.sendBodyComplete(stringified_body) catch return error.RequestSendBodyError;
    var response = http_request.receiveHead(&.{}) catch return error.ResponseReceiveHeadError;

    return try handleResponse(self.allocator, self.config, ResponseT, &response);
}

pub fn deinit(self: *RestClient) void {
    self.client.deinit();
}

pub const Config = struct {
    pub const default_user_agent = std.fmt.comptimePrint("DiscordBot (https://codeberg.org/lipfang/zigcord, {f})", .{zigcord.version});

    /// 1mb seems fair since all discord api responses should be text, with urls for anything large.
    /// surely they don't respond with more than 1 million characters... Clueless
    max_response_length: usize = 1_000_000,

    /// Allows customizing the user agent string. You are advised to keep the default value as a prefix (see https://discord.com/developers/docs/reference#user-agent)
    user_agent: []const u8 = default_user_agent,
};

const RawJsonParseError = std.json.ParseError(std.json.Reader);
fn reduceJsonParseError(err: RawJsonParseError) WaitForResponseError {
    switch (err) {
        error.EndOfStream,
        error.SyntaxError,
        error.UnexpectedEndOfInput,
        error.ValueTooLong,
        error.ReadFailed,
        => return error.ResponseReadError,
        error.OutOfMemory,
        error.Overflow,
        error.InvalidCharacter,
        error.UnexpectedToken,
        error.InvalidNumber,
        error.InvalidEnumTag,
        error.DuplicateField,
        error.UnknownField,
        error.MissingField,
        error.LengthMismatch,
        => return error.ResponseJsonParseError,
    }
}

pub fn PendingRequest(comptime T: type) type {
    return struct {
        allocator: std.mem.Allocator,
        request: std.http.Client.Request,
        config: Config,

        /// Waits for the server to return its response.
        pub fn waitForResponse(self: *PendingRequest(T)) WaitForResponseError!Result(T) {
            defer self.request.deinit();
            var response = self.request.receiveHead(&.{}) catch return error.ResponseReceiveHeadError;
            const result = handleResponse(self.allocator, self.config, T, &response);
            return result;
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
    code: Code = .general_error,
    message: []const u8 = "unknown message",
    errors: std.json.Value = std.json.Value{ .null = void{} },
    other_fields: std.json.ArrayHashMap(std.json.Value) = .{},

    pub const Code = ErrorCode;

    pub fn jsonStringify(self: DiscordError, jw: *std.json.Stringify) !void {
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
                        discord_error.code = try std.json.innerParse(Code, alloc, source, options);
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
                discord_error.code = try std.json.innerParseFromValue(Code, alloc, source, options);
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

        fn start(self: *TestServer(S)) void {
            var reader_buf: [2048]u8 = undefined;
            var writer_buf: [2048]u8 = undefined;

            var conn = self.net_server.accept() catch |err| std.debug.panic("while initializing connection: {}", .{err});
            var conn_reader = conn.stream.reader(&reader_buf);
            var conn_writer = conn.stream.writer(&writer_buf);

            var server = std.http.Server.init(conn_reader.interface(), &conn_writer.interface);
            while (true) {
                var req = server.receiveHead() catch |err| switch (err) {
                    error.HttpConnectionClosing => break,
                    else => std.debug.panic("while receiving headers: {}", .{err}),
                };
                const response: TestResponse = S.onRequest(&req) catch |err| std.debug.panic("while calling onRequest: {}", .{err});
                req.respond(response.body, .{ .status = response.status }) catch |err| std.debug.panic("while writing request: {}", .{err});
            }
        }

        fn destroy(self: *TestServer(S)) void {
            self.net_server.deinit();
            self.server_thread.join();
            std.testing.allocator.destroy(self);
        }

        fn port(self: *const TestServer(S)) u16 {
            return self.net_server.listen_address.in.getPort();
        }
    };
}
fn createTestServer(S: type) !*TestServer(S) {
    if (builtin.single_threaded) return error.SkipZigTest;

    const address = try std.net.Address.resolveIp("127.0.0.1", 0);
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
            try std.testing.expectEqual(.GET, req.head.method);
            try std.testing.expectEqualStrings("/api/v10/lol", req.head.target);

            var body_buf: [100]u8 = undefined;
            var body_reader = req.readerExpectNone(&body_buf);
            const body = try body_reader.allocRemaining(std.testing.allocator, .limited(1000));
            defer std.testing.allocator.free(body);

            try std.testing.expectEqualStrings("", body);

            return TestResponse{
                .status = std.http.Status.ok,
                .body = "{\"str\":\"some string\",\"num\":123}",
            };
        }
    });
    defer test_server.destroy();

    var client = init(allocator, .{ .bot = "sometoken" });
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
            try std.testing.expectEqual(.POST, req.head.method);
            try std.testing.expectEqualStrings("/api/v10/lol", req.head.target);

            var body_buf: [1000]u8 = undefined;
            var body_reader = req.readerExpectNone(&body_buf);
            const body = try body_reader.allocRemaining(std.testing.allocator, .unlimited);
            defer std.testing.allocator.free(body);
            try std.testing.expectEqualStrings("{\"str\":\"lol lmao\",\"num\":42}", body);

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

    var client = init(allocator, .{ .bot = "sometoken" });
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

test "requestWithValueBody jsonError in response" {
    const allocator = std.testing.allocator;

    const test_server = try createTestServer(struct {
        pub fn onRequest(req: *std.http.Server.Request) !TestResponse {
            try std.testing.expectEqual(.POST, req.head.method);
            try std.testing.expectEqualStrings("/api/v10/lol", req.head.target);

            var buf: [1000]u8 = undefined;
            const body_reader = req.readerExpectNone(&buf);
            var body_buf: [100]u8 = undefined;
            var body = std.Io.Writer.fixed(&body_buf);
            _ = try body_reader.stream(&body, .unlimited);

            try std.testing.expectEqualStrings("{\"str\":\"lol lmao\",\"num\":42}", body.buffered());

            return TestResponse{
                .status = std.http.Status.ok,
                .body = "{\"str\":\"some string\",\"num\":\"this is a string, not a number!\"}",
            };
        }
    });
    defer test_server.destroy();

    const obj = SomeJsonObj{
        .str = "lol lmao",
        .num = 42,
    };

    var client = init(allocator, .{ .bot = "sometoken" });
    defer client.deinit();

    const url = std.Uri{
        .host = .{ .raw = "127.0.0.1" },
        .path = .{ .raw = "/api/v10/lol" },
        .scheme = "http",
        .port = test_server.port(),
    };
    const err = client.requestWithValueBody(SomeJsonObj, .POST, url, obj, .{ .emit_null_optional_fields = true });
    try std.testing.expectError(error.ResponseJsonParseError, err);
}
