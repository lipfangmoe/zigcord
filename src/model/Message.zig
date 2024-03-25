const model = @import("../model.zig");
const Snowflake = model.Snowflake;
const Omittable = model.deanson.Omittable;
const ChannelMention = model.guild.channel.Mention;

id: Snowflake,
channel_id: Snowflake,
author: MessageAuthor,
content: []const u8,
timestamp: []const u8, // ISO8601 string
edited_timestamp: ?[]const u8, // ISO8601 string
tts: bool,
mention_everyone: bool,
mentions: []const model.User,
mention_roles: []const model.guild.Role,
mention_channels: Omittable([]const ChannelMention) = .{ .omitted = void{} },
attachments: []const Attachment,
// TODO more fields

pub const jsonStringify = model.deanson.stringifyWithOmit;

pub const MessageAuthor = union(enum) {
    user: model.User,
    webhook: struct {
        id: Snowflake,
        username: []const u8,
        avatar: ?[]const u8,
    },

    pub const jsonStringify = model.deanson.stringifyUnionInline;
};

pub const Attachment = struct {
    id: Snowflake,
    filename: []const u8,
    description: Omittable([]const u8) = .{ .omitted = void{} },
    content_type: Omittable([]const u8) = .{ .omitted = void{} },
    size: u64,
    url: []const u8,
    proxy_url: []const u8,
    height: Omittable(?[]const u8) = .{ .omitted = void{} },
    width: Omittable(?[]const u8) = .{ .omitted = void{} },
    ephemeral: Omittable(bool) = .{ .omitted = void{} },
    duration_secs: Omittable(f64) = .{ .omitted = void{} },
    waveform: Omittable([]const u8) = .{ .omitted = void{} },
    flags: Flags,

    const Flags = model.Flags(enum {
        crossposted,
        is_crosspost,
        suppress_embeds,
        source_message_deleted,
        urgent,
        has_thread,
        ephemeral,
        loading,
        failed_to_mention_some_roles_in_thread,
        suppress_notifications,
        is_voice_message,
    });
};
