const std = @import("std");
const event_data = @import("./event_data.zig");
const jconfig = @import("../root.zig").jconfig;
const SendEvent = @This();

op: event_data.Opcode,
d: event_data.SendEventData,
s: ?i64,
t: ?[]const u8,

pub fn identify(data: event_data.send_events.Identify) SendEvent {
    return .{
        .op = .identify,
        .t = null,
        .s = null,
        .d = .{ .identify = data },
    };
}

pub fn @"resume"(data: event_data.send_events.Resume) SendEvent {
    return .{
        .op = .@"resume",
        .t = null,
        .s = null,
        .d = .{ .@"resume" = data },
    };
}

pub fn heartbeat(data: event_data.send_events.Heartbeat) SendEvent {
    return .{
        .op = .heartbeat,
        .t = null,
        .s = null,
        .d = .{ .heartbeat = data },
    };
}

pub fn requestGuildMembers(data: event_data.send_events.RequestGuildMembers) SendEvent {
    return .{
        .op = .request_guild_members,
        .t = null,
        .s = null,
        .d = .{ .request_guild_members = data },
    };
}

pub fn updateVoiceState(data: event_data.send_events.UpdateVoiceState) SendEvent {
    return .{
        .op = .voice_state_update,
        .t = null,
        .s = null,
        .d = .{ .update_voice_state = data },
    };
}

pub fn updatePresence(data: event_data.send_events.UpdatePresence) SendEvent {
    return .{
        .op = .presence_update,
        .t = null,
        .s = null,
        .d = .{ .update_presence = data },
    };
}

pub fn jsonStringify(self: SendEvent, jw: *std.json.Stringify) !void {
    try jw.beginObject();

    inline for (std.meta.fields(SendEvent)) |field| {
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
