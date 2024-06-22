const model = @import("../../model.zig");
const Omittable = model.deanson.Omittable;

id: model.Snowflake,
unavailable: Omittable(bool) = .{ .omitted = void{} },

pub const jsonStringify = model.deanson.stringifyWithOmit;
