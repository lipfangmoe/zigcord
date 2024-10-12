const deancord = @import("../../root.zig");
const std = @import("std");
const model = deancord.model;
const rest = deancord.rest;
const jconfig = deancord.jconfig;

pub fn getSticker(
    client: *rest.EndpointClient,
    sticker_id: model.Snowflake,
) !rest.RestClient.Result(model.Sticker) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/stickers/{}", .{sticker_id});
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
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{}/stickers", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const model.Sticker, .GET, uri);
}

pub fn getGuildSticker(
    client: *rest.EndpointClient,
    guild_id: model.Snowflake,
    sticker_id: model.Sticker,
) !rest.RestClient.Result(model.Sticker) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{}/stickers/{}", .{ guild_id, sticker_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Sticker, .GET, uri);
}

pub fn createGuildSticker(
    client: *rest.EndpointClient,
    guild_id: model.Snowflake,
    sticker_id: model.Snowflake,
) !rest.RestClient.Result(model.Sticker) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{}/stickers/{}", .{ guild_id, sticker_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Sticker, .GET, uri);
}

pub const ListStickerPacksResponse = struct {
    sticker_packs: []const model.Sticker.Pack,
};

pub const CreateGuildStickerFormBody = struct {
    name: []const u8,
    description: []const u8,
    tags: []const u8,
    file: std.io.AnyReader,

    pub fn format(self: CreateGuildStickerFormBody, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        if (comptime !std.mem.eql(u8, fmt, "form")) {
            @compileError("CreateGuildStickerFormBody.format should only be called with fmt string {form}");
        }
        try rest.writeMultipartFormDataBody(self, "file", writer);
    }
};
