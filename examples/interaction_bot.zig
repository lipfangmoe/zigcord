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

    var env = try std.process.getEnvMap(allocator);
    defer env.deinit();
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

    while (server.receiveInteraction(allocator)) |_req| {
        var req = _req;
        defer req.deinit();

        const interaction = req.interaction;
        if (interaction.type == .application_command) {
            const data = interaction.data.asSome() orelse {
                std.log.warn("data expected from application command: {}", .{std.json.fmt(interaction, .{})});
                continue;
            };
            const command_data = data.application_command;
            if (command_data.id.asU64() == cmd_id.asU64()) {
                if (data.application_command.options.asSome()) |options| {
                    const lol_opt = for (options) |opt| {
                        if (std.mem.eql(u8, opt.name, "lol")) break opt;
                    } else continue;
                    if (lol_opt.value.asSome()) |value| {
                        const str = switch (value) {
                            .string => |str| str,
                            else => continue,
                        };
                        if (std.mem.eql(u8, str, "quit")) {
                            break;
                        } else {
                            try req.respond(deancord.model.interaction.InteractionResponse{
                                .type = .channel_message_with_source,
                                .data = .{ .some = .{ .content = .{ .some = str } } },
                            });
                        }
                    }
                }
            }
        }
    } else |err| {
        std.log.err("error when receiving interaction: {}", .{err});
    }
}

fn createTestCommand(client: *deancord.rest.Client, application_id: deancord.model.Snowflake) !deancord.model.Snowflake {
    // TODO - this is all way too verbose.
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
