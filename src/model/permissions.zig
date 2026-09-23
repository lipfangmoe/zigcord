const std = @import("std");
const logger = @import("shared").logger;

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
    send_voice_messages: bool = false,
    _unknown: u1 = 0, // 1 << 47: mysterious permission no one knows what they are
    set_voice_channel_status: bool = false,
    send_polls: bool = false,
    use_external_apps: bool = false, // 1 << 50
    pin_messages: bool = false,
    bypass_slowmode: bool = false, // 1 << 52

    _unknown2: u11 = 0,

    pub fn fromU64(int: u64) Permissions {
        return @bitCast(int);
    }

    pub fn asU64(self: Permissions) u64 {
        return @bitCast(self);
    }

    pub fn format(self: Permissions, writer: *std.Io.Writer) !void {
        try writer.print("{d}", .{self.asU64()});
    }

    pub fn jsonStringify(self: Permissions, jsonWriter: *std.json.Stringify) !void {
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
        try std.testing.expectEqual(1 << 50, (Permissions{ .use_external_apps = true }).asU64());
        try std.testing.expectEqual(1 << 52, (Permissions{ .bypass_slowmode = true }).asU64());
    }

    test "permissions from json" {
        const obj: std.json.Value = .{ .string = "4503599627370496" };
        const parsed = try std.json.parseFromValue(Permissions, std.testing.allocator, obj, .{});
        defer parsed.deinit();
        try std.testing.expectEqual(Permissions{ .bypass_slowmode = true }, parsed.value);
    }
};
