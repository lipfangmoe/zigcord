const std = @import("std");

pub const Authorization = union(enum) {
    bot: []const u8,
    bearer: []const u8,

    pub fn format(self: Authorization, writer: *std.Io.Writer) !void {
        switch (self) {
            .bot => |token| try writer.print("Bot {s}", .{token}),
            .bearer => |token| try writer.print("Bearer {s}", .{token}),
        }
    }
};
