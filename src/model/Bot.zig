const Bot = @This();

token: []const u8,

pub fn init(token: []const u8) Bot {
    return .{ .token = token };
}
