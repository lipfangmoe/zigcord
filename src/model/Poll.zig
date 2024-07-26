const std = @import("std");
const zigtime = @import("zig-time");
const deancord = @import("../root.zig");
const model = deancord.model;
const Snowflake = model.Snowflake;
const deanson = model.deanson;

question: Media,
answers: Answer,
expiry: ?zigtime.DateTime,
allow_multiselect: bool,
layout_type: i64,
results: deanson.Omittable(Results) = .omit,

pub const Media = struct {
    text: deanson.Omittable([]const u8) = .omit,
    emoji: deanson.Omittable(deanson.Partial(model.Emoji)) = .omit,

    pub const jsonStringify = model.deanson.stringifyWithOmit;
};

pub const Answer = struct {
    answer_id: deanson.Omittable(i64) = .omit,
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

pub const jsonStringify = model.deanson.stringifyWithOmit;
