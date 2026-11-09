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

    var endpoint_client: zigcord.EndpointClient = .init(io, allocator, .{ .bot = token });
    defer endpoint_client.deinit();

    var gateway_client: zigcord.GatewayClient = try .init(
        io,
        allocator,
        token,
        .{ .guild_messages = true, .message_content = true },
    );
    defer gateway_client.deinit();
    const app_id = gateway_client.getReadyEvent().application.id;
    std.log.info("authenticated as user {f}", .{gateway_client.json_ws_client.ready_event.?.event.user.id});

    const echo_id = try registerEchoCommand(app_id, &endpoint_client);
    const echo2_id = try registerEchoV2Command(app_id, &endpoint_client);

    while (true) {
        const event = try gateway_client.readEvent();
        defer event.deinit();

        switch (event.event orelse continue) {
            .interaction_create => |interaction| {
                switch (interaction.data orelse continue) {
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
                                try handleExampleV2ButtonClick(&endpoint_client, interaction, btn);
                            },
                            .string_select => |string_select| {
                                try handleExampleV2StringSelect(&endpoint_client, interaction, string_select);
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

fn registerEchoCommand(application_id: zigcord.model.Snowflake, endpoint_client: *zigcord.EndpointClient) !zigcord.model.Snowflake {
    const command_result = try endpoint_client.createGlobalApplicationCommand(application_id, .{
        .name = "echo",
        .description = "echoes your message back to you",
        .options = &.{.initStringOption(.{
            .name = "text",
            .description = "text to echo",
            .required = true,
            .autocomplete = true,
        })},
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
        .options = &.{.initStringOption(.{
            .name = "text",
            .description = "text to echo",
            .required = true,
        })},
    });
    defer command_result.deinit();
    const command = try command_result.expectOk("error while creating echo v2 command");

    return command.id;
}

fn executeEchoCommand(
    endpoint_client: *zigcord.EndpointClient,
    interaction: zigcord.model.interaction.Interaction,
    command_data: zigcord.model.interaction.ApplicationCommandInteractionData,
) !void {
    std.log.debug("received echo command", .{});

    const text_option = getOption("text", command_data.options orelse return error.NoOptions) orelse return error.NoTextOption;
    const text_value = text_option.value orelse return error.NoTextOption;
    const text = switch (text_value) {
        .string => |str| str,
        else => return error.InvalidTextOption,
    };

    const result = try endpoint_client.createInteractionResponse(interaction.id, interaction.token, .initChannelMessageWithSource(.{ .content = text }));
    defer result.deinit();
    _ = try result.expectOk("error while creating echo command interaction response");

    std.log.debug("echoed {s}", .{text});
}

const echo_autocompletes = [_][]const u8{ "aaaab", "aaabb", "aabbb", "abbbb", "bbbbb" };

fn executeEchoAutocomplete(
    endpoint_client: *zigcord.EndpointClient,
    interaction: zigcord.model.interaction.Interaction,
    autocomplete_data: zigcord.model.interaction.ApplicationCommandInteractionData,
) !void {
    std.log.debug("received echo autocomplete", .{});

    const text_option = getOption("text", autocomplete_data.options orelse return error.NoOptions) orelse return error.NoTextOption;
    const text_value = text_option.value orelse return error.NoTextOption;
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
    _ = try result.expectOk("error while creating echo autocomplete response");
}

fn executeEchoV2Command(
    endpoint_client: *zigcord.EndpointClient,
    interaction: zigcord.model.interaction.Interaction,
    command_data: zigcord.model.interaction.ApplicationCommandInteractionData,
) !void {
    std.log.debug("received echo v2 command", .{});

    const text_option = getOption("text", command_data.options orelse return error.NoOptions) orelse return error.NoTextOption;
    const text_value = text_option.value orelse return error.NoTextOption;
    const text = switch (text_value) {
        .string => |str| str,
        else => return error.InvalidTextOption,
    };

    const result = try endpoint_client.createInteractionResponse(interaction.id, interaction.token, .initChannelMessageWithSource(.{
        .flags = .{ .is_components_v2 = true },
        .components = &.{
            .initText(text),
            .initActionRow(.{ .components = &.{
                .initStringSelect(.{
                    .custom_id = "string_select",
                    .options = &.{
                        .{ .label = "Very Cool!", .value = "cool" },
                        .{ .label = "Not cool.", .value = "not-cool" },
                    },
                }),
            } }),
            .initActionRow(.{ .components = &.{
                .initPrimaryButton("modal", .{ .label = "open modal" }),
                .initSecondaryButton("ghost", .{ .label = "ghost message!", .emoji = .{ .name = .initSome("👻") } }),
                .initLinkButton("https://example.com", .{ .label = "example link" }),
                .initDangerButton("quit", .{ .label = "quit" }),
            } }),
        },
    }));
    defer result.deinit();

    _ = try result.expectOk("error while creating echov2 interaction response");

    std.log.debug("echoed {s} with cool buttons", .{text});
}

fn handleExampleV2StringSelect(
    endpoint_client: *zigcord.EndpointClient,
    interaction: zigcord.model.interaction.Interaction,
    select_data: zigcord.model.components.StringSelect.MessageInteractionData,
) !void {
    if (!std.mem.eql(u8, select_data.custom_id, "string_select")) {
        return error.InvalidSelect;
    }
    const selection = switch (select_data.values.len) {
        1 => select_data.values[0],
        else => return error.InvalidSelection,
    };
    if (std.mem.eql(u8, selection, "cool")) {
        const result = try endpoint_client.createInteractionResponse(interaction.id, interaction.token, .initChannelMessageWithSource(.{ .content = "ur so cool ..." }));
        defer result.deinit();
        _ = try result.expectOk("error while creating cool stringselect response");
    } else if (std.mem.eql(u8, selection, "not-cool")) {
        const result = try endpoint_client.createInteractionResponse(interaction.id, interaction.token, .initChannelMessageWithSource(.{ .content = "cringe!" }));
        defer result.deinit();
        _ = try result.expectOk("error while creating not-cool stringselect response");
    } else {
        return error.InvalidSelection;
    }
}

const Button = enum { modal, ghost, link, quit };

fn handleExampleV2ButtonClick(
    endpoint_client: *zigcord.EndpointClient,
    interaction: zigcord.model.interaction.Interaction,
    button_data: zigcord.model.components.Button.MessageInteractionData,
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
                        .initLabel(.{
                            .label = "Select Message",
                            .component = .initStringSelect(.{
                                .custom_id = "select-message",
                                .options = &.{
                                    .{ .label = "Foo", .value = "foo" },
                                    .{ .label = "Bar", .value = "bar" },
                                    .{ .label = "Baz", .value = "baz" },
                                },
                            }),
                        }),
                        .initLabel(.{
                            .label = "Extra Message",
                            .component = .initTextInput(.{
                                .custom_id = "extra-message",
                                .style = .short,
                            }),
                        }),
                    },
                }),
            );
            defer result.deinit();

            _ = try result.expectOk("modal button error");
        },
        .ghost => {
            std.log.info("ghost button!", .{});
            const result = try endpoint_client.createInteractionResponse(interaction.id, interaction.token, .initChannelMessageWithSource(.{
                .content = "oOoooOo spooky!",
                .flags = .{ .ephemeral = true },
            }));
            defer result.deinit();
            _ = try result.expectOk("ghost button error");
        },
        .link => {
            const user_who_clicked = interaction.user orelse return error.UserEmpty;
            const display_name = user_who_clicked.global_name orelse user_who_clicked.username;

            var buf: [1000]u8 = undefined;
            const message = try std.fmt.bufPrint(&buf, "yo {s} clicked the link lol", .{display_name});
            const result = try endpoint_client.createInteractionResponse(interaction.id, interaction.token, .initChannelMessageWithSource(.{
                .content = message,
            }));
            defer result.deinit();
            _ = try result.expectOk("link button error");
        },
        .quit => {
            const result = try endpoint_client.createInteractionResponse(interaction.id, interaction.token, .initChannelMessageWithSource(.{
                .content = "goodbye",
            }));
            defer result.deinit();
            _ = try result.expectOk("quit button error");
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
        .content = message,
    }));
    defer result.deinit();
    _ = try result.expectOk("modal submit error");
}

fn getOption(option_name: []const u8, options: []const zigcord.model.interaction.ApplicationCommandInteractionDataOption) ?zigcord.model.interaction.ApplicationCommandInteractionDataOption {
    for (options) |option| {
        if (std.mem.eql(u8, option.name, option_name)) {
            return option;
        }
    }

    return null;
}

fn getComponentValue(custom_id: []const u8, components: []const zigcord.model.components.TopLevelModalComponent.InteractionData) ![]const u8 {
    for (components) |component| {
        const label = switch (component) {
            .label => |label| label,
        };
        switch (label.component) {
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
