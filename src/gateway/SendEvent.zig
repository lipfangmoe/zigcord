const std = @import("std");
const event_data = @import("./event_data.zig");
const deanson = @import("../root.zig").model.deanson;
const SendEvent = @This();

op: event_data.Opcode,
d: event_data.AnySendEvent,
s: ?i64,
t: ?[]const u8,

pub fn identify(data: event_data.send_events.Identify) SendEvent {
    return .{
        .op = .identify,
        .t = null,
        .s = null,
        .d = .{ .Identify = data },
    };
}

pub fn @"resume"(data: event_data.send_events.Resume) SendEvent {
    return .{
        .op = .@"resume",
        .t = null,
        .s = null,
        .d = .{ .Resume = data },
    };
}

pub fn heartbeat(data: event_data.send_events.Heartbeat) SendEvent {
    return .{
        .op = .heartbeat,
        .t = null,
        .s = null,
        .d = .{ .Heartbeat = data },
    };
}

pub fn requestGuildMembers(data: event_data.send_events.RequestGuildMembers) SendEvent {
    return .{
        .op = .heartbeat,
        .t = null,
        .s = null,
        .d = .{ .RequestGuildMembers = data },
    };
}

pub fn updateVoiceState(data: event_data.send_events.UpdateVoiceState) SendEvent {
    return .{
        .op = .voice_state_update,
        .t = null,
        .s = null,
        .d = .{ .UpdateVoiceState = data },
    };
}

pub fn updatePresence(data: event_data.send_events.UpdatePresence) SendEvent {
    return .{
        .op = .presence_update,
        .t = null,
        .s = null,
        .d = .{ .UpdatePresence = data },
    };
}

pub fn jsonStringify(self: SendEvent, jw: anytype) !void {
    try jw.beginObject();

    inline for (std.meta.fields(SendEvent)) |field| {
        const field_value = @field(self, field.name);
        if (comptime std.mem.eql(u8, field.name, "d")) {
            try jw.objectField(field.name);
            try deanson.stringifyUnionInline(field_value, jw);
        } else {
            try jw.objectField(field.name);
            try jw.write(field_value);
        }
    }

    try jw.endObject();
}
