const model = @import("../root.zig").model;
const command = model.interaction.command;
const deanson = model.deanson;

application_commands: []const model.interaction.command.ApplicationCommand,
audit_log_entries: []const Entry,
auto_moderation_rules: []const model.AutoModerationRule,
guild_scheduled_events: []const model.GuildScheduledEvent,
integrations: []const deanson.Partial(model.guild.Integration),
threads: []const model.Channel,
users: []const model.User,
webhooks: []const Webhook,

// TODO
pub const Entry = struct {};

// TODO - Webhook.zig
pub const Webhook = struct {};
