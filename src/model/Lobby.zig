const std = @import("std");
const zigcord = @import("../root.zig");
const model = zigcord.model;
const jconfig = zigcord.jconfig;

const Lobby = @This();

id: model.Snowflake,
application_id: model.Snowflake,
metadata: ?std.json.ArrayHashMap([]const u8),
members: []const LobbyMember,
linked_Channel: jconfig.Omittable(model.Channel) = .omit,

pub const LobbyMember = struct {
    id: model.Snowflake,
    metadata: jconfig.Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    flags: jconfig.Omittable(Flags),

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const Flags = packed struct(u64) {
        can_link_lobby: bool = false,
        _padding: u63 = 0,

        const Mixin = model.PackedFlagsMixin(Flags);
        pub const format = Mixin.format;
        pub const formatNumber = Mixin.formatNumber;
        pub const jsonStringify = Mixin.jsonStringify;
        pub const jsonParse = Mixin.jsonParse;
        pub const jsonParseFromValue = Mixin.jsonParseFromValue;
    };
};

pub const LobbyMessage = struct {
    id: model.Snowflake,
    type: model.Message.Type,
    content: []const u8,
    lobby_id: model.Snowflake,
    channel_id: model.Snowflake,
    author: model.User,
    metadata: jconfig.Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    moderation_metadata: jconfig.Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    flags: model.Message.Flags,
    application_id: model.Snowflake,
};

pub const LobbyInvite = struct {
    code: []const u8,
};

test "example from documentation" {
    const input = @embedFile("./test/lobby.test.json");
    try jconfig.testing.expectParsedSuccessfully(Lobby, std.testing.allocator, input, .{});
}
