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
    const app_id = gateway_client.getReadyEvent().application.id;
    std.log.info("authenticated as user {f}", .{gateway_client.json_ws_client.ready_event.?.event.user.id});

    const echo_id = try registerEchoCommand(app_id, &endpoint_client);

    while (true) {
        const event = try gateway_client.readEvent();
        defer event.deinit();

        switch (event.event orelse continue) {
            .interaction_create => |interaction| {
                switch (interaction.data.asSome() orelse continue) {
                    .application_command => |cmd| {
                        if (cmd.id == echo_id) {
                            const create_response = try endpoint_client.createInteractionResponse(interaction.id, interaction.token, .initChannelMessageWithSource(.{ .content = .initSome("lmao") }));
                            create_response.deinit();
                            try init.io.sleep(.fromSeconds(2), .boot);
                            const delete_response = try endpoint_client.deleteOriginalInteractionResponse(interaction.id, interaction.token);
                            delete_response.deinit();
                            try endpoint_client.createMessage();
                        }
                    },
                    else => continue,
                }
            },
            else => continue,
        }
    }
}

fn registerEchoCommand(application_id: zigcord.model.Snowflake, endpoint_client: *zigcord.EndpointClient) !zigcord.model.Snowflake {
    const command_result = try endpoint_client.createGlobalApplicationCommand(application_id, .{
        .name = "echo",
        .description = "echoes your message back to you",
        .options = .initSome(&.{.initStringOption(.{
            .name = "text",
            .description = "text to echo",
            .required = .initSome(true),
            .autocomplete = .initSome(true),
        })}),
    });
    defer command_result.deinit();

    const command = switch (command_result.value()) {
        .ok => |ok| ok,
        .err => |err| {
            std.log.err("error: {f}", .{std.json.fmt(err, .{})});
            return error.DiscordError;
        },
    };
    return command.id;
}
