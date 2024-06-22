const model = @import("../model.zig");
const Snowflake = model.Snowflake;
const Omittable = model.deanson.Omittable;

id: ?Snowflake,
name: ?[]const u8,
roles: Omittable([]Snowflake) = .{ .omitted = void{} },
user: Omittable(Snowflake) = .{ .omitted = void{} },
require_colons: Omittable(bool) = .{ .omitted = void{} },
managed: Omittable(bool) = .{ .omitted = void{} },
animated: Omittable(bool) = .{ .omitted = void{} },
available: Omittable(bool) = .{ .omitted = void{} },

pub const jsonStringify = model.deanson.stringifyWithOmit;
