const std = @import("std");
const zigcord = @import("zigcord");

pub const std_options: std.Options = .{ .log_level = switch (@import("builtin").mode) {
    .Debug, .ReleaseSafe => .debug,
    .ReleaseFast, .ReleaseSmall => .err,
} };

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;
    const token = init.minimal.environ.getAlloc(allocator, "TOKEN") catch |err| {
        switch (err) {
            error.EnvironmentVariableMissing => {
                std.log.err("environment variable TOKEN is required", .{});
                return;
            },
            else => return err,
        }
    };
    defer allocator.free(token);

    var endpoint_client = zigcord.EndpointClient.init(io, allocator, .{ .bot = token });
    defer endpoint_client.deinit();

    var gateway_client = try zigcord.gateway.Client.init(
        io,
        allocator,
        token,
        zigcord.model.Intents{ .guild_messages = true, .message_content = true },
    );
    defer gateway_client.deinit();
    std.log.info("authenticated as user {f}", .{gateway_client.json_ws_client.ready_event.?.event.user.id});

    while (true) {
        const event = try gateway_client.readEvent();
        defer event.deinit();

        switch (event.event orelse continue) {
            .message_create => |msg_event| {
                std.log.info("message created with content \"{s}\"", .{msg_event.message.content});
                if (std.mem.eql(u8, msg_event.message.content, "fetch")) {
                    _ = try endpoint_client.createMessage(msg_event.message.channel_id, zigcord.EndpointClient.CreateMessageJsonBody{
                        .content = .initSome("wowie"),
                    });
                }
                if (std.mem.eql(u8, msg_event.message.content, "done")) {
                    return;
                }
            },
            else => continue,
        }
    }
}
