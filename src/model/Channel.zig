const jconfig = @import("jconfig");
const model = @import("../model.zig");
const Snowflake = model.Snowflake;
const User = model.User;
const Member = model.guild.Member;
const Channel = @This();

id: Snowflake,
type: Type,
guild_id: ?Snowflake = null,
position: ?i64 = null,
permission_overwrites: ?[]const PermissionOverwrite.Partial = null,
name: jconfig.Omittable(?[]const u8) = .omit,
topic: jconfig.Omittable(?[]const u8) = .omit,
nsfw: ?bool = null,
last_message_id: jconfig.Omittable(?Snowflake) = .omit,
bitrate: ?i64 = null,
user_limit: ?i64 = null,
rate_limit_per_user: ?i64 = null,
recipients: ?[]User = null,
icon: jconfig.Omittable(?[]const u8) = .omit,
owner_id: ?Snowflake = null,
application_id: jconfig.Omittable(?Snowflake) = .omit,
managed: ?bool = null,
parent_id: jconfig.Omittable(?Snowflake) = .omit,
last_pin_timestamp: jconfig.Omittable(?model.IsoTime) = .omit,
rtc_region: jconfig.Omittable(?[]const u8) = .omit,
video_quality_mode: ?VideoQualityMode = null,
message_count: ?i64 = null,
member_count: ?i64 = null,
thread_metadata: ?ThreadMetadata = null,
member: ?ThreadMember = null,
default_auto_archive_duration: ?i64 = null,
permissions: ?[]const u8 = null,
flags: ?Flags = null,
total_message_sent: ?i64 = null,
available_tags: ?[]const Tag = null,
applied_tags: ?[]const Snowflake = null,
default_reaction_emoji: jconfig.Omittable(?DefaultReaction) = .omit,
default_thread_rate_limit_per_user: ?i64 = null,
default_sort_order: jconfig.Omittable(?SortOrder) = .omit,
default_forum_layout: ?ForumLayout = null,
newly_created: ?bool = null,
app_permissions: ?model.Permissions = null,

pub const jsonStringify = jconfig.stringifyWithOmit;

pub const Partial = struct {
    id: ?Snowflake = null,
    type: ?Type = null,
    guild_id: ?Snowflake = null,
    position: ?i64 = null,
    permission_overwrites: ?[]const PermissionOverwrite.Partial = null,
    name: jconfig.Omittable(?[]const u8) = .omit,
    topic: jconfig.Omittable(?[]const u8) = .omit,
    nsfw: ?bool = null,
    last_message_id: jconfig.Omittable(?Snowflake) = .omit,
    bitrate: ?i64 = null,
    user_limit: ?i64 = null,
    rate_limit_per_user: ?i64 = null,
    recipients: ?[]User = null,
    icon: jconfig.Omittable(?[]const u8) = .omit,
    owner_id: ?Snowflake = null,
    application_id: jconfig.Omittable(?Snowflake) = .omit,
    managed: ?bool = null,
    parent_id: jconfig.Omittable(?Snowflake) = .omit,
    last_pin_timestamp: jconfig.Omittable(?model.IsoTime) = .omit,
    rtc_region: jconfig.Omittable(?[]const u8) = .omit,
    video_quality_mode: ?VideoQualityMode = null,
    message_count: ?i64 = null,
    member_count: ?i64 = null,
    thread_metadata: ?ThreadMetadata = null,
    member: ?ThreadMember = null,
    default_auto_archive_duration: ?i64 = null,
    permissions: ?[]const u8 = null,
    flags: ?Flags = null,
    total_message_sent: ?i64 = null,
    available_tags: ?[]const Tag = null,
    applied_tags: ?[]const Snowflake = null,
    default_reaction_emoji: jconfig.Omittable(?DefaultReaction) = .omit,
    default_thread_rate_limit_per_user: ?i64 = null,
    default_sort_order: jconfig.Omittable(?SortOrder) = .omit,
    default_forum_layout: ?ForumLayout = null,
    newly_created: ?bool = null,
    app_permissions: ?model.Permissions = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    test "is partial channel" {
        try jconfig.testing.expectIsPartialOfStrict(Channel.Partial, Channel);
    }
};

pub const Type = enum(u8) {
    guild_text = 0,
    dm = 1,
    guild_voice = 2,
    group_dm = 3,
    guild_category = 4,
    guild_announcement = 5,
    announcement_thread = 10,
    public_thread = 11,
    private_thread = 12,
    guild_stage_voice = 13,
    guild_directory = 14,
    guild_forum = 15,
    guild_media = 16,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};

pub const PermissionOverwrite = struct {
    id: Snowflake,
    type: PermissionOverwrite.Type,
    allow: []const u8,
    deny: []const u8,

    pub const Partial = struct {
        id: ?Snowflake = null,
        type: ?PermissionOverwrite.Type = null,
        allow: ?[]const u8 = null,
        deny: ?[]const u8 = null,

        pub const jsonStringify = jconfig.stringifyWithOmit;

        test "is partial PermissionOverwrite" {
            try jconfig.testing.expectIsPartialOf(PermissionOverwrite.Partial, PermissionOverwrite);
        }
    };

    pub const Type = enum {
        role,
        member,

        pub const jsonStringify = jconfig.stringifyEnumAsInt;
    };
};

// woah, discord actually used a data structure that follows how programming languages often define enums
pub const DefaultReaction = union(enum) {
    emoji_id: Snowflake,
    emoji_name: []const u8,
};

pub const Flags = packed struct(u64) {
    _unused: u1 = 0,

    // 1 << 1
    pinned: bool = false,

    _unused2: u2 = 0,

    // 1 << 4
    require_tag: bool = false,

    _unused3: u10 = 0,

    // 1 << 15
    hide_media_download_options: bool = false,

    _unused4: u1 = 0,

    channel_obfuscated: bool = false,

    _unused5: u3 = 0,

    is_spoiler_channel: bool = false,

    _overflow: u42 = 0,

    const Mixin = model.PackedFlagsMixin(@This());
    pub const format = Mixin.format;
    pub const formatNumber = Mixin.formatNumber;
    pub const jsonStringify = Mixin.jsonStringify;
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;
};

pub const ThreadMetadata = struct {
    archived: bool,
    auto_archive_duration: i64,
    archive_timestamp: model.IsoTime,
    locked: bool,
    invitable: ?bool = null,
    create_timestamp: ?model.IsoTime = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ThreadMember = struct {
    id: ?Snowflake = null,
    user_id: ?Snowflake = null,
    join_timestamp: model.IsoTime,
    flags: ThreadMember.Flags,
    member: ?Member = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const Flags = packed struct(u64) {
        notifications: bool = false,
        _overflow: u63 = 0,

        const Mixin = model.PackedFlagsMixin(@This());
        pub const format = Mixin.format;
        pub const formatNumber = Mixin.formatNumber;
        pub const jsonStringify = Mixin.jsonStringify;
        pub const jsonParse = Mixin.jsonParse;
        pub const jsonParseFromValue = Mixin.jsonParseFromValue;
    };
};

pub const VideoQualityMode = enum(u2) {
    auto = 1,
    full = 2,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
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

pub const Followed = struct {
    channel_id: Snowflake,
    webhook_id: Snowflake,
};

pub const SortOrder = enum(i64) {
    latest_activity = 0,
    creation_date = 1,
};

pub const ForumLayout = enum(i64) {
    not_set = 0,
    list_view = 1,
    gallery_view = 2,
};

pub const MessagePin = struct {
    pinned_at: model.IsoTime,
    message: model.Message,
};
