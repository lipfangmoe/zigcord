const deancord = @import("../../root.zig");
const model = deancord.model;
const jconfig = deancord.jconfig;
const receive_events = deancord.gateway.event_data.receive_events;

pub const Identify = struct {
    token: []const u8,
    properties: Connection,
    compress: jconfig.Omittable(bool) = .omit,
    large_threshold: jconfig.Omittable(i64) = .omit,
    shard: jconfig.Omittable([2]i64) = .omit,
    presence: jconfig.Omittable(receive_events.PresenceUpdate) = .omit,
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
    query: jconfig.Omittable([]const u8) = .omit,
    limit: i64,
    presences: jconfig.Omittable(bool) = .omit,
    user_ids: jconfig.Omittable([]const model.Snowflake) = .omit,
    nonce: jconfig.Omittable([]const u8) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
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
