const std = @import("std");
const model = @import("model");
const EndpointClient = @import("../EndpointClient.zig");
const RestClient = @import("../RestClient.zig");
const Result = RestClient.Result;
const allocDiscordUriStr = @import("../discord_uri.zig").allocDiscordUriStr;
const jconfig = @import("jconfig");

pub fn getGuildTemplate(
    client: *EndpointClient,
    template_code: []const u8,
) !Result(model.GuildTemplate) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/templates/{s}", .{template_code});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.GuildTemplate, .GET, uri);
}

pub fn createGuildFromGuildTemplate(
    client: *EndpointClient,
    template_code: []const u8,
    body: CreateGuildFromGuildTemplateBody,
) !Result(model.guild.Guild) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/templates/{s}", .{template_code});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBody(model.guild.Guild, .POST, uri, body, .{});
}

pub fn getGuildTemplates(
    client: *EndpointClient,
    guild_id: model.Snowflake,
) !Result([]model.GuildTemplate) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/templates", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]model.GuildTemplate, .GET, uri);
}

pub fn createGuildTemplate(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    body: CreateGuildTemplateBody,
) !Result(model.GuildTemplate) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/templates", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBody(model.GuildTemplate, .POST, uri, body, .{});
}

pub fn syncGuildTemplate(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    template_code: []const u8,
) !Result(model.GuildTemplate) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/templates/{s}", .{ guild_id, template_code });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.GuildTemplate, .PUT, uri);
}

pub fn modifyGuildTemplate(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    template_code: []const u8,
    body: ModifyGuildTemplateBody,
) !Result(model.GuildTemplate) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/templates/{s}", .{ guild_id, template_code });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBody(model.GuildTemplate, .PATCH, uri, body, .{});
}

pub fn deleteGuildTemplate(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    template_code: []const u8,
) !Result(model.GuildTemplate) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/templates/{s}", .{ guild_id, template_code });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.GuildTemplate, .DELETE, uri);
}

pub const CreateGuildFromGuildTemplateBody = struct {
    name: []const u8,
    icon: jconfig.Omittable(model.DataUri) = .omit,

    pub const jsonStringify = jconfig.OmittableFieldsMixin(@This()).jsonStringify;
};

pub const CreateGuildTemplateBody = struct {
    name: []const u8,
    description: jconfig.Omittable(?[]const u8) = .omit,

    pub const jsonStringify = jconfig.OmittableFieldsMixin(@This()).jsonStringify;
};

pub const ModifyGuildTemplateBody = struct {
    name: jconfig.Omittable([]const u8) = .omit,
    description: jconfig.Omittable(?[]const u8) = .omit,

    pub const jsonStringify = jconfig.OmittableFieldsMixin(@This()).jsonStringify;
};
