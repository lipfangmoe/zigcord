const model = @import("../model.zig");
const Omittable = model.deanson.Omittable;

type: Type,
metadata: Omittable(Metadata) = .{ .omitted = void{} },

pub const Type = enum(u8) {
    block_message = 1,
    send_alert_message = 2,
    timeout = 3,
    block_member_interaction = 4,
};

pub const Metadata = struct {
    channel_id: Omittable(model.Snowflake) = .{ .omitted = void{} },
    duration_seconds: Omittable(i64) = .{ .omitted = void{} },
    custom_message: Omittable([]const u8) = .{ .omitted = void{} },
};
