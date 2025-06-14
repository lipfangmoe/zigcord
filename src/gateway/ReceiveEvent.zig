const std = @import("std");
const event_data = @import("./event_data.zig");
const jconfig = @import("../root.zig").jconfig;
const ReceiveEvent = @This();

op: event_data.Opcode,
d: event_data.AnyReceiveEvent,
s: ?i64,
t: ?[]const u8,

pub fn jsonParse(alloc: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !ReceiveEvent {
    return try jsonParseFromValue(
        alloc,
        try std.json.innerParse(std.json.Value, alloc, source, options),
        options,
    );
}

pub fn jsonParseFromValue(alloc: std.mem.Allocator, source: std.json.Value, options: std.json.ParseOptions) std.json.ParseFromValueError!ReceiveEvent {
    const root = switch (source) {
        .object => |obj| obj,
        else => return std.json.ParseFromValueError.UnexpectedToken,
    };

    const op: event_data.Opcode = if (root.get("op")) |op_value| blk: {
        const op_int = switch (op_value) {
            .integer => |op| op,
            else => return std.json.ParseFromValueError.UnexpectedToken,
        };
        break :blk @enumFromInt(op_int);
    } else return std.json.ParseFromValueError.MissingField;

    const t: ?[]const u8 = if (root.get("t")) |t_value| blk: {
        break :blk switch (t_value) {
            .string => |str| str,
            .null => null,
            else => return std.json.ParseFromValueError.UnexpectedToken,
        };
    } else null;

    const s: ?i64 = if (root.get("s")) |s_value| blk: {
        break :blk switch (s_value) {
            .integer => |int| int,
            .number_string => |str| try std.fmt.parseInt(i64, str, 10),
            .null => null,
            else => return std.json.ParseFromValueError.UnexpectedToken,
        };
    } else null;

    const d_as_null: std.json.Value = root.get("d") orelse std.json.Value.null;

    const d: event_data.AnyReceiveEvent = switch (op) {
        .dispatch => try getDataFromTag(alloc, d_as_null, t, options),
        .reconnect => event_data.AnyReceiveEvent{ .Reconnect = null },
        .invalid_session => .{ .InvalidSession = try std.json.innerParseFromValue(event_data.receive_events.InvalidSession, alloc, d_as_null, options) },
        .hello => .{ .Hello = try std.json.innerParseFromValue(event_data.receive_events.Hello, alloc, d_as_null, options) },
        .heartbeat_ack => event_data.AnyReceiveEvent{ .HeartbeatACK = null },
        else => return std.json.ParseFromValueError.UnexpectedToken,
    };

    return ReceiveEvent{
        .op = op,
        .d = d,
        .s = s,
        .t = t,
    };
}

pub fn jsonStringify(self: ReceiveEvent, jw: anytype) !void {
    try jw.beginObject();

    inline for (std.meta.fields(ReceiveEvent)) |field| {
        const field_value = @field(self, field.name);
        if (comptime std.mem.eql(u8, field.name, "d")) {
            try jw.objectField(field.name);
            try jconfig.stringifyUnionInline(field_value, jw);
        } else {
            try jw.objectField(field.name);
            try jw.write(field_value);
        }
    }

    try jw.endObject();
}

fn getDataFromTag(alloc: std.mem.Allocator, d: std.json.Value, t: ?[]const u8, options: std.json.ParseOptions) std.json.ParseFromValueError!event_data.AnyReceiveEvent {
    const enum_tag_str = try snakeToTitleCase(t orelse "UNDOCUMENTED");

    const enum_tag = std.meta.stringToEnum(@typeInfo(event_data.AnyReceiveEvent).@"union".tag_type orelse unreachable, enum_tag_str.constSlice()) orelse .Undocumented;
    switch (enum_tag) {
        inline else => |tag| {
            const typ = @field(event_data.receive_events, @tagName(tag));
            return @unionInit(event_data.AnyReceiveEvent, @tagName(tag), try std.json.innerParseFromValue(typ, alloc, d, options));
        },
    }
}

fn snakeToTitleCase(source: []const u8) !std.BoundedArray(u8, 100) {
    var output = std.BoundedArray(u8, 100){};

    var next_char_upper = true;
    for (source) |char| {
        if (char == '_') {
            next_char_upper = true;
            continue;
        }

        if (next_char_upper) {
            try output.append(char);
            next_char_upper = false;
        } else {
            try output.append(std.ascii.toLower(char));
        }
    }

    return output;
}

test "resumed event" {
    const input =
        \\{"t":"RESUMED","s":78,"op":0,"d":{"_trace":["snip"]}}
    ;

    const parsed = try std.json.parseFromSlice(ReceiveEvent, std.testing.allocator, input, .{ .ignore_unknown_fields = true });
    parsed.deinit();
}

test "reconnect event" {
    const input =
        \\{"t":null,"s":null,"op":7,"d":null}
    ;

    const parsed = try std.json.parseFromSlice(ReceiveEvent, std.testing.allocator, input, .{ .ignore_unknown_fields = true });
    parsed.deinit();
}

test "undocumented event" {
    const input =
        \\{"t":"SOME_KIND_OF_UNDOCUMENTED_EVENT","s":119,"op":0,"d":{"user_id":"0","pause_ends_at":null,"id":"0","guild_id":"0","ended":false}}
    ;
    const parsed = try std.json.parseFromSlice(ReceiveEvent, std.testing.allocator, input, .{ .ignore_unknown_fields = true });
    const user_id = parsed.value.d.Undocumented.object.get("user_id") orelse unreachable;
    try std.testing.expectEqualStrings("0", user_id.string);
    parsed.deinit();
}

test "update message" {
    const input =
        \\{"t":"MESSAGE_UPDATE","s":207,"op":0,"d":{"webhook_id":"0","type":0,"tts":false,"timestamp":"2025-01-01T00:00:00.000000+00:00","position":0,"pinned":false,"mentions":[],"mention_roles":[],"mention_everyone":false,"member":{"roles":["0","2"],"premium_since":null,"pending":false,"nick":null,"mute":false,"joined_at":"2025-01-01T00:00:00.000000+00:00","flags":0,"deaf":false,"communication_disabled_until":null,"banner":null,"avatar":null},"interaction_metadata":{"user":{"username":"redacted","public_flags":0,"primary_guild":null,"id":"0","global_name":"redacted","discriminator":"0","collectibles":{"nameplate":{"sku_id":"0","palette":"bubble_gum","label":"COLLECTIBLES_NAMEPLATES_ANGELS_A11Y","expires_at":null,"asset":"nameplates/nameplates/angels/"}},"clan":null,"avatar_decoration_data":{"sku_id":"0","expires_at":null,"asset":"something"},"avatar":"avatar"},"type":2,"name":"favs","id":"0","command_type":1,"authorizing_integration_owners":{"0":"0"}},"interaction":{"user":{"username":"redacted","public_flags":0,"primary_guild":null,"id":"0","global_name":"redacted","discriminator":"0","collectibles":{"nameplate":{"sku_id":"0","palette":"bubble_gum","label":"COLLECTIBLES_NAMEPLATES_ANGELS_A11Y","expires_at":null,"asset":"nameplates/nameplates/angels/"}},"clan":null,"avatar_decoration_data":{"sku_id":"0","expires_at":null,"asset":"asset"},"avatar":"avatar"},"type":2,"name":"favs","member":{"roles":["0","1"],"premium_since":"2025-01-01T00:00:00.000000+00:00","pending":false,"nick":"redacted","mute":false,"joined_at":"2025-01-01T00:00:00.000000+00:00","flags":0,"deaf":false,"communication_disabled_until":null,"banner":"banner","avatar":"avatar"},"id":"0"},"id":"0","flags":0,"embeds":[{"type":"rich","thumbnail":{"width":625,"url":"https://example.com/","proxy_url":"https://example.com/","placeholder_version":1,"placeholder":"placeholder","height":0,"flags":0,"content_type":"image/jpeg"},"footer":{"text":"footer","proxy_icon_url":"https://example.com/","icon_url":"https://example.com/"},"description":"description","author":{"url":"https://example.com/","proxy_icon_url":"https://example.com/","name":"name","icon_url":"https://example.com/"}}],"edited_timestamp":"2025-01-01T00:00:00.000000+00:00","content":"","components":[{"type":1,"id":1,"components":[{"type":2,"style":1,"id":2,"emoji":{"name":"➡"},"custom_id":"➡"}]}],"channel_type":0,"channel_id":"0","author":{"username":"username","public_flags":0,"primary_guild":null,"id":"0","global_name":null,"discriminator":"0","collectibles":null,"clan":null,"bot":true,"avatar_decoration_data":null,"avatar":"avatar"},"attachments":[],"application_id":"0","guild_id":"0"}}
    ;

    const parsed = try std.json.parseFromSlice(ReceiveEvent, std.testing.allocator, input, .{ .ignore_unknown_fields = true });
    parsed.deinit();
}
