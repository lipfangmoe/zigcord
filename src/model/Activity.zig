const deancord = @import("../root.zig");
const model = deancord.model;
const deanson = model.deanson;

name: []const u8,
type: Type,
url: deanson.Omittable(?[]const u8) = .omit,
created_at: i64,
timestamps: deanson.Omittable(Timestamps) = .omit,
application_id: deanson.Omittable(model.Snowflake) = .omit,
details: deanson.Omittable(?[]const u8) = .omit,
state: deanson.Omittable(?[]const u8) = .omit,
emoji: deanson.Omittable(?model.Emoji) = .omit,
party: deanson.Omittable(Party) = .omit,
assets: deanson.Omittable(Assets) = .omit,
secrets: deanson.Omittable(Secrets) = .omit,
instance: deanson.Omittable(bool) = .omit,
flags: deanson.Omittable(Flags) = .omit,
buttons: deanson.Omittable([]const Button) = .omit,

pub const jsonStringify = deanson.stringifyWithOmit;

pub const Type = enum {
    playing,
    streaming,
    listening,
    watching,
    custom,
    competing,

    pub const jsonStringify = deanson.stringifyEnumAsInt;
};
pub const Timestamps = struct {
    start: deanson.Omittable(i64) = .omit,
    end: deanson.Omittable(i64) = .omit,

    pub const jsonStringify = deanson.stringifyWithOmit;
};
pub const Party = struct {
    id: deanson.Omittable([]const u8) = .omit,
    size: deanson.Omittable([2]i64) = .omit,

    pub const jsonStringify = deanson.stringifyWithOmit;
};
pub const Assets = struct {
    /// see https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-asset-image
    large_image: deanson.Omittable([]const u8) = .omit,
    large_text: deanson.Omittable([]const u8) = .omit,
    /// see https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-asset-image
    small_image: deanson.Omittable([]const u8) = .omit,
    small_text: deanson.Omittable([]const u8) = .omit,

    pub const jsonStringify = deanson.stringifyWithOmit;
};
pub const Secrets = struct {
    join: deanson.Omittable([]const u8) = .omit,
    spectate: deanson.Omittable([]const u8) = .omit,
    match: deanson.Omittable([]const u8) = .omit,

    pub const jsonStringify = deanson.stringifyWithOmit;
};
pub const Flags = packed struct {
    instance: bool = false,
    join: bool = false,
    spectate: bool = false,
    join_request: bool = false,
    sync: bool = false,
    play: bool = false,
    party_privacy_friends: bool = false,
    party_privacy_voice_channel: bool = false,
    embedded: bool = false,

    pub usingnamespace model.PackedFlagsMixin(@This());
};
pub const Button = struct {
    label: []const u8,
    url: []const u8,
};
