//! EndpointClient is a wrapper around an HttpClient which contains methods that call Discord API endpoints.

const std = @import("std");
const zigcord = @import("../root.zig");
const rest = zigcord.rest;

const EndpointClient = @This();

rest_client: rest.RestClient,

pub usingnamespace @import("./endpoints.zig");

/// Creates a discord http client with default configuration.
///
/// Cannot be used in tests, instead use `initWithConfig` and provide a mock response from the server.
pub fn init(allocator: std.mem.Allocator, auth: zigcord.Authorization) EndpointClient {
    return initWithConfig(allocator, auth, .{});
}

/// Creates a discord http client based on a configuration
pub fn initWithConfig(allocator: std.mem.Allocator, auth: zigcord.Authorization, config: rest.RestClient.Config) EndpointClient {
    const http_client = std.http.Client{ .allocator = allocator };
    const rest_client = rest.RestClient{
        .allocator = allocator,
        .auth = auth,
        .client = http_client,
        .config = config,
    };
    return EndpointClient{ .rest_client = rest_client };
}

pub fn deinit(self: *EndpointClient) void {
    self.rest_client.deinit();
}
