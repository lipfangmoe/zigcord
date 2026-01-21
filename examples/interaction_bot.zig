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

    const token = try getEnvVarOwned(allocator, "TOKEN");
    defer allocator.free(token);

    const app_id_str = try getEnvVarOwned(allocator, "APP_ID");
    defer allocator.free(app_id_str);
    const app_id: zigcord.model.Snowflake = try .fromString(app_id_str);

    var endpoint_client = zigcord.EndpointClient.init(allocator, .{ .bot = token });
    defer endpoint_client.deinit();

    var gateway_client = try zigcord.gateway.Client.init(
        allocator,
        token,
        zigcord.model.Intents{ .guild_messages = true, .message_content = true },
    );
    defer gateway_client.deinit();
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
                            try executeEchoCommand(&endpoint_client, interaction, cmd);
                        }
                    },
                    .application_command_autocomplete => |autocomplete| {
                        if (autocomplete.id == echo_id) {
                            try executeEchoAutocomplete(&endpoint_client, interaction, autocomplete);
                        }
                    },
                    else => continue,
                }
            },
            else => continue,
        }
    }
}

fn getEnvVarOwned(allocator: std.mem.Allocator, name: []const u8) ![]const u8 {
    return std.process.getEnvVarOwned(allocator, name) catch |err| {
        switch (err) {
            error.EnvironmentVariableNotFound => {
                std.log.err("environment variable {s} is required", .{name});
                std.process.exit(1);
            },
            else => return err,
        }
    };
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

fn executeEchoCommand(
    endpoint_client: *zigcord.EndpointClient,
    interaction: zigcord.model.interaction.Interaction,
    command_data: zigcord.model.interaction.ApplicationCommandInteractionData,
) !void {
    std.log.debug("received echo command", .{});

    const text_option = getOption("text", command_data.options.asSome() orelse return error.NoOptions) orelse return error.NoTextOption;
    const text_value = text_option.value.asSome() orelse return error.NoTextOption;
    const text = switch (text_value) {
        .string => |str| str,
        else => return error.InvalidTextOption,
    };

    const result = try endpoint_client.createInteractionResponse(interaction.id, interaction.token, .initChannelMessageWithSource(.{ .content = .initSome(text) }));
    defer result.deinit();

    std.log.debug("echoed {s}", .{text});
}

const echo_autocompletes = [_][]const u8{ "aaaab", "aaabb", "aabbb", "abbbb", "bbbbb" };

fn executeEchoAutocomplete(
    endpoint_client: *zigcord.EndpointClient,
    interaction: zigcord.model.interaction.Interaction,
    autocomplete_data: zigcord.model.interaction.ApplicationCommandInteractionData,
) !void {
    std.log.debug("received echo autocomplete", .{});

    const text_option = getOption("text", autocomplete_data.options.asSome() orelse return error.NoOptions) orelse return error.NoTextOption;
    const text_value = text_option.value.asSome() orelse return error.NoTextOption;
    const text = switch (text_value) {
        .string => |str| str,
        else => return error.InvalidTextOption,
    };

    std.log.debug("partial option: {s}", .{text});

    var filtered_echoes_buf: [echo_autocompletes.len]zigcord.model.interaction.command_option.StringChoice = undefined;
    var filtered_echoes: std.ArrayList(zigcord.model.interaction.command_option.StringChoice) = .initBuffer(&filtered_echoes_buf);
    for (echo_autocompletes) |echo| {
        if (std.mem.startsWith(u8, echo, text)) {
            std.log.debug("valid option: {s}", .{echo});
            try filtered_echoes.appendBounded(.{ .name = echo, .value = echo });
        }
    }

    const result = try endpoint_client.createInteractionResponse(interaction.id, interaction.token, .initApplicationCommandAutocompleteResultString(.{ .choices = filtered_echoes.items }));
    defer result.deinit();
}

fn getOption(option_name: []const u8, options: []const zigcord.model.interaction.ApplicationCommandInteractionDataOption) ?zigcord.model.interaction.ApplicationCommandInteractionDataOption {
    for (options) |option| {
        if (std.mem.eql(u8, option.name, option_name)) {
            return option;
        }
    }

    return null;
}
