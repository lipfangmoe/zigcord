const std = @import("std");
const zigcord = @import("../root.zig");

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
                            if (field.default_value_ptr) |default_value| {
                                break :blk @as(*const field.type, @ptrCast(@alignCast(default_value))).*;
                            } else {
                                zigcord.logger.err("Missing field for type '{s}': '{s}'", .{ @typeName(T), field.name });
                                return error.MissingField;
                            }
                        }
                    }
                };
            }

            return t;
        }

        pub fn jsonStringify(self: T, jw: *std.json.Stringify) !void {
            try jw.beginObject();
            inline for (std.meta.fields(T)) |outer_field| {
                const outer_field_value = @field(self, outer_field.name);
                if (comptime std.mem.eql(u8, outer_field.name, inline_field)) {
                    if (comptime std.meta.hasMethod(outer_field.type, "jsonStringify")) {
                        var buf: [100]u8 = undefined;
                        var substring_writer: SubstringWriter = .init(jw.writer, &buf);
                        try std.json.Stringify.value(outer_field_value, jw.options, &substring_writer.interface);
                        try substring_writer.interface.flush();
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

// trims the first and last characters of whatever is written to it
const SubstringWriter = struct {
    underlying_writer: *std.Io.Writer,
    start_trimmed: bool,
    interface: std.Io.Writer,

    pub fn init(underlying_writer: *std.Io.Writer, buf: []u8) SubstringWriter {
        std.debug.assert(buf.len > 0);

        return SubstringWriter{
            .underlying_writer = underlying_writer,
            .start_trimmed = false,
            .interface = std.Io.Writer{
                .buffer = buf,
                .vtable = &std.Io.Writer.VTable{
                    .drain = drain,
                    .flush = flush,
                },
            },
        };
    }

    pub fn drain(w: *std.Io.Writer, data: []const []const u8, splat: usize) std.Io.Writer.Error!usize {
        var self: *SubstringWriter = @alignCast(@fieldParentPtr("interface", w));

        if (!self.start_trimmed and self.interface.buffered().len > 0) {
            _ = self.interface.consume(1);
            self.start_trimmed = true;
            return 0;
        }

        const full_length = self.interface.buffered().len + std.Io.Writer.countSplat(data, splat);
        if (full_length <= 1) {
            return 0;
        }

        const limit: std.Io.Limit = .limited(full_length - 1);
        const n = try self.underlying_writer.writeSplatHeaderLimit(self.interface.buffered(), data, splat, limit);
        return self.interface.consume(n);
    }

    pub fn flush(w: *std.Io.Writer) std.Io.Writer.Error!void {
        var self: *SubstringWriter = @alignCast(@fieldParentPtr("interface", w));

        if (!self.start_trimmed and self.interface.buffered().len > 0) {
            _ = self.interface.consume(1);
            self.start_trimmed = true;
            return;
        }

        if (self.interface.buffered().len <= 1) {
            return;
        }

        const limit: std.Io.Limit = .limited(self.interface.buffered().len - 1);
        const writable = limit.slice(self.interface.buffered());

        try self.underlying_writer.writeAll(writable);
        _ = self.interface.consume(writable.len);
    }
};

test "InlineFieldJsonMixin - stringify" {
    const TestStruct = struct {
        field1: struct { foo: i64 },
        field2: struct { bar: u64 },

        const Mixin = InlineSingleStructFieldMixin(@This(), "field1");
        pub const jsonStringify = Mixin.jsonStringify;
        pub const jsonParse = Mixin.jsonParse;
        pub const jsonParseFromValue = Mixin.jsonParseFromValue;
    };

    const t = TestStruct{ .field1 = .{ .foo = 5 }, .field2 = .{ .bar = 100 } };
    var output = std.Io.Writer.Allocating.init(std.testing.allocator);
    defer output.deinit();

    try std.json.Stringify.value(t, .{}, &output.writer);

    try std.testing.expectEqualStrings(
        \\{"foo":5,"field2":{"bar":100}}
    , output.written());
}

test "InlineFieldJsonMixin - parse" {
    const TestStruct = struct {
        field1: struct { foo: i64 },
        field2: struct { bar: u64 },

        const Mixin = InlineSingleStructFieldMixin(@This(), "field1");
        pub const jsonStringify = Mixin.jsonStringify;
        pub const jsonParse = Mixin.jsonParse;
        pub const jsonParseFromValue = Mixin.jsonParseFromValue;
    };

    const str =
        \\{"foo":5,"field2":{"bar":100}}
    ;
    const actual = try std.json.parseFromSlice(TestStruct, std.testing.allocator, str, .{});
    defer actual.deinit();

    const expected = TestStruct{ .field1 = .{ .foo = 5 }, .field2 = .{ .bar = 100 } };
    try std.testing.expectEqual(expected, actual.value);
}
