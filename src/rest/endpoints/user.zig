const deancord = @import("../../root.zig");
const std = @import("std");
const model = deancord.model;
const rest = deancord.rest;
const deanson = model.deanson;

pub fn getCurrentUser(
    client: *rest.ApiClient,
) !rest.Client.Result(model.User) {
    const uri = try std.Uri.parse(rest.base_url ++ "/users/@me");

    return client.rest_client.request(model.User, .GET, uri);
}

pub fn getUser(
    client: *rest.ApiClient,
    user_id: model.Snowflake,
) !rest.Client.Result(model.User) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/users/{}", .{user_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.User, .GET, uri);
}

pub fn modifyCurrentUser(
    client: *rest.ApiClient,
    body: ModifyCurrentUserBody,
) !rest.Client.Result(model.User) {
    const uri = try std.Uri.parse(rest.base_url ++ "/users/@me");

    return client.rest_client.requestWithValueBody(model.User, .PATCH, uri, body, .{});
}

pub fn getCurrentUserGuilds(
    client: *rest.ApiClient,
    query: GetCurrentUserGuildsQuery,
) !rest.Client.Result([]const model.guild.PartialGuild) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/users/@me/guilds?{query}", .{query});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const model.guild.PartialGuild, .GET, uri);
}

pub fn leaveGuild(
    client: *rest.ApiClient,
    guild_id: model.Snowflake,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/users/@me/guilds/{}", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub fn createDm(
    client: *rest.ApiClient,
    body: CreateDmBody,
) !rest.Client.Result(model.Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/users/@me/channels", .{});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBody(void, .POST, uri, body, .{});
}

pub fn createGroupDm(
    client: *rest.ApiClient,
    body: CreateGroupDmBody,
) !rest.Client.Result(model.Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/users/@me/channels", .{});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBody(void, .POST, uri, body, .{});
}

pub fn getCurrentUserConnections(
    client: *rest.ApiClient,
) !rest.Client.Result([]const model.User.Connection) {
    const uri = try std.Uri.parse(rest.base_url ++ "/users/@me/connections");

    return client.rest_client.request(model.User, .GET, uri);
}

pub fn getCurrentUserApplicationRoleConnection(
    client: *rest.ApiClient,
    application_id: model.Snowflake,
) !rest.Client.Result([]const model.User.ApplicationRoleConnection) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/users/@me/applications/{}/role-connection", .{application_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const model.User.ApplicationRoleConnection, .GET, uri);
}

pub fn updateCurrentUserApplicationRoleConnection(
    client: *rest.ApiClient,
    application_id: model.Snowflake,
    body: UpdateCurrentUserApplicationRoleConnectionBody,
) !rest.Client.Result(model.User.ApplicationRoleConnection) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/users/@me/applications/{}/role-connection", .{application_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBody(model.User.ApplicationRoleConnection, .PUT, uri, body, .{});
}

pub const ModifyCurrentUserBody = struct {
    username: deanson.Omittable([]const u8) = .omit,
    avatar: deanson.Omittable(?model.ImageData) = .omit,
    banner: deanson.Omittable(?model.ImageData) = .omit,

    pub const jsonStringify = deanson.stringifyWithOmit;
};

pub const GetCurrentUserGuildsQuery = struct {
    before: ?model.Snowflake = null,
    after: ?model.Snowflake = null,
    limit: ?i64 = null,
    with_counts: ?bool,

    pub usingnamespace rest.QueryStringFormatMixin(@This());
};

pub const CreateDmBody = struct {
    recipient_id: model.Snowflake,
};

pub const CreateGroupDmBody = struct {
    access_tokens: []const []const u8,
    nicks: std.json.ArrayHashMap([]const u8),
};

pub const UpdateCurrentUserApplicationRoleConnectionBody = struct {
    platform_name: deanson.Omittable(?[]const u8) = .omit,
    platform_username: deanson.Omittable(?[]const u8) = .omit,
    metadata: deanson.Omittable(std.json.ArrayHashMap([]const u8)) = .omit,

    pub const jsonStringify = deanson.stringifyWithOmit;
};
