const std = @import("std");
const deancord = @import("../../root.zig");
const model = deancord.model;
const rest = deancord.rest;
const Omittable = model.deanson.Omittable;

pub fn getGuildTemplate(
    client: *rest.Client,
    template_code: []const u8,
) !rest.Client.Result(model.GuildTemplate) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/templates/{s}", .{template_code});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(model.GuildTemplate, .GET, uri);
}

pub fn createGuildFromGuildTemplate(
    client: *rest.Client,
    template_code: []const u8,
    body: CreateGuildFromGuildTemplateBody,
) !rest.Client.Result(model.guild.Guild) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/templates/{s}", .{template_code});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBody(model.guild.Guild, .POST, uri, body, .{});
}

pub fn getGuildTemplates(
    client: *rest.Client,
    guild_id: model.Snowflake,
) !rest.Client.Result([]model.GuildTemplate) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/templates", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request([]model.GuildTemplate, .GET, uri);
}

pub fn createGuildTemplate(
    client: *rest.Client,
    guild_id: model.Snowflake,
    body: CreateGuildTemplateBody,
) !rest.Client.Result(model.GuildTemplate) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/templates", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBody(model.GuildTemplate, .GET, uri, body, .{});
}

pub fn syncGuildTemplate(
    client: *rest.Client,
    guild_id: model.Snowflake,
    template_code: []const u8,
) !rest.Client.Result(model.GuildTemplate) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/templates/{s}", .{ guild_id, template_code });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(model.GuildTemplate, .PUT, uri);
}

pub fn modifyGuildTemplate(
    client: *rest.Client,
    guild_id: model.Snowflake,
    template_code: []const u8,
    body: ModifyGuildTemplateBody,
) !rest.Client.Result(model.GuildTemplate) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/templates/{s}", .{ guild_id, template_code });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBody(model.GuildTemplate, .PATCH, uri, body, .{});
}

pub fn deleteGuildTemplate(
    client: *rest.Client,
    guild_id: model.Snowflake,
    template_code: []const u8,
) !rest.Client.Result(model.GuildTemplate) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/templates/{s}", .{ guild_id, template_code });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(model.GuildTemplate, .DELETE, uri);
}

pub const CreateGuildFromGuildTemplateBody = struct {
    name: []const u8,
    icon: Omittable(model.ImageData) = .omit,

    pub usingnamespace model.deanson.OmittableJsonMixin(@This());
};

pub const CreateGuildTemplateBody = struct {
    name: []const u8,
    description: Omittable(?[]const u8) = .omit,

    pub usingnamespace model.deanson.OmittableJsonMixin(@This());
};

pub const ModifyGuildTemplateBody = struct {
    name: Omittable([]const u8) = .omit,
    description: Omittable(?[]const u8) = .omit,

    pub usingnamespace model.deanson.OmittableJsonMixin(@This());
};
