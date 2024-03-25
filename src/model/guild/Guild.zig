const model = @import("../../model.zig");
const Snowflake = model.Snowflake;
const deanson = @import("../deanson.zig");
const Role = @import("./Role.zig");
const GuildEmoji = @import("./GuildEmoji.zig");
const GuildSticker = @import("./GuildSticker.zig");

id: Snowflake,
name: []const u8,
icon: ?[]const u8,
/// used for guild templates
icon_hash: ?[]const u8,
splash: ?[]const u8,
discovery_splash: ?[]const u8,
/// true if the authenticated user is the owner of the guild
owner: ?bool,
owner_id: Snowflake,
permissions: ?[]const u8,
region: ?[]const u8,
afk_channel_id: ?Snowflake,
afk_timeout: i64,
widget_enabled: ?bool,
widget_channel_id: ?Snowflake,
verification_level: VerificationLevel,
default_message_notifications: MessageNotificationLevel,
explicit_content_filter: ExplicitContentFilterLevel,
roles: []Role,
emojis: []GuildEmoji,
/// https://discord.com/developers/docs/resources/guild#guild-object-guild-features
features: []const u8,
mfa_level: MfaLevel,
application_id: ?Snowflake,
system_channel_id: ?Snowflake,
system_channel_flags: SystemChannelFlags,
rules_channel_id: ?Snowflake,
max_presences: ?i64,
max_members: ?i64,
vanity_url_code: ?[]const u8,
description: ?[]const u8,
banner: ?[]const u8,
premium_tier: PremiumTier,
premium_subscription_count: i64,
preferred_locale: []const u8,
public_updates_channel_id: ?Snowflake,
max_video_channel_users: ?i64,
max_stage_video_channel_users: ?i64,
approximate_member_count: ?i64,
approximate_presence_count: ?i64,
welcome_screen: ?WelcomeScreen,
nsfw_level: NsfwLevel,
stickers: ?[]GuildSticker,
premium_progress_bar_enabled: bool,
safety_alerts_channel_id: ?Snowflake,

pub const VerificationLevel = enum {
    /// unrestricted
    none,
    /// must hav verified email
    low,
    /// must be registered on discord for 5 mins
    medium,
    /// must be a member of the server for 10 minutes
    high,
    /// must have a verified phone number
    very_high,

    pub const jsonStringify = deanson.stringifyEnumAsInt;
};

pub const MessageNotificationLevel = enum {
    all_messages,
    only_mentions,

    pub const jsonStringify = deanson.stringifyEnumAsInt;
};

pub const ExplicitContentFilterLevel = enum {
    disabled,
    members_without_roles,
    all_members,

    pub const jsonStringify = deanson.stringifyEnumAsInt;
};

pub const MfaLevel = enum {
    none,
    elevated,

    pub const jsonStringify = deanson.stringifyEnumAsInt;
};

pub const PremiumTier = enum {
    none,
    tier_1,
    tier_2,
    tier_3,

    pub const jsonStringify = deanson.stringifyEnumAsInt;
};

pub const NsfwLevel = enum {
    default,
    explicit,
    safe,
    age_restricted,

    pub const jsonStringify = deanson.stringifyEnumAsInt;
};

pub const WelcomeScreen = struct {
    description: ?[]const u8,
    welcome_channels: []WelcomeChannel,

    pub const WelcomeChannel = struct {
        channel_id: Snowflake,
        description: []const u8,
        /// the emoji id, if the emoji is custom
        emoji_id: ?Snowflake,
        /// the emoji name if custom, the unicode character if standard, or null if no emoji is set
        emoji_name: ?[]const u8,
    };
};

pub const SystemChannelFlags = model.Flags(enum {
    supress_join_notifications,
    suppress_premium_subscriptions,
    suppress_guild_reminder_notifications,
    suppress_join_notification_replies,
    suppress_role_subscription_purchase_notifications,
    suppress_role_subscription_purchase_notification_replies,
});
