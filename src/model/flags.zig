const std = @import("std");

pub fn PackedFlagsMixin(comptime FlagStruct: type) type {
    if (@typeInfo(FlagStruct) != .Struct or @typeInfo(FlagStruct).Struct.backing_integer == null) {
        @compileError("FlagEnum must be a packed struct");
    }

    const BackingInteger = comptime @typeInfo(FlagStruct).Struct.backing_integer orelse @compileError("already checked");

    return struct {
        const Self = @This();

        pub fn jsonStringify(self: Self, jsonWriter: anytype) !void {
            try jsonWriter.write(self.flags.mask);
        }
        pub fn jsonParse(alloc: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !Self {
            return @bitCast(try std.json.innerParse(BackingInteger, alloc, source, options));
        }
        pub fn jsonParseFromValue(alloc: std.mem.Allocator, source: std.json.Value, options: std.json.ParseOptions) !Self {
            return @bitCast(try std.json.innerParseFromValue(BackingInteger, alloc, source, options));
        }
    };
}

pub fn Flags(comptime FlagEnum: type) type {
    if (@typeInfo(FlagEnum) != .Enum or @typeInfo(FlagEnum).Enum.fields.len == 0) {
        @compileError("FlagEnum must be an enum with at least one entry");
    }
    const type_info = @typeInfo(FlagEnum).Enum;
    const enum_tag_type_info = @typeInfo(type_info.tag_type).Int;
    if (enum_tag_type_info.bits > 6) {
        @compileError("FlagEnum has a maximum tag size of u6, as you cannot bitshift by more than 64 bits. Found " ++ @typeName(type_info.tag_type));
    }
    if (enum_tag_type_info.signedness != .unsigned) {
        @compileError("FlagEnum tag must be unsigned");
    }
    const bitset_size: u16 = std.math.maxInt(type_info.tag_type) + 1;

    return struct {
        const Self = @This();

        flags: std.bit_set.IntegerBitSet(bitset_size),

        pub const Flag = FlagEnum;

        pub fn initEmpty() Self {
            return Self{ .flags = std.bit_set.IntegerBitSet(bitset_size).initEmpty() };
        }

        pub fn addFlag(self: *Self, flag: Flag) void {
            self.flags.set(@intFromEnum(flag));
        }

        pub fn removeFlag(self: *Self, flag: Flag) void {
            self.flags.unset(@intFromEnum(flag));
        }

        pub fn jsonStringify(self: Self, jsonWriter: anytype) !void {
            try jsonWriter.write(self.flags.mask);
        }
    };
}

test "zero indexed flags" {
    const ZeroIndexed = Flags(enum {
        shl_zero,
        shl_one,
        shl_two,
    });
    var zero_indexed = ZeroIndexed.initEmpty();

    const expected_initial_value: u3 = 0;
    try std.testing.expectEqual(expected_initial_value, zero_indexed.flags.mask);

    zero_indexed.addFlag(.shl_zero);
    zero_indexed.addFlag(.shl_two);

    const expected_final_value: u3 = (1 << 0) | (1 << 2);
    try std.testing.expectEqual(expected_final_value, zero_indexed.flags.mask);
}

test "one indexed flags" {
    const OneIndexed = Flags(enum(u6) {
        shl_one = 1,
        shl_two,
        shl_three,
    });

    var one_indexed = OneIndexed.initEmpty();

    const expected_initial_value: u64 = 0;
    try std.testing.expectEqual(expected_initial_value, one_indexed.flags.mask);

    one_indexed.addFlag(.shl_one);
    one_indexed.addFlag(.shl_two);

    const expected_final_value: u64 = (1 << 1) | (1 << 2);
    try std.testing.expectEqual(expected_final_value, one_indexed.flags.mask);
}

test "weird flags" {
    const Weird = Flags(enum(u6) {
        shl_ten = 10,
        shl_fifteen = 15,
        shl_thirty_five = 35,
    });

    var weird = Weird.initEmpty();

    const expected_initial_value: u64 = 0;
    try std.testing.expectEqual(expected_initial_value, weird.flags.mask);

    weird.addFlag(.shl_ten);
    weird.addFlag(.shl_thirty_five);

    const expected_final_value: u64 = (1 << 10) | (1 << 35);
    try std.testing.expectEqual(expected_final_value, weird.flags.mask);
}
