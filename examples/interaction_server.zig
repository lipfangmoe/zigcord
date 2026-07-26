const std = @import("std");
const zigcord = @import("zigcord");

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;

    var server: zigcord.HttpInteractionServer = try .init(io, .{ .ip4 = .loopback(8080) }, "0b5b7f244766de039bea16accfa59079e00e6869b3f25a151466b9cf1404c18b".*);
    defer server.deinit(init.io);

    const token = init.environ_map.get("TOKEN") orelse {
        std.log.err("TOKEN environment variable is required", .{});
        std.process.exit(1);
    };

    var endpoints: zigcord.EndpointClient = .init(io, init.gpa, .{ .bot = token });
    defer endpoints.deinit();

    const application_result = try endpoints.getCurrentApplication();
    defer application_result.deinit();
    const application = switch (application_result.value()) {
        .err => |err| {
            std.log.err("{f}", .{err});
            std.process.exit(1);
        },
        .ok => |ok| ok,
    };

    const echo_cmd_id = try registerEchoCommand(application.id, &endpoints);

    while (true) {
        var raw_arena: std.heap.ArenaAllocator = .init(gpa);
        defer raw_arena.deinit();
        const arena = raw_arena.allocator();

        var interaction_request = try server.receiveInteraction(arena, io);
        defer interaction_request.deinit();
        const interaction = interaction_request.interaction;

        switch (interaction.data.asSome() orelse continue) {
            .application_command => |cmd| {
                if (interaction.id == echo_cmd_id) {
                    try executeEchoCommand(&interaction_request, cmd);
                } else {
                    std.log.warn("unexpected interaction", .{});
                    continue;
                }
            },
            .message_component => |message_interaction_data| {
                switch (message_interaction_data) {
                    .button => |button_data| try handleExampleButtonClick(&interaction_request, button_data),
                    .string_select => |string_select_data| try handleExampleStringSelect(&interaction_request, string_select_data),
                    else => {
                        std.log.warn("unexpected interaction {t}", .{message_interaction_data});
                        continue;
                    },
                }
            },
            .modal_submit => |modal_submit| {
                try handleModalSubmit(&interaction_request, modal_submit);
            },
            else => continue,
        }
    }
}

fn registerEchoCommand(application_id: zigcord.model.Snowflake, endpoint_client: *zigcord.EndpointClient) !zigcord.model.Snowflake {
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
    interaction_request: *zigcord.interaction_server.InteractionRequest,
    command_data: zigcord.model.interaction.ApplicationCommandInteractionData,
) !void {
    std.log.debug("received echo v2 command", .{});

    const text_option = getOption("text", command_data.options.asSome() orelse return error.NoOptions) orelse return error.NoTextOption;
    const text_value = text_option.value.asSome() orelse return error.NoTextOption;
    const text = switch (text_value) {
        .string => |str| str,
        else => return error.InvalidTextOption,
    };

    try interaction_request.respond(.initChannelMessageWithSource(.{
        .flags = .initSome(.{ .is_components_v2 = true }),
        .components = .initSome(
            &.{
                .initTextDisplay(.{ .content = text }),
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
                    .initSecondaryButton("ghost", .{ .label = "ghost message!", .emoji = .{ .partial = .{ .name = .initSome("👻") } } }),
                    .initLinkButton("https://example.com", .{ .label = "example link" }),
                    .initDangerButton("quit", .{ .label = "quit" }),
                } }),
            },
        ),
    }));
}

fn handleExampleStringSelect(
    interaction_request: *zigcord.interaction_server.InteractionRequest,
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
        try interaction_request.respond(.initChannelMessageWithSource(.{ .content = .initSome("ur so cool ...") }));
    } else if (std.mem.eql(u8, selection, "not-cool")) {
        try interaction_request.respond(.initChannelMessageWithSource(.{ .content = .initSome("cringe!") }));
    } else {
        return error.InvalidSelection;
    }
}

const Button = enum { modal, ghost, link, quit };

fn handleExampleButtonClick(
    interaction_request: *zigcord.interaction_server.InteractionRequest,
    button_data: zigcord.model.components.Button.MessageInteractionData,
) !void {
    const button = std.meta.stringToEnum(Button, button_data.custom_id) orelse return error.InvalidButton;
    switch (button) {
        .modal => {
            std.log.info("modal button!", .{});
            try interaction_request.respond(
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
        },
        .ghost => {
            std.log.info("ghost button!", .{});
            try interaction_request.respond(.initChannelMessageWithSource(.{
                .content = .initSome("oOoooOo spooky!"),
                .flags = .initSome(.{ .ephemeral = true }),
            }));
        },
        .link => {
            const user_who_clicked = interaction_request.interaction.user.asSome() orelse return error.UserEmpty;
            const display_name = user_who_clicked.global_name orelse user_who_clicked.username;

            var buf: [1000]u8 = undefined;
            const message = try std.fmt.bufPrint(&buf, "yo {s} clicked the link lol", .{display_name});
            try interaction_request.respond(.initChannelMessageWithSource(.{
                .content = .initSome(message),
            }));
        },
        .quit => {
            try interaction_request.respond(.initChannelMessageWithSource(.{
                .content = .initSome("goodbye"),
            }));
            return error.QuitByButton;
        },
    }
}

fn handleModalSubmit(
    interaction_request: *zigcord.interaction_server.InteractionRequest,
    modal_submit: zigcord.model.interaction.ModalSubmitData,
) !void {
    const select = getComponentValue("select-message", modal_submit.components) catch return error.MissingSelectMessage;
    const extra = getComponentValue("extra-message", modal_submit.components) catch return error.MissingExtraMessage;

    var buf: [1000]u8 = undefined;
    const message = try std.fmt.bufPrint(&buf, "selected: {s}\nextra message: {s}", .{ select, extra });
    try interaction_request.respond(.initChannelMessageWithSource(.{
        .content = .initSome(message),
    }));
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
