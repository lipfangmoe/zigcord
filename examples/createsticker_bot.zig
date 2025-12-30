const std = @import("std");
const zigcord = @import("zigcord");

pub const std_options: std.Options = .{ .log_level = switch (@import("builtin").mode) {
    .Debug, .ReleaseSafe => .debug,
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

    const picture = std.fs.cwd().openFile("./examples/klee_small.png", .{ .mode = .read_only }) catch |err| {
        std.log.err("Failed to open sticker file: {any}", .{err});
        return;
    };
    defer picture.close();

    var buffer: [4096]u8 = undefined;
    var file_reader = picture.reader(&buffer);

    var endpoint_client = zigcord.EndpointClient.init(allocator, .{ .bot = token });
    defer endpoint_client.deinit();

    var gateway_client = try zigcord.gateway.Client.init(
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
            .MessageCreate => |msg_event| {
                const value = try endpoint_client.createGuildSticker(msg_event.guild_id.some, .{
                    .name = "sticker test",
                    .description = "fun sticker",
                    .tags = "fun",
                    .file = try .fromFileReader("klee.png", "image/png", &file_reader),
                }, null);
                defer value.deinit();
                switch (value) {
                    .ok => |ok| std.log.info("ok {f}", .{std.json.fmt(ok.value, .{})}),
                    .err => |err| std.log.info("err {f}", .{std.json.fmt(err.value, .{})}),
                }
                return;
            },
            else => continue,
        }
    }
}
