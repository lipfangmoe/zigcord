const jconfig = @import("jconfig");
const model = @import("../model.zig");

name: []const u8,
type: Type,
url: jconfig.Omittable(?[]const u8) = .omit,
created_at: i64,
timestamps: ?Timestamps = null,
application_id: ?model.Snowflake = null,
status_display_type: jconfig.Omittable(?StatusDisplayType) = .omit,
details: jconfig.Omittable(?[]const u8) = .omit,
details_url: jconfig.Omittable(?[]const u8) = .omit,
state: jconfig.Omittable(?[]const u8) = .omit,
state_url: jconfig.Omittable(?[]const u8) = .omit,
emoji: jconfig.Omittable(?model.Emoji) = .omit,
party: ?Party = null,
assets: ?Assets = null,
secrets: ?Secrets = null,
instance: ?bool = null,
flags: ?Flags = null,
buttons: ?[]const Button = null,

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
    start: ?i64 = null,
    end: ?i64 = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};
pub const Party = struct {
    id: ?[]const u8 = null,
    size: ?[2]i64 = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};
pub const Assets = struct {
    /// see https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-asset-image
    large_image: ?[]const u8 = null,
    large_text: ?[]const u8 = null,
    /// see https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-asset-image
    small_image: ?[]const u8 = null,
    small_text: ?[]const u8 = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};
pub const Secrets = struct {
    join: ?[]const u8 = null,
    spectate: ?[]const u8 = null,
    match: ?[]const u8 = null,

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

    const Mixin = model.PackedFlagsMixin(@This());
    pub const format = Mixin.format;
    pub const formatNumber = Mixin.formatNumber;
    pub const jsonStringify = Mixin.jsonStringify;
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;
};
pub const Button = struct {
    label: []const u8,
    url: []const u8,
};
pub const StatusDisplayType = enum(u2) {
    name = 0,
    state = 1,
    details = 2,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};
