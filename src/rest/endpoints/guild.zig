const std = @import("std");
const deancord = @import("../../root.zig");
const model = deancord.model;
const rest = deancord.rest;
const jconfig = deancord.jconfig;
const Omittable = jconfig.Omittable;
const Guild = model.guild.Guild;

pub fn createGuild(
    client: *rest.Client,
    body: CreateGuildBody,
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

        pub usingnamespace rest.QueryStringFormatMixin(@This());
    };
    const query = Query{ .with_counts = with_counts };
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}?{query}", .{ guild_id, query });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(Guild, .GET, uri);
}

pub fn getGuildPreview(
    client: *rest.Client,
    guild_id: model.Snowflake,
) !rest.Client.Result(model.guild.Preview) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/preview", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(model.guild.Preview, .GET, uri);
}

pub fn modifyGuild(
    client: *rest.Client,
    guild_id: model.Snowflake,
    body: ModifyGuildBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(Guild) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/preview", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndAuditLogReason(Guild, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn deleteGuild(
    client: *rest.Client,
    guild_id: model.Snowflake,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(void, .DELETE, uri);
}

pub fn getGuildChannels(
    client: *rest.Client,
    guild_id: model.Snowflake,
) !rest.Client.Result([]model.Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/channels", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request([]model.Channel, .GET, uri);
}

pub fn createGuildChannel(
    client: *rest.Client,
    guild_id: model.Snowflake,
    body: CreateGuildChannelBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(model.Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/channels", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndAuditLogReason(model.Channel, .POST, uri, body, .{}, audit_log_reason);
}

pub fn modifyGuildChannelPositions(
    client: *rest.Client,
    guild_id: model.Snowflake,
    body: []const ModifyGuildChannelPositionsBodyEntry,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/channels", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBody(void, .PATCH, uri, body, .{});
}

pub fn listActiveGuildThreads(
    client: *rest.Client,
    guild_id: model.Snowflake,
    body: ListActiveGuildThreadsBody,
) !rest.Client.Result([]const model.Channel) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/threads/active", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBody([]const model.Channel, .GET, uri, body, .{});
}

pub fn getGuildMember(
    client: *rest.Client,
    guild_id: model.Snowflake,
    user_id: model.Snowflake,
) !rest.Client.Result(model.guild.Member) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/members/{}", .{ guild_id, user_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(model.guild.Member, .GET, uri);
}

pub fn listGuildMembers(
    client: *rest.Client,
    guild_id: model.Snowflake,
    query: ListGuildMembersParams,
) !rest.Client.Result(model.guild.Member) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/members?{query}", .{ guild_id, query });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(model.guild.Member, .GET, uri);
}

pub fn searchGuildMembers(
    client: *rest.Client,
    guild_id: model.Snowflake,
    query: SearchGuildMembersParams,
) !rest.Client.Result(model.guild.Member) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/members/search?{query}", .{ guild_id, query });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(model.guild.Member, .GET, uri);
}

pub fn addGuildMember(
    client: *rest.Client,
    guild_id: model.Snowflake,
    user_id: model.Snowflake,
    body: AddGuildMemberBody,
) !rest.Client.Result(model.guild.Member) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/members/{}", .{ guild_id, user_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBody(model.guild.Member, .PUT, uri, body, .{});
}

pub fn modifyGuildMember(
    client: *rest.Client,
    guild_id: model.Snowflake,
    user_id: model.Snowflake,
    body: ModifyGuildMemberBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(model.guild.Member) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/members/{}", .{ guild_id, user_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndAuditLogReason(model.guild.Member, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn modifyCurrentMember(
    client: *rest.Client,
    guild_id: model.Snowflake,
    body: ModifyGuildMemberBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(model.guild.Member) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/members/@me", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndAuditLogReason(model.guild.Member, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn addGuildMemberRole(
    client: *rest.Client,
    guild_id: model.Snowflake,
    user_id: model.Snowflake,
    role_id: model.Snowflake,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/members/{}/roles/{}", .{ guild_id, user_id, role_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithAuditLogReason(void, .PUT, uri, audit_log_reason);
}

pub fn removeGuildmemberRole(
    client: *rest.Client,
    guild_id: model.Snowflake,
    user_id: model.Snowflake,
    role_id: model.Snowflake,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/members/{}/roles/{}", .{ guild_id, user_id, role_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithAuditLogReason(void, .DELETE, uri, audit_log_reason);
}

pub fn removeGuildMember(
    client: *rest.Client,
    guild_id: model.Snowflake,
    user_id: model.Snowflake,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/members/{}", .{ guild_id, user_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithAuditLogReason(void, .DELETE, uri, audit_log_reason);
}

pub fn getGuildBans(
    client: *rest.Client,
    guild_id: model.Snowflake,
    query: GetGuildBansQuery,
) !rest.Client.Result([]model.guild.Ban) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/bans?{query}", .{ guild_id, query });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request([]model.guild.Ban, .GET, uri);
}

pub fn getGuildBan(
    client: *rest.Client,
    guild_id: model.Snowflake,
    user_id: model.Snowflake,
) !rest.Client.Result(model.guild.Ban) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/bans/{}", .{ guild_id, user_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(model.guild.Ban, .GET, uri);
}

pub fn createGuildBan(
    client: *rest.Client,
    guild_id: model.Snowflake,
    user_id: model.Snowflake,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/bans/{}", .{ guild_id, user_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithAuditLogReason(void, .PUT, uri, audit_log_reason);
}

pub fn removeGuildBan(
    client: *rest.Client,
    guild_id: model.Snowflake,
    user_id: model.Snowflake,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/bans/{}", .{ guild_id, user_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithAuditLogReason(void, .DELETE, uri, audit_log_reason);
}

pub fn bulkGuildBan(
    client: *rest.Client,
    guild_id: model.Snowflake,
    body: BulkGuildBanBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(BulkGuildBanResponse) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/bulk-ban", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndAuditLogReason(BulkGuildBanResponse, .POST, uri, body, .{}, audit_log_reason);
}

pub fn getGuildRoles(
    client: *rest.Client,
    guild_id: model.Snowflake,
) !rest.Client.Result([]model.Role) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/roles", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request([]model.Role, .GET, uri);
}

pub fn createGuildRole(
    client: *rest.Client,
    guild_id: model.Snowflake,
    body: CreateGuildRoleBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result([]model.Role) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/roles", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndAuditLogReason([]model.Role, .POST, uri, body, .{}, audit_log_reason);
}

pub fn modifyGuildRolePositions(
    client: *rest.Client,
    guild_id: model.Snowflake,
    body: []const ModifyGuildRolePositionsBodyEntry,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result([]model.Role) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/roles", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndAuditLogReason([]model.Role, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn modifyGuildRole(
    client: *rest.Client,
    guild_id: model.Snowflake,
    role_id: model.Snowflake,
    body: ModifyGuildRoleBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(model.Role) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/roles/{}", .{ guild_id, role_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndAuditLogReason(model.Role, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn modifyGuildMfaLevel(
    client: *rest.Client,
    guild_id: model.Snowflake,
    body: ModifyGuildMfaLevelBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(model.guild.MfaLevel) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/mfa", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndAuditLogReason(model.guild.MfaLevel, .POST, uri, body, .{}, audit_log_reason);
}

pub fn deleteGuildRole(
    client: *rest.Client,
    guild_id: model.Snowflake,
    role_id: model.Snowflake,
    body: ModifyGuildMfaLevelBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(model.guild.MfaLevel) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/roles/{}", .{ guild_id, role_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndAuditLogReason(model.guild.MfaLevel, .DELETE, uri, body, .{}, audit_log_reason);
}

pub fn getGuildPruneCount(
    client: *rest.Client,
    guild_id: model.Snowflake,
    query: GetGuildPruneCountQuery,
) !rest.Client.Result(GetGuildPruneCountResponse) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/prune?{query}", .{ guild_id, query });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(GetGuildPruneCountResponse, .GET, uri);
}

pub fn beginGuildPrune(
    client: *rest.Client,
    guild_id: model.Snowflake,
    body: BeginGuildPruneBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(BeginGuildPruneResponse) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/prune", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndAuditLogReason(BeginGuildPruneResponse, .GET, uri, body, .{}, audit_log_reason);
}

pub fn getGuildVoiceRegions(
    client: *rest.Client,
    guild_id: model.Snowflake,
) !rest.Client.Result([]model.voice.Region) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/regions", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request([]model.voice.Region, .GET, uri);
}

pub fn getGuildInvites(
    client: *rest.Client,
    guild_id: model.Snowflake,
) !rest.Client.Result([]model.Invite) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/invites", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request([]model.Invite, .GET, uri);
}

pub fn getGuildIntegrations(
    client: *rest.Client,
    guild_id: model.Snowflake,
) !rest.Client.Result([]model.guild.Integration) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/integrations", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request([]model.guild.Integration, .GET, uri);
}

pub fn deleteGuildIntegration(
    client: *rest.Client,
    guild_id: model.Snowflake,
    integration_id: model.Snowflake,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/integrations/{}", .{ guild_id, integration_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithAuditLogReason(void, .DELETE, uri, audit_log_reason);
}

pub fn getGuildWidgetSettings(
    client: *rest.Client,
    guild_id: model.Snowflake,
) !rest.Client.Result(model.guild.WidgetSettings) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/widget", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(model.guild.WidgetSettings, .GET, uri);
}

pub fn modifyGuildWidget(
    client: *rest.Client,
    guild_id: model.Snowflake,
    body: ModifyGuildWidgetBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(model.guild.WidgetSettings) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/widget", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndAuditLogReason(model.guild.WidgetSettings, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn getGuildWidget(
    client: *rest.Client,
    guild_id: model.Snowflake,
) !rest.Client.Result(model.guild.WidgetSettings) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/widget.json", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(model.guild.WidgetSettings, .GET, uri);
}

pub fn getGuildVanityUrl(
    client: *rest.Client,
    guild_id: model.Snowflake,
) !rest.Client.Result(jconfig.Partial(model.Invite)) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/vanity-url", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(jconfig.Partial(model.Invite), .GET, uri);
}

/// Because this endpoint is unauthenticated and does not return JSON (it returns a PNG), `std.http.Client.Request` is
/// returned instead.
///
/// This method automatically calls `.send()` and `.wait()` on the request, it is the callers responsibility
/// to call `.reader()` (to read the PNG) and `.deinit()`. Does no error handling on the HTTP response.
pub fn getGuildWidgetImage(
    client: *rest.Client,
    guild_id: model.Snowflake,
    query: GetGuildWidgetImageQuery,
) !std.http.Client.Request {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/widget.png?{query}", .{ guild_id, query });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    var server_header_buffer: [4098]u8 = undefined;
    var request = try client.client.open(.GET, uri, .{ .server_header_buffer = &server_header_buffer });
    try request.send();
    try request.wait();

    return request;
}

pub fn getGuildWelcomeScreen(
    client: *rest.Client,
    guild_id: model.Snowflake,
) !rest.Client.Result(model.guild.WelcomeScreen) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/welcome-screen", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(model.guild.WelcomeScreen, .GET, uri);
}

pub fn modifyGuildWelcomeScreen(
    client: *rest.Client,
    guild_id: model.Snowflake,
    body: ModifyGuildWelcomeScreenBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(model.guild.WelcomeScreen) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/welcome-screen", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndAuditLogReason(model.guild.WelcomeScreen, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn getGuildOnboarding(
    client: *rest.Client,
    guild_id: model.Snowflake,
) !rest.Client.Result(model.guild.Onboarding) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/onboarding", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.request(model.guild.Onboarding, .GET, uri);
}

pub fn modifyGuildOnboarding(
    client: *rest.Client,
    guild_id: model.Snowflake,
    body: ModifyGuildOnboardingBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(model.guild.Onboarding) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/onboarding", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndAuditLogReason(model.guild.Onboarding, .PUT, uri, body, .{}, audit_log_reason);
}

pub fn modifyCurrentUserVoiceState(
    client: *rest.Client,
    guild_id: model.Snowflake,
    body: ModifyCurrentUserVoiceStateBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/voice-states/@me", .{guild_id});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndAuditLogReason(void, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn modifyUserVoiceState(
    client: *rest.Client,
    guild_id: model.Snowflake,
    user_id: model.Snowflake,
    body: ModifyUserVoiceStateBody,
    audit_log_reason: ?[]const u8,
) !rest.Client.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/guilds/{}/voice-states/{}", .{ guild_id, user_id });
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.requestWithValueBodyAndAuditLogReason(void, .PATCH, uri, body, .{}, audit_log_reason);
}

// BODY / QUERY CONTRACTS

pub const CreateGuildBody = struct {
    name: []const u8,
    region: model.jconfig.Omittable(?[]const u8) = .omit,
    icon: Omittable(?model.ImageData) = .omit,
    verification_level: Omittable(model.guild.VerificationLevel) = .omit,
    default_message_notifications: Omittable(model.guild.MessageNotificationLevel) = .omit,
    explicit_content_Filter: Omittable(model.guild.ExplicitContentFilterLevel) = .omit,
    roles: Omittable([]const model.Role) = .omit,
    channels: Omittable([]const jconfig.Partial(model.Channel)) = .omit,
    afk_channel_id: Omittable(model.Snowflake) = .omit,
    afk_timeout: Omittable(model.Snowflake) = .omit,
    system_channel_id: Omittable(model.Snowflake) = .omit,
    system_channel_flags: Omittable(model.guild.SystemChannelFlags) = .omit,

    pub const jsonStringify = model.jconfig.stringifyWithOmit;
};

pub const ModifyGuildBody = struct {
    name: Omittable([]const u8) = .omit,
    region: Omittable(?[]const u8) = .omit,
    verification_level: Omittable(?model.guild.VerificationLevel) = .omit,
    default_message_notifications: Omittable(?model.guild.MessageNotificationLevel) = .omit,
    explicit_content_filter: Omittable(?model.guild.ExplicitContentFilterLevel) = .omit,
    afk_channel_id: Omittable(model.Snowflake) = .omit,
    afk_timeout: Omittable(model.Snowflake) = .omit,
    icon: Omittable(?model.ImageData) = .omit,
    owner_id: Omittable(model.Snowflake) = .omit,
    splash: Omittable(?model.ImageData) = .omit,
    discovery_splash: Omittable(?model.ImageData) = .omit,
    banner: Omittable(?model.ImageData) = .omit,
    system_channel_id: Omittable(model.Snowflake) = .omit,
    system_channel_flags: Omittable(model.guild.SystemChannelFlags) = .omit,
    rules_channel_id: Omittable(?model.Snowflake) = .omit,
    public_updates_channel_id: Omittable(?model.Snowflake) = .omit,
    /// https://discord.com/developers/docs/reference#locales
    preferred_locale: Omittable([]const u8) = .omit,
    /// https://discord.com/developers/docs/resources/guild#guild-object-guild-features
    features: Omittable([]const []const u8) = .omit,
    description: Omittable(?[]const u8) = .omit,
    premium_progress_bar_enabled: Omittable(bool) = .omit,
    safety_alerts_channel_id: Omittable(?model.Snowflake) = .omit,

    pub const jsonStringify = model.jconfig.stringifyWithOmit;
};

const CreateGuildChannelBody = struct {
    name: []const u8,
    type: Omittable(?model.Channel.Type) = .omit,
    topic: Omittable(?[]const u8) = .omit,
    bitrate: Omittable(?i64) = .omit,
    user_limit: Omittable(?i64) = .omit,
    rate_limit_per_user: Omittable(?i64) = .omit,
    position: Omittable(?i64) = .omit,
    permission_overwrites: Omittable(?[]const jconfig.Partial(model.Channel.PermissionOverwrite)) = .omit,
    parent_id: Omittable(?model.Snowflake) = .omit,
    nsfw: Omittable(?bool) = .omit,
    rtc_region: Omittable(?[]const u8) = .omit,
    video_quality_mode: Omittable(?i64) = .omit,
    default_auto_archive_duration: Omittable(?i64) = .omit,
    default_reaction_emoji: Omittable(?model.Channel.DefaultReaction) = .omit,
    available_tags: Omittable(?[]const model.Channel.Tag) = .omit,
    default_sort_order: Omittable(?model.Channel.SortOrder) = .omit,
    default_forum_layout: Omittable(?model.Channel.ForumLayout) = .omit,
    default_thread_rate_limit_per_user: Omittable(?i64) = .omit,

    pub const jsonStringify = model.jconfig.stringifyWithOmit;
};

pub const ModifyGuildChannelPositionsBodyEntry = struct {
    id: model.Snowflake,
    position: Omittable(?i64) = .omit,
    lock_permissions: Omittable(?bool) = .omit,
    parent_id: Omittable(?model.Snowflake) = .omit,

    pub const jsonStringify = model.jconfig.stringifyWithOmit;
};

pub const ListActiveGuildThreadsBody = struct {
    threads: []const model.Channel,
    members: []const model.Channel.ThreadMember,
};

pub const ListGuildMembersParams = struct {
    limit: ?i64 = null,
    after: ?model.Snowflake = null,

    pub usingnamespace rest.QueryStringFormatMixin(@This());
};

pub const SearchGuildMembersParams = struct {
    query: []const u8,
    limit: ?i64 = null,

    pub usingnamespace rest.QueryStringFormatMixin(@This());
};

pub const AddGuildMemberBody = struct {
    access_token: []const u8,
    nick: Omittable([]const u8) = .omit,
    roles: Omittable([]const model.Snowflake) = .omit,
    mute: Omittable(bool) = .omit,
    deaf: Omittable(bool) = .omit,

    pub const jsonStringify = model.jconfig.stringifyWithOmit;
};

pub const ModifyGuildMemberBody = struct {
    nick: Omittable(?[]const u8) = .omit,
    roles: Omittable(?[]const model.Snowflake) = .omit,
    mute: Omittable(?bool) = .omit,
    deaf: Omittable(?bool) = .omit,
    channel_id: Omittable(?model.Snowflake) = .omit,
    comunication_disabled_until: Omittable(?[]const u8) = .omit,
    flags: Omittable(?model.guild.Member.Flags) = .omit,

    pub const jsonStringify = model.jconfig.stringifyWithOmit;
};

pub const GetGuildBansQuery = struct {
    limit: ?i64 = null,
    before: ?model.Snowflake = null,
    after: ?model.Snowflake = null,

    pub usingnamespace rest.QueryStringFormatMixin(@This());
};

pub const BulkGuildBanBody = struct {
    user_ids: []const model.Snowflake,
    delete_message_seconds: Omittable(i64) = .omit,

    pub const jsonStringify = model.jconfig.stringifyWithOmit;
};

pub const BulkGuildBanResponse = struct {
    banned_users: []model.Snowflake,
    failed_users: []model.Snowflake,
};

pub const CreateGuildRoleBody = struct {
    name: Omittable([]const u8) = .omit,
    permissions: Omittable(model.Permissions) = .omit,
    color: Omittable(i64) = .omit,
    hoist: Omittable(bool) = .omit,
    icon: Omittable(?model.ImageData) = .omit,
    unicode_emoji: Omittable(?[]const u8) = .omit,
    mentionable: Omittable(bool) = .omit,

    pub const jsonStringify = model.jconfig.stringifyWithOmit;
};

pub const ModifyGuildRolePositionsBodyEntry = struct {
    id: model.Snowflake,
    position: Omittable(?i64) = .omit,

    pub const jsonStringify = model.jconfig.stringifyWithOmit;
};

pub const ModifyGuildRoleBody = struct {
    name: Omittable(?[]const u8) = .omit,
    permissions: Omittable(?model.Permissions) = .omit,
    color: Omittable(?i64) = .omit,
    hoist: Omittable(?bool) = .omit,
    icon: Omittable(?model.ImageData) = .omit,
    unicode_emoji: Omittable(?[]const u8) = .omit,
    mentionable: Omittable(?bool) = .omit,

    pub const jsonStringify = model.jconfig.stringifyWithOmit;
};

pub const ModifyGuildMfaLevelBody = struct {
    level: model.guild.MfaLevel,
};

pub const GetGuildPruneCountQuery = struct {
    days: ?i64 = null,
    include_roles: ?[]const model.Snowflake = null,

    pub fn format(self: GetGuildPruneCountQuery, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        comptime {
            if (!std.mem.eql(u8, fmt, "query")) {
                @compileError("type GetGuildPruneCountQuery may only be formatted with the {query} format specifier");
            }
        }

        var ampersand = false;
        if (self.days) |days| {
            try std.fmt.format(writer, "days={d}", .{days});
            ampersand = true;
        }

        if (self.include_roles) |include_roles| {
            if (ampersand) {
                try writer.writeByte('&');
            }

            var comma = false;
            for (include_roles) |role| {
                if (comma) {
                    try std.fmt.format(writer, ",{}", .{role});
                } else {
                    try std.fmt.format(writer, "{}", .{role});
                    comma = true;
                }
            }
        }
    }
};

pub const GetGuildPruneCountResponse = struct {
    pruned: i64,
};

pub const BeginGuildPruneResponse = struct {
    pruned: ?i64,
};

pub const BeginGuildPruneBody = struct {
    days: Omittable(i64) = .omit,
    compute_prune_count: Omittable(bool) = .omit,
    include_roles: Omittable([]const model.Snowflake) = .omit,
    reason: Omittable([]const u8) = .omit,

    pub const jsonStringify = model.jconfig.stringifyWithOmit;
};

pub const ModifyGuildWidgetBody = struct {
    enabled: Omittable(bool) = .omit,
    channel_id: Omittable(?model.Snowflake) = .omit,

    pub const jsonStringify = model.jconfig.stringifyWithOmit;
};

pub const GetGuildWidgetImageQuery = struct {
    style: StyleOption,

    pub const StyleOption = enum {
        shield,
        banner1,
        banner2,
        banner3,
        banner4,

        pub fn format(self: StyleOption, comptime _: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            try std.fmt.formatBuf(@tagName(self), options, writer);
        }
    };

    pub usingnamespace rest.QueryStringFormatMixin(@This());
};

pub const ModifyGuildWelcomeScreenBody = struct {
    enabled: Omittable(?bool) = .omit,
    welcome_channels: Omittable(?[]const model.guild.WelcomeScreen.WelcomeChannel) = .omit,
    description: Omittable(?[]const u8) = .omit,

    pub const jsonStringify = model.jconfig.stringifyWithOmit;
};

pub const ModifyGuildOnboardingBody = struct {
    prompts: []const model.guild.Onboarding.Prompt,
    default_channel_ids: []const model.Snowflake,
    enabled: bool,
    mode: model.guild.Onboarding.Mode,
};

pub const ModifyCurrentUserVoiceStateBody = struct {
    channel_id: Omittable(model.Snowflake) = .omit,
    suppress: Omittable(bool) = .omit,
    request_to_speak_timestamp: Omittable(?[]const u8) = .omit,

    pub const jsonStringify = model.jconfig.stringifyWithOmit;
};

pub const ModifyUserVoiceStateBody = struct {
    channel_id: model.Snowflake,
    suppress: Omittable(bool) = .omit,

    pub const jsonStringify = model.jconfig.stringifyWithOmit;
};
