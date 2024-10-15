const std = @import("std");
const testing = std.testing;

pub const model = @import("./model.zig");
pub const rest = @import("./rest.zig");
pub const gateway = @import("./gateway.zig");
pub const jconfig = @import("./jconfig.zig");

pub const HttpInteractionServer = rest.HttpInteractionServer;
pub const EndpointClient = rest.EndpointClient;
pub const GatewayClient = gateway.Client;

pub const Authorization = union(enum) {
    bot: []const u8,
    bearer: []const u8,

    pub fn format(self: Authorization, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        switch (self) {
            .bot => |token| try writer.print("Bot {s}", .{token}),
            .bearer => |token| try writer.print("Bearer {s}", .{token}),
        }
    }
};

pub const version = @import("build").version;

test {
    std.testing.refAllDeclsRecursive(@This());
}
