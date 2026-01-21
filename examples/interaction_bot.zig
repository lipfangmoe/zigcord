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
    const echo2_id = try registerEchoV2Command(app_id, &endpoint_client);

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
                        if (cmd.id == echo2_id) {
                            try executeEchoV2Command(&endpoint_client, interaction, cmd);
                        }
                    },
                    .application_command_autocomplete => |autocomplete| {
                        if (autocomplete.id == echo_id) {
                            try executeEchoAutocomplete(&endpoint_client, interaction, autocomplete);
                        }
                    },
                    .message_component => |component_data| {
                        switch (component_data) {
                            .button => |btn| {
                                if (std.meta.stringToEnum(Button, btn.custom_id) != null) {
                                    try handleExampleV2ButtonClick(&endpoint_client, interaction, btn);
                                }
                            },
                            else => std.log.warn("hmmm we shouldn't have any components of type {t}", .{component_data}),
                        }
                    },
                    .modal_submit => |modal_submit| {
                        if (std.mem.eql(u8, modal_submit.custom_id, "button-modal")) {
                            try handleModalSubmit(&endpoint_client, interaction, modal_submit);
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

fn registerEchoV2Command(application_id: zigcord.model.Snowflake, endpoint_client: *zigcord.EndpointClient) !zigcord.model.Snowflake {
    const command_result = try endpoint_client.createGlobalApplicationCommand(application_id, .{
        .name = "echov2",
        .description = "echoes your message back to you, with cool components!",
        .options = .initSome(&.{.initStringOption(.{
            .name = "text",
            .description = "text to echo",
            .required = .initSome(true),
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

fn executeEchoV2Command(
    endpoint_client: *zigcord.EndpointClient,
    interaction: zigcord.model.interaction.Interaction,
    command_data: zigcord.model.interaction.ApplicationCommandInteractionData,
) !void {
    std.log.debug("received echo v2 command", .{});

    const text_option = getOption("text", command_data.options.asSome() orelse return error.NoOptions) orelse return error.NoTextOption;
    const text_value = text_option.value.asSome() orelse return error.NoTextOption;
    const text = switch (text_value) {
        .string => |str| str,
        else => return error.InvalidTextOption,
    };

    const result = try endpoint_client.createInteractionResponse(interaction.id, interaction.token, .initChannelMessageWithSource(.{
        .flags = .initSome(.{ .is_components_v2 = true }),
        .components = .initSome(
            &.{
                .initTextDisplay(null, .{ .content = text }),
                .initActionRow(null, .{ .components = &.{
                    .initButton(null, .initPrimaryButton("modal", .{ .label = "open modal" })),
                    .initButton(null, .initSecondaryButton("ghost", .{ .label = "ghost message!", .emoji = .{ .partial = .{ .name = .initSome("👻") } } })),
                    .initButton(null, .initLinkButton("https://example.com", .{ .label = "example link" })),
                    .initButton(null, .initDangerButton("quit", .{ .label = "quit" })),
                } }),
            },
        ),
    }));
    defer result.deinit();

    switch (result.value()) {
        .ok => std.log.debug("echoed {s} with cool buttons", .{text}),
        .err => |err| std.log.err("error! {f}", .{err}),
    }
}

const Button = enum { modal, ghost, link, quit };

fn handleExampleV2ButtonClick(
    endpoint_client: *zigcord.EndpointClient,
    interaction: zigcord.model.interaction.Interaction,
    button_data: zigcord.model.interaction.ButtonInteractionResponse,
) !void {
    const button = std.meta.stringToEnum(Button, button_data.custom_id) orelse return error.InvalidButton;
    switch (button) {
        .modal => {
            std.log.info("modal button!", .{});
            const result = try endpoint_client.createInteractionResponse(
                interaction.id,
                interaction.token,
                .initModal(.{
                    .custom_id = "button-modal",
                    .title = "Button Modal",
                    .components = &.{
                        .initLabel(null, .{
                            .label = "Select Message",
                            .component = &.initStringSelect(null, .{
                                .custom_id = "select-message",
                                .options = &.{
                                    .{ .label = "Foo", .value = "foo" },
                                    .{ .label = "Bar", .value = "bar" },
                                    .{ .label = "Baz", .value = "baz" },
                                },
                            }),
                        }),
                        .initLabel(null, .{
                            .label = "Extra Message",
                            .component = &.initTextInput(null, .{
                                .custom_id = "extra-message",
                                .style = .short,
                            }),
                        }),
                    },
                }),
            );
            defer result.deinit();

            switch (result.value()) {
                .ok => {},
                .err => |err| std.log.err("modal button error! {f}", .{err}),
            }
        },
        .ghost => {
            std.log.info("ghost button!", .{});
            const result = try endpoint_client.createInteractionResponse(interaction.id, interaction.token, .initChannelMessageWithSource(.{
                .content = .initSome("oOoooOo spooky!"),
                .flags = .initSome(.{ .ephemeral = true }),
            }));
            defer result.deinit();

            switch (result.value()) {
                .ok => {},
                .err => |err| std.log.err("modal button error! {f}", .{err}),
            }
        },
        .link => {
            const user_who_clicked = interaction.user.asSome() orelse return error.UserEmpty;
            const display_name = user_who_clicked.global_name orelse user_who_clicked.username;

            var buf: [1000]u8 = undefined;
            const message = try std.fmt.bufPrint(&buf, "yo {s} clicked the link lol", .{display_name});
            const result = try endpoint_client.createInteractionResponse(interaction.id, interaction.token, .initChannelMessageWithSource(.{
                .content = .initSome(message),
            }));
            defer result.deinit();

            switch (result.value()) {
                .ok => {},
                .err => |err| std.log.err("link button error! {f}", .{err}),
            }
        },
        .quit => {
            const result = try endpoint_client.createInteractionResponse(interaction.id, interaction.token, .initChannelMessageWithSource(.{
                .content = .initSome("goodbye"),
            }));
            defer result.deinit();

            switch (result.value()) {
                .ok => {},
                .err => |err| std.log.err("quit button error! {f}", .{err}),
            }
            return error.QuitByButton;
        },
    }
}

fn handleModalSubmit(
    endpoint_client: *zigcord.EndpointClient,
    interaction: zigcord.model.interaction.Interaction,
    modal_submit: zigcord.model.interaction.ModalSubmitData,
) !void {
    const select = getComponentValue("select-message", modal_submit.components) catch return error.MissingSelectMessage;
    const extra = getComponentValue("extra-message", modal_submit.components) catch return error.MissingExtraMessage;

    var buf: [1000]u8 = undefined;
    const message = try std.fmt.bufPrint(&buf, "selected: {s}\nextra message: {s}", .{ select, extra });
    const result = try endpoint_client.createInteractionResponse(interaction.id, interaction.token, .initChannelMessageWithSource(.{
        .content = .initSome(message),
    }));
    defer result.deinit();

    switch (result.value()) {
        .ok => {},
        .err => |err| std.log.err("modal submit error! {f}", .{err}),
    }
}

fn getOption(option_name: []const u8, options: []const zigcord.model.interaction.ApplicationCommandInteractionDataOption) ?zigcord.model.interaction.ApplicationCommandInteractionDataOption {
    for (options) |option| {
        if (std.mem.eql(u8, option.name, option_name)) {
            return option;
        }
    }

    return null;
}

fn getComponentValue(custom_id: []const u8, components: []const zigcord.model.interaction.ModalComponentInteractionResponse) ![]const u8 {
    for (components) |component| {
        s: switch (component) {
            .label => |label| {
                continue :s label.component.*;
            },
            .string_select => |select| {
                std.log.debug("{}", .{select});
                if (std.mem.eql(u8, select.custom_id, custom_id)) {
                    if (select.values.len > 0) {
                        return select.values[0];
                    } else {
                        return error.NoSelectValue;
                    }
                }
            },
            .text_input => |input| {
                std.log.debug("{}", .{input});
                if (std.mem.eql(u8, input.custom_id, custom_id)) {
                    return input.value;
                }
            },
            else => continue,
        }
    }
    return error.ComponentNotFound;
}
