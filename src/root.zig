const std = @import("std");
const testing = std.testing;

pub const model = @import("./model.zig");
pub const rest = @import("./rest.zig");
pub const gateway = @import("./gateway.zig");
pub const jconfig = @import("./jconfig.zig");

pub const HttpInteractionServer = rest.HttpInteractionServer;
pub const RestClient = rest.Client;
pub const GatewayClient = gateway.Client;

pub const version = @import("build").version;

test {
    std.testing.refAllDeclsRecursive(@This());
}
