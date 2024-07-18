const model = @import("../../model.zig");
const Snowflake = model.Snowflake;
const deanson = @import("../deanson.zig");
const Role = @import("./Role.zig");
const Emoji = @import("../Emoji.zig");
const GuildSticker = @import("./GuildSticker.zig");
const Omittable = deanson.Omittable;

id: Snowflake,
name: []const u8,
icon: ?[]const u8,
/// used for guild templates
icon_hash: Omittable(?[]const u8) = .omit,
splash: ?[]const u8,
discovery_splash: ?[]const u8,
/// true if the authenticated user is the owner of the guild
owner: Omittable(bool) = .omit,
owner_id: Snowflake,
permissions: Omittable([]const u8) = .omit,
region: Omittable(?[]const u8) = .omit,
afk_channel_id: ?Snowflake,
afk_timeout: i64,
widget_enabled: Omittable(bool) = .omit,
widget_channel_id: Omittable(?Snowflake) = .omit,
verification_level: VerificationLevel,
default_message_notifications: MessageNotificationLevel,
explicit_content_filter: ExplicitContentFilterLevel,
roles: []Role,
emojis: []Emoji,
/// https://discord.com/developers/docs/resources/guild#guild-object-guild-features
features: []const []const u8,
mfa_level: MfaLevel,
application_id: ?Snowflake,
system_channel_id: ?Snowflake,
system_channel_flags: SystemChannelFlags,
rules_channel_id: ?Snowflake,
max_presences: Omittable(?i64) = .omit,
max_members: Omittable(i64) = .omit,
vanity_url_code: ?[]const u8,
description: ?[]const u8,
banner: ?[]const u8,
premium_tier: PremiumTier,
premium_subscription_count: Omittable(i64) = .omit,
preferred_locale: []const u8,
public_updates_channel_id: ?Snowflake,
max_video_channel_users: Omittable(i64) = .omit,
max_stage_video_channel_users: Omittable(i64) = .omit,
approximate_member_count: Omittable(i64) = .omit,
approximate_presence_count: Omittable(i64) = .omit,
welcome_screen: Omittable(WelcomeScreen) = .omit,
nsfw_level: NsfwLevel,
stickers: Omittable([]const GuildSticker) = .omit,
premium_progress_bar_enabled: bool,
safety_alerts_channel_id: ?Snowflake,

pub const jsonStringify = deanson.stringifyWithOmit;

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

pub const SystemChannelFlags = model.Flags(enum(u4) {
    supress_join_notifications,
    suppress_premium_subscriptions,
    suppress_guild_reminder_notifications,
    suppress_join_notification_replies,
    suppress_role_subscription_purchase_notifications,
    suppress_role_subscription_purchase_notification_replies,
});

pub const Ban = struct {
    reason: ?[]const u8,
    user: model.User,
};

pub const Widget = struct {
    id: model.Snowflake,
    name: []const u8,
    instant_invite: ?[]const u8,
    channels: []const model.Channel,
    members: []const model.User,
    presence_count: i64,
};

pub const WidgetSettings = struct {
    enabled: bool,
    channel_id: ?Snowflake,
};

pub const Onboarding = struct {
    guild_id: Snowflake,
    prompts: []const Prompt,
    default_channel_ids: []const Snowflake,
    enabled: bool,
    mode: Mode,

    pub const Prompt = struct {
        id: Snowflake,
        type: PromptType,
        options: PromptOption,
        title: []const u8,
        single_select: bool,
        required: bool,
        in_onboarding: bool,
    };

    pub const PromptType = enum(u1) {
        multiple_choice = 0,
        dropdown = 1,
    };

    /// When creating or updating a prompt option, the `emoji_id`,
    /// `emoji_name`, and `emoji_animated` fields must be used instead of the emoji object.
    pub const PromptOption = struct {
        id: Snowflake,
        channel_ids: []const Snowflake,
        role_ids: []const Snowflake,
        emoji: Omittable(model.Emoji) = .omit,
        emoji_id: Omittable(Snowflake) = .omit,
        emoji_animated: Omittable(bool) = .omit,
        title: []const u8,
        description: ?[]const u8,
    };

    pub const Mode = enum(u1) {
        onboarding_default = 0,
        onboarding_advanced = 1,
    };
};
