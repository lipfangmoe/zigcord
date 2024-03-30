const std = @import("std");
const testing = std.testing;

pub const Application = @import("./model/Application.zig");
pub const ApplicationRoleConnectionMetadata = @import("./model/ApplicationRoleConnectionMetadata.zig");
pub const interaction = @import("./model/interaction.zig");
pub const User = @import("./model/User.zig");
pub const guild = @import("./model/guild.zig");
pub const Snowflake = @import("./model/snowflake.zig").Snowflake;
pub const Flags = @import("./model/flags.zig").Flags;
pub const deanson = @import("./model/deanson.zig");
pub const AuditLog = @import("./model/AuditLog.zig");
pub const Message = @import("./model/Message.zig");
pub const AutoModerationRule = @import("./model/AutoModerationRule.zig");

/// Represents an array of localization entries, ie:
/// [["en-US", "please enable cookies"], ["en-GB", "please enable biscuits"]]
///
/// See https://discord.com/developers/docs/reference#locales for the locales that discord supports
pub const Localizations = struct {
    entries: []const [2][]const u8,

    pub fn jsonStringify(self: *const @This(), jsonWriter: anytype) !void {
        try jsonWriter.beginObject();
        for (self.entries) |entry| {
            try jsonWriter.objectField(entry[0]);
            try jsonWriter.write(entry[1]);
        }
        try jsonWriter.endObject();
    }
};

pub const Permissions = packed struct {
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

    pub fn fromU64(int: u64) Permissions {
        return @bitCast(@as(u47, @truncate(int)));
    }

    pub fn asU64(self: Permissions) u64 {
        return @intCast(@as(u47, @bitCast(self)));
    }

    pub fn format(self: Permissions, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try writer.print(fmt, .{self.asU64()});
    }

    pub fn jsonStringify(self: Permissions, jsonWriter: anytype) !void {
        try jsonWriter.write(self.asU64());
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
