const model = @import("model");
const jconfig = @import("jconfig");
const receive_events = @import("./receive_events.zig");

pub const Identify = struct {
    token: []const u8,
    properties: Connection,
    compress: ?bool = null,
    large_threshold: ?i64 = null,
    shard: ?[2]i64 = null,
    presence: ?receive_events.PresenceUpdate = null,
    intents: model.Intents,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const Connection = struct {
        os: []const u8,
        browser: []const u8,
        device: []const u8,
    };
};

pub const Resume = struct {
    token: []const u8,
    session_id: []const u8,
    seq: i64,
};

pub const Heartbeat = ?i64;

pub const RequestGuildMembers = struct {
    guild_id: model.Snowflake,
    query: ?[]const u8 = null,
    limit: i64,
    presences: ?bool = null,
    user_ids: ?[]const model.Snowflake = null,
    nonce: ?[]const u8 = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const RequestSoundboardSounds = struct {
    guild_ids: []const model.Snowflake,
};

pub const RequestChannelInfo = struct {
    guild_id: model.Snowflake,
    fields: []const Field,

    pub const Field = enum {
        status,
        voice_start_time,
    };
};

pub const UpdateVoiceState = struct {
    guild_id: model.Snowflake,
    channel_id: ?model.Snowflake,
    self_mute: bool,
    self_deaf: bool,
};

pub const UpdatePresence = struct {
    since: ?i64,
    activities: []const model.Activity,
    status: []const u8,
    afk: bool,
};
