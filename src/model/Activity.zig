const deancord = @import("../root.zig");
const model = deancord.model;
const jconfig = deancord.jconfig;

name: []const u8,
type: Type,
url: jconfig.Omittable(?[]const u8) = .omit,
created_at: i64,
timestamps: jconfig.Omittable(Timestamps) = .omit,
application_id: jconfig.Omittable(model.Snowflake) = .omit,
details: jconfig.Omittable(?[]const u8) = .omit,
state: jconfig.Omittable(?[]const u8) = .omit,
emoji: jconfig.Omittable(?model.Emoji) = .omit,
party: jconfig.Omittable(Party) = .omit,
assets: jconfig.Omittable(Assets) = .omit,
secrets: jconfig.Omittable(Secrets) = .omit,
instance: jconfig.Omittable(bool) = .omit,
flags: jconfig.Omittable(Flags) = .omit,
buttons: jconfig.Omittable([]const Button) = .omit,

pub const jsonStringify = jconfig.stringifyWithOmit;

pub const Type = enum {
    playing,
    streaming,
    listening,
    watching,
    custom,
    competing,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};
pub const Timestamps = struct {
    start: jconfig.Omittable(i64) = .omit,
    end: jconfig.Omittable(i64) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};
pub const Party = struct {
    id: jconfig.Omittable([]const u8) = .omit,
    size: jconfig.Omittable([2]i64) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};
pub const Assets = struct {
    /// see https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-asset-image
    large_image: jconfig.Omittable([]const u8) = .omit,
    large_text: jconfig.Omittable([]const u8) = .omit,
    /// see https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-asset-image
    small_image: jconfig.Omittable([]const u8) = .omit,
    small_text: jconfig.Omittable([]const u8) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};
pub const Secrets = struct {
    join: jconfig.Omittable([]const u8) = .omit,
    spectate: jconfig.Omittable([]const u8) = .omit,
    match: jconfig.Omittable([]const u8) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};
pub const Flags = packed struct(u64) {
    instance: bool = false,
    join: bool = false,
    spectate: bool = false,
    join_request: bool = false,
    sync: bool = false,
    play: bool = false,
    party_privacy_friends: bool = false,
    party_privacy_voice_channel: bool = false,
    embedded: bool = false,
    _overflow: u55 = 0,

    pub usingnamespace model.PackedFlagsMixin(@This());
};
pub const Button = struct {
    label: []const u8,
    url: []const u8,
};
