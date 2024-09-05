const std = @import("std");
const IsoTime = @This();

year: u64,
month: u4,
day: u5,
hour: u5,
minute: u8,
second: u8,
fractional_second: ?f64 = null,
zone: ?Zone = null,

pub fn jsonStringify(self: IsoTime, jw: anytype) !void {
    try jw.print("\"{}\"", .{self});
}

pub fn jsonParse(alloc: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) std.json.ParseError(@TypeOf(source.*))!IsoTime {
    const str = try std.json.innerParse([]const u8, alloc, source, options);
    return parse(str) catch return error.UnexpectedToken;
}

pub fn jsonParseFromValue(alloc: std.mem.Allocator, source: std.json.Value, options: std.json.ParseOptions) std.json.ParseFromValueError!IsoTime {
    const str = try std.json.innerParseFromValue([]const u8, alloc, source, options);
    return parse(str) catch |err| return switch (err) {
        error.EndOfStream => return error.LengthMismatch,
        error.InvalidFormat => return error.UnexpectedToken,
        else => |other_err| return other_err,
    };
}

pub fn format(self: IsoTime, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
    try writer.print("{d:0>4}-{d:0>2}-{d:0>2}T{d:0>2}:{d:0>2}:{d:0>2}", .{ self.year, self.month, self.day, self.hour, self.minute, self.second });

    if (self.fractional_second) |fractional_second| {
        // we'll just always format with width 6...
        const fractional_second_as_int = std.math.lossyCast(u64, fractional_second * 1_000_000);
        try writer.print(".{d:0>6}", .{fractional_second_as_int});
    }

    if (self.zone) |zone| {
        try writer.print("{}", .{zone});
    }
}

pub fn parse(str: []const u8) !IsoTime {
    var byte_reader = std.io.fixedBufferStream(str);
    const reader = byte_reader.reader();

    const year_str = try reader.readBytesNoEof(4);
    const year = try std.fmt.parseInt(u64, &year_str, 10);
    _ = try reader.readByte(); // '-'

    const month_str = try reader.readBytesNoEof(2);
    const month = try std.fmt.parseInt(u4, &month_str, 10);
    _ = try reader.readByte(); // '-'

    const day_str = try reader.readBytesNoEof(2);
    const day = try std.fmt.parseInt(u5, &day_str, 10);
    _ = try reader.readByte(); // 'T'

    const hour_str = try reader.readBytesNoEof(2);
    const hour = try std.fmt.parseInt(u5, &hour_str, 10);
    _ = try reader.readByte(); // ':'

    const minute_str = try reader.readBytesNoEof(2);
    const minute = try std.fmt.parseInt(u6, &minute_str, 10);
    _ = try reader.readByte(); // ':'

    const second_str = try reader.readBytesNoEof(2);
    const second = try std.fmt.parseInt(u6, &second_str, 10);

    var fractional_second: ?f64 = null;

    var divider = reader.readByte() catch |err| { // '.', '+', '-', or 'Z'
        if (err == error.EndOfStream) {
            return IsoTime{
                .year = year,
                .month = month,
                .day = day,
                .hour = hour,
                .minute = minute,
                .second = second,
            };
        } else {
            return err;
        }
    };
    if (divider == '.') {
        var buf: [10]u8 = .{'.'} ++ .{undefined} ** 9;
        const fractional_second_str = blk: {
            for (1.., buf[1..]) |idx, *byte| {
                const digit = try reader.readByte();
                if (digit == '+' or digit == '-' or digit == 'Z') {
                    divider = digit;
                    break :blk buf[0..idx];
                }
                byte.* = digit;
            } else {
                return error.InvalidFormat;
            }
        };
        fractional_second = try std.fmt.parseFloat(f64, fractional_second_str);
    }
    if (divider == 'Z') {
        return IsoTime{
            .year = year,
            .month = month,
            .day = day,
            .hour = hour,
            .minute = minute,
            .second = second,
            .fractional_second = fractional_second,
            .zone = .gmt,
        };
    }
    if (divider == '+' or divider == '-') {
        const zone_hrs_str = try reader.readBytesNoEof(2);
        const zone_hrs = try std.fmt.parseInt(u8, &zone_hrs_str, 10);
        const sign: Zone.Sign = if (divider == '-') .negative else .positive;

        _ = reader.readByte() catch |err| { // ':'
            if (err == error.EndOfStream) {
                return IsoTime{
                    .year = year,
                    .month = month,
                    .day = day,
                    .hour = hour,
                    .minute = minute,
                    .second = second,
                    .fractional_second = fractional_second,
                    .zone = .{ .hour_offset = .{ .sign = sign, .hour = zone_hrs } },
                };
            } else {
                return err;
            }
        };

        const zone_mins_str = try reader.readBytesNoEof(2);
        const zone_mins = try std.fmt.parseInt(u8, &zone_mins_str, 10);
        return IsoTime{
            .year = year,
            .month = month,
            .day = day,
            .hour = hour,
            .minute = minute,
            .second = second,
            .fractional_second = fractional_second,
            .zone = .{ .hour_and_minute_offset = .{ .sign = sign, .hour = zone_hrs, .minute = zone_mins } },
        };
    }
    return IsoTime{ .year = year, .month = month, .day = day, .hour = hour, .minute = minute, .second = second, .fractional_second = fractional_second };
}

pub const Zone = union(enum) {
    gmt: void,
    hour_offset: struct { sign: Sign, hour: u8 },
    hour_and_minute_offset: struct { sign: Sign, hour: u8, minute: u8 },

    pub const Sign = enum(u1) {
        positive,
        negative,

        pub fn format(self: Sign, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
            switch (self) {
                .positive => try writer.writeByte('+'),
                .negative => try writer.writeByte('-'),
            }
        }
    };

    pub fn format(self: Zone, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        switch (self) {
            .gmt => try writer.writeByte('Z'),
            .hour_offset => |offset| try writer.print("{}{d:0>2}", .{ offset.sign, offset.hour }),
            .hour_and_minute_offset => |offset| try writer.print("{}{d:0>2}:{d:0>2}", .{ offset.sign, offset.hour, offset.minute }),
        }
    }
};

fn testStringifies(actual: IsoTime, comptime expected: []const u8) !void {
    var fmt_buf = std.BoundedArray(u8, 100){};
    var json_buf = std.BoundedArray(u8, 100){};

    try fmt_buf.writer().print("{}", .{actual});
    try std.json.stringify(actual, .{}, json_buf.writer());

    try std.testing.expectEqualStrings(expected, fmt_buf.constSlice());
    try std.testing.expectEqualStrings("\"" ++ expected ++ "\"", json_buf.constSlice());
}

test "isotime stringify gmt" {
    const structure = IsoTime{ .year = 2024, .month = 2, .day = 23, .hour = 4, .minute = 35, .second = 22, .zone = .gmt };
    const str = "2024-02-23T04:35:22Z";
    try testStringifies(structure, str);
}
test "isotime stringify zone=+hour" {
    const structure = IsoTime{ .year = 2024, .month = 2, .day = 23, .hour = 4, .minute = 35, .second = 22, .zone = .{ .hour_offset = .{ .sign = .positive, .hour = 5 } } };
    const str = "2024-02-23T04:35:22+05";
    try testStringifies(structure, str);
}
test "isotime stringify zone=-hour" {
    const structure = IsoTime{ .year = 2024, .month = 2, .day = 23, .hour = 4, .minute = 35, .second = 22, .zone = .{ .hour_offset = .{ .sign = .negative, .hour = 5 } } };
    const str = "2024-02-23T04:35:22-05";
    try testStringifies(structure, str);
}
test "isotime stringify zone=+hour:min" {
    const structure = IsoTime{ .year = 2024, .month = 2, .day = 23, .hour = 4, .minute = 35, .second = 22, .zone = .{ .hour_and_minute_offset = .{ .sign = .positive, .hour = 5, .minute = 6 } } };
    const str = "2024-02-23T04:35:22+05:06";
    try testStringifies(structure, str);
}
test "isotime stringify zone=-hour:min" {
    const structure = IsoTime{ .year = 2024, .month = 2, .day = 23, .hour = 4, .minute = 35, .second = 22, .zone = .{ .hour_and_minute_offset = .{ .sign = .negative, .hour = 5, .minute = 6 } } };
    const str = "2024-02-23T04:35:22-05:06";
    try testStringifies(structure, str);
}
test "isotime stringify frac" {
    const structure = IsoTime{ .year = 2024, .month = 2, .day = 23, .hour = 4, .minute = 35, .second = 22, .fractional_second = 0.02054 };
    const str = "2024-02-23T04:35:22.020540";
    try testStringifies(structure, str);
}
test "isotime stringify frac zone=gmt" {
    const structure = IsoTime{ .year = 2024, .month = 2, .day = 23, .hour = 4, .minute = 35, .second = 22, .fractional_second = 0.02054, .zone = .gmt };
    const str = "2024-02-23T04:35:22.020540Z";
    try testStringifies(structure, str);
}
test "isotime stringify frac zone=+hour:min" {
    const structure = IsoTime{ .year = 2024, .month = 2, .day = 23, .hour = 4, .minute = 35, .second = 22, .fractional_second = 0.02054, .zone = .{ .hour_and_minute_offset = .{ .sign = .positive, .hour = 5, .minute = 6 } } };
    const str = "2024-02-23T04:35:22.020540+05:06";
    try testStringifies(structure, str);
}
