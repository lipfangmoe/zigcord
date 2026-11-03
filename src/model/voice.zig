const jconfig = @import("jconfig");
const model = @import("../model.zig");

pub const VoiceState = struct {
    guild_id: ?model.Snowflake = null,
    channel_id: ?model.Snowflake,
    user_id: model.Snowflake,
    member: ?model.guild.Member = null,
    session_id: []const u8,
    deaf: bool,
    mute: bool,
    self_deaf: bool,
    self_mute: bool,
    self_stream: ?bool = null,
    self_video: bool,
    suppress: bool,
    request_to_speak_timestamp: ?model.IsoTime,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const Region = struct {
    id: []const u8,
    name: []const u8,
    optimal: bool,
    deprecated: bool,
    custom: bool,
};
