const std = @import("std");
const zigcord = @import("../root.zig");
const jconfig = zigcord.jconfig;
const model = zigcord.model;
const rest = zigcord.rest;
const Snowflake = model.Snowflake;

pub const command = @import("./interaction/command.zig");
pub const command_option = @import("./interaction/command_option.zig");

pub const Interaction = struct {
    id: Snowflake,
    application_id: Snowflake,
    type: InteractionType,
    data: jconfig.Omittable(InteractionData) = .omit,
    guild: jconfig.Omittable(model.guild.PartialGuild) = .omit,
    guild_id: jconfig.Omittable(Snowflake) = .omit,
    channel: jconfig.Omittable(jconfig.Partial(model.Channel)) = .omit,
    channel_id: jconfig.Omittable(Snowflake) = .omit,
    member: jconfig.Omittable(model.guild.Member) = .omit,
    user: jconfig.Omittable(model.User) = .omit,
    token: []const u8,
    version: i64,
    message: jconfig.Omittable(model.Message) = .omit,
    app_permissions: model.Permissions,
    locale: jconfig.Omittable([]const u8) = .omit,
    guild_locale: jconfig.Omittable([]const u8) = .omit,
    entitlements: []const model.Entitlement,
    authorizing_integration_owners: std.json.ArrayHashMap(model.Snowflake),
    context: jconfig.Omittable(Context) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
    pub fn jsonParseFromValue(allocator: std.mem.Allocator, source: std.json.Value, options: std.json.ParseOptions) std.json.ParseFromValueError!Interaction {
        const obj = switch (source) {
            .object => |obj| obj,
            else => return error.UnexpectedToken,
        };

        var interaction: Interaction = undefined;

        inline for (comptime std.meta.fields(Interaction)) |field| {
            if (comptime std.mem.eql(u8, field.name, "data")) {
                continue;
            }
            if (obj.get(field.name)) |value| {
                @field(interaction, field.name) = try std.json.innerParseFromValue(field.type, allocator, value, options);
            } else if (field.default_value_ptr) |value_ptr| {
                const value: *const field.type = @ptrCast(@alignCast(value_ptr));
                @field(interaction, field.name) = value.*;
            } else {
                return error.MissingField;
            }
        }

        if (obj.get("data")) |data_value| {
            switch (interaction.type) {
                inline else => |interaction_type| {
                    const data_type_name = @tagName(interaction_type);
                    const DataT = @FieldType(InteractionData, data_type_name);
                    if (DataT == void) {
                        interaction.data = .omit;
                    } else {
                        interaction.data = .initSome(@unionInit(InteractionData, data_type_name, try std.json.innerParseFromValue(DataT, allocator, data_value, options)));
                    }
                },
            }
        } else {
            interaction.data = .omit;
        }

        return interaction;
    }
    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) std.json.ParseError(@TypeOf(source.*))!Interaction {
        const value = try std.json.innerParse(std.json.Value, allocator, source, options);
        return try jsonParseFromValue(allocator, value, options);
    }
};

pub const InteractionType = enum(u8) {
    application_command = 2,
    message_component = 3,
    application_command_autocomplete = 4,
    modal_submit = 5,
    ping = 1, // `ping` at the end because otherwise InlineUnionMixin will always deserialize into `void`

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};

pub const InteractionData = union(InteractionType) {
    application_command: ApplicationCommandInteractionData,
    message_component: MessageComponentData,
    application_command_autocomplete: ApplicationCommandInteractionData,
    modal_submit: ModalSubmitData,
    ping: void, // `ping` at the end because otherwise InlineUnionMixin will always deserialize into `void`

    const Mixin = jconfig.InlineUnionMixin(@This());
    pub const jsonStringify = Mixin.jsonStringify;
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;
};

pub const ApplicationCommandInteractionData = struct {
    id: Snowflake,
    name: []const u8,
    type: command.ApplicationCommandType,
    resolved: jconfig.Omittable(ResolvedData) = .omit,
    options: jconfig.Omittable([]const ApplicationCommandInteractionDataOption) = .omit,
    guild_id: jconfig.Omittable(model.Snowflake) = .omit,
    target_id: jconfig.Omittable(model.Snowflake) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ApplicationCommandInteractionDataOption = struct {
    name: []const u8,
    type: command.ApplicationCommandType,
    value: jconfig.Omittable(Value) = .omit,
    options: jconfig.Omittable([]const ApplicationCommandInteractionDataOption) = .omit,
    focused: jconfig.Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const Value = union(enum) {
        string: []const u8,
        int: i64,
        double: f64,
        boolean: bool,

        const Mixin = jconfig.InlineUnionMixin(@This());
        pub const jsonStringify = Mixin.jsonStringify;
        pub const jsonParse = Mixin.jsonParse;
        pub const jsonParseFromValue = Mixin.jsonParseFromValue;
    };
};

pub const MessageComponentData = struct {
    custom_id: []const u8,
    component_type: model.MessageComponent.Type,
    values: jconfig.Omittable(model.MessageComponent.StringSelect.Option) = .omit,
    resolved: jconfig.Omittable(ResolvedData) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ModalSubmitData = struct {
    custom_id: []const u8,
    components: []const model.MessageComponent,
};

pub const ResolvedData = struct {
    users: jconfig.Omittable(std.json.ArrayHashMap(model.User)) = .omit,
    members: jconfig.Omittable(std.json.ArrayHashMap(InteractionMember)) = .omit,
    roles: jconfig.Omittable(std.json.ArrayHashMap(model.Role)) = .omit,
    channels: jconfig.Omittable(std.json.ArrayHashMap(jconfig.Partial(model.Channel))) = .omit,
    messages: jconfig.Omittable(std.json.ArrayHashMap(model.Message)) = .omit,
    attachments: jconfig.Omittable(std.json.ArrayHashMap(model.Message.Attachment)) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const InteractionMember = struct {
    nick: jconfig.Omittable(?[]const u8) = .omit,
    avatar: jconfig.Omittable(?[]const u8) = .omit,
    roles: []Snowflake,
    joined_at: model.IsoTime,
    premium_since: jconfig.Omittable(?model.IsoTime) = .omit,
    flags: model.guild.Member.Flags,
    pending: jconfig.Omittable(bool) = .omit,
    permissions: jconfig.Omittable([]const u8) = .omit,
    communication_disabled_until: jconfig.Omittable(?model.IsoTime) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const InteractionResponse = union(Type) {
    pong: void,
    channel_message_with_source: InteractionCallbackMessage,
    deferred_channel_message_with_source: InteractionCallbackMessage,
    deferred_update_message: InteractionCallbackMessage,
    update_message: InteractionCallbackMessage,
    application_command_autocomplete_result: InteractionCallbackAutocompleteAny,
    modal: InteractionCallbackModal,
    launch_activity: void,

    pub fn jsonStringify(self: InteractionResponse, jw: *std.json.Stringify) std.json.Stringify.Error!void {
        try jw.beginObject();

        try jw.objectField("type");
        try jw.write(@intFromEnum(std.meta.activeTag(self)));

        switch (self) {
            inline else => |prong| {
                if (@TypeOf(prong) != void) {
                    try jw.objectField("data");
                    try jw.write(prong);
                }
            },
        }
        try jw.endObject();
    }

    pub fn initPong() InteractionResponse {
        return .pong;
    }

    pub fn initChannelMessageWithSource(data: InteractionCallbackMessage) InteractionResponse {
        return .{ .channel_message_with_source = data };
    }

    pub fn initDeferredChannelMessageWithSource(data: InteractionCallbackMessage) InteractionResponse {
        return .{ .deferred_channel_message_with_source = data };
    }

    pub fn initDeferredUpdateMessage(data: InteractionCallbackMessage) InteractionResponse {
        return .{ .deferred_update_message = data };
    }

    pub fn initUpdateMessage(data: InteractionCallbackMessage) InteractionResponse {
        return .{ .update_message = data };
    }

    pub fn initApplicationCommandAutocompleteResultString(data: InteractionCallbackAutocompleteString) InteractionResponse {
        return .{ .application_command_autocomplete_result = .{ .string = data } };
    }

    pub fn initApplicationCommandAutocompleteResultInteger(data: InteractionCallbackAutocompleteInteger) InteractionResponse {
        return .{ .application_command_autocomplete_result = .{ .integer = data } };
    }

    pub fn initApplicationCommandAutocompleteResultDouble(data: InteractionCallbackAutocompleteDouble) InteractionResponse {
        return .{ .application_command_autocomplete_result = .{ .double = data } };
    }

    pub fn initModal(data: InteractionCallbackModal) InteractionResponse {
        return .{ .modal = data };
    }

    pub fn initLaunchActivity() InteractionResponse {
        return .launch_activity;
    }

    pub const Type = enum(u8) {
        pong = 1,
        channel_message_with_source = 4,
        deferred_channel_message_with_source = 5,
        deferred_update_message = 6,
        update_message = 7,
        application_command_autocomplete_result = 8,
        modal = 9,
        launch_activity = 12,

        pub const jsonStringify = jconfig.stringifyEnumAsInt;
    };
};

pub const InteractionCallbackAny = union(enum) {
    message: InteractionCallbackMessage,
    modal: InteractionCallbackModal,
    autocomplete: InteractionCallbackAutocompleteAny,

    const Mixin = jconfig.InlineUnionMixin(InteractionCallbackAny);
    pub const jsonStringify = Mixin.jsonStringify;
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;
};

pub const InteractionCallbackMessage = struct {
    tts: jconfig.Omittable(bool) = .omit,
    content: jconfig.Omittable([]const u8) = .omit,
    embeds: jconfig.Omittable([]const model.Message.Embed) = .omit,
    allowed_mentions: jconfig.Omittable(model.Message.AllowedMentions) = .omit,
    flags: jconfig.Omittable(model.Message.Flags) = .omit,
    components: jconfig.Omittable([]const model.MessageComponent) = .omit,
    attachments: jconfig.Omittable([]const jconfig.Partial(model.Message.Attachment)) = .omit,
    poll: jconfig.Omittable(model.Poll) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const InteractionCallbackModal = struct {
    custom_id: []const u8,
    title: []const u8,
    components: []const model.MessageComponent,
};

pub const InteractionCallbackAutocompleteAny = union(enum) {
    string: InteractionCallbackAutocompleteString,
    integer: InteractionCallbackAutocompleteInteger,
    double: InteractionCallbackAutocompleteDouble,

    const Mixin = jconfig.InlineUnionMixin(InteractionCallbackAutocompleteAny);
    pub const jsonStringify = Mixin.jsonStringify;
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;
};

pub const InteractionCallbackAutocompleteString = struct {
    choices: []const command_option.StringChoice,
};

pub const InteractionCallbackAutocompleteInteger = struct {
    choices: []const command_option.IntegerChoice,
};

pub const InteractionCallbackAutocompleteDouble = struct {
    choices: []const command_option.DoubleChoice,
};

pub const Context = enum(u2) {
    guild = 0,
    bot_dm = 1,
    private_channel = 2,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};
