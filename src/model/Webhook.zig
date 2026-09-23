const jconfig = @import("jconfig");
const Snowflake = @import("./snowflake.zig").Snowflake;
const User = @import("./User.zig");
const guild = @import("./guild.zig");
const Channel = @import("./Channel.zig");

id: Snowflake,
type: Type,
guild_id: jconfig.Omittable(?Snowflake) = .omit,
channel_id: ?Snowflake,
user: jconfig.Omittable(User) = .omit,
name: ?[]const u8,
avatar: ?[]const u8, // avatar hash
token: jconfig.Omittable([]const u8) = .omit,
application_id: ?Snowflake,
source_guild: jconfig.Omittable(guild.PartialGuild) = .omit,
source_channel: jconfig.Omittable(jconfig.Partial(Channel)) = .omit,
url: jconfig.Omittable([]const u8) = .omit,

pub const jsonStringify = jconfig.stringifyWithOmit;

pub const Type = enum(u2) {
    incoming = 1,
    channel_follower = 2,
    application = 3,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};
