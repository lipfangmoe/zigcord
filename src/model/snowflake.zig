const std = @import("std");

/// https://discord.com/developers/docs/reference#snowflakes
pub const Snowflake = packed struct {
    timestamp: u42,
    worker: u5,
    process_id: u5,
    increment_id: u12,

    pub fn timestampWithOffset(self: Snowflake) i64 {
        return self.timestamp + 1420070400000;
    }

    /// a u64 bitcast to a snowflake
    pub fn fromU64(num: u64) Snowflake {
        return @bitCast(num);
    }

    /// this snowflake bitcast as a u64
    pub fn asU64(self: Snowflake) u64 {
        return @bitCast(self);
    }

    pub fn format(self: Snowflake, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try std.fmt.format(writer, "{d}", .{self.asU64()});
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !Snowflake {
        switch (try source.nextAllocMax(allocator, options.allocate orelse .alloc_if_needed, 100)) {
            .string,
            .allocated_string,
            .number,
            .allocated_number,
            => |str| {
                const int = std.fmt.parseInt(u64, str, 10) catch {
                    return error.UnexpectedToken;
                };
                return Snowflake.fromU64(int);
            },
            else => return error.UnexpectedToken,
        }
    }

    pub fn jsonParseFromValue(_: std.mem.Allocator, source: std.json.Value, _: std.json.ParseOptions) !Snowflake {
        switch (source) {
            .integer => |int| {
                return Snowflake.fromU64(std.math.cast(u64, int) orelse return error.UnexpectedToken);
            },
            .number_string, .string => |str| {
                const int = std.fmt.parseInt(u64, str, 10) catch {
                    return error.UnexpectedToken;
                };
                return Snowflake.fromU64(int);
            },
            else => return error.UnexpectedToken,
        }
    }

    pub fn jsonStringify(self: *const Snowflake, jw: anytype) !void {
        var buf: [100]u8 = undefined;
        const n = std.fmt.formatIntBuf(&buf, self.asU64(), 10, .lower, .{});
        try jw.write(buf[0..n]);
    }
};

test "parse" {
    const snowflake_str = "\"1234567890\"";
    const snowflake = try std.json.parseFromSlice(Snowflake, std.testing.allocator, snowflake_str, .{});
    defer snowflake.deinit();

    try std.testing.expectEqual(Snowflake.fromU64(1234567890), snowflake.value);
}
