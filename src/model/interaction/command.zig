const std = @import("std");
const model = @import("../../root.zig").model;
const jconfig = @import("../../root.zig").jconfig;
const Snowflake = model.Snowflake;
const ApplicationCommandOption = model.interaction.command_option.ApplicationCommandOption;
const Omittable = jconfig.Omittable;
const Permissions = model.Permissions;

// TODO - sometimes this contains name_localized and description_localized fields.
// See https://discord.com/developers/docs/interactions/application-commands#retrieving-localized-commands
// TODO - translate to use Omittable
pub const ApplicationCommand = struct {
    id: Snowflake,
    type: ApplicationCommandType, // documentation says this is omittable but REST api seems to disagree
    application_id: Snowflake,
    guild_id: Omittable(Snowflake) = .omit,
    name: []const u8,
    name_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    description: []const u8,
    description_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    options: Omittable([]const ApplicationCommandOption) = .omit,
    default_member_permissions: ?Permissions,
    dm_permission: Omittable(bool) = .omit,
    default_permission: Omittable(?bool) = .omit,
    nsfw: Omittable(bool) = .omit,
    version: Snowflake,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ApplicationCommandType = enum(u8) {
    chat_input = 1,
    user = 2,
    message = 3,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};

pub const GuildApplicationCommandPermissions = struct {
    id: model.Snowflake,
    application_id: model.Snowflake,
    guild_id: model.Snowflake,
    permissions: []const ApplicationCommandPermission,
};

pub const ApplicationCommandPermission = struct {
    /// NOTE: id may be set to `guild_id` to represent @everyone in a guild,
    /// or `guild_id-1`  to represent all channels in a guild
    id: model.Snowflake,
    type: Type,
    permission: bool,

    pub const Type = enum(u8) {
        role = 1,
        user = 2,
        channel = 3,
    };
};
