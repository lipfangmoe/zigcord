const std = @import("std");
const model = @import("model");
const jconfig = @import("jconfig");
const EndpointClient = @import("../EndpointClient.zig");
const RestClient = @import("../RestClient.zig");
const Result = RestClient.Result;
const allocDiscordUriStr = @import("../discord_uri.zig").allocDiscordUriStr;
const Omittable = jconfig.Omittable;
const Guild = model.guild.Guild;
const query_strings = @import("../query_strings.zig");

pub fn getGuild(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    with_counts: ?bool,
) !Result(Guild) {
    const Query = struct {
        with_counts: ?bool,

        pub const format = query_strings.formatAsQueryString;
    };
    const query = Query{ .with_counts = with_counts };
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}?{f}", .{ guild_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(Guild, .GET, uri);
}

pub fn getGuildPreview(
    client: *EndpointClient,
    guild_id: model.Snowflake,
) !Result(model.guild.Preview) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/preview", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.guild.Preview, .GET, uri);
}

pub fn modifyGuild(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    body: ModifyGuildBody,
    audit_log_reason: ?[]const u8,
) !Result(Guild) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/preview", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(Guild, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn deleteGuild(
    client: *EndpointClient,
    guild_id: model.Snowflake,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(void, .DELETE, uri);
}

pub fn getGuildChannels(
    client: *EndpointClient,
    guild_id: model.Snowflake,
) !Result([]model.Channel) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/channels", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]model.Channel, .GET, uri);
}

pub fn createGuildChannel(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    body: CreateGuildChannelBody,
    audit_log_reason: ?[]const u8,
) !Result(model.Channel) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/channels", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(model.Channel, .POST, uri, body, .{}, audit_log_reason);
}

pub fn modifyGuildChannelPositions(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    body: []const ModifyGuildChannelPositionsBodyEntry,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/channels", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBody(void, .PATCH, uri, body, .{});
}

pub fn listActiveGuildThreads(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    body: ListActiveGuildThreadsBody,
) !Result([]const model.Channel) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/threads/active", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBody([]const model.Channel, .GET, uri, body, .{});
}

pub fn getGuildMember(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    user_id: model.Snowflake,
) !Result(model.guild.Member) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/members/{f}", .{ guild_id, user_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.guild.Member, .GET, uri);
}

pub fn listGuildMembers(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    query: ListGuildMembersParams,
) !Result(model.guild.Member) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/members?{f}", .{ guild_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.guild.Member, .GET, uri);
}

pub fn searchGuildMembers(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    query: SearchGuildMembersParams,
) !Result(model.guild.Member) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/members/search?{f}", .{ guild_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.guild.Member, .GET, uri);
}

pub fn addGuildMember(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    user_id: model.Snowflake,
    body: AddGuildMemberBody,
) !Result(model.guild.Member) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/members/{f}", .{ guild_id, user_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBody(model.guild.Member, .PUT, uri, body, .{});
}

pub fn modifyGuildMember(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    user_id: model.Snowflake,
    body: ModifyGuildMemberBody,
    audit_log_reason: ?[]const u8,
) !Result(model.guild.Member) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/members/{f}", .{ guild_id, user_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(model.guild.Member, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn modifyCurrentMember(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    body: ModifyGuildMemberBody,
    audit_log_reason: ?[]const u8,
) !Result(model.guild.Member) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/members/@me", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(model.guild.Member, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn addGuildMemberRole(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    user_id: model.Snowflake,
    role_id: model.Snowflake,
    audit_log_reason: ?[]const u8,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/members/{f}/roles/{f}", .{ guild_id, user_id, role_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithAuditLogReason(void, .PUT, uri, audit_log_reason);
}

pub fn removeGuildMemberRole(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    user_id: model.Snowflake,
    role_id: model.Snowflake,
    audit_log_reason: ?[]const u8,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/members/{f}/roles/{f}", .{ guild_id, user_id, role_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithAuditLogReason(void, .DELETE, uri, audit_log_reason);
}

pub fn removeGuildMember(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    user_id: model.Snowflake,
    audit_log_reason: ?[]const u8,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/members/{f}", .{ guild_id, user_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithAuditLogReason(void, .DELETE, uri, audit_log_reason);
}

pub fn getGuildBans(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    query: GetGuildBansQuery,
) !Result([]model.guild.Ban) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/bans?{f}", .{ guild_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]model.guild.Ban, .GET, uri);
}

pub fn getGuildBan(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    user_id: model.Snowflake,
) !Result(model.guild.Ban) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/bans/{f}", .{ guild_id, user_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.guild.Ban, .GET, uri);
}

pub fn createGuildBan(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    user_id: model.Snowflake,
    body: CreateGuildBanBody,
    audit_log_reason: ?[]const u8,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/bans/{f}", .{ guild_id, user_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(void, .PUT, uri, body, .{}, audit_log_reason);
}

pub fn removeGuildBan(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    user_id: model.Snowflake,
    audit_log_reason: ?[]const u8,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/bans/{f}", .{ guild_id, user_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithAuditLogReason(void, .DELETE, uri, audit_log_reason);
}

pub fn bulkGuildBan(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    body: BulkGuildBanBody,
    audit_log_reason: ?[]const u8,
) !Result(BulkGuildBanResponse) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/bulk-ban", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(BulkGuildBanResponse, .POST, uri, body, .{}, audit_log_reason);
}

pub fn getGuildRoles(
    client: *EndpointClient,
    guild_id: model.Snowflake,
) !Result([]model.Role) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/roles", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]model.Role, .GET, uri);
}

pub fn getGuildRole(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    role_id: model.Snowflake,
) !Result(model.Role) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/roles/{f}", .{ guild_id, role_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Role, .GET, uri);
}

pub fn getGuildRoleMemberCounts(
    client: *EndpointClient,
    guild_id: model.Snowflake,
) !Result(std.json.ArrayHashMap(u64)) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/roles/member_counts", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(std.json.ArrayHashMap(u64), .GET, uri);
}

pub fn createGuildRole(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    body: CreateGuildRoleBody,
    audit_log_reason: ?[]const u8,
) !Result([]model.Role) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/roles", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason([]model.Role, .POST, uri, body, .{}, audit_log_reason);
}

pub fn modifyGuildRolePositions(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    body: []const ModifyGuildRolePositionsBodyEntry,
    audit_log_reason: ?[]const u8,
) !Result([]model.Role) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/roles", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason([]model.Role, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn modifyGuildRole(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    role_id: model.Snowflake,
    body: ModifyGuildRoleBody,
    audit_log_reason: ?[]const u8,
) !Result(model.Role) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/roles/{f}", .{ guild_id, role_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(model.Role, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn modifyGuildMfaLevel(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    body: ModifyGuildMfaLevelBody,
    audit_log_reason: ?[]const u8,
) !Result(model.guild.MfaLevel) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/mfa", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(model.guild.MfaLevel, .POST, uri, body, .{}, audit_log_reason);
}

pub fn deleteGuildRole(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    role_id: model.Snowflake,
    body: ModifyGuildMfaLevelBody,
    audit_log_reason: ?[]const u8,
) !Result(model.guild.MfaLevel) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/roles/{f}", .{ guild_id, role_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(model.guild.MfaLevel, .DELETE, uri, body, .{}, audit_log_reason);
}

pub fn getGuildPruneCount(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    query: GetGuildPruneCountQuery,
) !Result(GetGuildPruneCountResponse) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/prune?{f}", .{ guild_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(GetGuildPruneCountResponse, .GET, uri);
}

pub fn beginGuildPrune(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    body: BeginGuildPruneBody,
    audit_log_reason: ?[]const u8,
) !Result(BeginGuildPruneResponse) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/prune", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(BeginGuildPruneResponse, .GET, uri, body, .{}, audit_log_reason);
}

pub fn getGuildVoiceRegions(
    client: *EndpointClient,
    guild_id: model.Snowflake,
) !Result([]model.voice.Region) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/regions", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]model.voice.Region, .GET, uri);
}

pub fn getGuildInvites(
    client: *EndpointClient,
    guild_id: model.Snowflake,
) !Result([]model.Invite) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/invites", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]model.Invite, .GET, uri);
}

pub fn getGuildIntegrations(
    client: *EndpointClient,
    guild_id: model.Snowflake,
) !Result([]model.guild.Integration) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/integrations", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]model.guild.Integration, .GET, uri);
}

pub fn deleteGuildIntegration(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    integration_id: model.Snowflake,
    audit_log_reason: ?[]const u8,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/integrations/{f}", .{ guild_id, integration_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithAuditLogReason(void, .DELETE, uri, audit_log_reason);
}

pub fn getGuildWidgetSettings(
    client: *EndpointClient,
    guild_id: model.Snowflake,
) !Result(model.guild.WidgetSettings) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/widget", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.guild.WidgetSettings, .GET, uri);
}

pub fn modifyGuildWidget(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    body: ModifyGuildWidgetBody,
    audit_log_reason: ?[]const u8,
) !Result(model.guild.WidgetSettings) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/widget", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(model.guild.WidgetSettings, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn getGuildWidget(
    client: *EndpointClient,
    guild_id: model.Snowflake,
) !Result(model.guild.WidgetSettings) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/widget.json", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.guild.WidgetSettings, .GET, uri);
}

pub fn getGuildVanityUrl(
    client: *EndpointClient,
    guild_id: model.Snowflake,
) !Result(jconfig.Partial(model.Invite)) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/vanity-url", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(jconfig.Partial(model.Invite), .GET, uri);
}

/// Because this endpoint is unauthenticated and does not return JSON (it returns a PNG), `std.http.client.rest_client.request` is
/// returned instead.
pub fn getGuildWidgetImage(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    query: GetGuildWidgetImageQuery,
) !std.http.Client.Response {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/widget.png?{f}", .{ guild_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    var request = try client.rest_client.client.request(.GET, uri, .{});
    try request.sendBodiless();
    const response = try request.receiveHead(&.{});

    return response;
}

pub fn getGuildWelcomeScreen(
    client: *EndpointClient,
    guild_id: model.Snowflake,
) !Result(model.guild.WelcomeScreen) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/welcome-screen", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.guild.WelcomeScreen, .GET, uri);
}

pub fn modifyGuildWelcomeScreen(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    body: ModifyGuildWelcomeScreenBody,
    audit_log_reason: ?[]const u8,
) !Result(model.guild.WelcomeScreen) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/welcome-screen", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(model.guild.WelcomeScreen, .PATCH, uri, body, .{}, audit_log_reason);
}

pub fn getGuildOnboarding(
    client: *EndpointClient,
    guild_id: model.Snowflake,
) !Result(model.guild.Onboarding) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/onboarding", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.guild.Onboarding, .GET, uri);
}

pub fn modifyGuildOnboarding(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    body: ModifyGuildOnboardingBody,
    audit_log_reason: ?[]const u8,
) !Result(model.guild.Onboarding) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/onboarding", .{guild_id});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBodyAndAuditLogReason(model.guild.Onboarding, .PUT, uri, body, .{}, audit_log_reason);
}

pub fn searchGuildMessages(
    client: *EndpointClient,
    guild_id: model.Snowflake,
    query: SearchGuildMessagesQueryParams,
) !Result([]const model.Message) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/guilds/{f}/messages/search?{f}", .{ guild_id, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request([]const model.Message, .GET, uri);
}

// BODY / QUERY CONTRACTS

pub const ModifyGuildBody = struct {
    name: Omittable([]const u8) = .omit,
    region: Omittable(?[]const u8) = .omit,
    verification_level: Omittable(?model.guild.VerificationLevel) = .omit,
    default_message_notifications: Omittable(?model.guild.MessageNotificationLevel) = .omit,
    explicit_content_filter: Omittable(?model.guild.ExplicitContentFilterLevel) = .omit,
    afk_channel_id: Omittable(model.Snowflake) = .omit,
    afk_timeout: Omittable(model.Snowflake) = .omit,
    icon: Omittable(?model.DataUri) = .omit,
    owner_id: Omittable(model.Snowflake) = .omit,
    splash: Omittable(?model.DataUri) = .omit,
    discovery_splash: Omittable(?model.DataUri) = .omit,
    banner: Omittable(?model.DataUri) = .omit,
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

    pub const jsonStringify = jconfig.stringifyWithOmit;
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

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ModifyGuildChannelPositionsBodyEntry = struct {
    id: model.Snowflake,
    position: Omittable(?i64) = .omit,
    lock_permissions: Omittable(?bool) = .omit,
    parent_id: Omittable(?model.Snowflake) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ListActiveGuildThreadsBody = struct {
    threads: []const model.Channel,
    members: []const model.Channel.ThreadMember,
};

pub const ListGuildMembersParams = struct {
    limit: ?i64 = null,
    after: ?model.Snowflake = null,

    pub const format = query_strings.formatAsQueryString;
};

pub const SearchGuildMembersParams = struct {
    query: []const u8,
    limit: ?i64 = null,

    pub const format = query_strings.formatAsQueryString;
};

pub const AddGuildMemberBody = struct {
    access_token: []const u8,
    nick: Omittable([]const u8) = .omit,
    roles: Omittable([]const model.Snowflake) = .omit,
    mute: Omittable(bool) = .omit,
    deaf: Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ModifyGuildMemberBody = struct {
    nick: Omittable(?[]const u8) = .omit,
    roles: Omittable(?[]const model.Snowflake) = .omit,
    mute: Omittable(?bool) = .omit,
    deaf: Omittable(?bool) = .omit,
    channel_id: Omittable(?model.Snowflake) = .omit,
    comunication_disabled_until: Omittable(?[]const u8) = .omit,
    flags: Omittable(?model.guild.Member.Flags) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const GetGuildBansQuery = struct {
    limit: ?i64 = null,
    before: ?model.Snowflake = null,
    after: ?model.Snowflake = null,

    pub const format = query_strings.formatAsQueryString;
};

pub const BulkGuildBanBody = struct {
    user_ids: []const model.Snowflake,
    delete_message_seconds: Omittable(i64) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
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
    icon: Omittable(?model.DataUri) = .omit,
    unicode_emoji: Omittable(?[]const u8) = .omit,
    mentionable: Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ModifyGuildRolePositionsBodyEntry = struct {
    id: model.Snowflake,
    position: Omittable(?i64) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ModifyGuildRoleBody = struct {
    name: Omittable(?[]const u8) = .omit,
    permissions: Omittable(?model.Permissions) = .omit,
    color: Omittable(?i64) = .omit,
    hoist: Omittable(?bool) = .omit,
    icon: Omittable(?model.DataUri) = .omit,
    unicode_emoji: Omittable(?[]const u8) = .omit,
    mentionable: Omittable(?bool) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ModifyGuildMfaLevelBody = struct {
    level: model.guild.MfaLevel,
};

pub const GetGuildPruneCountQuery = struct {
    days: ?i64 = null,
    include_roles: ?[]const model.Snowflake = null,

    pub fn format(self: GetGuildPruneCountQuery, writer: *std.Io.Writer) !void {
        var ampersand = false;
        if (self.days) |days| {
            try writer.print("days={d}", .{days});
            ampersand = true;
        }

        if (self.include_roles) |include_roles| {
            if (ampersand) {
                try writer.writeByte('&');
            }

            var comma = false;
            for (include_roles) |role| {
                if (comma) {
                    try writer.print(",{f}", .{role});
                } else {
                    try writer.print("{f}", .{role});
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

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ModifyGuildWidgetBody = struct {
    enabled: Omittable(bool) = .omit,
    channel_id: Omittable(?model.Snowflake) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const GetGuildWidgetImageQuery = struct {
    style: StyleOption,

    pub const StyleOption = enum {
        shield,
        banner1,
        banner2,
        banner3,
        banner4,

        pub fn format(self: StyleOption, writer: *std.Io.Writer) !void {
            try writer.print("{t}", .{self});
        }
    };

    pub const format = query_strings.formatAsQueryString;
};

pub const GetGuildImageResponse = struct {
    response: std.http.Client.Response,

    pub fn deinit(self: GetGuildImageResponse) void {
        self.response.request.deinit();
    }
};

pub const ModifyGuildWelcomeScreenBody = struct {
    enabled: Omittable(?bool) = .omit,
    welcome_channels: Omittable(?[]const model.guild.WelcomeScreen.WelcomeChannel) = .omit,
    description: Omittable(?[]const u8) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ModifyGuildOnboardingBody = struct {
    prompts: []const model.guild.Onboarding.Prompt,
    default_channel_ids: []const model.Snowflake,
    enabled: bool,
    mode: model.guild.Onboarding.Mode,
};

pub const SearchGuildMessagesQueryParams = struct {
    limit: ?i64 = null,
    offset: ?i64 = null,
    max_id: ?model.Snowflake = null,
    min_id: ?model.Snowflake = null,
    slop: ?i64 = null,
    content: ?[]const u8 = null,
    channel_id: ?[]const model.Snowflake = null,
    author_type: ?[]const AuthorType = null,
    author_id: ?[]const model.Snowflake = null,
    mentions: ?[]const model.Snowflake = null,
    mentions_role_id: ?[]const model.Snowflake = null,
    mention_everyone: ?bool = null,
    replied_to_user_id: ?[]const model.Snowflake = null,
    replied_to_message_id: ?[]const model.Snowflake = null,
    pinned: ?bool = null,
    has: ?[]const SearchHasType = null,
    embed_type: ?[]const EmbedType = null,
    embed_provider: ?[]const []const u8 = null,
    link_hostname: ?[]const []const u8 = null,
    attachment_filename: ?[]const []const u8 = null,
    attachment_extension: ?[]const []const u8 = null,
    sort_by: ?SearchSortMode = null,
    sort_order: ?[]const u8 = null,
    include_nsfw: ?bool = null,

    pub const format = query_strings.formatAsQueryString;

    pub const AuthorType = enum {
        user,
        bot,
        webhook,
        not_user,
        not_bot,
        not_webhook,

        pub fn format(self: AuthorType, writer: *std.Io.Writer) !void {
            switch (self) {
                .user, .bot, .webhook => try writer.writeAll(@tagName(self)),
                .not_user, .not_bot, .not_webhook => {
                    try writer.writeByte('_');
                    try writer.writeAll(@tagName(self)[4..]);
                },
            }
        }
    };

    pub const SearchHasType = enum {
        image,
        sound,
        video,
        file,
        sticker,
        embed,
        link,
        poll,
        snapshot,
        not_image,
        not_sound,
        not_video,
        not_file,
        not_sticker,
        not_embed,
        not_link,
        not_poll,
        not_snapshot,

        pub fn format(self: SearchHasType, writer: *std.Io.Writer) !void {
            switch (self) {
                .image,
                .sound,
                .video,
                .file,
                .sticker,
                .embed,
                .link,
                .poll,
                .snapshot,
                => try writer.writeAll(@tagName(self)),
                .not_image,
                .not_sound,
                .not_video,
                .not_file,
                .not_sticker,
                .not_embed,
                .not_link,
                .not_poll,
                .not_snapshot,
                => {
                    try writer.writeByte('_');
                    try writer.writeAll(@tagName(self)[4..]);
                },
            }
        }
    };

    pub const EmbedType = enum {
        image,
        video,
        gif,
        sound,
        article,

        pub fn format(self: EmbedType, writer: *std.Io.Writer) !void {
            try writer.writeAll(@tagName(self));
        }
    };

    pub const SearchSortMode = enum {
        timestamp,
        relevance,

        pub fn format(self: SearchSortMode, writer: *std.Io.Writer) !void {
            try writer.writeAll(@tagName(self));
        }
    };
};

pub const CreateGuildBanBody = struct {
    delete_message_seconds: jconfig.Omittable(u64) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};
