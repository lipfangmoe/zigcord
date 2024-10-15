const std = @import("std");
const deancord = @import("deancord");

pub const std_options: std.Options = .{ .log_level = switch (@import("builtin").mode) {
    .Debug, .ReleaseSafe => .info,
    .ReleaseFast, .ReleaseSmall => .err,
} };

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

    var gateway_client = try deancord.gateway.Client.init(allocator, deancord.Authorization{ .bot = token });
    defer gateway_client.deinit();

    {
        const ready_event = try gateway_client.authenticate(token, deancord.model.Intents{ .guild_messages = true, .message_content = true });
        defer ready_event.deinit();
        std.log.info("authenticated as user {}", .{ready_event.value.d.?.Ready.user.id});
    }

    while (true) {
        const parsed = try gateway_client.readEvent();
        defer parsed.deinit();
        const event = parsed.value;

        switch (event.d orelse continue) {
            .MessageCreate => |msg_event| {
                std.log.info("message created with content \"{?s}\"", .{msg_event.message.content});
                if (std.mem.eql(u8, msg_event.message.content, "done")) {
                    return;
                }
            },
            else => continue,
        }
    }
}
