const std = @import("std");

pub const Intents = packed struct(u64) {
    guilds: bool = false, // 1 << 0
    guild_members: bool = false,
    guild_moderation: bool = false,
    guild_emojis_and_stickers: bool = false,
    guild_integrations: bool = false,
    guild_webhooks: bool = false,
    guild_invites: bool = false,
    guild_voice_states: bool = false,
    guild_presences: bool = false,
    guild_messages: bool = false,
    guild_message_reactions: bool = false, // 1 << 10
    guild_message_typing: bool = false,
    direct_messages: bool = false,
    direct_message_reactions: bool = false,
    direct_message_typing: bool = false,
    message_content: bool = false,
    guild_scheduled_events: bool = false,
    _gap: u3 = 0, // gap of 3 removed(?) intents
    auto_moderation_configuration: bool = false, // 1 << 20
    auto_moderation_execution: bool = false,
    _gap2: u2 = 0, // gap of 2 more removed(?) intents
    guild_message_polls: bool = false,
    direct_message_polls: bool = false, // 1 << 25
    _unknown: u38 = 0,

    pub const all: Intents = @bitCast(@as(u64, 0xFFFFFFFF_FFFFFFFF));

    pub fn fromU64(int: u64) Intents {
        return @bitCast(int);
    }

    pub fn asU64(self: Intents) u64 {
        return @bitCast(self);
    }

    pub fn jsonStringify(self: Intents, jw: *std.json.Stringify) !void {
        const int: u64 = @bitCast(self);
        try jw.write(int);
    }

    pub fn jsonParse(alloc: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !Intents {
        const int = try std.json.innerParse(u64, alloc, source, options);
        return @bitCast(int);
    }

    pub fn jsonParseFromValue(alloc: std.mem.Allocator, source: std.json.Value, options: std.json.ParseOptions) !Intents {
        const int = try std.json.innerParseFromValue(u64, alloc, source, options);
        return @bitCast(int);
    }
};
