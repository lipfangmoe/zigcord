const std = @import("std");
const deancord = @import("../root.zig");
const model = deancord.model;
const jconfig = deancord.jconfig;
const Snowflake = model.Snowflake;

const Message = @This();

id: Snowflake,
channel_id: Snowflake,
author: MessageAuthor,
content: []const u8,
timestamp: model.IsoTime,
edited_timestamp: ?model.IsoTime,
tts: bool,
mention_everyone: bool,
mentions: []const model.User,
mention_roles: []const model.Role,
mention_channels: jconfig.Omittable([]const ChannelMention) = .omit,
attachments: []const Attachment,
embeds: []const Embed,
reactions: jconfig.Omittable([]const Reaction) = .omit,
nonce: jconfig.Omittable(Nonce) = .omit,
pinned: bool,
webhook_id: jconfig.Omittable(Snowflake) = .omit,
type: Type,
activity: jconfig.Omittable(Activity) = .omit,
application: jconfig.Omittable(jconfig.Partial(model.Application)) = .omit,
application_id: jconfig.Omittable(Snowflake) = .omit,
message_reference: jconfig.Omittable(Reference) = .omit,
flags: jconfig.Omittable(Flags) = .omit,
referenced_message: jconfig.Omittable(?*const Message) = .omit,
interaction_metadata: jconfig.Omittable(InteractionMetadata) = .omit,
thread: jconfig.Omittable(model.Channel) = .omit,
components: jconfig.Omittable([]const model.MessageComponent) = .omit,
sticker_items: jconfig.Omittable([]const model.Sticker.Item) = .omit,
stickers: jconfig.Omittable([]const model.Sticker) = .omit,
position: jconfig.Omittable(i64) = .omit,
role_subscription_data: jconfig.Omittable(RoleSubscriptionData) = .omit,
resolved: jconfig.Omittable(model.interaction.ResolvedData) = .omit,
poll: jconfig.Omittable(model.Poll) = .omit,
call: jconfig.Omittable(Call) = .omit,

pub const jsonStringify = model.jconfig.stringifyWithOmit;

pub fn jsonParse(alloc: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !Message {
    return try jsonParseFromValue(
        alloc,
        try std.json.innerParse(std.json.Value, alloc, source, options),
        options,
    );
}

pub fn jsonParseFromValue(alloc: std.mem.Allocator, source: std.json.Value, options: std.json.ParseOptions) std.json.ParseFromValueError!Message {
    const object = switch (source) {
        .object => |obj| obj,
        else => return error.UnexpectedToken,
    };

    const author: MessageAuthor = blk: {
        if (object.get("webhook_id")) |_| {
            break :blk .{ .webhook = try std.json.innerParseFromValue(MessageAuthor.WebhookAuthor, alloc, object.get("author") orelse return error.MissingField, options) };
        } else {
            break :blk .{ .user = try std.json.innerParseFromValue(model.User, alloc, object.get("author") orelse return error.MissingField, options) };
        }
    };

    var message: Message = undefined;
    inline for (std.meta.fields(Message)) |field| {
        if (comptime std.mem.eql(u8, field.name, "author")) {
            @field(message, "author") = author;
        } else {
            if (object.get(field.name)) |field_value| {
                @field(message, field.name) = try std.json.innerParseFromValue(field.type, alloc, field_value, options);
            } else {
                const default_opt: ?*const field.type = @alignCast(@ptrCast(field.default_value));
                if (default_opt) |default| {
                    @field(message, field.name) = default.*;
                } else {
                    std.log.err("Missing field: {s}", .{field.name});
                    return error.MissingField;
                }
            }
        }
    }
    return message;
}

pub const MessageAuthor = union(enum) {
    user: model.User,
    webhook: WebhookAuthor,

    pub const WebhookAuthor = struct {
        id: Snowflake,
        username: []const u8,
        avatar: ?[]const u8,
    };

    pub usingnamespace jconfig.InlineUnionMixin(@This());
};

pub const Attachment = struct {
    id: Snowflake,
    filename: []const u8,
    description: jconfig.Omittable([]const u8) = .omit,
    content_type: jconfig.Omittable([]const u8) = .omit,
    size: u64,
    url: []const u8,
    proxy_url: []const u8,
    height: jconfig.Omittable(?[]const u8) = .omit,
    width: jconfig.Omittable(?[]const u8) = .omit,
    ephemeral: jconfig.Omittable(bool) = .omit,
    duration_secs: jconfig.Omittable(f64) = .omit,
    waveform: jconfig.Omittable([]const u8) = .omit,
    flags: Flags,

    pub const jsonStringify = model.jconfig.stringifyWithOmit;
};

pub const ChannelMention = struct {
    id: Snowflake,
    guild_id: Snowflake,
    type: model.Channel.Type,
    name: []const u8,
};

pub const Embed = struct {
    title: jconfig.Omittable([]const u8) = .omit,
    type: jconfig.Omittable(EmbedType) = .omit,
    description: jconfig.Omittable([]const u8) = .omit,
    url: jconfig.Omittable([]const u8) = .omit,
    timestamp: jconfig.Omittable(model.IsoTime) = .omit,
    color: jconfig.Omittable(i64) = .omit,
    footer: jconfig.Omittable(Footer) = .omit,
    image: jconfig.Omittable(Media) = .omit,
    thumbnail: jconfig.Omittable(Media) = .omit,
    video: jconfig.Omittable(Media) = .omit,
    provider: jconfig.Omittable(Provider) = .omit,
    author: jconfig.Omittable(Author) = .omit,
    fields: jconfig.Omittable([]const Field) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const EmbedType = enum {
        rich,
        image,
        video,
        gifv,
        article,
        link,

        // enums are encoded as string by default, no need for custom jsonStringify
    };

    pub const Footer = struct {
        text: []const u8,
        icon_url: jconfig.Omittable([]const u8) = .omit,
        proxy_icon_url: jconfig.Omittable([]const u8) = .omit,

        pub const jsonStringify = jconfig.stringifyWithOmit;
    };

    pub const Media = struct {
        url: jconfig.Omittable([]const u8) = .omit,
        proxy_url: jconfig.Omittable([]const u8) = .omit,
        height: jconfig.Omittable(i64) = .omit,
        width: jconfig.Omittable(i64) = .omit,

        pub const jsonStringify = jconfig.stringifyWithOmit;
    };

    pub const Provider = struct {
        name: jconfig.Omittable([]const u8) = .omit,
        url: jconfig.Omittable([]const u8) = .omit,

        pub const jsonStringify = jconfig.stringifyWithOmit;
    };

    pub const Author = struct {
        name: []const u8,
        url: jconfig.Omittable([]const u8) = .omit,
        icon_url: jconfig.Omittable([]const u8) = .omit,
        proxy_icon_url: jconfig.Omittable([]const u8) = .omit,

        pub const jsonStringify = jconfig.stringifyWithOmit;
    };

    pub const Field = struct {
        name: []const u8,
        value: []const u8,
        @"inline": jconfig.Omittable(bool) = .omit,
    };
};

pub const Reaction = struct {
    count: i64,
    count_details: CountDetails,
    me: bool,
    me_burst: bool,
    emoji: jconfig.Partial(model.Emoji),
    burst_colors: []const i64,

    pub const CountDetails = struct {
        burst: i64,
        normal: i64,
    };

    pub const Type = enum(u1) {
        normal,
        burst,
    };
};

pub const Nonce = union(enum) {
    int: i64,
    str: []const u8,

    pub const jsonStringify = model.jconfig.stringifyUnionInline;

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, _: std.json.ParseOptions) !Nonce {
        const token = try source.nextAlloc(allocator, .alloc_if_needed);
        switch (token) {
            .number, .allocated_number => |number_str| {
                const number = try std.fmt.parseInt(i64, number_str, 10);
                return .{ .int = number };
            },
            .string, .allocated_string => |string| {
                return .{ .str = string };
            },
            else => return error.UnexpectedToken,
        }
    }

    pub fn jsonParseFromValue(_: std.mem.Allocator, source: std.json.Value, _: std.json.ParseOptions) !Nonce {
        return switch (source) {
            .integer => |int| .{ .int = int },
            .string, .number_string => |str| .{ .str = str },
            else => error.UnexpectedToken,
        };
    }
};

pub const Type = enum(u8) {
    default = 0,
    recipient_add = 1,
    recipient_remove = 2,
    call = 3,
    channel_name_change = 4,
    channel_icon_change = 5,
    channel_pinned_message = 6,
    user_join = 7,
    guild_boost = 8,
    guild_boost_tier_1 = 9,
    guild_boost_tier_2 = 10,
    guild_boost_tier_3 = 11,
    channel_follow_add = 12,
    guild_discovery_disqualified = 14,
    guild_discovery_requalified = 15,
    guild_discovery_grace_period_initial_warning = 16,
    guild_discovery_grace_period_final_warning = 17,
    thread_created = 18,
    reply = 19,
    chat_input_command = 20,
    thread_starter_message = 21,
    guild_invite_reminder = 22,
    context_menu_command = 23,
    auto_moderation_action = 24,
    role_subscription_purchase = 25,
    interaction_premium_upsell = 26,
    stage_start = 27,
    stage_end = 28,
    stage_speaker = 29,
    stage_topic = 31,
    guild_application_premium_subscription = 32,
    guild_incident_alert_mode_enabled = 36,
    guild_incident_alert_mode_disabled = 37,
    guild_incident_report_raid = 38,
    guild_incident_report_false_alarm = 39,
    purchase_notification = 44,
    _,

    pub const jsonStringify = model.jconfig.stringifyEnumAsInt;
};

pub const Activity = struct {
    type: ActivityType,
    party_id: jconfig.Omittable([]const u8) = .omit,

    pub const ActivityType = enum(u3) {
        join = 1,
        spectate = 2,
        listen = 3,
        join_request = 5,

        pub const jsonStringify = model.jconfig.stringifyEnumAsInt;
    };
};

pub const Reference = struct {
    message_id: jconfig.Omittable(Snowflake) = .omit,
    channel_id: jconfig.Omittable(Snowflake) = .omit,
    guild_id: jconfig.Omittable(Snowflake) = .omit,
    fail_if_not_exists: jconfig.Omittable(bool) = .omit,
};

pub const Flags = packed struct {
    crossposted: bool = false,
    is_crosspost: bool = false,
    suppress_embeds: bool = false,
    source_message_deleted: bool = false,
    urgent: bool = false,
    has_thread: bool = false,
    ephemeral: bool = false,
    loading: bool = false,
    failed_to_mention_some_roles_in_thread: bool = false,
    suppress_notifications: bool = false,
    is_voice_message: bool = false,

    pub usingnamespace model.PackedFlagsMixin(@This());
};

pub const InteractionMetadata = struct {
    id: Snowflake,
    type: model.interaction.InteractionType,
    user: model.User,
    authorizing_integration_owners: std.json.Value, // TODO: https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-authorizing-integration-owners-object
    original_response_message_id: jconfig.Omittable(Snowflake) = .omit,
    interacted_message_id: jconfig.Omittable(Snowflake) = .omit,
    triggering_interaction_metadata: jconfig.Omittable(?*const InteractionMetadata) = .omit,

    pub const jsonStringify = model.jconfig.stringifyWithOmit;
};

pub const RoleSubscriptionData = struct {
    role_subscription_listing_id: Snowflake,
    tier_name: []const u8,
    total_months_subscribed: i64,
    is_renwal: bool,
};

pub const Call = struct {
    participants: []const Snowflake,
    ended_timestamp: jconfig.Omittable(?model.IsoTime) = .omit,

    pub const jsonStringify = model.jconfig.stringifyWithOmit;
};

pub const AllowedMentions = struct {
    parse: []const AllowedMentionsType,
    roles: []const Snowflake,
    users: []const Snowflake,
    replied_user: bool,

    pub const AllowedMentionsType = enum {
        roles,
        users,
        everyone,
    };
};
