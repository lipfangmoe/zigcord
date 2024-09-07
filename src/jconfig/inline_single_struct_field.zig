const std = @import("std");

const writePossiblyOmittableFieldToStream = @import("./omit.zig").writePossiblyOmittableFieldToStream;

/// For `struct{ field1: struct{ foo: i64 }, field2: struct{ bar: u64 }, pub usingnamespace InlineFieldJsonMixin(@This(), "field1"); }`,
/// returns a mixin which will JSON stringify and parse the struct into a `struct{ foo: i64, field2: struct{ bar: u64 }}`
pub fn InlineSingleStructFieldMixin(comptime T: type, comptime inline_field: []const u8) type {
    return struct {
        pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !T {
            // way too lazy to give this a more efficient implementation. maybe in the future.
            const json_value = try std.json.innerParse(std.json.Value, allocator, source, options);
            return jsonParseFromValue(allocator, json_value, options);
        }

        pub fn jsonParseFromValue(allocator: std.mem.Allocator, source: std.json.Value, options: std.json.ParseOptions) !T {
            const object = switch (source) {
                .object => |obj| obj,
                else => return error.UnexpectedToken,
            };

            // allow unknown fields
            var inner_options = options;
            inner_options.ignore_unknown_fields = true;

            var t: T = undefined;
            inline for (std.meta.fields(T)) |field| {
                @field(t, field.name) = blk: {
                    if (std.mem.eql(u8, field.name, inline_field)) {
                        const field_value = try std.json.innerParseFromValue(field.type, allocator, source, inner_options);
                        break :blk field_value;
                    } else {
                        if (object.get(field.name)) |value| {
                            const field_value = try std.json.innerParseFromValue(field.type, allocator, value, options);
                            break :blk field_value;
                        } else {
                            if (field.default_value) |default_value| {
                                break :blk @as(*const field.type, @alignCast(@ptrCast(default_value))).*;
                            } else {
                                return error.MissingField;
                            }
                        }
                    }
                };
            }

            return t;
        }

        pub fn jsonStringify(self: T, jw: anytype) !void {
            try jw.beginObject();
            inline for (std.meta.fields(T)) |outer_field| {
                const outer_field_value = @field(self, outer_field.name);
                if (std.mem.eql(u8, outer_field.name, inline_field)) {
                    if (std.meta.hasMethod(outer_field.type, "jsonStringify")) {
                        const jw_inline_obj = inlineFieldsJsonWriteStream(jw);
                        try outer_field_value.jsonStringify(jw_inline_obj);
                        continue;
                    }
                    inline for (std.meta.fields(outer_field.type)) |inner_field| {
                        const inner_field_value = @field(outer_field_value, inner_field.name);
                        try writePossiblyOmittableFieldToStream(inner_field, inner_field_value, jw);
                    }
                } else {
                    try writePossiblyOmittableFieldToStream(outer_field, outer_field_value, jw);
                }
            }
            try jw.endObject();
        }
    };
}

// not public because this should work for my specific use-case, but may be incorrect on other use-cases
fn inlineFieldsJsonWriteStream(jw: anytype) InlineFieldsJsonWriteStream(@TypeOf(jw)) {
    return .{ .underlying_write_stream = jw };
}
fn InlineFieldsJsonWriteStream(UnderlyingWriteStream: type) type {
    return struct {
        underlying_write_stream: UnderlyingWriteStream,
        nesting_level: u64 = 0,

        const Self = @This();

        // changed methods
        pub fn beginObject(self: *Self) !void {
            if (self.nesting_level > 0) {
                try self.underlying_write_stream.beginObject();
            }
            self.nesting_level += 1;
        }
        pub fn endObject(self: *Self) !void {
            if (self.nesting_level > 1) {
                try self.underlying_write_stream.endObject();
            }
            self.nesting_level -= 1;
        }
        pub fn beginArray(self: *Self) !void {
            if (self.nesting_level > 0) {
                try self.underlying_write_stream.beginArray();
            }
            self.nesting_level += 1;
        }
        pub fn endArray(self: *Self) !void {
            if (self.nesting_level > 1) {
                try self.underlying_write_stream.endArray();
            }
            self.nesting_level -= 1;
        }

        // unchanged methods
        pub fn print(self: *Self, comptime fmt: []const u8, args: anytype) !void {
            return self.underlying_write_stream.print(fmt, args);
        }
        pub fn write(self: *Self, value: anytype) !void {
            return self.underlying_write_stream.write(value);
        }
        pub fn objectField(self: *Self, name: []const u8) !void {
            return self.underlying_write_stream.objectField(name);
        }
        pub fn objectFieldRaw(self: *Self, name: []const u8) !void {
            return self.underlying_write_stream.objectFieldRaw(name);
        }
        pub fn deinit(self: *Self) void {
            self.underlying_write_stream.deinit();
        }
    };
}

test "InlineFieldJsonMixin - stringify" {
    const TestStruct = struct {
        field1: struct { foo: i64 },
        field2: struct { bar: u64 },

        pub usingnamespace InlineSingleStructFieldMixin(@This(), "field1");
    };

    const t = TestStruct{ .field1 = .{ .foo = 5 }, .field2 = .{ .bar = 100 } };
    var out = std.BoundedArray(u8, 100){};

    try std.json.stringify(t, .{}, out.writer());

    try std.testing.expectEqualStrings(
        \\{"foo":5,"field2":{"bar":100}}
    , out.constSlice());
}

test "InlineFieldJsonMixin - parse" {
    const TestStruct = struct {
        field1: struct { foo: i64 },
        field2: struct { bar: u64 },

        pub usingnamespace InlineSingleStructFieldMixin(@This(), "field1");
    };

    const str =
        \\{"foo":5,"field2":{"bar":100}}
    ;
    const actual = try std.json.parseFromSlice(TestStruct, std.testing.allocator, str, .{});
    defer actual.deinit();

    const expected = TestStruct{ .field1 = .{ .foo = 5 }, .field2 = .{ .bar = 100 } };
    try std.testing.expectEqual(expected, actual.value);
}
