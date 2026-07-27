const std = @import("std");
const zigcord = @import("../../root.zig");
const model = zigcord.model;
const rest = zigcord.rest;
const jconfig = zigcord.jconfig;

pub fn createLobby(
    client: *rest.EndpointClient,
    body: CreateLobbyBody,
) !rest.RestClient.Result(model.Lobby) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/lobbies", .{});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBody(model.Lobby, .POST, uri, body, .{});
}

pub fn createOrJoinLobby(
    client: *rest.EndpointClient,
    body: CreateOrJoinLobbyBody,
) !rest.RestClient.Result(model.Lobby) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/lobbies", .{});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBody(model.Lobby, .PUT, uri, body, .{});
}

pub fn getLobby(
    client: *rest.EndpointClient,
    lobby_id: model.Snowflake,
) !rest.RestClient.Result(model.Lobby) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/lobbies/{f}", .{lobby_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Lobby, .GET, uri);
}

pub fn modifyLobby(
    client: *rest.EndpointClient,
    body: ModifyLobbyBody,
) !rest.RestClient.Result(model.Lobby) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/lobbies", .{});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBody(model.Lobby, .PATCH, uri, body, .{});
}

pub fn deleteLobby(
    client: *rest.EndpointClient,
    lobby_id: model.Snowflake,
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/lobbies/{f}", .{lobby_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub fn addAMemberToALobby(
    client: *rest.EndpointClient,
    lobby_id: model.Snowflake,
    user_id: model.Snowflake,
    body: AddAMemberToALobbyBody,
) !rest.RestClient.Result(model.Lobby.LobbyMember) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/lobbies/{f}/members/{f}", .{ lobby_id, user_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBody(model.Lobby.LobbyMember, .PUT, uri, body, .{});
}

pub fn bulkUpdateLobbyMembers(
    client: *rest.EndpointClient,
    lobby_id: model.Snowflake,
    body: []const BulkUpdateLobbyMember,
) !rest.RestClient.Result([]const model.Lobby.LobbyMember) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/lobbies/{f}/members/bulk", .{lobby_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBody([]const model.Lobby.LobbyMember, .POST, uri, body, .{});
}

pub fn deleteAMemberFromALobby(
    client: *rest.EndpointClient,
    lobby_id: model.Snowflake,
    user_id: model.Snowflake,
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/lobbies/{f}/members/{f}", .{ lobby_id, user_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub fn leaveLobby(
    client: *rest.EndpointClient,
    lobby_id: model.Snowflake,
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/lobbies/{f}/members/@me", .{lobby_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub fn linkChannelToLobby(
    client: *rest.EndpointClient,
    lobby_id: model.Snowflake,
    body: LinkChannelToLobbyBody,
) !rest.RestClient.Result(model.Lobby) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/lobbies/{f}/channel-linking", .{lobby_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBody(model.Lobby, .PATCH, uri, body, .{});
}

pub fn unlinkChannelFromLobby(
    client: *rest.EndpointClient,
    lobby_id: model.Snowflake,
) !rest.RestClient.Result(model.Lobby) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/lobbies/{f}/channel-linking", .{lobby_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Lobby, .PATCH, uri);
}

pub fn sendLobbyMessage(
    client: *rest.EndpointClient,
    lobby_id: model.Snowflake,
    body: SendLobbyMessageBody,
) !rest.RestClient.Result(model.Lobby.LobbyMessage) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/lobbies/{f}/messages", .{lobby_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBody(model.Lobby.LobbyMessage, .POST, uri, body, .{});
}

pub fn getLobbyMessages(
    client: *rest.EndpointClient,
    lobby_id: model.Snowflake,
    query: GetLobbyMessagesQuery,
) !rest.RestClient.Result([]const model.Lobby.LobbyMessage) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/lobbies/{f}/messages?{f}", .{ lobby_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const model.Lobby.LobbyMessage, .GET, uri);
}

pub fn updateLobbyMessageModerationMetadata(
    client: *rest.EndpointClient,
    lobby_id: model.Snowflake,
    message_id: model.Snowflake,
    body: std.json.ArrayHashMap([]const u8),
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/lobbies/{f}/messages/{f}/moderation-metadata", .{ lobby_id, message_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBody(void, .PUT, uri, body, .{});
}

pub fn createLobbyChannelInviteForSelf(
    client: *rest.EndpointClient,
    lobby_id: model.Snowflake,
) !rest.RestClient.Result(model.Lobby.LobbyInvite) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/lobbies/{f}/members/@me/invites", .{lobby_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Lobby.LobbyInvite, .POST, uri);
}

pub fn createLobbyChannelInviteForUser(
    client: *rest.EndpointClient,
    lobby_id: model.Snowflake,
    user_id: model.Snowflake,
) !rest.RestClient.Result(model.Lobby.LobbyInvite) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/lobbies/{f}/members/{f}/invites", .{ lobby_id, user_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Lobby.LobbyInvite, .POST, uri);
}

pub const CreateLobbyBody = struct {
    metadata: jconfig.Omittable(std.json.ArrayHashMap([]const u8)) = .omit,
    members: jconfig.Omittable([]const model.Lobby.LobbyMember) = .omit,
    idle_timeout_seconds: jconfig.Omittable(u32) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const CreateOrJoinLobbyBody = struct {
    secret: []const u8,
    metadata: jconfig.Omittable(std.json.ArrayHashMap([]const u8)) = .omit,
    members: jconfig.Omittable([]const model.Lobby.LobbyMember) = .omit,
    idle_timeout_seconds: jconfig.Omittable(u32) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ModifyLobbyBody = struct {
    metadata: jconfig.Omittable(std.json.ArrayHashMap([]const u8)) = .omit,
    members: jconfig.Omittable([]const model.Lobby.LobbyMember) = .omit,
    idle_timeout_seconds: jconfig.Omittable(u32) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const AddAMemberToALobbyBody = struct {
    metadata: jconfig.Omittable(std.json.ArrayHashMap([]const u8)) = .omit,
    flags: jconfig.Omittable(model.Lobby.LobbyMember.Flags) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const BulkUpdateLobbyMember = struct {
    id: model.Snowflake,
    metadata: jconfig.Omittable(std.json.ArrayHashMap([]const u8)) = .omit,
    flags: jconfig.Omittable(model.Lobby.LobbyMember.Flags) = .omit,
    remove_member: jconfig.Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const LinkChannelToLobbyBody = struct {
    channel_id: jconfig.Omittable(model.Snowflake) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const SendLobbyMessageBody = struct {
    content: []const u8,
    metadata: jconfig.Omittable(std.json.ArrayHashMap([]const u8)) = .omit,
    flags: jconfig.Omittable(model.Message.Flags) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const GetLobbyMessagesQuery = struct {
    limit: ?u8 = null,

    pub const format = rest.QueryStringFormatMixin(GetLobbyMessagesQuery).format;
};

test {
    std.testing.refAllDecls(@This());
}
