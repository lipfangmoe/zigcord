const std = @import("std");
const zigcord = @import("../../root.zig");
const model = zigcord.model;
const rest = zigcord.rest;
const jconfig = zigcord.jconfig;

pub fn updateApplicationIdentityProfile(
    client: *rest.EndpointClient,
    application_id: model.Snowflake,
    user_id: model.Snowflake,
    provider_issued_user_id: []const u8,
    body: UpdateApplicationIdentityProfileBody,
) !rest.RestClient.Result(model.ApplicationIdentity.Profile) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/applications/{f}/users/{f}/identities/{f}/profile", .{ application_id, user_id, provider_issued_user_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBody(model.ApplicationIdentity.Profile, .PATCH, uri, body, .{});
}

pub fn getApplicationIdentityProfile(
    client: *rest.EndpointClient,
    application_id: model.Snowflake,
    user_id: model.Snowflake,
    provider_issued_user_id: []const u8,
) !rest.RestClient.Result(model.ApplicationIdentity.Profile) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/applications/{f}/users/{f}/identities/{f}/profile", .{ application_id, user_id, provider_issued_user_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.ApplicationIdentity.Profile, .GET, uri);
}

pub fn getApplicationIdentitiesByUserId(
    client: *rest.EndpointClient,
    user_id: model.Snowflake,
    application_id: model.Snowflake,
) !rest.RestClient.Result(WrappedApplicationIdentites) {
    const uri_str = try rest.allocDiscordUriStr(client.rest_client.allocator, "/users/{f}/application-identities/{f}", .{ user_id, application_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(WrappedApplicationIdentites, .GET, uri);
}

pub fn getApplicationIdentitiesByExternalId(
    client: *rest.EndpointClient,
    application_id: model.Snowflake,
    provider_type: []const u8,
    provider_issued_user_id: []const u8,
    query: GetApplicationIdentitiesByExternalIdQuery,
) !rest.RestClient.Result(WrappedApplicationIdentites) {
    const uri_str = try rest.allocDiscordUriStr(
        client.rest_client.allocator,
        "/applications/{application_id}/application-identities/{provider_type}/{provider_issued_user_id}?{f}",
        .{ application_id, provider_type, provider_issued_user_id, query },
    );
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(WrappedApplicationIdentites, .GET, uri);
}

pub fn deleteApplicationIdentity(
    client: *rest.EndpointClient,
    user_id: model.Snowflake,
    application_id: model.Snowflake,
    provider_type: []const u8,
    provider_issued_user_id: []const u8,
    body: DeleteApplicationidentityBody,
) !rest.RestClient.Result(void) {
    const uri_str = try rest.allocDiscordUriStr(
        client.rest_client.allocator,
        "/users/{f}/application-identities/{f}/{f}/{f}/delete",
        .{ user_id, application_id, provider_type, provider_issued_user_id },
    );
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBody(void, .POST, uri, body, .{});
}

pub const UpdateApplicationIdentityProfileBody = struct {
    username: jconfig.Omittable([]const u8) = .omit,
    data: jconfig.Omittable(model.ApplicationIdentity.ProfileData) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const WrappedApplicationIdentites = struct {
    identities: []model.ApplicationIdentity,
};

pub const GetApplicationIdentitiesByExternalIdQuery = struct {
    provider_id: ?[]const u8 = null,

    pub const format = rest.QueryStringFormatMixin(@This()).format;
};

pub const DeleteApplicationidentityBody = struct {
    provider_id: jconfig.Omittable([]const u8) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};
