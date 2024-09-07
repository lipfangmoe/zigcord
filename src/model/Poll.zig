const std = @import("std");
const deancord = @import("../root.zig");
const jconfig = deancord.jconfig;
const model = deancord.model;
const Snowflake = model.Snowflake;

question: Media,
answers: Answer,
expiry: ?model.IsoTime,
allow_multiselect: bool,
layout_type: i64,
results: jconfig.Omittable(Results) = .omit,

pub const jsonStringify = jconfig.stringifyWithOmit;

pub const Media = struct {
    text: jconfig.Omittable([]const u8) = .omit,
    emoji: jconfig.Omittable(jconfig.Partial(model.Emoji)) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const Answer = struct {
    answer_id: jconfig.Omittable(i64) = .omit,
    poll_media: Media,
};

pub const Results = struct {
    is_finalized: bool,
    answer_counts: []AnswerCount,

    pub const AnswerCount = struct {
        id: i64,
        count: i64,
        me_voted: bool,
    };
};
