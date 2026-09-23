const std = @import("std");
const testing = std.testing;

pub const interaction_server = @import("interaction_server");
pub const model = @import("model");
pub const rest = @import("rest");
pub const gateway = @import("gateway");
pub const jconfig = @import("jconfig");

pub const HttpInteractionServer = interaction_server.HttpServer;
pub const EndpointClient = rest.EndpointClient;
pub const GatewayClient = gateway.Client;

pub const version = @import("shared").version;

test {
    std.testing.refAllDecls(@This());
}
