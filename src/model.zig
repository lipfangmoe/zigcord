const std = @import("std");
const testing = std.testing;

pub const Application = @import("./model/Application.zig");
pub const ApplicationRoleConnectionMetadata = @import("./model/ApplicationRoleConnectionMetadata.zig");
pub const interaction = @import("./model/interaction.zig");
pub const User = @import("./model/User.zig");
pub const guild = @import("./model/guild.zig");
pub const Snowflake = @import("./model/snowflake.zig").Snowflake;
pub const PackedFlagsMixin = @import("./model/flags.zig").PackedFlagsMixin;
pub const AuditLog = @import("./model/AuditLog.zig");
pub const Message = @import("./model/Message.zig");
pub const AutoModerationRule = @import("./model/AutoModerationRule.zig");
pub const AutoModerationAction = @import("./model/AutoModerationAction.zig");
pub const Entitlement = @import("./model/Entitlement.zig");
pub const voice = @import("./model/voice.zig");
pub const Emoji = @import("./model/Emoji.zig");
pub const Sticker = @import("./model/Sticker.zig");
pub const Channel = @import("./model/Channel.zig");
pub const MessageComponent = @import("./model/MessageComponent.zig");
pub const Invite = @import("./model/Invite.zig");
pub const ImageData = @import("./model/ImageData.zig");
pub const GuildScheduledEvent = @import("./model/GuildScheduledEvent.zig");
pub const GuildTemplate = @import("./model/GuildTemplate.zig");
pub const Role = @import("./model/Role.zig");
pub const StageInstance = @import("./model/StageInstance.zig");
pub const Poll = @import("./model/Poll.zig");
pub const Webhook = @import("./model/Webhook.zig");
pub const Activity = @import("./model/Activity.zig");
pub const IsoTime = @import("./model/IsoTime.zig");

pub const Permissions = packed struct(u64) {
    create_instant_invite: bool = false, // 1 << 0
    kick_members: bool = false,
    ban_members: bool = false,
    administrator: bool = false,
    manage_channels: bool = false,
    manage_guild: bool = false,
    add_reactions: bool = false,
    view_audit_log: bool = false,
    priority_speaker: bool = false,
    stream: bool = false,
    view_channel: bool = false, // 1 << 10
    send_messages: bool = false,
    send_tts_messages: bool = false,
    manage_messages: bool = false,
    embed_links: bool = false,
    attach_files: bool = false,
    read_message_history: bool = false,
    mention_everyone: bool = false,
    use_external_emojis: bool = false,
    view_guild_insights: bool = false,
    connect: bool = false, // 1 << 20
    speak: bool = false,
    mute_members: bool = false,
    deafen_members: bool = false,
    move_members: bool = false,
    use_vad: bool = false,
    change_nickname: bool = false,
    manage_nicknames: bool = false,
    manage_roles: bool = false,
    manage_webhooks: bool = false,
    manage_guild_expressions: bool = false, // 1 << 30
    use_application_commands: bool = false,
    request_to_speak: bool = false,
    manage_events: bool = false,
    manage_threads: bool = false,
    create_public_threads: bool = false,
    create_private_threads: bool = false,
    use_external_stickers: bool = false,
    send_messages_in_threads: bool = false,
    use_embedded_activities: bool = false,
    moderate_members: bool = false, // 1 << 40
    view_creator_monetization_analytics: bool = false,
    use_soundboard: bool = false,
    create_guild_expressions: bool = false,
    create_events: bool = false,
    use_external_sounds: bool = false,
    send_voice_messages: bool = false, // 1 << 46
    _unknown: u17 = 0,

    pub fn fromU64(int: u64) Permissions {
        return @bitCast(int);
    }

    pub fn asU64(self: Permissions) u64 {
        return @bitCast(self);
    }

    pub fn format(self: Permissions, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        try std.fmt.formatIntValue(self.asU64(), fmt, options, writer);
    }

    pub fn jsonStringify(self: Permissions, jsonWriter: anytype) !void {
        try jsonWriter.write(self.asU64());
    }

    pub fn jsonParse(alloc: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !Permissions {
        const int = try std.json.innerParse(u64, alloc, source, options);
        return fromU64(int);
    }

    pub fn jsonParseFromValue(alloc: std.mem.Allocator, source: std.json.Value, options: std.json.ParseOptions) !Permissions {
        const int = try std.json.innerParseFromValue(u64, alloc, source, options);
        return fromU64(int);
    }

    test "basic permission expectations" {
        // just test some expected permissions to make sure that certain permissions are not missed
        try std.testing.expectEqual(1 << 10, (Permissions{ .view_channel = true }).asU64());
        try std.testing.expectEqual(1 << 20, (Permissions{ .connect = true }).asU64());
        try std.testing.expectEqual(1 << 30, (Permissions{ .manage_guild_expressions = true }).asU64());
        try std.testing.expectEqual(1 << 40, (Permissions{ .moderate_members = true }).asU64());
        try std.testing.expectEqual(1 << 46, (Permissions{ .send_voice_messages = true }).asU64());
    }
};

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

    pub fn jsonStringify(self: Intents, jw: anytype) !void {
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
