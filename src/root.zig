const std = @import("std");
const testing = std.testing;

pub const model = @import("./model.zig");
pub const rest = @import("./rest.zig");
pub const gateway = @import("./gateway.zig");
pub const jconfig = @import("./jconfig.zig");

pub const InteractionServer = rest.Server;
pub const RestClient = rest.Client;
pub const GatewayClient = gateway.Client;

pub const version = "0.0.0";

test {
    std.testing.refAllDeclsRecursive(@This());
}
