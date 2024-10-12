const std = @import("std");
const deancord = @import("../../root.zig");
const model = deancord.model;
const rest = deancord.rest;
const jconfig = deancord.jconfig;
const Omittable = jconfig.Omittable;
const stringifyWithOmit = jconfig.stringifyWithOmit;
const ApplicationCommandOption = model.interaction.command_option.ApplicationCommandOption;
const ApplicationCommand = model.interaction.command.ApplicationCommand;
const ApplicationCommandType = model.interaction.command.ApplicationCommandType;
const Snowflake = model.Snowflake;

/// The objects returned by this endpoint may be augmented with additional fields if localization is active.
///
/// Fetch all of the global commands for your application. Returns an array of application command objects.
pub fn getGlobalApplicationCommands(client: *rest.EndpointClient, application_id: Snowflake, with_localizations: ?bool) !rest.RestClient.Result([]ApplicationCommand) {
    const query = WithLocalizationsQuery{ .with_localizations = with_localizations };

    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/applications/{d}/commands?{query}", .{ application_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]ApplicationCommand, .GET, uri);
}

/// Creating a command with the same name as an existing command for your application will overwrite the old command.
///
/// Create a new global command. Returns `201` if a command with the same name does not
/// already exist, or a `200` if it does (in which case the previous command will be overwritten).
/// Both responses include an application command object.
pub fn createGlobalApplicationCommand(client: *rest.EndpointClient, application_id: Snowflake, body: CreateGlobalApplicationCommandBody) !rest.RestClient.Result(ApplicationCommand) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/applications/{d}/commands?", .{application_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBody(ApplicationCommand, .POST, uri, body, .{});
}

/// Fetch a global command for your application. Returns an application command object.
pub fn getGlobalApplicationCommand(client: *rest.EndpointClient, application_id: Snowflake, command_id: Snowflake) !rest.RestClient.Result(ApplicationCommand) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/applications/{d}/commands/{d}", .{ application_id, command_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(ApplicationCommand, .GET, uri);
}

/// Edit a global command. Returns `200` and an application command object.
/// All fields are optional, but any fields provided will entirely overwrite the existing values of those fields.
pub fn editGlobalApplicationCommand(client: *rest.EndpointClient, application_id: Snowflake, command_id: Snowflake, body: EditGlobalApplicationCommandBody) !rest.RestClient.Result(ApplicationCommand) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/applications/{d}/commands/{d}", .{ application_id, command_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBody(ApplicationCommand, .PATCH, uri, body, .{});
}

/// Deletes a global command. Returns `204 No Content` on success.
pub fn deleteGlobalApplicationCommand(client: *rest.EndpointClient, application_id: Snowflake, command_id: Snowflake) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/applications/{d}/commands/{d}", .{ application_id, command_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

/// Takes a list of application commands, overwriting the existing global command list for this application.
/// Returns `200` and a list of application command objects.
/// Commands that do not already exist will count toward daily application command create limits.
///
/// This will overwrite all types of application commands: slash commands, user commands, and message commands.
pub fn bulkOverwriteGlobalApplicationCommands(client: *rest.EndpointClient, application_id: Snowflake, new_commands: []const ApplicationCommand) !rest.RestClient.Result([]ApplicationCommand) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/applications/{d}/commands/", .{application_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBody([]ApplicationCommand, .PUT, uri, new_commands, .{});
}

pub fn getGuildApplicationCommands(client: *rest.EndpointClient, application_id: Snowflake, guild_id: Snowflake, with_localizations: ?bool) !rest.RestClient.Result([]ApplicationCommand) {
    const query = WithLocalizationsQuery{ .with_localizations = with_localizations };
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/applications/{d}/guilds/{d}/commands?{query}", .{ application_id, guild_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]ApplicationCommand, .GET, uri);
}

pub fn createGuildApplicationCommand(client: *rest.EndpointClient, application_id: Snowflake, guild_id: Snowflake, body: CreateGuildApplicationCommandBody) !rest.RestClient.Result(ApplicationCommand) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/applications/{d}/guilds/{d}/commands", .{ application_id, guild_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBody(ApplicationCommand, .POST, uri, body, .{});
}

pub fn getGuildApplicationCommand(client: *rest.EndpointClient, application_id: Snowflake, guild_id: Snowflake, command_id: Snowflake) !rest.RestClient.Result(ApplicationCommand) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/applications/{d}/guilds/{d}/commands/{d}", .{ application_id, guild_id, command_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(ApplicationCommand, .GET, uri);
}

pub fn editGuildApplicationCommand(client: *rest.EndpointClient, application_id: Snowflake, guild_id: Snowflake, command_id: Snowflake, body: EditGuildApplicationCommandBody) !rest.RestClient.Result(ApplicationCommand) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/applications/{d}/guilds/{d}/commands/{d}", .{ application_id, guild_id, command_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBody(ApplicationCommand, .PATCH, uri, body, .{});
}

pub fn deleteGuildApplicationCommand(
    client: *rest.EndpointClient,
    application_id: Snowflake,
    guild_id: Snowflake,
    command_id: Snowflake,
) !rest.RestClient.Result(ApplicationCommand) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/applications/{d}/guilds/{d}/commands/{d}", .{ application_id, guild_id, command_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(ApplicationCommand, .DELETE, uri);
}

pub fn bulkOverwriteGuildApplicationCommands(
    client: *rest.EndpointClient,
    application_id: Snowflake,
    guild_id: Snowflake,
    new_commands: []const ApplicationCommand,
) !rest.RestClient.Result([]const ApplicationCommand) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/applications/{d}/guilds/{d}/commands", .{ application_id, guild_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBody([]const ApplicationCommand, .PUT, uri, new_commands, .{});
}

pub fn getGuildApplicationCommandPermissions(
    client: *rest.EndpointClient,
    application_id: Snowflake,
    guild_id: Snowflake,
) !rest.RestClient.Result([]const model.interaction.command.GuildApplicationCommandPermissions) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/applications/{d}/guilds/{d}/permissions", .{ application_id, guild_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const model.interaction.command.GuildApplicationCommandPermissions, .GET, uri);
}

pub fn getApplicationCommandPermissions(
    client: *rest.EndpointClient,
    application_id: Snowflake,
    guild_id: Snowflake,
    command_id: Snowflake,
) !rest.RestClient.Result(model.interaction.command.ApplicationCommandPermission) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/applications/{d}/guilds/{d}/commands/{d}/permissions", .{ application_id, guild_id, command_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.interaction.command.ApplicationCommandPermission, .GET, uri);
}

pub fn editApplicationCommandPermissions(
    client: *rest.EndpointClient,
    application_id: Snowflake,
    guild_id: Snowflake,
    command_id: Snowflake,
    body: []const model.interaction.command.ApplicationCommandPermission,
) !rest.RestClient.Result(model.interaction.command.ApplicationCommandPermission) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/applications/{d}/guilds/{d}/commands/{d}/permissions", .{ application_id, guild_id, command_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBody(model.interaction.command.ApplicationCommandPermission, .PUT, uri, body, .{});
}

pub const CreateGlobalApplicationCommandBody = struct {
    name: []const u8,
    name_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    description: []const u8,
    description_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    options: Omittable([]const ApplicationCommandOption) = .omit,
    default_member_permissions: Omittable(?[]const u8) = .omit,
    dm_permission: Omittable(?bool) = .omit,
    default_permission: Omittable(bool) = .omit,
    type: Omittable(ApplicationCommandType) = .omit,
    nsfw: Omittable(bool) = .omit,

    pub const jsonStringify = stringifyWithOmit;
};

pub const EditGlobalApplicationCommandBody = struct {
    name: Omittable([]const u8) = .omit,
    name_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    description: Omittable([]const u8) = .omit,
    description_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    options: Omittable([]const ApplicationCommandOption) = .omit,
    default_member_permissions: Omittable(?[]const u8) = .omit,
    dm_permission: Omittable(?bool) = .omit,
    default_permission: Omittable(bool) = .omit,
    nsfw: Omittable(bool) = .omit,

    pub const jsonStringify = stringifyWithOmit;
};

pub const CreateGuildApplicationCommandBody = struct {
    name: []const u8,
    name_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    description: Omittable([]const u8) = .omit,
    description_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    options: Omittable([]const ApplicationCommandOption) = .omit,
    default_member_permissions: Omittable(?[]const u8) = .omit,
    default_permission: Omittable(bool) = .omit,
    type: Omittable(ApplicationCommandType) = .omit,
    nsfw: Omittable(bool) = .omit,

    pub const jsonStringify = stringifyWithOmit;
};

pub const EditGuildApplicationCommandBody = struct {
    name: Omittable([]const u8) = .omit,
    name_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    description: Omittable([]const u8) = .omit,
    description_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    options: Omittable([]const ApplicationCommandOption) = .omit,
    default_member_permissions: Omittable(?[]const u8) = .omit,
    default_permission: Omittable(bool) = .omit,
    nsfw: Omittable(bool) = .omit,

    pub const jsonStringify = stringifyWithOmit;
};

const WithLocalizationsQuery = struct {
    with_localizations: ?bool = null,

    pub usingnamespace rest.QueryStringFormatMixin(WithLocalizationsQuery);
};
