//! rest.Client is a wrapper around an http.Client which contains methods that call Discord API endpoints.

const std = @import("std");
const builtin = @import("builtin");
const shared = @import("shared");
const testing = @import("./testing.zig");
const Authorization = @import("./authorization.zig").Authorization;
const ErrorCode = @import("./JsonErrorCodes.zig").ErrorCode;

const RestClient = @This();

io: std.Io,
allocator: std.mem.Allocator,
auth: Authorization,
client: std.http.Client,
config: Config,

/// Creates a discord http client with default configuration.
///
/// Cannot be used in tests, instead use `initWithConfig` and provide a mock response from the server.
pub fn init(io: std.Io, allocator: std.mem.Allocator, auth: Authorization) RestClient {
    const config = Config{};
    return initWithConfig(io, allocator, auth, config);
}

/// Creates a discord http client based on a configuration
pub fn initWithConfig(io: std.Io, allocator: std.mem.Allocator, auth: Authorization, config: Config) RestClient {
    const client = std.http.Client{ .io = io, .allocator = allocator };
    return .{
        .io = io,
        .allocator = allocator,
        .auth = auth,
        .client = client,
        .config = config,
    };
}

pub const BeginRequestError = error{ OutOfMemory, Canceled, OpenError, RequestSendBodyError };
pub const WaitForResponseError = error{ OutOfMemory, Canceled, RequestFinishError, ResponseReceiveHeadError, ResponseReadError, ResponseJsonParseError };
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

    var defaulted_headers: std.http.Client.Request.Headers = headers orelse .{};
    if (defaulted_headers.authorization == .default) {
        defaulted_headers.authorization = .{ .override = auth_value.buffered() };
    }
    if (defaulted_headers.content_type == .default) {
        defaulted_headers.content_type = .{ .override = "application/json" };
    }

    var req = self.client.request(method, url, .{
        .headers = defaulted_headers,
        .extra_headers = extra_headers orelse &.{},
    }) catch |err| switch (err) {
        error.Canceled => return error.Canceled,
        else => return error.OpenError,
    };
    errdefer req.deinit();

    req.transfer_encoding = transfer_encoding;

    return req;
}

fn handleResponse(
    gpa: std.mem.Allocator,
    config: Config,
    comptime ResponseT: type,
    response: *std.http.Client.Response,
) WaitForResponseError!Result(ResponseT) {
    // workaround for https://codeberg.org/ziglang/zig/issues/36830
    if (response.head.status == .no_content and response.request.response_content_length == null) {
        response.request.response_content_length = 0;
    }

    const status = response.head.status;
    const status_class = status.class();
    if (ResponseT == void and status_class == .success) {
        return .{ .gpa = gpa, .arena = null, .status = status, .raw = null, .value = .{ .ok = {} } };
    }
    if (ResponseT != void and status == .no_content) {
        return error.ResponseJsonParseError;
    }

    var buf: [2000]u8 = undefined;
    var decompress: std.http.Decompress = undefined;
    const decompress_buffer: []u8 = switch (response.head.content_encoding) {
        .identity => &.{},
        .zstd => try gpa.alloc(u8, std.compress.zstd.default_window_len),
        .deflate, .gzip => try gpa.alloc(u8, std.compress.flate.max_window_len),
        .compress => return error.ResponseReadError,
    };
    defer switch (response.head.content_encoding) {
        .zstd, .deflate, .gzip => gpa.free(decompress_buffer),
        else => {},
    };
    const body_reader = response.readerDecompressing(&buf, &decompress, decompress_buffer);

    const arena = try gpa.create(std.heap.ArenaAllocator);
    errdefer gpa.destroy(arena);
    arena.* = .init(gpa);
    errdefer arena.deinit();

    if (ResponseT == RawBody) {
        _ = switch (status_class) {
            .success => {
                const body = body_reader.allocRemaining(arena.allocator(), .limited(response.head.content_length orelse @intCast(config.max_response_length))) catch return error.ResponseReadError;
                return .{
                    .gpa = gpa,
                    .arena = arena,
                    .status = status,
                    .raw = null,
                    .value = .{ .ok = .{ .body = body } },
                };
            },
            else => {
                var json_reader: std.json.Reader = .init(arena.allocator(), body_reader);
                const weak_value = std.json.parseFromTokenSourceLeaky(std.json.Value, arena.allocator(), &json_reader, .{ .allocate = .alloc_always, .max_value_len = config.max_response_length }) catch |err| return reduceJsonParseError(err);

                if (std.json.parseFromValueLeaky(DiscordError, arena.allocator(), weak_value, .{ .ignore_unknown_fields = true })) |value| {
                    return .{ .gpa = gpa, .arena = arena, .status = status, .raw = weak_value, .value = .{ .discord_err = value } };
                } else |_| {
                    return error.ResponseJsonParseError;
                }
            },
        };
    }

    var json_reader: std.json.Reader = .init(arena.allocator(), body_reader);
    const weak_value = std.json.parseFromTokenSourceLeaky(std.json.Value, arena.allocator(), &json_reader, .{ .allocate = .alloc_always, .max_value_len = config.max_response_length }) catch |err| return reduceJsonParseError(err);

    switch (status_class) {
        .success => {
            if (ResponseT != void) {
                if (std.json.parseFromValueLeaky(ResponseT, arena.allocator(), weak_value, .{ .ignore_unknown_fields = true })) |value| {
                    return .{ .gpa = gpa, .arena = arena, .status = status, .raw = weak_value, .value = .{ .ok = value } };
                } else |_| {
                    return .{ .gpa = gpa, .arena = arena, .status = status, .raw = weak_value, .value = .json_err };
                }
            } else {
                // unreachable because we have a special case for `T == void and status_class == .success` earlier
                unreachable;
            }
        },
        else => {
            if (std.json.parseFromValueLeaky(DiscordError, arena.allocator(), weak_value, .{ .ignore_unknown_fields = true })) |value| {
                return .{ .gpa = gpa, .arena = arena, .status = status, .raw = weak_value, .value = .{ .discord_err = value } };
            } else |_| {
                return .{ .gpa = gpa, .arena = arena, .status = status, .raw = weak_value, .value = .json_err };
            }
        },
    }
}

pub fn beginMultipartRequest(
    self: *RestClient,
    comptime ResponseT: type,
    method: std.http.Method,
    url: std.Uri,
    transfer_encoding: std.http.Client.Request.TransferEncoding,
    boundary: []const u8,
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
        null,
    );

    return PendingRequest(ResponseT){ .allocator = self.allocator, .request = http_request, .config = self.config };
}

pub fn beginMultipartRequestWithAuditLogReason(
    self: *RestClient,
    comptime ResponseT: type,
    method: std.http.Method,
    url: std.Uri,
    transfer_encoding: std.http.Client.Request.TransferEncoding,
    boundary: []const u8,
    buf: *[1028]u8,
    audit_log_reason: ?[]const u8,
) BeginRequestError!PendingRequest(ResponseT) {
    var fba: std.heap.FixedBufferAllocator = .init(buf);

    var extra_headers: []const std.http.Header = &.{};
    if (audit_log_reason) |reason| {
        const headers = try fba.allocator().alloc(std.http.Header, 1);
        headers[0] = .{ .name = "X-Audit-Log-Reason", .value = reason };
        extra_headers = headers;
    }

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
    var http_request = try self.setupRequest(&buf, method, url, .none, null, null);
    defer http_request.deinit();

    switch (method) {
        .GET, .DELETE => http_request.sendBodiless() catch |err| switch (err) {
            error.WriteFailed => return reduceSendRequestError(&http_request),
        },
        .POST, .PUT, .PATCH => http_request.sendBodyComplete("") catch |err| switch (err) {
            error.WriteFailed => return reduceSendRequestError(&http_request),
        },
        else => return error.RequestSendBodyError, // unsupported http method
    }

    var response = http_request.receiveHead(&.{}) catch |err| switch (err) {
        error.Canceled => return error.Canceled,
        else => return reduceReceiveHeadError(&http_request),
    };

    return try handleResponse(self.allocator, self.config, ResponseT, &response);
}

/// Sends a request to the Discord REST API with the credentials stored in this context
pub fn requestWithAuditLogReason(self: *RestClient, comptime ResponseT: type, method: std.http.Method, url: std.Uri, audit_log_reason: ?[]const u8) RequestError!Result(ResponseT) {
    const extra_headers: []const std.http.Header = if (audit_log_reason) |reason|
        &.{std.http.Header{ .name = "X-Audit-Log-Reason", .value = reason }}
    else
        &.{};

    var buf: [200]u8 = undefined;
    var http_request = try self.setupRequest(&buf, method, url, .none, null, extra_headers);
    defer http_request.deinit();

    http_request.sendBodiless() catch |err| switch (err) {
        error.WriteFailed => return reduceSendRequestError(&http_request),
    };
    var response = http_request.receiveHead(&.{}) catch |err| switch (err) {
        error.Canceled => return error.Canceled,
        else => return reduceReceiveHeadError(&http_request),
    };

    return try handleResponse(self.allocator, self.config, ResponseT, &response);
}

pub const JsonRequestError = BeginRequestError || WaitForResponseError || error{RequestJsonStringifyError};

/// Sends a request (with a body) to the Discord REST API with the credentials stored in this context.
pub fn requestWithBody(self: *RestClient, comptime ResponseT: type, method: std.http.Method, url: std.Uri, body: *std.Io.Reader, content_type: []const u8, transfer_encoding: std.http.Client.Request.TransferEncoding) RequestError!Result(ResponseT) {
    var buf: [200]u8 = undefined;
    var http_request = try self.setupRequest(&buf, method, url, transfer_encoding, .{ .content_type = .{ .override = content_type } }, null);
    defer http_request.deinit();

    http_request.sendBodyComplete(body) catch |err| switch (err) {
        error.WriteFailed => return reduceSendRequestError(&http_request),
    };
    var response = http_request.receiveHead(&.{}) catch |err| switch (err) {
        error.Canceled => return error.Canceled,
        else => return reduceReceiveHeadError(&http_request),
    };

    return try handleResponse(self.allocator, self.config, ResponseT, &response);
}

/// Sends a request (with a body) to the Discord REST API with the credentials stored in this context.
pub fn requestWithBodyAndAuditLogReason(self: *RestClient, comptime ResponseT: type, method: std.http.Method, url: std.Uri, body: *std.Io.Reader, content_type: []const u8, transfer_encoding: std.http.Client.Request.TransferEncoding, audit_log_reason: ?[]const u8) RequestError!Result(ResponseT) {
    const extra_headers: []const std.http.Header = if (audit_log_reason) |reason|
        &.{std.http.Header{ .name = "X-Audit-Log-Reason", .value = reason }}
    else
        &.{};

    var buf: [200]u8 = undefined;
    var http_request = try self.setupRequest(&buf, method, url, transfer_encoding, .{ .content_type = .{ .override = content_type } }, extra_headers);
    defer http_request.deinit();

    http_request.sendBodyComplete(body) catch |err| switch (err) {
        error.WriteFailed => return reduceSendRequestError(&http_request),
    };
    var response = http_request.receiveHead(&.{}) catch |err| switch (err) {
        error.Canceled => return error.Canceled,
        else => return reduceReceiveHeadError(&http_request),
    };

    return try handleResponse(self.allocator, self.config, ResponseT, &response);
}

/// Sends a request (with a body) to the Discord REST API with the credentials stored in this context.
pub fn requestWithJsonBody(self: *RestClient, comptime ResponseT: type, method: std.http.Method, url: std.Uri, body: anytype, stringify_options: std.json.Stringify.Options) JsonRequestError!Result(ResponseT) {
    const stringified_body = std.json.Stringify.valueAlloc(self.allocator, body, stringify_options) catch return error.RequestJsonStringifyError;
    defer self.allocator.free(stringified_body);

    var buf: [200]u8 = undefined;
    var http_request = try self.setupRequest(&buf, method, url, .{ .content_length = stringified_body.len }, null, null);
    defer http_request.deinit();

    http_request.sendBodyComplete(stringified_body) catch |err| switch (err) {
        error.WriteFailed => return reduceSendRequestError(&http_request),
    };
    var response = http_request.receiveHead(&.{}) catch |err| switch (err) {
        error.Canceled => return error.Canceled,
        else => return reduceReceiveHeadError(&http_request),
    };

    return try handleResponse(self.allocator, self.config, ResponseT, &response);
}

/// Sends a request (with a body) to the Discord REST API with the credentials stored in this context.
pub fn requestWithJsonBodyAndAuditLogReason(
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

    http_request.sendBodyComplete(stringified_body) catch |err| switch (err) {
        error.WriteFailed => return reduceSendRequestError(&http_request),
    };
    var response = http_request.receiveHead(&.{}) catch |err| switch (err) {
        error.Canceled => return error.Canceled,
        else => return reduceReceiveHeadError(&http_request),
    };

    return try handleResponse(self.allocator, self.config, ResponseT, &response);
}

pub fn deinit(self: *RestClient) void {
    self.client.deinit();
}

pub const Config = struct {
    pub const default_user_agent = std.fmt.comptimePrint("DiscordBot (https://codeberg.org/lipfang/zigcord, {f})", .{shared.version});

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

fn reduceSendRequestError(req: *const std.http.Client.Request) BeginRequestError {
    // try to forward a `error.Canceled` if possible
    if (req.connection) |conn| {
        if (conn.stream_writer.err) |err2| {
            switch (err2) {
                error.Canceled => return error.Canceled,
                else => {},
            }
        }
    }

    return error.RequestSendBodyError;
}

fn reduceReceiveHeadError(req: *const std.http.Client.Request) WaitForResponseError {
    // try to forward a `error.Canceled` if possible
    if (req.connection) |conn| {
        if (conn.stream_reader.err) |err2| {
            switch (err2) {
                error.Canceled => return error.Canceled,
                else => {},
            }
        }
    }

    return error.ResponseReceiveHeadError;
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
            const result = try handleResponse(self.allocator, self.config, T, &response);
            return result;
        }
    };
}

pub fn Result(T: type) type {
    return struct {
        gpa: std.mem.Allocator,
        arena: ?*std.heap.ArenaAllocator,
        status: std.http.Status,
        raw: ?std.json.Value,
        value: union(enum) {
            ok: T,
            discord_err: DiscordError,
            json_err: void,
        },

        pub fn format(self: @This(), writer: *std.Io.Writer) !void {
            switch (self.value) {
                .ok => |ok| try writer.print(if (@hasDecl(T, "format")) "{f}" else "{}", .{ok}),
                .discord_err => |err| try writer.print("{f}", err),
                .json_err => try writer.print("{f}", .{std.json.fmt(self.raw, .{})}),
            }
        }

        /// converts the Result's .value into an error union, returning the unwrapped value if its ok,
        /// and otherwise returns an error
        pub fn valueOk(self: Result(T)) error{ DiscordError, JsonError }!T {
            return switch (self.value) {
                .ok => |ok| ok,
                .discord_err => error.DiscordError,
                .json_err => error.JsonError,
            };
        }

        /// similar to `valueOk()`, but logs additional information on error.
        pub fn expectOk(self: Result(T), context_on_error: []const u8) error{ DiscordError, JsonError }!T {
            return switch (self.value) {
                .ok => |ok| ok,
                .discord_err => |err| {
                    const error_code = @backingInt(err.code);
                    shared.logger.err("{s}: {d} ({s})\n{f}", .{ context_on_error, error_code, err.message, err });
                    return error.DiscordError;
                },
                .json_err => |err| {
                    shared.logger.err("{s}: the following response does not conform to zigcord's `{s}` type:\n{f}", .{ context_on_error, @typeName(T), std.json.fmt(err, .{}) });
                    return error.JsonError;
                },
            };
        }

        /// similar to `valueOk()`, but logs additional information on error. Allows a fmt-string to be passed in as the context string.
        pub fn expectOkFmt(self: Result(T), comptime context_on_error_fmt: []const u8, fmt_args: anytype) error{ DiscordError, JsonError }!T {
            return switch (self) {
                .ok => |ok| ok.value,
                .discord_err => |err| {
                    const error_code = @backingInt(err.code);
                    shared.logger.err(context_on_error_fmt ++ ": {d} ({s})\n{f}", fmt_args ++ .{ error_code, err.value.message, err });
                    return error.DiscordError;
                },
                .json_err => {
                    shared.logger.err(context_on_error_fmt ++ ": the following response does not conform to zigcord's `{s}` type:\n{f}", fmt_args ++ .{ @typeName(T), std.json.fmt(self.raw, .{}) });
                    return error.JsonError;
                },
            };
        }

        pub fn deinit(self: Result(T)) void {
            if (self.arena) |arena| {
                arena.deinit();
                self.gpa.destroy(arena);
            }
        }
    };
}

pub const DiscordError = struct {
    code: Code = .general_error,
    message: []const u8 = "unknown message",
    errors: std.json.Value = .null,
    other_fields: std.json.ArrayHashMap(std.json.Value) = .{},

    pub const Code = ErrorCode;

    pub fn format(self: DiscordError, w: *std.Io.Writer) !void {
        try w.print("{f}", .{std.json.fmt(self, .{})});
    }

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

/// Can be used in place of ResponseT to be supplied with the raw value for the response rather than a json-parsed one.
pub const RawBody = struct {
    body: []const u8,
};

const SomeJsonObj = struct {
    str: []const u8,
    num: f64,
};

test "request parses response body" {
    const gpa = std.testing.allocator;
    const io = std.testing.io;

    var server: testing.TestServer = try .init(gpa, io);
    defer server.deinit(gpa, io);

    const body =
        \\{"str":"some string","num":123}
    ;

    const expected_request_body = "";
    try server.queueResponse(io, .{
        .expected_request_method = .GET,
        .expected_request_path = "/api/v10/lol",
        .expected_request_body = expected_request_body,
        .body = body,
    });

    var client = init(io, gpa, .{ .bot = "sometoken" });
    defer client.deinit();

    const url = try server.url(gpa, "/api/v10/lol");
    defer gpa.free(url);
    const uri: std.Uri = try .parse(url);

    const result = try client.request(SomeJsonObj, .GET, uri);
    defer result.deinit();

    const expected: SomeJsonObj = .{ .str = "some string", .num = 123 };
    try std.testing.expectEqualDeep(expected, result.value.ok);
    try std.testing.expectEqual(std.http.Status.ok, result.status);
}

test "requestWithJsonBody stringifies struct request body" {
    const gpa = std.testing.allocator;
    const io = std.testing.io;

    var server: testing.TestServer = try .init(gpa, io);
    defer server.deinit(gpa, io);

    const body =
        \\{"str":"some string","num":123}
    ;

    const expected_request_body =
        \\{"str":"lol lmao","num":42}
    ;
    try server.queueResponse(io, .{
        .expected_request_method = .POST,
        .expected_request_path = "/api/v10/lol",
        .expected_request_body = expected_request_body,
        .body = body,
    });

    var client = init(io, gpa, .{ .bot = "sometoken" });
    defer client.deinit();

    const url = try server.url(gpa, "/api/v10/lol");
    defer gpa.free(url);
    const uri: std.Uri = try .parse(url);

    const obj = SomeJsonObj{
        .str = "lol lmao",
        .num = 42,
    };

    const result = try client.requestWithJsonBody(SomeJsonObj, .POST, uri, obj, .{ .emit_null_optional_fields = true });
    defer result.deinit();

    const value = try result.valueOk();
    var expected_raw_value_map: std.json.ObjectMap = try .init(
        std.testing.allocator,
        &.{ "str", "num" },
        &.{ .{ .string = "some string" }, .{ .integer = 123 } },
    );
    const expected_raw_value: std.json.Value = .{ .object = expected_raw_value_map };
    defer expected_raw_value_map.deinit(std.testing.allocator);

    try testing.expectEqualJsonValues(expected_raw_value, result.raw.?);
    try std.testing.expectEqualStrings("some string", value.str);
    try std.testing.expectEqual(123, value.num);
}

test "requestWithJsonBody jsonError in response" {
    const gpa = std.testing.allocator;
    const io = std.testing.io;

    var server: testing.TestServer = try .init(gpa, io);
    defer server.deinit(gpa, io);

    const body =
        \\{"str":"some string","num":"this is a string, not a number!"}
    ;
    const expected_request_body =
        \\{"str":"lol lmao","num":42}
    ;

    try server.queueResponse(io, .{
        .expected_request_method = .POST,
        .expected_request_path = "/api/v10/lol",
        .expected_request_body = expected_request_body,
        .body = body,
    });

    var client = init(io, gpa, .{ .bot = "sometoken" });
    defer client.deinit();

    const url = try server.url(gpa, "/api/v10/lol");
    defer gpa.free(url);
    const uri: std.Uri = try .parse(url);

    const obj = SomeJsonObj{
        .str = "lol lmao",
        .num = 42,
    };

    const response = try client.requestWithJsonBody(SomeJsonObj, .POST, uri, obj, .{ .emit_null_optional_fields = true });
    defer response.deinit();

    try std.testing.expectEqualStrings("json_err", @tagName(response.value));
    try std.testing.expectEqualStrings("some string", response.raw.?.object.get("str").?.string);
    try std.testing.expectEqualStrings("this is a string, not a number!", response.raw.?.object.get("num").?.string);
}

test "requestWithJsonBody with non-json response" {
    const gpa = std.testing.allocator;
    const io = std.testing.io;

    var server: testing.TestServer = try .init(gpa, io);
    defer server.deinit(gpa, io);

    const body = "this is not json";
    try server.queueResponse(io, .{ .body = body });

    var client = init(io, gpa, .{ .bot = "sometoken" });
    defer client.deinit();

    const url = try server.url(gpa, "/");
    defer gpa.free(url);
    const uri: std.Uri = try .parse(url);

    const obj = SomeJsonObj{
        .str = "lol lmao",
        .num = 42,
    };

    const response_err_union = client.requestWithJsonBody(SomeJsonObj, .POST, uri, obj, .{ .emit_null_optional_fields = true });
    defer if (response_err_union) |r| r.deinit() else |_| {};

    try std.testing.expectError(error.ResponseReadError, response_err_union);
}

test "request with non-json response (expected)" {
    const gpa = std.testing.allocator;
    const io = std.testing.io;

    var server: testing.TestServer = try .init(gpa, io);
    defer server.deinit(gpa, io);

    const body = "this is a raw response body";
    try server.queueResponse(io, .{ .body = body });

    var client = init(io, gpa, .{ .bot = "sometoken" });
    defer client.deinit();

    const url = try server.url(gpa, "/");
    defer gpa.free(url);
    const uri: std.Uri = try .parse(url);

    const obj: SomeJsonObj = .{
        .str = "lol lmao",
        .num = 42,
    };

    const result = try client.requestWithJsonBody(RawBody, .POST, uri, obj, .{ .emit_null_optional_fields = true });
    defer result.deinit();
    const response = try result.valueOk();

    const expected_raw: ?std.json.Value = null;
    try std.testing.expectEqual(expected_raw, result.raw);
    try std.testing.expectEqualStrings("this is a raw response body", response.body);
}
