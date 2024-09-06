const std = @import("std");
const testing = std.testing;

pub const model = @import("./model.zig");
pub const rest = @import("./rest.zig");
pub const gateway = @import("./gateway.zig");
pub const Server = @import("./interaction_server/Server.zig");

pub const version = "0.0.0";

test {
    std.testing.refAllDeclsRecursive(@This());
}
