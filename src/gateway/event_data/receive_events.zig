const std = @import("std");
const model = @import("model");
const jconfig = @import("jconfig");

pub const Hello = struct {
    heartbeat_interval: u64,
};

pub const Ready = struct {
    v: i64,
    user: model.User,
    guilds: []const model.guild.UnavailableGuild,
    session_id: []const u8,
    resume_gateway_url: []const u8,
    shard: ?[2]i64 = null,
    application: PartialApplication,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const PartialApplication = struct {
        id: model.Snowflake,
        flags: model.Application.Flags,
    };
};

pub const Resumed = ?struct {}; // should be ?noreturn or @TypeOf(null)

pub const Reconnect = ?struct {}; // should be ?noreturn or @TypeOf(null)

pub const HeartbeatACK = ?struct {}; // should be ?noreturn or @TypeOf(null)

pub const InvalidSession = bool;

pub const ApplicationCommandPermissionsUpdate = model.interaction.command.ApplicationCommandPermission;

pub const AutoModerationRuleCreate = model.AutoModerationRule;

pub const AutoModerationRuleUpdate = model.AutoModerationRule;

pub const AutoModerationRuleDelete = model.AutoModerationRule;

pub const AutoModerationActionExecution = struct {
    guild_id: model.Snowflake,
    action: model.AutoModerationAction,
    rule_id: model.Snowflake,
    rule_trigger_type: model.AutoModerationRule.TriggerType,
    user_id: model.Snowflake,
    channel_id: ?model.Snowflake = null,
    message_id: ?model.Snowflake = null,
    alert_system_message_id: ?model.Snowflake = null,
    content: []const u8,
    matched_keyword: ?[]const u8,
    matched_content: ?[]const u8,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ChannelCreate = model.Channel;

pub const ChannelUpdate = model.Channel;

pub const ChannelDelete = model.Channel;

pub const ChannelPinsUpdate = struct {
    guild_id: ?model.Snowflake = null,
    channel_id: model.Snowflake,
    last_pin_timestamp: jconfig.Omittable(?model.IsoTime) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ChannelInfo = struct {
    guild_id: model.Snowflake,
    channels: []const Channel,

    pub const Channel = struct {
        id: model.Snowflake,
        status: jconfig.Omittable(?[]const u8) = .omit,
        voice_start_time: jconfig.Omittable(?u64) = .omit,
    };
};

pub const VoiceChannelStatusUpdate = struct {
    id: model.Snowflake,
    guild_id: model.Snowflake,
    status: ?[]const u8,
};

pub const VoiceChannelStartTimeUpdate = struct {
    id: model.Snowflake,
    guild_id: model.Snowflake,
    voice_start_time: jconfig.Omittable(?u64) = .omit,
};

pub const ThreadCreate = model.Channel;

pub const ThreadUpdate = model.Channel;

pub const ThreadDelete = struct {
    id: model.Snowflake,
    guild_id: ?model.Snowflake = null,
    parent_id: ?model.Snowflake = null,
    type: model.Channel.Type,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ThreadListSync = struct {
    guild_id: model.Snowflake,
    channel_ids: ?[]const model.Snowflake = null,
    threads: []const model.Channel,
    members: []const model.Channel.ThreadMember,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ThreadMemberUpdate = struct {
    guild_id: model.Snowflake,
    id: ?model.Snowflake = null,
    user_id: ?model.Snowflake = null,
    join_timestamp: model.IsoTime,
    flags: model.Channel.ThreadMember.Flags,
    member: ?model.guild.Member = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const ThreadMembersUpdate = struct {
    id: model.Snowflake,
    guild_id: model.Snowflake,
    member_count: i64,
    added_members: ?[]const model.Channel.ThreadMember = null,
    removed_members: ?[]const model.Snowflake = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const EntitlementCreate = model.Entitlement;

pub const EntitlementUpdate = model.Entitlement;

pub const EntitlementDelete = model.Entitlement;

pub const GuildCreate = model.guild.MaybeAvailable(struct {
    guild: model.guild.AvailableGuild,

    joined_at: model.IsoTime,
    large: bool,
    unavailable: ?bool = null,
    member_count: i64,
    voice_states: []const model.voice.VoiceState,
    members: []const model.guild.Member,
    channels: []const model.Channel,
    threads: []const model.Channel,
    presences: []const jconfig.Partial(PresenceUpdate),
    stage_instances: []const model.StageInstance,
    guild_scheduled_events: []const model.GuildScheduledEvent,

    const Mixin = jconfig.InlineSingleStructFieldMixin(@This(), "guild");
    pub const jsonStringify = Mixin.jsonStringify;
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;
});

pub const GuildUpdate = model.guild.Guild;

pub const GuildDelete = model.guild.UnavailableGuild;

pub const GuildAuditLogEntryCreate = struct {
    audit_log_entry: model.AuditLog.Entry,
    guild_id: model.Snowflake,

    const Mixin = jconfig.InlineSingleStructFieldMixin(GuildAuditLogEntryCreate, "audit_log_entry");
    pub const jsonStringify = Mixin.jsonStringify;
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;
};

pub const GuildBanAdd = struct {
    guild_id: model.Snowflake,
    user: model.User,
};

pub const GuildBanRemove = struct {
    guild_id: model.Snowflake,
    user: model.User,
};

pub const GuildEmojisUpdate = struct {
    guild_id: model.Snowflake,
    emojis: []const model.Emoji,
};

pub const GuildStickersUpdate = struct {
    guild_id: model.Snowflake,
    stickers: []const model.Sticker,
};

pub const GuildIntegrationsUpdate = struct {
    guild_id: model.Snowflake,
};

pub const GuildMemberAdd = struct {
    guild_member: model.guild.Member,
    guild_id: model.Snowflake,

    const Mixin = jconfig.InlineSingleStructFieldMixin(@This(), "guild_member");
    pub const jsonStringify = Mixin.jsonStringify;
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;
};

pub const GuildMemberRemove = struct {
    guild_id: model.Snowflake,
    user: model.User,
};

pub const GuildMemberUpdate = struct {
    guild_id: model.Snowflake,
    roles: []const model.Snowflake,
    user: model.User,
    nick: jconfig.Omittable(?[]const u8) = .omit,
    avatar: ?[]const u8,
    joined_at: ?model.IsoTime,
    premium_since: jconfig.Omittable(?model.IsoTime) = .omit,
    deaf: ?bool = null,
    mute: ?bool = null,
    pending: ?bool = null,
    communications_disabled_until: jconfig.Omittable(?model.IsoTime) = .omit,
    flags: model.guild.Member.Flags,
    avatar_decoration_data: jconfig.Omittable(?model.User.AvatarDecorationData) = .omit,
    collectibles: jconfig.Omittable(?model.User.Collectibles) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const GuildMembersChunk = struct {
    guild_id: model.Snowflake,
    members: []const model.guild.Member,
    chunk_index: i64,
    chunk_count: i64,
    not_found: ?[]const std.json.Value = null,
    presences: ?[]const PresenceUpdate = null,
    nonce: ?[]const u8 = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const GuildRoleCreate = struct {
    guild_id: model.Snowflake,
    role: model.Role,
};

pub const GuildRoleUpdate = struct {
    guild_id: model.Snowflake,
    role: model.Role,
};

pub const GuildRoleDelete = struct {
    guild_id: model.Snowflake,
    role_id: model.Snowflake,
};

pub const GuildScheduledEventCreate = model.GuildScheduledEvent;

pub const GuildScheduledEventUpdate = model.GuildScheduledEvent;

pub const GuildScheduledEventDelete = model.GuildScheduledEvent;

pub const GuildScheduledEventUserAdd = struct {
    guild_scheduled_event_id: model.Snowflake,
    user_id: model.Snowflake,
    guild_id: model.Snowflake,
};

pub const GuildScheduledEventUserRemove = struct {
    guild_scheduled_event_id: model.Snowflake,
    user_id: model.Snowflake,
    guild_id: model.Snowflake,
};

pub const GuildSoundboardSoundCreate = model.SoundboardSound;

pub const GuildSoundboardSoundUpdate = model.SoundboardSound;

pub const GuildSoundboardSoundDelete = struct {
    sound_id: model.Snowflake,
    guild_id: model.Snowflake,
};

pub const GuildSoundboardSoundsUpdate = struct {
    soundboard_sounds: []const model.SoundboardSound,
    guild_id: model.Snowflake,
};

pub const SoundboardSounds = struct {
    soundboard_sounds: []const model.SoundboardSound,
    guild_id: model.Snowflake,
};

pub const IntegrationCreate = struct {
    integration: model.guild.Integration,
    guild_id: model.Snowflake,

    const Mixin = jconfig.InlineSingleStructFieldMixin(@This(), "integration");
    pub const jsonStringify = Mixin.jsonStringify;
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;
};

pub const IntegrationUpdate = struct {
    integration: model.guild.Integration,
    guild_id: model.Snowflake,

    const Mixin = jconfig.InlineSingleStructFieldMixin(@This(), "integration");
    pub const jsonStringify = Mixin.jsonStringify;
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;
};

pub const IntegrationDelete = struct {
    id: model.Snowflake,
    guild_id: model.Snowflake,
    application_id: ?model.Snowflake = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const InteractionCreate = model.interaction.Interaction;

pub const InviteCreate = struct {
    channel_id: model.Snowflake,
    code: []const u8,
    created_at: model.IsoTime,
    guild_id: ?model.Snowflake = null,
    inviter: ?model.User = null,
    max_age: i64,
    max_uses: i64,
    target_type: ?model.Invite.Type = null,
    target_user: ?model.User = null,
    target_application: ?model.Application = null,
    temporary: bool,
    uses: i64,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const InviteDelete = struct {
    channel_id: model.Snowflake,
    guild_id: ?model.Snowflake = null,
    code: []const u8,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const MessageCreate = struct {
    message: model.Message,
    guild_id: ?model.Snowflake = null,
    member: ?jconfig.Partial(model.guild.Member) = null,
    mentions: []const UserWithPartialMember,

    const Mixin = jconfig.InlineSingleStructFieldMixin(@This(), "message");
    pub const jsonStringify = Mixin.jsonStringify;
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;

    pub const UserWithPartialMember = struct {
        user: model.User,
        member: ?jconfig.Partial(model.guild.Member) = null,

        const Mixin2 = jconfig.InlineSingleStructFieldMixin(@This(), "user");
        pub const jsonStringify = Mixin2.jsonStringify;
        pub const jsonParse = Mixin2.jsonParse;
        pub const jsonParseFromValue = Mixin2.jsonParseFromValue;
    };
};

pub const MessageUpdate = struct {
    message: model.Message,
    guild_id: ?model.Snowflake = null,
    member: ?jconfig.Partial(model.guild.Member) = null,
    mentions: []const UserWithPartialMember,

    const Mixin = jconfig.InlineSingleStructFieldMixin(@This(), "message");
    pub const jsonStringify = Mixin.jsonStringify;
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;

    pub const UserWithPartialMember = struct {
        user: model.User,
        member: ?jconfig.Partial(model.guild.Member) = null,

        const Mixin2 = jconfig.InlineSingleStructFieldMixin(@This(), "user");
        pub const jsonStringify = Mixin2.jsonStringify;
        pub const jsonParse = Mixin2.jsonParse;
        pub const jsonParseFromValue = Mixin2.jsonParseFromValue;
    };
};

pub const MessageDelete = struct {
    id: model.Snowflake,
    channel_id: model.Snowflake,
    guild_id: ?model.Snowflake = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const MessageDeleteBulk = struct {
    ids: []const model.Snowflake,
    channel_id: model.Snowflake,
    guild_id: ?model.Snowflake = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const MessageReactionAdd = struct {
    user_id: model.Snowflake,
    channel_id: model.Snowflake,
    message_id: model.Snowflake,
    guild_id: ?model.Snowflake = null,
    member: ?model.guild.Member = null,
    emoji: jconfig.Partial(model.Emoji),
    message_author_id: ?model.Snowflake = null,
    burst: bool,
    burst_colors: ?[]const u8 = null,
    type: model.Message.Reaction.Type,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const MessageReactionRemove = struct {
    user_id: model.Snowflake,
    channel_id: model.Snowflake,
    message_id: model.Snowflake,
    guild_id: ?model.Snowflake = null,
    emoji: jconfig.Partial(model.Emoji),
    burst: bool,
    type: model.Message.Reaction.Type,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const MessageReactionRemoveAll = struct {
    channel_id: model.Snowflake,
    message_id: model.Snowflake,
    guild_id: ?model.Snowflake = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const MessageReactionRemoveEmoji = struct {
    channel_id: model.Snowflake,
    message_id: model.Snowflake,
    guild_id: ?model.Snowflake = null,
    emoji: jconfig.Partial(model.Emoji),

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const PresenceUpdate = struct {
    user: ?PartialUser = null,
    guild_id: ?model.Snowflake = null,
    status: ?Status = null,
    activities: ?[]const model.Activity = null,
    client_status: ?ClientStatus = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const PartialUser = struct {
        id: model.Snowflake,
        username: ?[]const u8 = null,
        discriminator: ?[]const u8 = null,
        global_name: jconfig.Omittable(?[]const u8) = .omit,
        avatar: jconfig.Omittable(?[]const u8) = .omit,
        bot: ?bool = null,
        system: ?bool = null,
        mfa_enabled: ?(bool) = null,
        banner: jconfig.Omittable(?[]const u8) = .omit,
        accent_color: jconfig.Omittable(?i64) = .omit,
        locale: ?([]const u8) = null,
        verified: ?(bool) = null,
        email: jconfig.Omittable(?[]const u8) = .omit,
        flags: ?model.User.Flags = null,
        premium_type: ?model.User.NitroType = null,
        public_flags: ?model.User.Flags = null,
        avatar_decoration_data: jconfig.Omittable(?model.User.AvatarDecorationData) = .omit,
        collectibles: jconfig.Omittable(?model.User.Collectibles) = .omit,
        primary_guild: jconfig.Omittable(?model.User.PrimaryGuild) = .omit,

        pub const jsonStringify = jconfig.stringifyWithOmit;

        test "is partial user" {
            try jconfig.testing.expectIsPartialOf(PartialUser, model.User);
        }
    };

    pub const Status = enum {
        idle,
        dnd,
        online,
        offline,
    };
    pub const ClientStatus = struct {
        desktop: ?[]const u8 = null,
        mobile: ?[]const u8 = null,
        web: ?[]const u8 = null,

        pub const jsonStringify = jconfig.stringifyWithOmit;
    };
};

pub const StageInstanceCreate = model.StageInstance;

pub const StageInstanceUpdate = model.StageInstance;

pub const StageInstanceDelete = model.StageInstance;

pub const SubscriptionCreate = model.Subscription;

pub const SubscriptionUpdate = model.Subscription;

pub const SubscriptionDelete = model.Subscription;

pub const TypingStart = struct {
    channel_id: model.Snowflake,
    guild_id: ?model.Snowflake = null,
    user_id: model.Snowflake,
    timestamp: i64,
    member: ?model.guild.Member = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const UserUpdate = model.User;

pub const VoiceChannelEffectSend = struct {
    channel_id: model.Snowflake,
    guild_id: model.Snowflake,
    user_id: model.Snowflake,
    emoji: jconfig.Omittable(?model.Emoji) = .omit,
    animation_type: jconfig.Omittable(?AnimationType) = .omit,
    animation_id: ?i64 = null,
    sound_id: ?model.Snowflake = null,
    sound_volume: ?f64 = null,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const AnimationType = enum {
        premium,
        basic,

        pub const jsonStringify = jconfig.stringifyEnumAsInt;
    };
};

pub const VoiceStateUpdate = model.voice.VoiceState;

pub const VoiceServerUpdate = struct {
    token: []const u8,
    guild_id: model.Snowflake,
    endpoint: ?[]const u8,
};

pub const WebhooksUpdate = struct {
    guild_id: model.Snowflake,
    channel_id: model.Snowflake,
};

pub const MessagePollVoteAdd = struct {
    user_id: model.Snowflake,
    channel_id: model.Snowflake,
    message_id: model.Snowflake,
    guild_id: ?model.Snowflake = null,
    answer_id: i64,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const MessagePollVoteRemove = struct {
    user_id: model.Snowflake,
    channel_id: model.Snowflake,
    message_id: model.Snowflake,
    guild_id: ?model.Snowflake = null,
    answer_id: i64,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const Undocumented = std.json.Value;
