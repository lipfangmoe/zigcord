const std = @import("std");
const rest = @import("../root.zig").rest;

const ApiClient = @This();

rest_client: rest.Client,

pub fn init(rest_client: rest.Client) ApiClient {
    return ApiClient{ .rest_client = rest_client };
}

pub usingnamespace @import("./endpoints.zig");
