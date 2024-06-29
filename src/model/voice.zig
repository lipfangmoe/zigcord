pub const model = @import("../model.zig");
pub const deanson = model.deanson;
pub const Omittable = deanson.Omittable;

pub const VoiceState = struct {
    guild_id: Omittable(model.Snowflake) = .omit,
    channel_id: ?model.Snowflake,
    user_id: model.Snowflake,
    member: Omittable(model.guild.Member) = .omit,
    session_id: []const u8,
    deaf: bool,
    mute: bool,
    self_deaf: bool,
    self_mute: bool,
    self_stream: Omittable(bool) = .omit,
    self_video: bool,
    suppress: bool,
    request_to_speak_timestamp: ?[]const u8,

    pub const jsonStringify = deanson.stringifyWithOmit;
};
