const std = @import("std");
const model = @import("model");
const EndpointClient = @import("../EndpointClient.zig");
const Result = @import("../RestClient.zig").Result;
const base_url = @import("../discord_uri.zig").base_url;
const Application = model.Application;

pub fn getCurrentApplication(client: *EndpointClient) !Result(Application) {
    const uri = try std.Uri.parse(base_url ++ "/applications/@me");
    return client.rest_client.request(Application, .GET, uri);
}

pub fn editCurrentApplication(client: *EndpointClient, params: EditParams) !Result(Application) {
    const uri = try std.Uri.parse(base_url ++ "/applications/@me");
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
