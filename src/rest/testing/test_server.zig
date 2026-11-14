const std = @import("std");
const builtin = @import("builtin");

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
        net_server: std.Io.net.Server,

        fn init(io: std.Io) !TestServer(S) {
            const address: std.Io.net.IpAddress = std.Io.net.IpAddress.resolve(io, "127.0.0.1", 0) catch unreachable;
            return .{ .net_server = try address.listen(io, .{ .reuse_address = true }) };
        }

        fn accept(self: *TestServer(S), io: std.Io) void {
            var reader_buf: [2048]u8 = undefined;
            var writer_buf: [2048]u8 = undefined;

            var conn = self.net_server.accept(io) catch |err| std.debug.panic("while initializing connection: {}", .{err});
            var conn_reader = conn.reader(io, &reader_buf);
            var conn_writer = conn.writer(io, &writer_buf);

            var server = std.http.Server.init(&conn_reader.interface, &conn_writer.interface);
            while (true) {
                var req = server.receiveHead() catch |err| switch (err) {
                    error.HttpConnectionClosing => break,
                    else => std.debug.panic("while receiving headers: {}", .{err}),
                };
                const response: TestResponse = S.onRequest(&req) catch |err| std.debug.panic("while calling onRequest: {}", .{err});
                req.respond(response.body, .{ .status = response.status }) catch |err| std.debug.panic("while writing request: {}", .{err});
            }
        }

        fn destroy(self: *TestServer(S), io: std.Io) void {
            self.net_server.deinit(io);
        }

        fn port(self: *const TestServer(S)) u16 {
            return self.net_server.socket.address.getPort();
        }
    };
}

pub const TestServer2 = struct {
    context: *Context,
    task: std.Io.Future(void),

    pub const Context = struct {
        net_server: std.Io.net.Server,
        response_queue_buf: [25]TestResponse,
        response_queue: std.Io.Queue(TestResponse),
    };

    pub fn init(gpa: std.mem.Allocator, io: std.Io) !TestServer2 {
        const address: std.Io.net.IpAddress = std.Io.net.IpAddress.resolve(io, "127.0.0.1", 0) catch unreachable;

        const net_server = try address.listen(io, .{ .reuse_address = true });
        errdefer net_server.deinit(io);

        const context = try gpa.create(Context);
        errdefer gpa.destroy(context);

        context.* = .{
            .net_server = net_server,
            .response_queue_buf = undefined,
            .response_queue = .init(&context.response_queue_buf),
        };

        const task = try std.Io.concurrent(io, start, .{context});
        errdefer task.cancel(io);

        return .{ .context = context, .task = task };
    }

    pub fn deinit(self: *TestServer2, gpa: std.mem.Allocator, io: std.Io) void {
        self.context.response_queue.close(io);
        self.task.cancel(io);
        gpa.destroy(self.context);
    }

    pub fn create(gpa: std.mem.Allocator, io: std.Io) !*TestServer2 {
        const address: std.Io.net.IpAddress = std.Io.net.IpAddress.resolve(io, "127.0.0.1", 0) catch unreachable;
        const server = try gpa.create(TestServer2);
        errdefer gpa.destroy(server);

        const net_server = try address.listen(io, .{ .reuse_address = true });
        errdefer net_server.deinit(io);

        const buf = try gpa.alloc(15, TestResponse);
        errdefer gpa.free(buf);

        const response_queue: std.Io.Queue(TestResponse) = .init(buf);

        server.* = .{
            .net_server = net_server,
            .response_queue = response_queue,
            .accept_task = undefined,
        };
        server.accept_task = try io.concurrent(start, .{ server, io });
        errdefer server.accept_task.cancel(io);
    }

    fn start(io: std.Io, context: *Context) void {
        var reader_buf: [2048]u8 = undefined;
        var writer_buf: [2048]u8 = undefined;

        var conn = context.net_server.accept(io) catch |err| std.debug.panic("while initializing connection: {}", .{err});
        var conn_reader = conn.reader(io, &reader_buf);
        var conn_writer = conn.writer(io, &writer_buf);

        var server = std.http.Server.init(&conn_reader.interface, &conn_writer.interface);
        while (true) {
            var req = server.receiveHead() catch |err| switch (err) {
                error.HttpConnectionClosing => break,
                else => std.debug.panic("while receiving headers: {}", .{err}),
            };
            const response = context.response_queue.getOne(io);
            req.respond(response.body, .{ .status = response.status }) catch |err| std.debug.panic("while writing request: {}", .{err});
        }
    }
};
