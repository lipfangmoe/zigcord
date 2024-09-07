const std = @import("std");
const deancord = @import("deancord");

pub const std_options: std.Options = .{ .log_level = switch (@import("builtin").mode) {
    .Debug, .ReleaseSafe => .info,
    .ReleaseFast, .ReleaseSmall => .err,
} };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const env = try std.process.getEnvMap(allocator);
    const token = env.get("TOKEN") orelse {
        std.log.err("environment variable TOKEN (set to bot token) is required", .{});
        return error.MissingEnv;
    };
    const application_id_str = env.get("APP") orelse {
        std.log.err("environment variable APP (set to application id) is required", .{});
        return error.MissingEnv;
    };
    const application_id = deancord.model.Snowflake.fromU64(try std.fmt.parseInt(u64, application_id_str, 10));

    var client = deancord.rest.Client.init(allocator, .{ .token = .{ .bot = token } });
    defer client.deinit();

    var server = try deancord.rest.Server.init(std.net.Address.initIp4(.{ 0, 0, 0, 0 }, 8080));

    const cmd_id = try createTestCommand(&client, application_id);

    while (server.receiveInteraction()) |req| {
        defer req.deinit();

        const interaction = req.interaction;
        if (interaction.type == .application_command) {
            const data = interaction.data.asSome() orelse {
                std.log.warn("data expected from application command: {}", .{std.json.fmt(interaction, .{})});
                continue;
            };
            if (data.id == cmd_id) {}
        }
    } else |err| {
        _ = err;
    }
}

fn createTestCommand(client: *deancord.rest.Client, application_id: deancord.model.Snowflake) !deancord.model.Snowflake {
    const command_result = try deancord.rest.endpoints.application_commands.createGlobalApplicationCommand(
        client,
        application_id,
        deancord.rest.endpoints.application_commands.CreateGlobalApplicationCommandBody{
            .name = "test",
            .type = .{ .some = .chat_input },
            .options = .{ .some = &.{deancord.model.interaction.command_option.ApplicationCommandOption.new(
                deancord.model.interaction.command_option.ApplicationCommandOption.Builder{ .string = deancord.model.interaction.command_option.StringOptionBuilder{
                    .name = "lol",
                    .description = "set to 'quit' to quit",
                } },
            )} },
        },
    );
    defer command_result.deinit();

    const command = switch (command_result.value()) {
        .ok => |cmd| cmd,
        .err => |discord_err| {
            std.log.err("error creating command: {}", .{std.json.fmt(discord_err, .{})});
            return error.RestError;
        },
    };

    return command.id;
}
