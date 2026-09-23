const std = @import("std");

pub const version = @import("build").version;
pub const logger = std.log.scoped(.zigcord);
