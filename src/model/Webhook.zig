const jconfig = @import("jconfig");
const Snowflake = @import("./snowflake.zig").Snowflake;
const User = @import("./User.zig");
const guild = @import("./guild.zig");
const Channel = @import("./Channel.zig");

id: Snowflake,
type: Type,
guild_id: jconfig.Omittable(?Snowflake) = .omit,
channel_id: ?Snowflake,
user: ?User = null,
name: ?[]const u8,
avatar: ?[]const u8, // avatar hash
token: ?[]const u8 = null,
application_id: ?Snowflake,
source_guild: ?guild.PartialGuild = null,
source_channel: ?jconfig.Partial(Channel) = null,
url: ?[]const u8 = null,

pub const jsonStringify = jconfig.stringifyWithOmit;
pub const Type = enum(u2) {
    incoming = 1,
    channel_follower = 2,
    application = 3,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};
