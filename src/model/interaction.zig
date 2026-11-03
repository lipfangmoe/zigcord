const std = @import("std");
const jconfig = @import("jconfig");
const logger = @import("shared").logger;
const guild = @import("./guild.zig");
const Snowflake = @import("./snowflake.zig").Snowflake;
const User = @import("./User.zig");
const Channel = @import("./Channel.zig");
const Message = @import("./Message.zig");
const Permissions = @import("./permissions.zig").Permissions;
const Entitlement = @import("./Entitlement.zig");
const components = @import("./components.zig");
const Role = @import("./Role.zig");
const IsoTime = @import("./IsoTime.zig");
const Poll = @import("./Poll.zig");

pub const command = @import("./interaction/command.zig");
pub const command_option = @import("./interaction/command_option.zig");

pub const Interaction = struct {
    id: Snowflake,
    application_id: Snowflake,
    type: InteractionType,
    data: ?InteractionData = null,
    guild: ?guild.PartialGuild = null,
    guild_id: ?Snowflake = null,
    channel: ?jconfig.Partial(Channel) = null,
    channel_id: ?Snowflake = null,
    member: ?guild.Member = null,
    user: ?User = null,
    token: []const u8,
    version: i64,
    message: ?Message = null,
    app_permissions: Permissions,
    locale: ?[]const u8 = null,
    guild_locale: ?[]const u8 = null,
    entitlements: []const Entitlement,
    authorizing_integration_owners: std.json.ArrayHashMap(Snowflake),
    context: ?Context = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
    pub fn jsonParseFromValue(allocator: std.mem.Allocator, source: std.json.Value, options: std.json.ParseOptions) std.json.ParseFromValueError!Interaction {
        const obj = switch (source) {
            .object => |obj| obj,
            else => return error.UnexpectedToken,
        };

        var interaction: Interaction = undefined;
        const interaction_typeinfo = @typeInfo(Interaction).@"struct";
        inline for (interaction_typeinfo.field_names, interaction_typeinfo.field_types, interaction_typeinfo.field_attrs) |field_name, FieldType, field_attrs| {
            if (comptime std.mem.eql(u8, field_name, "data")) {
                continue;
            }
            if (obj.get(field_name)) |value| {
                @field(interaction, field_name) = try std.json.innerParseFromValue(FieldType, allocator, value, options);
            } else if (field_attrs.default_value_ptr) |value_ptr| {
                const value: *const FieldType = @ptrCast(@alignCast(value_ptr));
                @field(interaction, field_name) = value.*;
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
                        interaction.data = null;
                    } else {
                        interaction.data = @unionInit(InteractionData, data_type_name, try std.json.innerParseFromValue(DataT, allocator, data_value, options));
                    }
                },
            }
        } else {
            interaction.data = null;
        }

        return interaction;
    }
    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) std.json.ParseError(@TypeOf(source.*))!Interaction {
        const value = try std.json.innerParse(std.json.Value, allocator, source, options);
        return try jsonParseFromValue(allocator, value, options);
    }
};

pub const InteractionType = enum(u8) {
    ping = 1,
    application_command = 2,
    message_component = 3,
    application_command_autocomplete = 4,
    modal_submit = 5,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};

pub const InteractionData = union(InteractionType) {
    ping: void,
    application_command: ApplicationCommandInteractionData,
    message_component: components.TopLevelMessageComponent.InteractionData,
    application_command_autocomplete: ApplicationCommandInteractionData,
    modal_submit: ModalSubmitData,

    const Mixin = jconfig.InlineUnionMixin(@This());
    pub const jsonStringify = Mixin.jsonStringify;
    // jsonParse/jsonParseFromValue are not needed since inline parsing is handled by Interaction
};

pub const ApplicationCommandInteractionData = struct {
    id: Snowflake,
    name: []const u8,
    type: command.ApplicationCommandType,
    resolved: ?ResolvedData = null,
    options: ?[]const ApplicationCommandInteractionDataOption = null,
    guild_id: ?Snowflake = null,
    target_id: ?Snowflake = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ApplicationCommandInteractionDataOption = struct {
    name: []const u8,
    type: command_option.ApplicationCommandOptionType,
    value: ?Value = null,
    options: ?[]const ApplicationCommandInteractionDataOption = null,
    focused: ?bool = null,

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

pub const ModalSubmitData = struct {
    custom_id: []const u8,
    components: []const components.TopLevelModalComponent.InteractionData,
    resolved: ?ResolvedData = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ResolvedData = struct {
    users: ?std.json.ArrayHashMap(User) = null,
    members: ?std.json.ArrayHashMap(InteractionMember) = null,
    roles: ?std.json.ArrayHashMap(Role) = null,
    channels: ?std.json.ArrayHashMap(Channel) = null,
    messages: ?std.json.ArrayHashMap(Message) = null,
    attachments: ?std.json.ArrayHashMap(Message.Attachment) = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const InteractionMember = struct {
    nick: jconfig.Omittable(?[]const u8) = .omit,
    avatar: jconfig.Omittable(?[]const u8) = .omit,
    roles: []Snowflake,
    joined_at: IsoTime,
    premium_since: jconfig.Omittable(?IsoTime) = .omit,
    flags: guild.Member.Flags,
    pending: ?bool = null,
    permissions: ?[]const u8 = null,
    communication_disabled_until: jconfig.Omittable(?IsoTime) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const InteractionCallback = union(Type) {
    pong: InteractionCallbackPong,
    channel_message_with_source: ChannelMessageWithSource,
    deferred_channel_message_with_source: DeferredChannelMessageWithSource,
    deferred_update_message: DeferredUpdateMessage,
    update_message: UpdateMessage,
    application_command_autocomplete_result: AnyInteractionCallbackAutocomplete,
    modal: ModalInteractionCallback,
    launch_activity: void,

    pub fn jsonStringify(self: InteractionCallback, jw: *std.json.Stringify) std.json.Stringify.Error!void {
        try jw.beginObject();

        try jw.objectField("type");
        try jw.write(@backingInt(std.meta.activeTag(self)));

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

    pub fn initPong() InteractionCallback {
        return .{ .pong = .{} };
    }

    pub fn initChannelMessageWithSource(data: ChannelMessageWithSource) InteractionCallback {
        return .{ .channel_message_with_source = data };
    }

    pub fn initDeferredChannelMessageWithSource(data: DeferredChannelMessageWithSource) InteractionCallback {
        return .{ .deferred_channel_message_with_source = data };
    }

    pub fn initDeferredUpdateMessage(data: DeferredUpdateMessage) InteractionCallback {
        return .{ .deferred_update_message = data };
    }

    pub fn initUpdateMessage(data: UpdateMessage) InteractionCallback {
        return .{ .update_message = data };
    }

    pub fn initApplicationCommandAutocompleteResultString(data: InteractionCallbackAutocompleteString) InteractionCallback {
        return .{ .application_command_autocomplete_result = .{ .string = data } };
    }

    pub fn initApplicationCommandAutocompleteResultInteger(data: InteractionCallbackAutocompleteInteger) InteractionCallback {
        return .{ .application_command_autocomplete_result = .{ .integer = data } };
    }

    pub fn initApplicationCommandAutocompleteResultDouble(data: InteractionCallbackAutocompleteDouble) InteractionCallback {
        return .{ .application_command_autocomplete_result = .{ .double = data } };
    }

    pub fn initModal(data: ModalInteractionCallback) InteractionCallback {
        return .{ .modal = data };
    }

    pub fn initLaunchActivity() InteractionCallback {
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

pub const InteractionCallbackPong = struct {
    type: InteractionCallback.Type = .pong,
};

pub const ChannelMessageWithSource = struct {
    type: InteractionCallback.Type = .channel_message_with_source,
    tts: ?bool = null,
    content: ?[]const u8 = null,
    embeds: ?[]const Message.Embed = null,
    allowed_mentions: ?Message.AllowedMentions = null,
    flags: ?Message.Flags = null,
    components: ?[]const components.TopLevelMessageComponent = null,
    attachments: ?[]const PartialAttachment = null,
    poll: ?Poll = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const DeferredChannelMessageWithSource = struct {
    type: InteractionCallback.Type = .deferred_channel_message_with_source,
    tts: ?bool = null,
    content: ?[]const u8 = null,
    embeds: ?[]const Message.Embed = null,
    allowed_mentions: ?Message.AllowedMentions = null,
    flags: ?Message.Flags = null,
    components: ?[]components.TopLevelMessageComponent = null,
    attachments: ?[]const PartialAttachment = null,
    poll: ?Poll = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const DeferredUpdateMessage = struct {
    type: InteractionCallback.Type = .deferred_update_message,
    tts: ?bool = null,
    content: ?[]const u8 = null,
    embeds: ?[]const Message.Embed = null,
    allowed_mentions: ?Message.AllowedMentions = null,
    flags: ?Message.Flags = null,
    components: ?[]const components.TopLevelMessageComponent = null,
    attachments: ?[]const PartialAttachment = null,
    poll: ?Poll = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const UpdateMessage = struct {
    type: InteractionCallback.Type = .update_message,
    tts: ?bool = null,
    content: ?[]const u8 = null,
    embeds: ?[]const Message.Embed = null,
    allowed_mentions: ?Message.AllowedMentions = null,
    flags: ?Message.Flags = null,
    components: ?[]const components.TopLevelMessageComponent = null,
    attachments: ?[]const PartialAttachment = null,
    poll: ?Poll = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ModalInteractionCallback = struct {
    custom_id: []const u8,
    title: []const u8,
    components: []const components.TopLevelModalComponent,
};

pub const AnyInteractionCallbackAutocomplete = union(enum) {
    string: InteractionCallbackAutocompleteString,
    integer: InteractionCallbackAutocompleteInteger,
    double: InteractionCallbackAutocompleteDouble,

    const Mixin = jconfig.InlineUnionMixin(AnyInteractionCallbackAutocomplete);
    pub const jsonStringify = Mixin.jsonStringify;
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;
};

pub const InteractionCallbackAutocompleteString = struct {
    type: InteractionCallback.Type = .application_command_autocomplete_result,
    choices: []const command_option.StringChoice,
};

pub const InteractionCallbackAutocompleteInteger = struct {
    type: InteractionCallback.Type = .application_command_autocomplete_result,
    choices: []const command_option.IntegerChoice,
};

pub const InteractionCallbackAutocompleteDouble = struct {
    type: InteractionCallback.Type = .application_command_autocomplete_result,
    choices: []const command_option.DoubleChoice,
};

pub const PartialAttachment = struct {
    filename: ?[]const u8 = null,
    description: ?[]const u8 = null,
    content_type: ?[]const u8 = null,
    size: ?u64 = null,
    url: ?[]const u8 = null,
    proxy_url: ?[]const u8 = null,
    height: jconfig.Omittable(?i64) = .omit,
    width: jconfig.Omittable(?i64) = .omit,
    ephemeral: ?bool = null,
    duration_secs: ?f64 = null,
    waveform: ?[]const u8 = null,
    flags: ?Message.AttachmentFlags = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const Context = enum(u2) {
    guild = 0,
    bot_dm = 1,
    private_channel = 2,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};
