const std = @import("std");
const model = @import("../root.zig").model;
const zigtime = @import("zig-time");
const Snowflake = model.Snowflake;
const deanson = model.deanson;

pub const Guild = union(enum) {
    available: AvailableGuild,
    unavailable: UnavailableGuild,

    pub const jsonStringify = model.deanson.stringifyUnionInline;

    pub fn jsonParse(alloc: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !Guild {
        const value = try std.json.innerParse(std.json.Value, alloc, source, options);

        return try jsonParseFromValue(alloc, value, options);
    }

    pub fn jsonParseFromValue(alloc: std.mem.Allocator, source: std.json.Value, options: std.json.ParseOptions) !Guild {
        const obj: std.json.ObjectMap = switch (source) {
            .object => |object| object,
            else => return error.UnexpectedToken,
        };

        if (obj.get("unavailable")) |unavailable_value| {
            const unavailable = switch (unavailable_value) {
                .bool => |boolean| boolean,
                else => return error.UnexpectedToken,
            };
            if (unavailable) {
                return .{ .unavailable = try std.json.innerParseFromValue(UnavailableGuild, alloc, source, options) };
            }
        }

        return .{ .available = try std.json.innerParseFromValue(AvailableGuild, alloc, source, options) };
    }
};

pub const PartialGuild = union(enum) {
    available: deanson.Partial(AvailableGuild),
    unavailable: deanson.Partial(UnavailableGuild),

    pub const jsonStringify = model.deanson.stringifyUnionInline;

    pub fn jsonParse(alloc: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !PartialGuild {
        const value = try std.json.innerParse(std.json.Value, alloc, source, options);

        return try jsonParseFromValue(alloc, value, options);
    }

    pub fn jsonParseFromValue(alloc: std.mem.Allocator, source: std.json.Value, options: std.json.ParseOptions) !PartialGuild {
        const obj: std.json.ObjectMap = switch (source) {
            .object => |object| object,
            else => return error.UnexpectedToken,
        };

        if (obj.get("unavailable")) |unavailable_value| {
            const unavailable = switch (unavailable_value) {
                .bool => |boolean| boolean,
                else => return error.UnexpectedToken,
            };
            if (unavailable) {
                return .{ .unavailable = try std.json.innerParseFromValue(deanson.Partial(UnavailableGuild), alloc, source, options) };
            }
        }

        return .{ .available = try std.json.innerParseFromValue(deanson.Partial(AvailableGuild), alloc, source, options) };
    }
};

pub const AvailableGuild = struct {
    id: Snowflake,
    name: []const u8,
    icon: ?[]const u8,
    /// used for guild templates
    icon_hash: deanson.Omittable(?[]const u8) = .omit,
    splash: ?[]const u8,
    discovery_splash: ?[]const u8,
    /// true if the authenticated user is the owner of the guild
    owner: deanson.Omittable(bool) = .omit,
    owner_id: Snowflake,
    permissions: deanson.Omittable([]const u8) = .omit,
    region: deanson.Omittable(?[]const u8) = .omit,
    afk_channel_id: ?Snowflake,
    afk_timeout: i64,
    widget_enabled: deanson.Omittable(bool) = .omit,
    widget_channel_id: deanson.Omittable(?Snowflake) = .omit,
    verification_level: VerificationLevel,
    default_message_notifications: MessageNotificationLevel,
    explicit_content_filter: ExplicitContentFilterLevel,
    roles: []model.Role,
    emojis: []model.Emoji,
    /// https://discord.com/developers/docs/resources/guild#guild-object-guild-features
    features: []const []const u8,
    mfa_level: MfaLevel,
    application_id: ?Snowflake,
    system_channel_id: ?Snowflake,
    system_channel_flags: SystemChannelFlags,
    rules_channel_id: ?Snowflake,
    max_presences: deanson.Omittable(?i64) = .omit,
    max_members: deanson.Omittable(i64) = .omit,
    vanity_url_code: ?[]const u8,
    description: ?[]const u8,
    banner: ?[]const u8,
    premium_tier: PremiumTier,
    premium_subscription_count: deanson.Omittable(i64) = .omit,
    preferred_locale: []const u8,
    public_updates_channel_id: ?Snowflake,
    max_video_channel_users: deanson.Omittable(i64) = .omit,
    max_stage_video_channel_users: deanson.Omittable(i64) = .omit,
    approximate_member_count: deanson.Omittable(i64) = .omit,
    approximate_presence_count: deanson.Omittable(i64) = .omit,
    welcome_screen: deanson.Omittable(WelcomeScreen) = .omit,
    nsfw_level: NsfwLevel,
    stickers: deanson.Omittable([]const model.Sticker) = .omit,
    premium_progress_bar_enabled: bool,
    safety_alerts_channel_id: ?Snowflake,

    pub const jsonStringify = model.deanson.stringifyWithOmit;
};

pub const UnavailableGuild = struct {
    id: deanson.Omittable(model.Snowflake) = .omit,
    unavailable: deanson.Omittable(bool) = .omit,

    pub const jsonStringify = model.deanson.stringifyWithOmit;
};

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

    pub const jsonStringify = model.deanson.stringifyEnumAsInt;
};

pub const MessageNotificationLevel = enum {
    all_messages,
    only_mentions,

    pub const jsonStringify = model.deanson.stringifyEnumAsInt;
};

pub const ExplicitContentFilterLevel = enum {
    disabled,
    members_without_roles,
    all_members,

    pub const jsonStringify = model.deanson.stringifyEnumAsInt;
};

pub const MfaLevel = enum {
    none,
    elevated,

    pub const jsonStringify = model.deanson.stringifyEnumAsInt;
};

pub const PremiumTier = enum {
    none,
    tier_1,
    tier_2,
    tier_3,

    pub const jsonStringify = model.deanson.stringifyEnumAsInt;
};

pub const NsfwLevel = enum {
    default,
    explicit,
    safe,
    age_restricted,

    pub const jsonStringify = model.deanson.stringifyEnumAsInt;
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
    channels: []const deanson.Partial(model.Channel),
    members: []const deanson.Partial(model.User),
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
        emoji: deanson.Omittable(model.Emoji) = .omit,
        emoji_id: deanson.Omittable(Snowflake) = .omit,
        emoji_animated: deanson.Omittable(bool) = .omit,
        title: []const u8,
        description: ?[]const u8,

        pub usingnamespace model.deanson.OmittableJsonMixin(@This());
    };

    pub const Mode = enum(u1) {
        onboarding_default = 0,
        onboarding_advanced = 1,
    };
};

pub const Preview = struct {
    id: Snowflake,
    name: []const u8,
    icon: ?[]const u8,
    splash: ?[]const u8,
    discovery_splash: ?[]const u8,
    emojis: []model.Emoji,
    /// https://discord.com/developers/docs/resources/guild#guild-object-guild-features
    features: []const u8,
    mfa_level: MfaLevel,
    approximate_member_count: ?i64,
    approximate_presence_count: ?i64,
    description: ?[]const u8,
    stickers: ?[]model.Sticker,
};

pub const Integration = struct {
    id: model.Snowflake,
    name: []const u8,
    type: []const u8,
    enabled: bool,
    syncing: deanson.Omittable(bool) = .omit,
    role_id: deanson.Omittable(model.Snowflake) = .omit,
    enable_emoticons: deanson.Omittable(bool) = .omit,
    expire_behavior: deanson.Omittable(ExpireBehavior) = .omit,
    expire_grace_period: deanson.Omittable(i64) = .omit,
    user: deanson.Omittable(model.User) = .omit,
    account: deanson.Omittable(Account) = .omit,
    synced_at: deanson.Omittable([]const u8) = .omit,
    subscriber_count: deanson.Omittable(i64) = .omit,
    revoked: deanson.Omittable(bool) = .omit,
    application: deanson.Omittable(model.Application) = .omit,
    scopes: deanson.Omittable([]const []const u8) = .omit,

    pub const ExpireBehavior = enum(u1) {
        remove_role = 0,
        kick = 1,
    };

    pub const Account = struct {
        id: []const u8,
        name: []const u8,
    };
};

pub const Member = struct {
    /// The User object for this guild member
    user: deanson.Omittable(model.User) = .omit,
    /// The nickname this user uses in this guild
    nick: deanson.Omittable(?[]const u8) = .omit,
    /// A guild-specific avatar hash
    avatar: deanson.Omittable(?[]const u8) = .omit,
    /// The role ids that this user has
    roles: []Snowflake,
    /// when the user joined the guild
    joined_at: zigtime.DateTime,
    /// when the user started boosting the guild
    premium_since: deanson.Omittable(?[]zigtime.DateTime) = .omit,
    /// true if this user is deafened in voice channels
    deaf: bool,
    /// true if this user is muted in voice channels
    mute: bool,
    /// guild member flags
    flags: Flags,
    /// true if the user has not passed the guild's membership screening requirements
    pending: deanson.Omittable(bool) = .omit,
    /// returned inside of interaction objects, permissions of the member in the interacted channel
    permissions: deanson.Omittable([]const u8) = .omit,
    /// when the user's timeout will expire. may be in the past; if so, the user is not timed out.
    communication_disabled_until: deanson.Omittable(?[]zigtime.DateTime) = .omit,

    pub const jsonStringify = model.deanson.stringifyWithOmit;

    pub const Flags = model.Flags(enum {
        did_rejoin,
        completed_onboarding,
        bypasses_verification,
        started_onboarding,
    });
};
