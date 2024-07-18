const model = @import("../root.zig").model;
const ApplicationCommand = model.interaction.command.ApplicationCommand;
const Channel = model.Channel;
const User = model.User;

application_commands: []const ApplicationCommand,
audit_log_entries: []const Entry,
auto_moderation_rules: []const AutoModerationRule,
guild_scheduled_events: []const model.GuildScheduledEvent,
integrations: []const PartialIntegration,
threads: []const Channel,
users: []const User,
webhooks: []const Webhook,

pub const Entry = struct {};

// TODO - move to separate file
pub const AutoModerationRule = struct {};

pub const PartialIntegration = struct {};

// TODO - move to separate file
pub const Webhook = struct {};
