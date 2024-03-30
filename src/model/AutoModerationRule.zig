const model = @import("model");
const deanson = model.deanson;
const Snowflake = model.Snowflake;

id: Snowflake,
guild_id: Snowflake,
name: []const u8,
creator_id: Snowflake,
event_type: EventType,
trigger_type: TriggerType,
trigger_metadata: TriggerMetadata,

pub const EventType = enum(u8) {
    message_send = 1,

    pub const jsonStringify = deanson.stringifyEnumAsInt;
};

pub const TriggerType = enum(u8) {
    keyword = 1,
    spam = 3,
    keyword_preset = 4,
    mention_spam = 5,

    pub const jsonStringify = deanson.stringifyEnumAsInt;
};

// TODO https://discord.com/developers/docs/resources/auto-moderation#auto-moderation-rule-object-trigger-metadata
pub const TriggerMetadata = union(TriggerType) {
    keyword: struct {
        keyword_filter: []const []const u8,
        regex_patterns: []const []const u8,
        allow_list: []const []const u8,
    },
    spam: struct {},
    keyword_preset: struct {
        presets: []const KeywordPreset,
        allow_list: []const []const u8,
    },
    mention_spam: struct {
        mention_total_limit: i64,
        mention_raid_protection_enabled: bool,
    },

    pub const jsonStringify = deanson.stringifyUnionInline;
};

pub const KeywordPreset = enum(u8) {
    profanity = 1,
    sexual_content = 2,
    slurs = 3,
};
