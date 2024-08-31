const std = @import("std");
const deancord = @import("../../root.zig");
const model = deancord.model;
const deanson = model.deanson;

pub const Hello = struct {
    heartbeat_interval: u64,
};

pub const Ready = struct {
    v: i64,
    user: model.User,
    guilds: []const model.guild.UnavailableGuild,
    session_id: []const u8,
    resume_gateway_url: []const u8,
    shard: deanson.Omittable([2]i64) = .omit,
    application: PartialApplication,

    pub const jsonStringify = deanson.stringifyWithOmit;

    pub const PartialApplication = struct {
        id: model.Snowflake,
        flags: model.Application.Flags,
    };
};

pub const Resumed = u0;

pub const Reconnect = u0;

pub const HeartbeatACK = u0;

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
    channel_id: deanson.Omittable(model.Snowflake) = .omit,
    message_id: deanson.Omittable(model.Snowflake) = .omit,
    alert_system_message_id: deanson.Omittable(model.Snowflake) = .omit,
    content: []const u8,
    matched_keyword: ?[]const u8,
    matched_content: ?[]const u8,

    pub const jsonStringify = deanson.stringifyWithOmit;
};

pub const ChannelCreate = model.Channel;

pub const ChannelUpdate = model.Channel;

pub const ChannelDelete = model.Channel;

pub const ChannelPinsUpdate = struct {
    guild_id: deanson.Omittable(model.Snowflake) = .omit,
    channel_id: model.Snowflake,
    last_pin_timestamp: deanson.Omittable(?model.IsoTime) = .omit,

    pub const jsonStringify = deanson.stringifyWithOmit;
};

pub const ThreadCreate = model.Channel;

pub const ThreadUpdate = model.Channel;

pub const ThreadDelete = struct {
    id: model.Snowflake,
    guild_id: deanson.Omittable(model.Snowflake) = .omit,
    parent_id: deanson.Omittable(model.Snowflake) = .omit,
    type: model.Channel.Type,

    pub const jsonStringify = deanson.stringifyWithOmit;
};

pub const ThreadListSync = struct {
    guild_id: model.Snowflake,
    channel_ids: deanson.Omittable([]const model.Snowflake) = .omit,
    threads: []const model.Channel,
    members: []const model.Channel.ThreadMember,

    pub const jsonStringify = deanson.stringifyWithOmit;
};

pub const ThreadMemberUpdate = struct {
    guild_id: model.Snowflake,
    id: deanson.Omittable(model.Snowflake) = .omit,
    user_id: deanson.Omittable(model.Snowflake) = .omit,
    join_timestamp: []model.IsoTime,
    flags: model.Channel.ThreadMember.Flags,
    member: deanson.Omittable(model.guild.Member) = .omit,

    pub const jsonStringify = deanson.stringifyWithOmit;
};

pub const ThreadMembersUpdate = struct {
    id: model.Snowflake,
    guild_id: model.Snowflake,
    member_count: i64,
    added_members: deanson.Omittable([]const model.Channel.ThreadMember) = .omit,
    removed_members: deanson.Omittable([]const model.Snowflake) = .omit,

    pub const jsonStringify = deanson.stringifyWithOmit;
};

pub const EntitlementCreate = model.Entitlement;

pub const EntitlementUpdate = model.Entitlement;

pub const EntitlementDelete = model.Entitlement;

pub const GuildCreate = model.guild.MaybeAvailable(struct {
    guild: model.guild.AvailableGuild,

    joined_at: model.IsoTime,
    large: bool,
    unavailable: deanson.Omittable(bool) = .omit,
    member_count: i64,
    voice_states: []const deanson.Partial(model.voice.VoiceState),
    members: []const model.guild.Member,
    channels: []const model.Channel,
    threads: []const model.Channel,
    presences: []const deanson.Partial(PresenceUpdate),
    stage_instances: []const model.StageInstance,
    guild_scheduled_events: []const model.GuildScheduledEvent,

    pub usingnamespace deanson.InlineFieldJsonMixin(@This(), "guild");
});

pub const GuildUpdate = model.guild.Guild;

pub const GuildDelete = model.guild.UnavailableGuild;

pub const GuildAuditLogEntryCreate = struct {
    audit_log_entry: model.AuditLog.Entry,
    guild_id: model.Snowflake,

    pub usingnamespace deanson.InlineFieldJsonMixin(GuildAuditLogEntryCreate, "audit_log_entry");
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

    pub usingnamespace deanson.InlineFieldJsonMixin(@This(), "guild_member");
};

pub const GuildMemberRemove = struct {
    guild_id: model.Snowflake,
    user: model.User,
};

pub const GuildMemberUpdate = struct {
    guild_id: model.Snowflake,
    roles: []const model.Snowflake,
    user: model.User,
    nick: deanson.Omittable(?[]const u8) = .omit,
    avatar: ?[]const u8,
    joined_at: ?model.IsoTime,
    premium_since: deanson.Omittable(?model.IsoTime) = .omit,
    deaf: deanson.Omittable(bool) = .omit,
    mute: deanson.Omittable(bool) = .omit,
    pending: deanson.Omittable(bool) = .omit,
    communications_disabled_until: deanson.Omittable(?model.IsoTime) = .omit,
    flags: model.guild.Member.Flags,
    avatar_decoration_data: model.User.AvatarDecorationData,

    pub const jsonStringify = model.deanson.stringifyWithOmit;
};

pub const GuildMembersChunk = struct {
    guild_id: model.Snowflake,
    members: []const model.guild.Member,
    chunk_index: i64,
    chunk_count: i64,
    not_found: deanson.Omittable([]const std.json.Value) = .omit,
    presences: deanson.Omittable([]const PresenceUpdate) = .omit,
    nonce: deanson.Omittable([]const u8) = .omit,

    pub const jsonStringify = model.deanson.stringifyWithOmit;
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

pub const IntegrationCreate = struct {
    integration: model.guild.Integration,
    guild_id: model.Snowflake,

    pub usingnamespace deanson.InlineFieldJsonMixin(@This(), "integration");
};

pub const IntegrationUpdate = struct {
    integration: model.guild.Integration,
    guild_id: model.Snowflake,

    pub usingnamespace deanson.InlineFieldJsonMixin(@This(), "integration");
};

pub const IntegrationDelete = struct {
    id: model.Snowflake,
    guild_id: model.Snowflake,
    application_id: deanson.Omittable(model.Snowflake) = .omit,

    pub const jsonStringify = model.deanson.stringifyWithOmit;
};

pub const InteractionCreate = model.interaction.Interaction;

pub const InviteCreate = struct {
    channel_id: model.Snowflake,
    code: []const u8,
    created_at: model.IsoTime,
    guild_id: deanson.Omittable(model.Snowflake) = .omit,
    inviter: deanson.Omittable(model.User) = .omit,
    max_age: i64,
    max_uses: i64,
    target_type: deanson.Omittable(model.Invite.Type) = .omit,
    target_user: deanson.Omittable(model.User) = .omit,
    target_application: deanson.Omittable(model.Application) = .omit,
    temporary: bool,
    uses: i64,

    pub const jsonStringify = model.deanson.stringifyWithOmit;
};

pub const InviteDelete = struct {
    channel_id: model.Snowflake,
    guild_id: deanson.Omittable(model.Snowflake) = .omit,
    code: []const u8,

    pub const jsonStringify = model.deanson.stringifyWithOmit;
};

pub const MessageCreate = struct {
    message: model.Message,
    guild_id: deanson.Omittable(model.Snowflake) = .omit,
    member: deanson.Omittable(deanson.Partial(model.guild.Member)) = .omit,
    mentions: []const UserWithPartialMember,

    pub usingnamespace deanson.InlineFieldJsonMixin(@This(), "message");

    pub const UserWithPartialMember = struct {
        user: model.User,
        member: deanson.Partial(model.guild.Member),

        pub usingnamespace deanson.InlineFieldJsonMixin(@This(), "user");
    };
};

pub const MessageUpdate = struct {
    message: model.Message,
    guild_id: deanson.Omittable(model.Snowflake) = .omit,
    member: deanson.Omittable(deanson.Partial(model.guild.Member)) = .omit,
    mentions: []const UserWithPartialMember,

    pub usingnamespace deanson.InlineFieldJsonMixin(@This(), "message");

    pub const UserWithPartialMember = struct {
        user: model.User,
        member: deanson.Partial(model.guild.Member),

        pub usingnamespace deanson.InlineFieldJsonMixin(@This(), "user");
    };
};

pub const MessageDelete = struct {
    id: model.Snowflake,
    channel_id: model.Snowflake,
    guild_id: deanson.Omittable(model.Snowflake),

    pub const jsonStringify = deanson.stringifyWithOmit;
};

pub const MessageDeleteBulk = struct {
    ids: []const model.Snowflake,
    channel_id: model.Snowflake,
    guild_id: deanson.Omittable(model.Snowflake) = .omit,

    pub const jsonStringify = deanson.stringifyWithOmit;
};

pub const MessageReactionAdd = struct {
    user_id: model.Snowflake,
    channel_id: model.Snowflake,
    message_id: model.Snowflake,
    guild_id: deanson.Omittable(model.Snowflake) = .omit,
    member: deanson.Omittable(model.guild.Member) = .omit,
    emoji: deanson.Partial(model.Emoji),
    message_author_id: deanson.Omittable(model.Snowflake) = .omit,
    burst: bool,
    burst_colors: deanson.Omittable([]const u8) = .omit,
    type: model.Message.Reaction.Type,

    pub const jsonStringify = deanson.stringifyWithOmit;
};

pub const MessageReactionRemove = struct {
    user_id: model.Snowflake,
    channel_id: model.Snowflake,
    message_id: model.Snowflake,
    guild_id: deanson.Omittable(model.Snowflake) = .omit,
    emoji: deanson.Partial(model.Emoji),
    burst: bool,
    type: model.Message.Reaction.Type,

    pub const jsonStringify = deanson.stringifyWithOmit;
};

pub const MessageReactionRemoveAll = struct {
    channel_id: model.Snowflake,
    message_id: model.Snowflake,
    guild_id: deanson.Omittable(model.Snowflake) = .omit,

    pub const jsonStringify = deanson.stringifyWithOmit;
};

pub const MessageReactionRemoveEmoji = struct {
    channel_id: model.Snowflake,
    message_id: model.Snowflake,
    guild_id: deanson.Omittable(model.Snowflake) = .omit,
    emoji: deanson.Partial(model.Emoji),

    pub const jsonStringify = deanson.stringifyWithOmit;
};

pub const PresenceUpdate = struct {
    user: model.User,
    guild_id: model.Snowflake,
    status: Status,
    activities: []const model.Activity,
    client_status: []const ClientStatus,

    pub const Status = enum {
        idle,
        dnd,
        online,
        offline,
    };
    pub const ClientStatus = struct {
        desktop: deanson.Omittable([]const u8) = .omit,
        mobile: deanson.Omittable([]const u8) = .omit,
        web: deanson.Omittable([]const u8) = .omit,

        pub const jsonStringify = deanson.stringifyWithOmit;
    };
};

pub const StageInstanceCreate = model.StageInstance;

pub const StageInstanceUpdate = model.StageInstance;

pub const StageInstanceDelete = model.StageInstance;

pub const TypingStart = struct {
    channel_id: model.Snowflake,
    guild_id: deanson.Omittable(model.Snowflake) = .omit,
    user_id: model.Snowflake,
    timestamp: i64,
    member: deanson.Omittable(model.guild.Member) = .omit,

    pub const jsonStringify = deanson.stringifyWithOmit;
};

pub const UserUpdate = model.User;

pub const VoiceChannelEffectSend = struct {
    channel_id: model.Snowflake,
    guild_id: model.Snowflake,
    user_id: model.Snowflake,
    emoji: deanson.Omittable(?model.Emoji) = .omit,
    animation_type: deanson.Omittable(?AnimationType) = .omit,
    animation_id: deanson.Omittable(i64) = .omit,
    sound_id: deanson.Omittable(model.Snowflake) = .omit,
    sound_volume: deanson.Omittable(f64) = .omit,

    pub const jsonStringify = deanson.stringifyWithOmit;

    pub const AnimationType = enum {
        premium,
        basic,

        pub const jsonStringify = deanson.stringifyEnumAsInt;
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
    guild_id: deanson.Omittable(model.Snowflake) = .omit,
    answer_id: i64,

    pub const jsonStringify = deanson.stringifyWithOmit;
};

pub const MessagePollVoteRemove = struct {
    user_id: model.Snowflake,
    channel_id: model.Snowflake,
    message_id: model.Snowflake,
    guild_id: deanson.Omittable(model.Snowflake) = .omit,
    answer_id: i64,

    pub const jsonStringify = deanson.stringifyWithOmit;
};
