const jconfig = @import("jconfig");
const model = @import("../model.zig");

type: Type,
metadata: ?Metadata = null,

pub const jsonStringify = jconfig.stringifyWithOmit;
pub const Type = enum(u8) {
    block_message = 1,
    send_alert_message = 2,
    timeout = 3,
    block_member_interaction = 4,
};

pub const Metadata = struct {
    channel_id: ?model.Snowflake = null,
    duration_seconds: ?i64 = null,
    custom_message: ?[]const u8 = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};
