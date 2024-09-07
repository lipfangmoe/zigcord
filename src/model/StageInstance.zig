const model = @import("../root.zig").model;
const jconfig = @import("../root.zig").jconfig;

id: model.Snowflake,
guild_id: model.Snowflake,
channel_id: model.Snowflake,
topic: []const u8,
privacy_level: PrivacyLevel,
/// not actually omittable, but deprecated, so maybe omit someday
discoverable_disabled: jconfig.Omittable(bool) = .omit,
guild_scheduled_event_id: ?bool,

pub usingnamespace jconfig.OmittableFieldsMixin(@This());

pub const PrivacyLevel = enum(u2) {
    public = 1,
    guild_only = 2,
};
