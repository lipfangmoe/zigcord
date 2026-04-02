const std = @import("std");
const root = @import("../../root.zig");
const model = root.model;
const rest = root.rest;
const Application = model.Application;

pub fn getCurrentApplication(client: *rest.EndpointClient) !rest.RestClient.Result(Application) {
    const uri = try std.Uri.parse(rest.base_url ++ "/applications/@me");
    return client.rest_client.request(Application, .GET, uri);
}

pub fn editCurrentApplication(client: *rest.EndpointClient, params: EditParams) !rest.RestClient.Result(Application) {
    const uri = try std.Uri.parse(rest.base_url ++ "/applications/@me");
    return client.rest_client.requestWithJsonBody(Application, .PATCH, uri, params, .{});
}

pub const EditParams = struct {
    custom_install_url: []const u8,
    description: ?[]const u8,
    role_connections_verification_url: ?[]const u8,
    install_params: ?InstallParams,
    flags: ?model.Application.Flags,
    icon: ?union(enum) {
        remove: void,
        set: []const u8,
    },
    cover_image: ?union(enum) {
        remove: void,
        set: []const u8,
    },
    interactions_endpoint_url: []const u8,
    tags: []const []const u8,

    pub const InstallParams = struct {
        scopes: []const []const u8,
        permissions: []const u8,
    };
};
