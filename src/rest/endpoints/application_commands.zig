const std = @import("std");
const root = @import("root");
const model = root.model;
const rest = root.rest;
const Omittable = model.deanson.Omittable;
const stringifyWithOmit = model.deanson.stringifyWithOmit;
const RestResult = rest.Client.Result;
const ApplicationCommandOption = model.interaction.command_option.ApplicationCommandOption;
const ApplicationCommand = model.interaction.command.ApplicationCommand;
const ApplicationCommandType = model.interaction.command.ApplicationCommandType;
const Client = rest.Client;
const Snowflake = model.Snowflake;

/// The objects returned by this endpoint may be augmented with additional fields if localization is active.
///
/// Fetch all of the global commands for your application. Returns an array of application command objects.
pub fn getGlobalApplicationCommands(client: *Client, application_id: Snowflake, with_localizations: ?bool) !RestResult([]ApplicationCommand) {
    const query = WithLocalizationsQuery{ .with_localizations = with_localizations };

    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/applications/{d}/commands?{query}", .{ application_id, query });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request([]ApplicationCommand, .GET, uri);
}

/// Creating a command with the same name as an existing command for your application will overwrite the old command.
///
/// Create a new global command. Returns `201` if a command with the same name does not
/// already exist, or a `200` if it does (in which case the previous command will be overwritten).
/// Both responses include an application command object.
pub fn createGlobalApplicationCommand(client: *Client, application_id: Snowflake, body: CreateGlobalApplicationCommandBody) !RestResult(ApplicationCommand) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/applications/{d}/commands?", .{application_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBody(ApplicationCommand, .POST, uri, body, .{});
}

/// Fetch a global command for your application. Returns an application command object.
pub fn getGlobalApplicationCommand(client: *Client, application_id: Snowflake, command_id: Snowflake) !RestResult(ApplicationCommand) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/applications/{d}/commands/{d}", .{ application_id, command_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(ApplicationCommand, .GET, uri);
}

/// Edit a global command. Returns `200` and an application command object.
/// All fields are optional, but any fields provided will entirely overwrite the existing values of those fields.
pub fn editGlobalApplicationCommand(client: *Client, application_id: Snowflake, command_id: Snowflake, body: EditGlobalApplicationCommandBody) !RestResult(ApplicationCommand) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/applications/{d}/commands/{d}", .{ application_id, command_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBody(ApplicationCommand, .PATCH, uri, body, .{});
}

/// Deletes a global command. Returns `204 No Content` on success.
pub fn deleteGlobalApplicationCommand(client: *Client, application_id: Snowflake, command_id: Snowflake) !RestResult(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/applications/{d}/commands/{d}", .{ application_id, command_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(void, .DELETE, uri);
}

/// Takes a list of application commands, overwriting the existing global command list for this application.
/// Returns `200` and a list of application command objects.
/// Commands that do not already exist will count toward daily application command create limits.
///
/// This will overwrite all types of application commands: slash commands, user commands, and message commands.
pub fn bulkOverwriteGlobalApplicationCommands(client: *Client, application_id: Snowflake, new_commands: []const ApplicationCommand) !RestResult([]ApplicationCommand) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/applications/{d}/commands/", .{application_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBody([]ApplicationCommand, .PUT, uri, new_commands, .{});
}

pub fn getGuildApplicationCommands(client: *Client, application_id: Snowflake, guild_id: Snowflake, with_localizations: ?bool) !RestResult([]ApplicationCommand) {
    const query = WithLocalizationsQuery{ .with_localizations = with_localizations };
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/applications/{d}/guilds/{d}/commands?{query}", .{ application_id, guild_id, query });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request([]ApplicationCommand, .GET, uri);
}

pub fn createGuildApplicationCommand(client: *Client, application_id: Snowflake, guild_id: Snowflake, body: CreateGuildApplicationCommandBody) !RestResult(ApplicationCommand) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/applications/{d}/guilds/{d}/commands", .{ application_id, guild_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBody(ApplicationCommand, .POST, uri, body, .{});
}

pub fn getGuildApplicationCommand(client: *Client, application_id: Snowflake, guild_id: Snowflake, command_id: Snowflake) !RestResult(ApplicationCommand) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/applications/{d}/guilds/{d}/commands/{d}", .{ application_id, guild_id, command_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(ApplicationCommand, .GET, uri);
}

pub fn editGuildApplicationCommand(client: *Client, application_id: Snowflake, guild_id: Snowflake, command_id: Snowflake, body: EditGuildApplicationCommandBody) !RestResult(ApplicationCommand) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/applications/{d}/guilds/{d}/commands/{d}", .{ application_id, guild_id, command_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBody(ApplicationCommand, .PATCH, uri, body, .{});
}

pub fn deleteGuildApplicationCommand(
    client: *Client,
    application_id: Snowflake,
    guild_id: Snowflake,
    command_id: Snowflake,
) !RestResult(ApplicationCommand) {
    const path = try std.fmt.allocPrint(client.allocator, "/applications/{d}/guilds/{d}/commands/{d}", .{ application_id, guild_id, command_id });
    defer client.allocator.free(path);

    const url = try rest.DiscordUri.init(client.allocator, path, null);
    defer url.deinit();

    return client.request(ApplicationCommand, .DELETE, url);
}

pub fn bulkOverwriteGuildApplicationCommands(
    client: *Client,
    application_id: Snowflake,
    guild_id: Snowflake,
    new_commands: []const ApplicationCommand,
) !RestResult([]const ApplicationCommand) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/applications/{d}/guilds/{d}/commands", .{ application_id, guild_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBody([]const ApplicationCommand, .PUT, uri, new_commands, .{});
}

pub fn getGuildApplicationCommandPermissions(
    client: *Client,
    application_id: Snowflake,
    guild_id: Snowflake,
) !RestResult([]const GuildApplicationCommandPermissions) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/applications/{d}/guilds/{d}/permissions", .{ application_id, guild_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request([]const GuildApplicationCommandPermissions, .GET, uri);
}

pub fn getApplicationCommandPermissions(client: *Client, application_id: Snowflake, guild_id: Snowflake, command_id: Snowflake) !RestResult(GuildApplicationCommandPermissions) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/applications/{d}/guilds/{d}/commands/{d}/permissions", .{ application_id, guild_id, command_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(GuildApplicationCommandPermissions, .GET, uri);
}

pub fn editApplicationCommandPermissions(client: *Client, application_id: Snowflake, guild_id: Snowflake, command_id: Snowflake, body: []const ApplicationCommandPermission) !RestResult(GuildApplicationCommandPermissions) {
    const path = try std.fmt.allocPrint(client.allocator, "/applications/{d}/guilds/{d}/commands/{d}/permissions", .{ application_id, guild_id, command_id });
    defer client.allocator.free(path);

    const url = try rest.DiscordUri.init(client.allocator, path, null);
    defer url.deinit();

    return client.requestWithValueBody(GuildApplicationCommandPermissions, .PUT, url, body, .{});
}

pub const CreateGlobalApplicationCommandBody = struct {
    name: []const u8,
    name_localizations: Omittable(?model.Localizations) = .omit,
    description: Omittable([]const u8) = .omit,
    description_localizations: Omittable(?model.Localizations) = .omit,
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
    name_localizations: Omittable(?model.Localizations) = .omit,
    description: Omittable([]const u8) = .omit,
    description_localizations: Omittable(?model.Localizations) = .omit,
    options: Omittable([]const ApplicationCommandOption) = .omit,
    default_member_permissions: Omittable(?[]const u8) = .omit,
    dm_permission: Omittable(?bool) = .omit,
    default_permission: Omittable(bool) = .omit,
    nsfw: Omittable(bool) = .omit,

    pub const jsonStringify = stringifyWithOmit;
};

pub const CreateGuildApplicationCommandBody = struct {
    name: []const u8,
    name_localizations: Omittable(?model.Localizations) = .omit,
    description: Omittable([]const u8) = .omit,
    description_localizations: Omittable(?model.Localizations) = .omit,
    options: Omittable([]const ApplicationCommandOption) = .omit,
    default_member_permissions: Omittable(?[]const u8) = .omit,
    default_permission: Omittable(bool) = .omit,
    type: Omittable(ApplicationCommandType) = .omit,
    nsfw: Omittable(bool) = .omit,

    pub const jsonStringify = stringifyWithOmit;
};

pub const EditGuildApplicationCommandBody = struct {
    name: Omittable([]const u8) = .omit,
    name_localizations: Omittable(?model.Localizations) = .omit,
    description: Omittable([]const u8) = .omit,
    description_localizations: Omittable(?model.Localizations) = .omit,
    options: Omittable([]const ApplicationCommandOption) = .omit,
    default_member_permissions: Omittable(?[]const u8) = .omit,
    default_permission: Omittable(bool) = .omit,
    nsfw: Omittable(bool) = .omit,

    pub const jsonStringify = stringifyWithOmit;
};

pub const GuildApplicationCommandPermissions = struct {
    id: Snowflake,
    application_id: Snowflake,
    guild_id: Snowflake,
    permissions: ApplicationCommandPermission,
};

pub const ApplicationCommandPermission = struct {
    id: Snowflake,
    type: enum(u4) { role = 1, user = 2, channel = 3 },
    permission: bool,
};

const WithLocalizationsQuery = struct {
    with_localizations: ?bool = null,

    pub const format = rest.formatAsQueryString;
};
