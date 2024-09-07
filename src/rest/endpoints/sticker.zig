const deancord = @import("../../root.zig");
const std = @import("std");
const model = deancord.model;
const rest = deancord.rest;
const deanson = model.jconfig;

pub fn getSticker(
    client: *rest.Client,
    sticker_id: model.Snowflake,
) !rest.Client.Result(model.Sticker) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/stickers/{}", .{sticker_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(model.Sticker, .GET, uri);
}

pub fn listStickerPacks(
    client: *rest.Client,
) !rest.Client.Result(ListStickerPacksResponse) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/sticker-packs", .{});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(ListStickerPacksResponse, .GET, uri);
}

pub fn listGuildStickers(
    client: *rest.Client,
    guild_id: model.Snowflake,
) !rest.Client.Result([]const model.Sticker) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/stickers", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request([]const model.Sticker, .GET, uri);
}

pub fn getGuildSticker(
    client: *rest.Client,
    guild_id: model.Snowflake,
    sticker_id: model.Sticker,
) !rest.Client.Result(model.Sticker) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/stickers/{}", .{ guild_id, sticker_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(model.Sticker, .GET, uri);
}

pub fn createGuildSticker(
    client: *rest.Client,
    guild_id: model.Snowflake,
    sticker_id: model.Snowflake,
) !rest.Client.Result(model.Sticker) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/stickers/{}", .{ guild_id, sticker_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(model.Sticker, .GET, uri);
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
