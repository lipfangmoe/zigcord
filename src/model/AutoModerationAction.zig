const model = @import("../model.zig");
const Omittable = model.deanson.Omittable;

type: Type,
metadata: Omittable(Metadata) = .omit,

pub const Type = enum(u8) {
    block_message = 1,
    send_alert_message = 2,
    timeout = 3,
    block_member_interaction = 4,
};

pub const Metadata = struct {
    channel_id: Omittable(model.Snowflake) = .omit,
    duration_seconds: Omittable(i64) = .omit,
    custom_message: Omittable([]const u8) = .omit,
};
