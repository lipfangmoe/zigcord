const std = @import("std");
const Omittable = @import("./omit.zig").Omittable;

pub fn expectParsedSuccessfully(comptime T: type, allocator: std.mem.Allocator, input: []const u8, options: std.json.ParseOptions) !void {
    var reader: std.Io.Reader = .fixed(input);
    var json_reader: std.json.Reader = .init(allocator, &reader);
    defer json_reader.deinit();

    var diag: std.json.Diagnostics = .{};
    json_reader.enableDiagnostics(&diag);

    const parsed = std.json.parseFromTokenSource(T, allocator, &json_reader, options) catch |err| {
        std.debug.print("error while parsing json: {} (at {d}:{d})\n", .{ err, diag.getLine(), diag.getColumn() });
        std.debug.print("surrounding json at parse error:\n", .{});

        const surroundings = 30;
        const start = if (diag.getByteOffset() > surroundings) diag.getByteOffset() - surroundings else 0;
        const end = if (diag.getByteOffset() < input.len - surroundings) diag.getByteOffset() + surroundings else input.len;

        for (start..end) |each| {
            const c = input[each];
            if (c == '\n') {
                std.debug.print("␊", .{});
            } else {
                std.debug.print("{c}", .{c});
            }
        }
        std.debug.print("\n", .{});
        const padding = @min(start, surroundings);
        for (0..padding) |_| {
            std.debug.print(" ", .{});
        }
        std.debug.print("^\n", .{});

        return err;
    };
    defer parsed.deinit();
}

pub fn expectIsPartialOf(comptime PartialT: type, comptime BaseT: type) !void {
    const partial_info = @typeInfo(PartialT).@"struct";
    const base_info = @typeInfo(BaseT).@"struct";

    if (partial_info.field_names.len != base_info.field_names.len) {
        printWhyUnequalLen(PartialT, BaseT);
        return error.UnmatchingFields;
    }

    for (
        partial_info.field_names,
        partial_info.field_types,
        base_info.field_names,
        base_info.field_types,
    ) |partial_field_name, PartialFieldType, base_field_name, BaseFieldType| {
        if (!std.mem.eql(u8, partial_field_name, base_field_name)) {
            std.debug.print("Type {s} is not a partial type of {s}\n", .{ @typeName(PartialT), @typeName(BaseT) });
            std.debug.print("  Fields do not match:\n    {s}: {s}\n    {s}: {s}", .{ @typeName(PartialT), partial_field_name, @typeName(BaseT), base_field_name });

            return error.UnmatchingField;
        }

        if (PartialFieldType != BaseFieldType and PartialFieldType != ?BaseFieldType and PartialFieldType != Omittable(BaseFieldType)) {
            std.debug.print("Type {s} is not a partial type of {s}\n", .{ @typeName(PartialT), @typeName(BaseT) });
            std.debug.print("  Field Types for field `{s}` do not match:\n    {s}: {s}\n    {s}: {s}", .{ base_field_name, @typeName(PartialT), @typeName(PartialFieldType), @typeName(BaseT), @typeName(BaseFieldType) });

            return error.UnmatchingFieldType;
        }
    }
}

fn printWhyUnequalLen(comptime PartialT: type, comptime BaseT: type) void {
    const partial_info = @typeInfo(PartialT).@"struct";
    const base_info = @typeInfo(BaseT).@"struct";

    const partial_field_name_set: std.StaticStringMap(void) = .initComptime(partial_info.field_names);
    const base_field_name_set: std.StaticStringMap(void) = .initComptime(base_info.field_names);

    if (partial_field_name_set.kvs.len > base_field_name_set.kvs.len) {
        std.debug.print("Type {s} is not a partial type of {s}\n", .{ @typeName(PartialT), @typeName(BaseT) });
        std.debug.print("  Partial Type {s} contains the following extra fields: ", .{@typeName(PartialT)});
        var first = true;
        for (partial_field_name_set.keys()) |field_name| {
            if (!base_field_name_set.has(field_name)) {
                if (!first) {
                    std.debug.print(", ", .{});
                }
                std.debug.print("{s}", .{field_name});
                first = false;
            }
        }
        std.debug.print("\n", .{});
    }
    if (base_field_name_set.kvs.len > partial_field_name_set.kvs.len) {
        std.debug.print("Type {s} is not a partial type of {s}\n", .{ @typeName(PartialT), @typeName(BaseT) });
        std.debug.print("  Partial Type {s} is missing the following fields: ", .{@typeName(PartialT)});
        var first = true;
        for (base_field_name_set.keys()) |field_name| {
            if (!partial_field_name_set.has(field_name)) {
                if (!first) {
                    std.debug.print(", ", .{});
                }
                std.debug.print("{s}", .{field_name});
                first = false;
            }
        }
        std.debug.print("\n", .{});
        return error.UnmatchingFieldNames;
    }
}
