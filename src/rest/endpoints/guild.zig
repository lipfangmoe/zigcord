const model = @import("root").model;
const rest = @import("root").rest;
const std = @import("std");
const Omittable = model.deanson.Omittable;
const Guild = model.guild.Guild;

pub fn createGuild(
    client: *rest.Client,
    body: CreateGuildParams,
) !rest.Client.Result(model.guild.Guild) {
    const uri_str = rest.base_url ++ "/guilds";
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBody(model.guild.Guild, .POST, uri, body, .{});
}

pub fn getGuild(
    client: *rest.Client,
    guild_id: model.Snowflake,
    with_counts: ?bool,
) !rest.Client.Result(Guild) {
    const Query = struct {
        with_counts: ?bool,

        pub const format = rest.formatAsQueryString;
    };
    const query = Query{ .with_counts = with_counts };
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}?{}", .{ guild_id, query });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(Guild, .GET, uri);
}

pub fn getGuildPreview(
    client: *rest.Client,
    guild_id: model.Snowflake,
) !rest.Client.Result(model.guild.GuildPreview) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/preview", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(model.guild.GuildPreview, .GET, uri);
}

pub const CreateGuildParams = struct {
    name: []const u8,
    region: model.deanson.Omittable(?[]const u8) = .omit,
    /// https://discord.com/developers/docs/reference#image-data
    icon: Omittable(?[]const u8) = .omit,
    verification_level: Omittable(model.guild.Guild.VerificationLevel) = .omit,
    default_message_notifications: Omittable(Guild.MessageNotificationLevel) = .omit,
    explicit_content_Filter: Omittable(Guild.ExplicitContentFilterLevel) = .omit,
    roles: Omittable([]const model.guild.Role) = .omit,
    channels: Omittable([]const model.Channel) = .omit,
    afk_channel_id: Omittable(model.Snowflake) = .omit,
    afk_timeout: Omittable(model.Snowflake) = .omit,
    system_channel_id: Omittable(model.Snowflake) = .omit,
    system_channel_flags: Omittable(Guild.SystemChannelFlags) = .omit,
};
