const std = @import("std");
const jconfig = @import("jconfig");
const model = @import("../model.zig");

name: []const u8,
sound_id: model.Snowflake,
volume: f64,
emoji_id: ?model.Snowflake,
emoji_name: ?[]const u8,
guild_id: jconfig.Omittable(model.Snowflake) = .omit,
available: bool,
user: jconfig.Omittable(model.User) = .omit,
