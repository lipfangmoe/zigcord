const std = @import("std");
const model = @import("../root.zig").model;
const jconfig = @import("../root.zig").jconfig;

id: model.Snowflake,
type: Type,
application_id: model.Snowflake,
name: []const u8,
slug: []const u8,
flags: Flags,

pub const Type = enum(u8) {
    durable = 2,
    consumable = 3,
    subscription = 5,
    subscription_group = 6,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};

pub const Flags = packed struct(u64) {
    _unknown: u2 = 0,
    available: bool = false, // 1<<2
    _unknown2: u4 = 0,
    guild_subscription: bool = false, // 1<<7
    user_subscription: bool = false, // 1<<8
    _unknown3: u55 = 0,

    pub usingnamespace model.PackedFlagsMixin(Flags);

    test "flags test" {
        try std.testing.expectEqual(Flags{ .user_subscription = true }, @as(Flags, @bitCast(@as(u64, 1 << 8))));
    }
};
