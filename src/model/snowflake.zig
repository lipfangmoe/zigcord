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

    pub fn format(self: Snowflake, writer: *std.Io.Writer) !void {
        try writer.print("{d}", .{self.asU64()});
    }

    pub fn formatNumber(self: Snowflake, writer: *std.Io.Writer, options: std.fmt.Number) !void {
        try writer.printInt(
            self.asU64(),
            options.mode.base() orelse 10,
            options.case,
            .{
                .alignment = options.alignment,
                .precision = options.precision,
                .width = options.width,
                .fill = options.fill,
            },
        );
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

    pub fn jsonStringify(self: Snowflake, jw: anytype) !void {
        try jw.print("{d}", .{self.asU64()});
    }
};

test "parse" {
    const snowflake_str = "\"1234567890\"";
    const snowflake = try std.json.parseFromSlice(Snowflake, std.testing.allocator, snowflake_str, .{});
    defer snowflake.deinit();

    try std.testing.expectEqual(Snowflake.fromU64(1234567890), snowflake.value);
}
