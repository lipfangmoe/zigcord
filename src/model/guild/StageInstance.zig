const model = @import("../../model.zig");
const deanson = model.deanson;
const Omittable = deanson.Omittable;

id: model.Snowflake,
guild_id: model.Snowflake,
channel_id: model.Snowflake,
topic: []const u8,
privacy_level: PrivacyLevel,
/// not actually omittable, but deprecated, so maybe omitted someday
discoverable_disabled: Omittable(bool) = .{ .omitted = void{} },
guild_scheduled_event_id: ?bool,

pub const PrivacyLevel = enum(u2) {
    public = 1,
    guild_only = 2,
};
