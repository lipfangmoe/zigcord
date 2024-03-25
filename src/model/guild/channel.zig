const model = @import("../../model.zig");
const Snowflake = model.Snowflake;
const User = model.User;
const Member = model.guild.Member;
const Omittable = model.deanson.Omittable;

/// Prefer using a properly typed XyzChannel rather than just Channel.
///
/// TODO - provide builders instead of alternate structs
pub const Channel = struct {
    id: Snowflake,
    type: Type,
    guild_id: Omittable(Snowflake) = .{ .omitted = void{} },
    position: Omittable(i64) = .{ .omitted = void{} },
    permission_overwrites: Omittable([]PermissionOverwrite) = .{ .omitted = void{} },
    name: Omittable(?[]const u8) = .{ .omitted = void{} },
    topic: Omittable(?[]const u8) = .{ .omitted = void{} },
    nsfw: Omittable(bool) = .{ .omitted = void{} },
    last_message_id: Omittable(?Snowflake) = .{ .omitted = void{} },
    bitrate: Omittable(i64) = .{ .omitted = void{} },
    user_limit: Omittable(i64) = .{ .omitted = void{} },
    rate_limit_per_user: Omittable(i64) = .{ .omitted = void{} },
    recipients: Omittable([]User) = .{ .omitted = void{} },
    icon: Omittable(?[]const u8) = .{ .omitted = void{} },
    owner_id: Omittable(Snowflake) = .{ .omitted = void{} },
    application_id: Omittable(Snowflake) = .{ .omitted = void{} },
    managed: Omittable(bool) = .{ .omitted = void{} },
    parent_id: Omittable(?Snowflake) = .{ .omitted = void{} },
    last_pin_timestamp: Omittable(?[]const u8) = .{ .omitted = void{} },
    rtc_region: Omittable(?[]const u8) = .{ .omitted = void{} },
    video_quality_mode: Omittable(i64) = .{ .omitted = void{} },
    message_count: Omittable(i64) = .{ .omitted = void{} },
    member_count: Omittable(i64) = .{ .omitted = void{} },
    thread_metadata: Omittable(ThreadMetadata) = .{ .omitted = void{} },
    member: Omittable(ThreadMember) = .{ .omitted = void{} },
    default_auto_archive_duration: Omittable(i64) = .{ .omitted = void{} },
    permissions: Omittable([]const u8) = .{ .omitted = void{} },
    flags: Omittable(ChannelFlags) = .{ .omitted = void{} },
    total_message_sent: Omittable(i64) = .{ .omitted = void{} },
    available_tags: Omittable([]Tag) = .{ .omitted = void{} },
    applied_tags: Omittable([]Snowflake) = .{ .omitted = void{} },
    default_reaction_emoji: Omittable(?DefaultReaction) = .{ .omitted = void{} },
    default_thread_rate_limit_per_user: Omittable(i64) = .{ .omitted = void{} },
    default_sort_order: Omittable(?i64) = .{ .omitted = void{} },
    default_forum_layout: Omittable(i64) = .{ .omitted = void{} },
};

pub const Mention = struct {
    id: Snowflake,
    guild_id: Snowflake,
    type: Type,
    name: []const u8,
};

pub const Type = enum {
    guild_text,
    dm,
    guild_voice,
    group_dm,
    guild_category,
    guild_announcement,
    announcement_thread,
    public_thread,
    private_thread,
    guild_stage_voice,
    guild_directory,
    guild_forum,
    guild_media,

    pub const jsonStringify = model.deanson.stringifyEnumAsInt;
};

/// utility for parsing text channels
pub const GuildTextChannel = struct {
    id: Snowflake,
    guild_id: Snowflake,
    position: Omittable(i64) = .{ .omitted = void{} },
    permission_overwrites: Omittable([]PermissionOverwrite) = .{ .omitted = void{} },
    name: []const u8,
    topic: Omittable(?[]const u8) = .{ .omitted = void{} },
    nsfw: Omittable(bool) = .{ .omitted = void{} },
    last_message_id: Omittable(?Snowflake) = .{ .omitted = void{} },
    rate_limit_per_user: ?i64,
    parent_id: ?Snowflake,
    last_pin_timestamp: Omittable(?[]const u8) = .{ .omitted = void{} },
    member_count: Omittable(i64) = .{ .omitted = void{} },
    permissions: Omittable([]const u8) = .{ .omitted = void{} },
    flags: Omittable(ChannelFlags) = .{ .omitted = void{} },
    default_thread_rate_limit_per_user: Omittable(i64) = .{ .omitted = void{} },
};

pub const PermissionOverwrite = struct {
    id: Snowflake,
    type: enum {
        role,
        member,

        pub fn jsonStringify(self: *@This(), jsonWriter: anytype) !void {
            try jsonWriter.write(@intFromEnum(self.*));
        }
    },
    allow: []const u8,
    deny: []const u8,
};

pub const DefaultReaction = union(enum) {
    emoji_id: Snowflake,
    emoji_name: []const u8,
};

pub const Tag = struct {
    /// id of the tag
    id: Snowflake,
    /// name of the tag
    name: []const u8,
    /// whether this tag can only be added/removed by moderators
    moderated: bool,
    /// id of a guild-specific emoji
    emoji_id: ?Snowflake,
    /// unicode character representing an emoji
    emoji_name: ?[]const u8,
};

pub const ChannelFlags = model.Flags(enum(u6) {
    pinned = 1,
    require_tag = 4,
    hide_media_download_options = 15,
});

pub const ThreadMetadata = struct {
    archived: bool,
    auto_archive_duration: i64,
    archive_timestamp: []const u8,
    locked: bool,
    invitable: bool,
    create_timestamp: ?[]const u8,
};

pub const ThreadMember = struct {
    id: ?Snowflake,
    user_id: ?Snowflake,
    join_timestamp: []const u8,
    flags: Flags,
    member: ?Member,

    pub const Flags = model.Flags(enum {
        notifications,
    });
};
