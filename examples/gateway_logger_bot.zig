const std = @import("std");
const zigcord = @import("zigcord");

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

    var gateway_client = try zigcord.GatewayClient.init(
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
                if (std.mem.eql(u8, msg_event.message.content, "send error")) {
                    return error.UserRestart;
                }
                std.log.info("{f}", .{std.json.fmt(msg_event, .{})});
            },
            inline else => |event_data| {
                std.log.info("{f}", .{std.json.fmt(event_data, .{})});
            },
        }
    }
}
