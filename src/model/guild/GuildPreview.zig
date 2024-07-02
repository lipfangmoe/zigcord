const model = @import("../../model.zig");
const Snowflake = model.Snowflake;
const deanson = @import("../deanson.zig");
const Role = @import("./Role.zig");
const Emoji = @import("../Emoji.zig");
const GuildSticker = @import("./GuildSticker.zig");

id: Snowflake,
name: []const u8,
icon: ?[]const u8,
splash: ?[]const u8,
discovery_splash: ?[]const u8,
emojis: []Emoji,
/// https://discord.com/developers/docs/resources/guild#guild-object-guild-features
features: []const u8,
mfa_level: model.guild.Guild.MfaLevel,
approximate_member_count: ?i64,
approximate_presence_count: ?i64,
description: ?[]const u8,
stickers: ?[]GuildSticker,
