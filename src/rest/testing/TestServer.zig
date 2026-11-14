const std = @import("std");
const builtin = @import("builtin");

const TestServer = @This();

pub const Response = struct {
    expected_request_method: ?std.http.Method = null,
    expected_request_path: ?[]const u8 = null,
    expected_request_body: ?[]const u8 = null,

    response_status: std.http.Status = .ok,
    body: []const u8,
};

context: *Context,
task: std.Io.Future(void),

pub const ResponseError = error{ TestExpectedEqualMethod, TestExpectedEqualPath, TestExpectedEqualBody };

pub const Context = struct {
    net_server: std.Io.net.Server,
    response_queue_buf: [25]Response,
    response_queue: std.Io.Queue(Response),
};

pub fn init(gpa: std.mem.Allocator, io: std.Io) !TestServer {
    const address: std.Io.net.IpAddress = std.Io.net.IpAddress.resolve(io, "127.0.0.1", 0) catch unreachable;

    var net_server = try address.listen(io, .{ .reuse_address = true });
    errdefer net_server.deinit(io);

    const context = try gpa.create(Context);
    errdefer gpa.destroy(context);

    context.* = .{
        .net_server = net_server,
        .response_queue_buf = undefined,
        .response_queue = .init(&context.response_queue_buf),
    };

    const task = try std.Io.concurrent(io, start, .{ gpa, io, context });
    errdefer task.cancel(io);

    return .{ .context = context, .task = task };
}

pub fn url(self: TestServer, gpa: std.mem.Allocator, suffix: []const u8) ![]const u8 {
    const ip = self.context.net_server.socket.address;
    return try gpa.print("http://{f}{s}", .{ ip, suffix });
}

pub fn deinit(self: *TestServer, gpa: std.mem.Allocator, io: std.Io) void {
    self.context.response_queue.close(io);
    self.task.cancel(io);
    self.context.net_server.deinit(io);
    gpa.destroy(self.context);
}

pub fn queueResponse(self: *TestServer, io: std.Io, response: Response) !void {
    try self.context.response_queue.putOne(io, response);
}

fn start(gpa: std.mem.Allocator, io: std.Io, context: *Context) void {
    var conn_reader_buf: [2048]u8 = undefined;
    var conn_writer_buf: [2048]u8 = undefined;

    var conn = context.net_server.accept(io) catch |err| switch (err) {
        error.Canceled => {
            std.log.warn("server canceled during initialization", .{});
            return;
        },
        else => std.debug.panic("while initializing connection: {}", .{err}),
    };
    defer conn.close(io);

    var conn_reader = conn.reader(io, &conn_reader_buf);
    var conn_writer = conn.writer(io, &conn_writer_buf);

    var server: std.http.Server = .init(&conn_reader.interface, &conn_writer.interface);
    while (true) {
        const response = context.response_queue.getOne(io) catch |err| switch (err) {
            error.Canceled, error.Closed => return,
        };

        var req = server.receiveHead() catch |err| switch (err) {
            else => {
                std.log.warn("i/o error receiving headers: {}", .{err});
                return;
            },
        };

        var body_writer_buf: [1000]u8 = undefined;
        if (response.expected_request_method) |expected_method| {
            std.testing.expectEqual(expected_method, req.head.method) catch {
                req.respond("error", .{ .status = .internal_server_error }) catch @panic("io");
                return;
            };
        }
        if (response.expected_request_path) |expected_path| {
            std.testing.expectEqualStrings(expected_path, req.head.target) catch {
                req.respond("error", .{ .status = .internal_server_error }) catch @panic("io");
                return;
            };
        }
        if (response.expected_request_body) |expected_request_body| {
            const body_reader = req.readerExpectNone(&body_writer_buf);
            const request_body = body_reader.allocRemaining(gpa, .limited(10_000_000)) catch @panic("oom/io");
            defer gpa.free(request_body);

            std.testing.expectEqualStrings(expected_request_body, request_body) catch {
                req.respond("error", .{ .status = .internal_server_error }) catch @panic("io");
                return;
            };
        } else {
            var body_reader_buf: [100]u8 = undefined;
            const body_reader = req.readerExpectNone(&body_reader_buf);
            _ = body_reader.discardRemaining() catch @panic("io");
        }

        req.respond(response.body, .{ .status = response.response_status }) catch |err| std.debug.panic("while writing request: {}", .{err});
    }
}

fn surroundings(str: []const u8, idx: usize) []const u8 {
    const window_size = 10;
    const begin: usize = if (idx < window_size) 0 else idx - window_size;
    const end: usize = if (idx > str.len - window_size) str.len else idx + window_size;

    return str[begin..end];
}
