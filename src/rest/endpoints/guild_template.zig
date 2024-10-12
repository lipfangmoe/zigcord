const std = @import("std");
const deancord = @import("../../root.zig");
const model = deancord.model;
const rest = deancord.rest;
const jconfig = deancord.jconfig;

pub fn getGuildTemplate(
    client: *rest.ApiClient,
    template_code: []const u8,
) !rest.Client.Result(model.GuildTemplate) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/templates/{s}", .{template_code});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.GuildTemplate, .GET, uri);
}

pub fn createGuildFromGuildTemplate(
    client: *rest.ApiClient,
    template_code: []const u8,
    body: CreateGuildFromGuildTemplateBody,
) !rest.Client.Result(model.guild.Guild) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/templates/{s}", .{template_code});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBody(model.guild.Guild, .POST, uri, body, .{});
}

pub fn getGuildTemplates(
    client: *rest.ApiClient,
    guild_id: model.Snowflake,
) !rest.Client.Result([]model.GuildTemplate) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{}/templates", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]model.GuildTemplate, .GET, uri);
}

pub fn createGuildTemplate(
    client: *rest.ApiClient,
    guild_id: model.Snowflake,
    body: CreateGuildTemplateBody,
) !rest.Client.Result(model.GuildTemplate) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{}/templates", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBody(model.GuildTemplate, .GET, uri, body, .{});
}

pub fn syncGuildTemplate(
    client: *rest.ApiClient,
    guild_id: model.Snowflake,
    template_code: []const u8,
) !rest.Client.Result(model.GuildTemplate) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{}/templates/{s}", .{ guild_id, template_code });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.GuildTemplate, .PUT, uri);
}

pub fn modifyGuildTemplate(
    client: *rest.ApiClient,
    guild_id: model.Snowflake,
    template_code: []const u8,
    body: ModifyGuildTemplateBody,
) !rest.Client.Result(model.GuildTemplate) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{}/templates/{s}", .{ guild_id, template_code });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithValueBody(model.GuildTemplate, .PATCH, uri, body, .{});
}

pub fn deleteGuildTemplate(
    client: *rest.ApiClient,
    guild_id: model.Snowflake,
    template_code: []const u8,
) !rest.Client.Result(model.GuildTemplate) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/guilds/{}/templates/{s}", .{ guild_id, template_code });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.GuildTemplate, .DELETE, uri);
}

pub const CreateGuildFromGuildTemplateBody = struct {
    name: []const u8,
    icon: jconfig.Omittable(model.ImageData) = .omit,

    pub usingnamespace jconfig.OmittableFieldsMixin(@This());
};

pub const CreateGuildTemplateBody = struct {
    name: []const u8,
    description: jconfig.Omittable(?[]const u8) = .omit,

    pub usingnamespace jconfig.OmittableFieldsMixin(@This());
};

pub const ModifyGuildTemplateBody = struct {
    name: jconfig.Omittable([]const u8) = .omit,
    description: jconfig.Omittable(?[]const u8) = .omit,

    pub usingnamespace jconfig.OmittableFieldsMixin(@This());
};
