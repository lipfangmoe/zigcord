const std = @import("std");
const root = @import("../../root.zig");
const model = root.model;
const rest = root.rest;

const RestResult = rest.Client.Result;
const Client = rest.Client;
const Application = model.Application;

pub fn getCurrentApplication(client: *Client) !RestResult(Application) {
    const url = rest.base_url ++ "/application/@me";
    return client.request(Application, .GET, try std.Uri.parse(url));
}

pub fn editCurrentApplication(client: *Client, params: EditParams) !RestResult(Application) {
    const url = rest.base_url ++ "/application/@me";

    return client.requestWithValueBody(Application, .PATCH, try std.Uri.parse(url), params, .{});
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
