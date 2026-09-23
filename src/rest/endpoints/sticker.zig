const std = @import("std");
const model = @import("model");
const jconfig = @import("jconfig");
const EndpointClient = @import("../EndpointClient.zig");
const RestClient = @import("../RestClient.zig");
const Result = RestClient.Result;
const allocDiscordUriStr = @import("../discord_uri.zig").allocDiscordUriStr;
const multipart = @import("../multipart.zig");
const Upload = @import("../upload.zig").Upload;

pub fn getSticker(
    client: *EndpointClient,
    sticker_id: model.Snowflake,
) !Result(model.Sticker) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/stickers/{f}", .{sticker_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Sticker, .GET, uri);
}

pub fn listStickerPacks(
    client: *EndpointClient,
) !Result(ListStickerPacksResponse) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/sticker-packs", .{});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(ListStickerPacksResponse, .GET, uri);
}

pub fn listGuildStickers(
    client: *EndpointClient,
    guild_id: model.Snowflake,
) !Result([]const model.Sticker) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/stickers", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const model.Sticker, .GET, uri);
}

pub fn getGuildSticker(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    sticker_id: model.Snowflake,
) !Result(model.Sticker) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/stickers/{f}", .{ guild_id, sticker_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Sticker, .GET, uri);
}

pub fn createGuildSticker(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    body: CreateGuildStickerFormBody,
    audit_log_reason: ?[]const u8,
) !Result(model.Sticker) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/stickers", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    const transfer_encoding = try multipart.getTransferEncoding(body, "file");

    // https://codeberg.org/ziglang/zig/issues/30623 - for now, we will write the file
    // to an allocatingwriter and send it all in one shot. once streaming to body_writer is fixed,
    // this should be updated to write directly to body_writer instead of allocating the entire file.
    var aw: std.Io.Writer.Allocating = switch (transfer_encoding) {
        .content_length => |len| try .initCapacity(client.rest_client.allocator, len),
        .chunked => .init(client.rest_client.allocator),
        .none => unreachable,
    };
    defer aw.deinit();

    try aw.writer.print("{f}", .{body.fmt("file")});

    var buf: [1028]u8 = undefined;
    var pending_request = try client.rest_client.beginMultipartRequestWithAuditLogReason(model.Sticker, .POST, uri, transfer_encoding, multipart.boundary, &buf, audit_log_reason);

    try pending_request.request.sendBodyComplete(aw.written());

    return pending_request.waitForResponse();
}

pub const ListStickerPacksResponse = struct {
    sticker_packs: []const model.Sticker.Pack,
};

pub const CreateGuildStickerFormBody = multipart.FormDataBody(Upload, CreateGuildStickerFormPayload);
pub const CreateGuildStickerFormPayload = struct {
    name: []const u8,
    description: []const u8,
    tags: []const u8,
};
