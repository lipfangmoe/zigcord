const std = @import("std");
const model = @import("model");
const jconfig = @import("jconfig");
const EndpointClient = @import("../EndpointClient.zig");
const RestClient = @import("../RestClient.zig");
const allocDiscordUriStr = @import("../discord_uri.zig").allocDiscordUriStr;
const queryFmt = @import("../query_strings.zig").fmt;
const Result = RestClient.Result;

pub fn updateApplicationIdentityProfile(
    client: *EndpointClient,
    application_id: model.Snowflake,
    user_id: model.Snowflake,
    provider_issued_user_id: []const u8,
    body: UpdateApplicationIdentityProfileBody,
) !Result(model.ApplicationIdentity.Profile) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/applications/{f}/users/{f}/identities/{s}/profile", .{ application_id, user_id, provider_issued_user_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithJsonBody(model.ApplicationIdentity.Profile, .PATCH, uri, body, .{});
}

pub fn getApplicationIdentityProfile(
    client: *EndpointClient,
    application_id: model.Snowflake,
    user_id: model.Snowflake,
    provider_issued_user_id: []const u8,
) !Result(model.ApplicationIdentity.Profile) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/applications/{f}/users/{f}/identities/{s}/profile", .{ application_id, user_id, provider_issued_user_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.ApplicationIdentity.Profile, .GET, uri);
}

pub fn getApplicationIdentitiesByUserId(
    client: *EndpointClient,
    user_id: model.Snowflake,
    application_id: model.Snowflake,
) !Result(WrappedApplicationIdentites) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/users/{f}/application-identities/{f}", .{ user_id, application_id });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(WrappedApplicationIdentites, .GET, uri);
}

pub fn getApplicationIdentitiesByExternalId(
    client: *EndpointClient,
    application_id: model.Snowflake,
    provider_type: []const u8,
    provider_issued_user_id: []const u8,
    query: GetApplicationIdentitiesByExternalIdQuery,
) !Result(WrappedApplicationIdentites) {
    const uri_str = try allocDiscordUriStr(
        client.rest_client.allocator,
        "/applications/{f}/application-identities/{s}/{s}?{f}",
        .{ application_id, provider_type, provider_issued_user_id, queryFmt(query) },
    );
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(WrappedApplicationIdentites, .GET, uri);
}

pub fn deleteApplicationIdentity(
    client: *EndpointClient,
    user_id: model.Snowflake,
    application_id: model.Snowflake,
    provider_type: []const u8,
    provider_issued_user_id: []const u8,
    body: DeleteApplicationidentityBody,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(
        client.rest_client.allocator,
        "/users/{f}/application-identities/{f}/{s}/{s}/delete",
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
};

pub const DeleteApplicationidentityBody = struct {
    provider_id: jconfig.Omittable([]const u8) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};
