const model = @import("../root.zig").model;
const jconfig = @import("../root.zig").jconfig;

type: Type,
metadata: jconfig.Omittable(Metadata) = .omit,

pub const jsonStringify = jconfig.stringifyWithOmit;

pub const Type = enum(u8) {
    block_message = 1,
    send_alert_message = 2,
    timeout = 3,
    block_member_interaction = 4,
};

pub const Metadata = struct {
    channel_id: jconfig.Omittable(model.Snowflake) = .omit,
    duration_seconds: jconfig.Omittable(i64) = .omit,
    custom_message: jconfig.Omittable([]const u8) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};
