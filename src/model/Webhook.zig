const deancord = @import("../root.zig");
const model = deancord.model;
const deanson = model.jconfig;

id: model.Snowflake,
type: Type,
guild_id: deanson.Omittable(?model.Snowflake) = .omit,
channel_id: ?model.Snowflake,
user: deanson.Omittable(model.User) = .omit,
name: ?[]const u8,
avatar: ?[]const u8, // avatar hash
token: deanson.Omittable([]const u8) = .omit,
application_id: ?model.Snowflake,
source_guild: deanson.Omittable(model.guild.PartialGuild) = .omit,
source_channel: deanson.Omittable(deanson.Partial(model.Channel)) = .omit,
url: deanson.Omittable([]const u8) = .omit,

pub const jsonStringify = deanson.stringifyWithOmit;

pub const Type = enum(u2) {
    incoming = 1,
    channel_follower = 2,
    application = 3,

    pub const jsonStringify = deanson.stringifyEnumAsInt;
};
