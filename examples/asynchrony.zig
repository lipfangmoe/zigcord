const std = @import("std");
const zigcord = @import("zigcord");

pub const std_options: std.Options = .{ .log_level = switch (@import("builtin").mode) {
    .Debug, .ReleaseSafe => .debug,
    .ReleaseFast, .ReleaseSmall => .err,
} };

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;
    const token = init.environ_map.get("TOKEN") orelse {
        std.log.err("environment variable TOKEN is required", .{});
        std.process.exit(1);
    };

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
                if (std.mem.eql(u8, msg_event.message.content, "race")) {
                    const SelectT = union(enum) {
                        a: void,
                        b: void,
                        c: void,
                        d: void,
                        e: void,
                        f: void,
                        g: void,
                        h: void,
                        i: void,
                        j: void,
                    };
                    var buf: [1]SelectT = undefined;
                    var select: std.Io.Select(SelectT) = .init(io, &buf);

                    const channel_id = msg_event.message.channel_id;
                    std.log.info("racing!", .{});

                    try select.concurrent(.a, sendMessage, .{ &endpoint_client, channel_id, "a wins" });
                    try select.concurrent(.b, sendMessage, .{ &endpoint_client, channel_id, "b wins" });
                    try select.concurrent(.c, sendMessage, .{ &endpoint_client, channel_id, "c wins" });
                    try select.concurrent(.d, sendMessage, .{ &endpoint_client, channel_id, "d wins" });
                    try select.concurrent(.e, sendMessage, .{ &endpoint_client, channel_id, "e wins" });
                    try select.concurrent(.f, sendMessage, .{ &endpoint_client, channel_id, "f wins" });
                    try select.concurrent(.g, sendMessage, .{ &endpoint_client, channel_id, "g wins" });
                    try select.concurrent(.h, sendMessage, .{ &endpoint_client, channel_id, "h wins" });
                    try select.concurrent(.i, sendMessage, .{ &endpoint_client, channel_id, "i wins" });
                    try select.concurrent(.j, sendMessage, .{ &endpoint_client, channel_id, "j wins" });

                    _ = try select.await();
                    select.cancelDiscard();
                }
                if (std.mem.eql(u8, msg_event.message.content, "done")) {
                    return;
                }
            },
            else => continue,
        }
    }
}

fn sendMessage(endpoint_client: *zigcord.EndpointClient, channel_id: zigcord.model.Snowflake, content: []const u8) void {
    const lmao = endpoint_client.createMessage(channel_id, .{ .content = .initSome(content) }) catch |err| {
        std.log.err("error {} while printing [{s}]", .{ err, content });
        return;
    };
    lmao.deinit();
}
