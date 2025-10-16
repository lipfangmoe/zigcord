const zigcord = @import("../../root.zig");
const std = @import("std");
const model = zigcord.model;
const rest = zigcord.rest;
const jconfig = zigcord.jconfig;

pub fn getCurrentUser(
    client: *rest.EndpointClient,
) !rest.RestClient.Result(model.User) {
    const uri = try std.Uri.parse(rest.base_url ++ "/users/@me");

    return client.rest_client.request(model.User, .GET, uri);
}

pub fn getUser(
    client: *rest.EndpointClient,
    user_id: model.Snowflake,
) !rest.RestClient.Result(model.User) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/users/{f}", .{user_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.User, .GET, uri);
}

pub fn modifyCurrentUser(
    client: *rest.EndpointClient,
    body: ModifyCurrentUserBody,
) !rest.RestClient.Result(model.User) {
    const uri = try std.Uri.parse(rest.base_url ++ "/users/@me");

    return client.rest_client.requestWithValueBody(model.User, .PATCH, uri, body, .{});
}

pub fn getCurrentUserGuilds(
    client: *rest.EndpointClient,
    query: GetCurrentUserGuildsQuery,
) !rest.RestClient.Result([]const model.guild.PartialGuild) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/users/@me/guilds?{f}", .{query});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const model.guild.PartialGuild, .GET, uri);
}

pub fn leaveGuild(
    client: *rest.EndpointClient,
    guild_id: model.Snowflake,
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/users/@me/guilds/{f}", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub fn createDm(
    client: *rest.EndpointClient,
    body: CreateDmBody,
) !rest.RestClient.Result(model.Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/users/@me/channels", .{});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBody(model.Channel, .POST, uri, body, .{});
}

pub fn createGroupDm(
    client: *rest.EndpointClient,
    body: CreateGroupDmBody,
) !rest.RestClient.Result(model.Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/users/@me/channels", .{});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return try client.rest_client.requestWithValueBody(model.Channel, .POST, uri, body, .{});
}

pub fn getCurrentUserConnections(
    client: *rest.EndpointClient,
) !rest.RestClient.Result([]const model.User.Connection) {
    const uri = try std.Uri.parse(rest.base_url ++ "/users/@me/connections");

    return try client.rest_client.request([]const model.User.Connection, .GET, uri);
}

pub fn getCurrentUserApplicationRoleConnection(
    client: *rest.EndpointClient,
    application_id: model.Snowflake,
) !rest.RestClient.Result([]const model.User.ApplicationRoleConnection) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/users/@me/applications/{f}/role-connection", .{application_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const model.User.ApplicationRoleConnection, .GET, uri);
}

pub fn updateCurrentUserApplicationRoleConnection(
    client: *rest.EndpointClient,
    application_id: model.Snowflake,
    body: UpdateCurrentUserApplicationRoleConnectionBody,
) !rest.RestClient.Result(model.User.ApplicationRoleConnection) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/users/@me/applications/{f}/role-connection", .{application_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBody(model.User.ApplicationRoleConnection, .PUT, uri, body, .{});
}

pub const ModifyCurrentUserBody = struct {
    username: jconfig.Omittable([]const u8) = .omit,
    avatar: jconfig.Omittable(?model.DataUri) = .omit,
    banner: jconfig.Omittable(?model.DataUri) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const GetCurrentUserGuildsQuery = struct {
    before: ?model.Snowflake = null,
    after: ?model.Snowflake = null,
    limit: ?i64 = null,
    with_counts: ?bool,

    pub const format = rest.QueryStringFormatMixin(@This()).format;
};

pub const CreateDmBody = struct {
    recipient_id: model.Snowflake,
};

pub const CreateGroupDmBody = struct {
    access_tokens: []const []const u8,
    nicks: std.json.ArrayHashMap([]const u8),
};

pub const UpdateCurrentUserApplicationRoleConnectionBody = struct {
    platform_name: jconfig.Omittable(?[]const u8) = .omit,
    platform_username: jconfig.Omittable(?[]const u8) = .omit,
    metadata: jconfig.Omittable(std.json.ArrayHashMap([]const u8)) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};
