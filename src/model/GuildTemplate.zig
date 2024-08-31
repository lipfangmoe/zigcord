const std = @import("std");
const deancord = @import("../root.zig");
const model = deancord.model;

code: []const u8,
name: []const u8,
description: ?[]const u8,
usage_count: i64,
creator_id: model.Snowflake,
creator: model.User,
created_at: model.IsoTime,
updated_at: model.IsoTime,
source_guild_id: model.Snowflake,
serialized_source_guild: model.guild.PartialGuild,
is_dirty: ?bool,
