const std = @import("std");
const deancord = @import("deancord");

pub const std_options: std.Options = .{ .log_level = switch (@import("builtin").mode) {
    .Debug => .debug,
    .ReleaseSafe => .info,
    .ReleaseFast, .ReleaseSmall => .err,
} };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var env = try std.process.getEnvMap(allocator);
    defer env.deinit();

    const application_public_key = env.get("APPLICATION_PUBLIC_KEY") orelse {
        std.log.err("environment variable APPLICATION_PUBLIC_KEY is required", .{});
        return error.MissingEnv;
    };
    const token = env.get("TOKEN") orelse {
        std.log.err("environment variable TOKEN (set to bot token) is required", .{});
        return error.MissingEnv;
    };
    const application_id_str = env.get("APPLICATION_ID") orelse {
        std.log.err("environment variable APPLICATION_ID is required", .{});
        return error.MissingEnv;
    };
    const port_str = env.get("PORT") orelse "8080";
    const port = std.fmt.parseInt(u16, port_str, 10) catch {
        std.log.err("environment variable PORT must be a number", .{});
        return error.InvalidEnv;
    };
    const application_id = deancord.model.Snowflake.fromU64(try std.fmt.parseInt(u64, application_id_str, 10));

    var client = deancord.rest.Client.init(allocator, .{ .token = .{ .bot = token } });
    defer client.deinit();

    var server = try deancord.rest.Server.init(std.net.Address.initIp4(.{ 0, 0, 0, 0 }, port), application_public_key[0..64].*);

    const cmd_id = try createTestCommand(&client, application_id);

    while (true) {
        var req = server.receiveInteraction(allocator) catch |err| {
            std.log.err("error when receiving interaction: {}", .{err});
            const trace = @errorReturnTrace() orelse continue;
            std.debug.dumpStackTrace(trace.*);
            continue;
        };
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
    }
}

fn createTestCommand(client: *deancord.rest.Client, application_id: deancord.model.Snowflake) !deancord.model.Snowflake {
    // TODO - this is all way too verbose.
    const command_result = try deancord.rest.endpoints.createGlobalApplicationCommand(
        client,
        application_id,
        deancord.rest.endpoints.CreateGlobalApplicationCommandBody{
            .name = "test",
            .type = .{ .some = .chat_input },
            .description = "test",
            .options = .{ .some = &.{deancord.model.interaction.command_option.ApplicationCommandOption.new(
                .{ .string = deancord.model.interaction.command_option.StringOptionBuilder{ .name = "weee", .description = "wowie!" } },
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
