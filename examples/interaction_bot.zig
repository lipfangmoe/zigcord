const std = @import("std");
const deancord = @import("deancord");

pub const std_options: std.Options = .{ .log_level = switch (@import("builtin").mode) {
    .Debug, .ReleaseSafe => .info,
    .ReleaseFast, .ReleaseSmall => .err,
} };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const token = std.process.getEnvVarOwned(allocator, "TOKEN") catch |err| {
        switch (err) {
            error.EnvironmentVariableNotFound => {
                std.log.err("environment variable TOKEN is required", .{});
                return;
            },
            else => return err,
        }
    };

    var client = deancord.rest.Client.init(allocator, .{ .token = .{ .bot = token } });
    defer client.deinit();

    var server = try deancord.rest.Server.init(std.net.Address.initIp4(.{ 0, 0, 0, 0 }, 8080));

    while (server.receiveInteraction()) |req| {
        defer req.deinit();

        const interaction = req.interaction;
    } else |err| {
        _ = err;
    }
}
