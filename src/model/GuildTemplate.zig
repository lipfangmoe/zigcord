const std = @import("std");
const deancord = @import("../root.zig");
const zigtime = @import("zig-time");
const model = deancord.model;

code: []const u8,
name: []const u8,
description: ?[]const u8,
usage_count: i64,
creator_id: model.Snowflake,
creator: model.User,
created_at: zigtime.DateTime,
updated_at: zigtime.DateTime,
source_guild_id: model.Snowflake,
serialized_source_guild: model.guild.PartialGuild,
is_dirty: ?bool,
