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

    const transfer_encoding = try rest.getTransferEncoding(body, "file");

    // https://codeberg.org/ziglang/zig/issues/30623 - for now, we will write the file
    // to an allocatingwriter and send it all in one shot. once streaming to body_writer is fixed,
    // this should be updated to write directly to body_writer instead of allocating the entire file.
    var aw: std.Io.Writer.Allocating = switch (transfer_encoding) {
        .content_length => |len| try .initCapacity(client.rest_client.allocator, len),
        .chunked => .init(client.rest_client.allocator),
        .none => unreachable,
    };
    defer aw.deinit();

    try rest.writeMultipartFormDataBody(body, "file", &aw.writer);

    var buf: [1028]u8 = undefined;
    var pending_request = try client.rest_client.beginMultipartRequestWithAuditLogReason(model.Sticker, .POST, uri, transfer_encoding, rest.multipart_boundary, &buf, audit_log_reason);

    try pending_request.request.sendBodyComplete(aw.written());

    return pending_request.waitForResponse();
}

pub const ListStickerPacksResponse = struct {
    sticker_packs: []const model.Sticker.Pack,
};

pub const CreateGuildStickerFormBody = struct {
    name: []const u8,
    description: []const u8,
    tags: []const u8,
    file: rest.Upload,
};
