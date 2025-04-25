const std = @import("std");

pub const Client = @import("./gateway/Client.zig");
pub const JsonWSClient = @import("./gateway/JsonWSClient.zig");
pub const SendEvent = @import("./gateway/SendEvent.zig");
pub const ReceiveEvent = @import("./gateway/ReceiveEvent.zig");
pub const event_data = @import("./gateway/event_data.zig");

pub const ReadEventData = event_data.AnyReceiveEvent;
