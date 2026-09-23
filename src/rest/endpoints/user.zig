const std = @import("std");
const model = @import("model");
const jconfig = @import("jconfig");
const EndpointClient = @import("../EndpointClient.zig");
const RestClient = @import("../RestClient.zig");
const Result = RestClient.Result;
const discord_uri = @import("../discord_uri.zig");
const allocDiscordUriStr = discord_uri.allocDiscordUriStr;
const base_url = discord_uri.base_url;
const query_strings = @import("../query_strings.zig");

pub fn getCurrentUser(
    client: *EndpointClient,
) !Result(model.User) {
    const uri = try std.Uri.parse(base_url ++ "/users/@me");

    return client.rest_client.request(model.User, .GET, uri);
}

pub fn getUser(
    client: *EndpointClient,
    user_id: model.Snowflake,
) !Result(model.User) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/users/{f}", .{user_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.User, .GET, uri);
}

pub fn modifyCurrentUser(
    client: *EndpointClient,
    body: ModifyCurrentUserBody,
) !Result(model.User) {
    const uri = try std.Uri.parse(base_url ++ "/users/@me");

    return client.rest_client.requestWithJsonBody(model.User, .PATCH, uri, body, .{});
}

pub fn getCurrentUserGuilds(
    client: *EndpointClient,
    query: GetCurrentUserGuildsQuery,
) !Result([]const model.guild.PartialGuild) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/users/@me/guilds?{f}", .{query});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const model.guild.PartialGuild, .GET, uri);
}

pub fn leaveGuild(
    client: *EndpointClient,
    guild_id: model.Snowflake,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/users/@me/guilds/{f}", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub fn createDm(
    client: *EndpointClient,
    body: CreateDmBody,
) !Result(model.Channel) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/users/@me/channels", .{});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBody(model.Channel, .POST, uri, body, .{});
}

pub fn createGroupDm(
    client: *EndpointClient,
    body: CreateGroupDmBody,
) !Result(model.Channel) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/users/@me/channels", .{});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return try client.rest_client.requestWithJsonBody(model.Channel, .POST, uri, body, .{});
}

pub fn getCurrentUserConnections(
    client: *EndpointClient,
) !Result([]const model.User.Connection) {
    const uri = try std.Uri.parse(base_url ++ "/users/@me/connections");

    return try client.rest_client.request([]const model.User.Connection, .GET, uri);
}

pub fn getCurrentUserApplicationRoleConnection(
    client: *EndpointClient,
    application_id: model.Snowflake,
) !Result([]const model.User.ApplicationRoleConnection) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/users/@me/applications/{f}/role-connection", .{application_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const model.User.ApplicationRoleConnection, .GET, uri);
}

pub fn updateCurrentUserApplicationRoleConnection(
    client: *EndpointClient,
    application_id: model.Snowflake,
    body: UpdateCurrentUserApplicationRoleConnectionBody,
) !Result(model.User.ApplicationRoleConnection) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/users/@me/applications/{f}/role-connection", .{application_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBody(model.User.ApplicationRoleConnection, .PUT, uri, body, .{});
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

    pub const format = query_strings.formatAsQueryString;
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
