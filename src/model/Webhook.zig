const deancord = @import("../root.zig");
const model = deancord.model;
const jconfig = deancord.jconfig;

id: model.Snowflake,
type: Type,
guild_id: jconfig.Omittable(?model.Snowflake) = .omit,
channel_id: ?model.Snowflake,
user: jconfig.Omittable(model.User) = .omit,
name: ?[]const u8,
avatar: ?[]const u8, // avatar hash
token: jconfig.Omittable([]const u8) = .omit,
application_id: ?model.Snowflake,
source_guild: jconfig.Omittable(model.guild.PartialGuild) = .omit,
source_channel: jconfig.Omittable(jconfig.Partial(model.Channel)) = .omit,
url: jconfig.Omittable([]const u8) = .omit,

pub const jsonStringify = jconfig.stringifyWithOmit;

pub const Type = enum(u2) {
    incoming = 1,
    channel_follower = 2,
    application = 3,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};
