const zigcord = @import("../../root.zig");
const std = @import("std");
const model = zigcord.model;
const rest = zigcord.rest;
const jconfig = zigcord.jconfig;

pub fn getSticker(
    client: *rest.EndpointClient,
    sticker_id: model.Snowflake,
) !rest.RestClient.Result(model.Sticker) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/stickers/{f}", .{sticker_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Sticker, .GET, uri);
}

pub fn listStickerPacks(
    client: *rest.EndpointClient,
) !rest.RestClient.Result(ListStickerPacksResponse) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/sticker-packs", .{});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(ListStickerPacksResponse, .GET, uri);
}

pub fn listGuildStickers(
    client: *rest.EndpointClient,
    guild_id: model.Snowflake,
) !rest.RestClient.Result([]const model.Sticker) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/stickers", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const model.Sticker, .GET, uri);
}

pub fn getGuildSticker(
    client: *rest.EndpointClient,
    guild_id: model.Snowflake,
    sticker_id: model.Snowflake,
) !rest.RestClient.Result(model.Sticker) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/stickers/{f}", .{ guild_id, sticker_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Sticker, .GET, uri);
}

pub fn createGuildSticker(
    client: *rest.EndpointClient,
    guild_id: model.Snowflake,
    body: CreateGuildStickerFormBody,
    audit_log_reason: ?[]const u8,
) !rest.RestClient.Result(model.Sticker) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/stickers", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    const headers: []const std.http.Header = if (audit_log_reason) |reason|
        &.{std.http.Header{ .name = "X-Audit-Log-Reason", .value = reason }}
    else
        &.{};

    var buf: [1028]u8 = undefined;
    var pending_request = try client.rest_client.beginMultipartRequest(model.Sticker, .POST, uri, .chunked, rest.multipart_boundary, headers, &buf);

    var body_writer = try pending_request.request.sendBodyUnflushed("");
    try body_writer.writer.print("{f}", .{body});
    try body_writer.end();

    return pending_request.waitForResponse();
}

pub const ListStickerPacksResponse = struct {
    sticker_packs: []const model.Sticker.Pack,
};

pub const CreateGuildStickerFormBody = struct {
    name: []const u8,
    description: []const u8,
    tags: []const u8,
    file: *std.Io.Reader,

    pub fn format(self: CreateGuildStickerFormBody, writer: *std.Io.Writer) !void {
        rest.writeMultipartFormDataBody(self, "file", writer) catch return error.WriteFailed;
    }
};
