const std = @import("std");
const model = @import("../../model.zig");
const Snowflake = model.Snowflake;
const ApplicationCommandOption = model.interaction.command_option.ApplicationCommandOption;
const Localizations = model.Localizations;
const Omittable = model.deanson.Omittable;
const Permissions = model.Permissions;

// TODO - sometimes this contains name_localized and description_localized fields.
// See https://discord.com/developers/docs/interactions/application-commands#retrieving-localized-commands
// TODO - translate to use Omittable
pub const ApplicationCommand = struct {
    id: Snowflake,
    type: Omittable(ApplicationCommandType) = .{ .omitted = void{} },
    application_id: Snowflake,
    guild_id: Omittable(Snowflake) = .{ .omitted = void{} },
    name: []const u8,
    name_localizations: Omittable(?Localizations) = .{ .omitted = void{} },
    description: []const u8,
    description_localizations: Omittable(?Localizations) = .{ .omitted = void{} },
    options: Omittable([]const ApplicationCommandOption) = .{ .omitted = void{} },
    default_member_permissions: ?Permissions,
    dm_permission: Omittable(bool) = .{ .omitted = void{} },
    default_permission: Omittable(?bool) = .{ .omitted = void{} },
    nsfw: Omittable(bool) = .{ .omitted = void{} },
    version: Snowflake,

    pub const jsonStringify = model.deanson.stringifyWithOmit;
};

pub const ApplicationCommandType = enum(u8) {
    chat_input = 1,
    user = 2,
    message = 3,
};
