const std = @import("std");
const zigcord = @import("zigcord");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .stack_trace_frames = if (std.debug.sys_can_stack_trace) 100 else 0 }){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const token = std.process.getEnvVarOwned(allocator, "TOKEN") catch |err| {
        switch (err) {
            error.EnvironmentVariableNotFound => {
                std.log.err("environment variable TOKEN is required", .{});
                return;
            },
            else => return err,
        }
    };
    defer allocator.free(token);

    var gateway_client = try zigcord.GatewayClient.init(
        allocator,
        token,
        zigcord.model.Intents{ .guild_messages = true, .message_content = true },
    );
    defer gateway_client.deinit();
    std.log.info("authenticated as user {}", .{gateway_client.json_ws_client.ready_event.?.event.user.id});

    while (true) {
        const event = try gateway_client.readEvent();
        defer event.deinit();

        switch (event.event orelse continue) {
            .MessageCreate => |msg_event| {
                if (std.mem.eql(u8, msg_event.message.content, "send error")) {
                    return error.UserRestart;
                }
                std.log.info("{}", .{std.json.fmt(msg_event, .{})});
            },
            inline else => |event_data| {
                std.log.info("{}", .{std.json.fmt(event_data, .{})});
            },
        }
    }
}
