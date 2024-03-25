const model = @import("../model.zig");
const ApplicationCommand = model.interaction.command.ApplicationCommand;
const Channel = model.guild.channel.Channel;
const User = model.User;

application_commands: []const ApplicationCommand,
audit_log_entries: []const Entry,
auto_moderation_rules: []const AutoModerationRule,
guild_scheduled_events: []const GuildScheduledEvents,
integrations: []const PartialIntegration,
threads: []const Channel,
users: []const User,
webhooks: []const Webhook,

pub const Entry = struct {};

// TODO - move to separate file
pub const AutoModerationRule = struct {};

// TODO - move to separate file
pub const GuildScheduledEvents = struct {};

pub const PartialIntegration = struct {};

// TODO - move to separate file
pub const Webhook = struct {};
