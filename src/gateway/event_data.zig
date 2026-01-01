const std = @import("std");
const jconfig = @import("../root.zig").jconfig;

pub const send_events = @import("./event_data/send_events.zig");
pub const receive_events = @import("./event_data/receive_events.zig");

pub const ReceiveEvent = union(enum) {
    hello: receive_events.Hello,
    ready: receive_events.Ready,
    resumed: receive_events.Resumed,
    reconnect: receive_events.HeartbeatACK,
    invalid_session: receive_events.InvalidSession,
    application_command_permissions_update: receive_events.ApplicationCommandPermissionsUpdate,
    auto_moderation_rule_create: receive_events.AutoModerationRuleCreate,
    auto_moderation_rule_update: receive_events.AutoModerationRuleUpdate,
    auto_moderation_rule_delete: receive_events.AutoModerationRuleDelete,
    auto_moderation_action_execution: receive_events.AutoModerationActionExecution,
    channel_create: receive_events.ChannelCreate,
    channel_update: receive_events.ChannelUpdate,
    channel_delete: receive_events.ChannelDelete,
    thread_create: receive_events.ThreadCreate,
    thread_update: receive_events.ThreadUpdate,
    thread_delete: receive_events.ThreadDelete,
    thread_list_sync: receive_events.ThreadListSync,
    thread_member_update: receive_events.ThreadMemberUpdate,
    thread_members_update: receive_events.ThreadMembersUpdate,
    entitlement_create: receive_events.EntitlementCreate,
    entitlement_update: receive_events.EntitlementUpdate,
    entitlement_delete: receive_events.EntitlementDelete,
    guild_create: receive_events.GuildCreate,
    guild_update: receive_events.GuildUpdate,
    guild_delete: receive_events.GuildDelete,
    guild_audit_log_entry_create: receive_events.GuildAuditLogEntryCreate,
    guild_ban_add: receive_events.GuildBanAdd,
    guild_ban_remove: receive_events.GuildBanRemove,
    guild_emojis_update: receive_events.GuildEmojisUpdate,
    guild_stickers_update: receive_events.GuildStickersUpdate,
    guild_integrations_update: receive_events.GuildIntegrationsUpdate,
    guild_member_add: receive_events.GuildMemberAdd,
    guild_member_remove: receive_events.GuildMemberRemove,
    guild_member_update: receive_events.GuildMemberUpdate,
    guild_members_chunk: receive_events.GuildMembersChunk,
    guild_role_create: receive_events.GuildRoleCreate,
    guild_role_update: receive_events.GuildRoleUpdate,
    guild_role_delete: receive_events.GuildRoleDelete,
    guild_scheduled_event_create: receive_events.GuildScheduledEventCreate,
    guild_scheduled_event_update: receive_events.GuildScheduledEventUpdate,
    guild_scheduled_event_delete: receive_events.GuildScheduledEventDelete,
    guild_scheduled_event_user_add: receive_events.GuildScheduledEventUserAdd,
    guild_scheduled_event_user_remove: receive_events.GuildScheduledEventUserRemove,
    guild_soundboard_sound_create: receive_events.GuildSoundboardSoundCreate,
    guild_soundboard_sound_update: receive_events.GuildSoundboardSoundUpdate,
    guild_soundboard_sound_delete: receive_events.GuildSoundboardSoundDelete,
};

pub const SendEvent = AnyNamespaceDecl(send_events);

pub const Opcode = enum(u64) {
    dispatch = 0,
    heartbeat = 1,
    identify = 2,
    presence_update = 3,
    voice_state_update = 4,
    @"resume" = 6,
    reconnect = 7,
    request_guild_members = 8,
    invalid_session = 9,
    hello = 10,
    heartbeat_ack = 11,
    _,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};

test "AnyNamespaceDecl" {
    const TestNamespace = struct {
        pub const Foo = struct { foo: []const u8 };
        pub const Bar = struct { bar: i64 };
    };
    const AnyTest = AnyNamespaceDecl(TestNamespace);

    _ = AnyTest{ .Foo = TestNamespace.Foo{ .foo = "lol" } };
    _ = AnyTest{ .Bar = TestNamespace.Bar{ .bar = 5 } };
}
