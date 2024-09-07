const std = @import("std");
const jconfig = @import("../root.zig").jconfig;

type: Type,
key: []const u8,
name: []const u8,
name_localizations: jconfig.Omittable(std.json.ArrayHashMap([]const u8)) = .omit,
description: []const u8,
description_localizations: jconfig.Omittable(std.json.ArrayHashMap([]const u8)) = .omit,

pub const jsonStringify = jconfig.stringifyWithOmit;

const Type = enum(u8) {
    integer_less_than_or_equal = 1,
    integer_greater_than_or_equal,
    integer_equal,
    integer_not_equal,
    datetime_less_than_or_equal,
    datetime_greater_than_or_equal,
    boolean_equal,
    boolean_not_equal,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};
