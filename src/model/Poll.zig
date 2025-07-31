const std = @import("std");
const zigcord = @import("../root.zig");
const jconfig = zigcord.jconfig;
const model = zigcord.model;
const Snowflake = model.Snowflake;

const Poll = @This();

question: Media,
answers: []const Answer,
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

    pub const jsonStringify = jconfig.stringifyWithOmit;
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

test "poll" {
    const poll_example =
        \\{"question":{"text":"redacted"},"layout_type":1,"expiry":"2025-07-01T14:00:00.000000+00:00","answers":[    {"poll_media":{"text":"redacted"},"answer_id":1},    {"poll_media":{"text":"redacted"},"answer_id":2}],"allow_multiselect":false}
    ;

    const value = try std.json.parseFromSlice(Poll, std.testing.allocator, poll_example, .{});
    value.deinit();
}
