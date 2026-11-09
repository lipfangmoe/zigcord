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

    var partial_field_name_set: std.StringHashMapUnmanaged(void) = .empty;
    defer partial_field_name_set.deinit(std.testing.allocator);
    for (partial_info.field_names) |name| try partial_field_name_set.put(std.testing.allocator, name, {});
    var base_field_name_set: std.StringHashMapUnmanaged(void) = .empty;
    defer base_field_name_set.deinit(std.testing.allocator);
    for (base_info.field_names) |name| try base_field_name_set.put(std.testing.allocator, name, {});

    var partial_extra_fields: std.ArrayList([]const u8) = .empty;
    defer partial_extra_fields.deinit(std.testing.allocator);
    var base_extra_fields: std.ArrayList([]const u8) = .empty;
    defer base_extra_fields.deinit(std.testing.allocator);
    try getDifferenceOf(partial_field_name_set, base_field_name_set, &partial_extra_fields);
    try getDifferenceOf(base_field_name_set, partial_field_name_set, &base_extra_fields);

    if (partial_extra_fields.items.len > 0 or base_extra_fields.items.len > 0) {
        std.debug.print("Type {s} is not a partial type of {s}\n", .{ @typeName(PartialT), @typeName(BaseT) });
    }
    if (partial_extra_fields.items.len > 0) {
        std.debug.print("  Partial Type {s} contains the following extra fields: ", .{@typeName(PartialT)});
        for (0.., partial_extra_fields.items) |idx, field_name| {
            if (idx > 0) {
                std.debug.print(", ", .{});
            }
            std.debug.print("{s}", .{field_name});
        }
        return error.UnmatchingFieldNames;
    }
    if (base_extra_fields.items.len > 0) {
        std.debug.print("  Partial Type {s} is missing the following fields: ", .{@typeName(PartialT)});
        for (0.., base_extra_fields.items) |idx, field_name| {
            if (idx > 0) {
                std.debug.print(", ", .{});
            }
            std.debug.print("{s}", .{field_name});
        }
        return error.UnmatchingFieldNames;
    }

    inline for (
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

pub fn expectIsPartialOfLoose(comptime PartialT: type, comptime BaseT: type) !void {
    const partial_info = @typeInfo(PartialT).@"struct";
    const base_info = @typeInfo(BaseT).@"struct";

    const partial_field_name_set: std.StringHashMapUnmanaged(void) = .empty;
    defer partial_field_name_set.deinit(std.testing.allocator);
    for (partial_info.field_names) |name| try partial_field_name_set.put(std.testing.allocator, name, {});
    const base_field_name_set: std.StringHashMapUnmanaged(void) = .empty;
    defer base_field_name_set.deinit(std.testing.allocator);
    for (base_info.field_names) |name| try base_field_name_set.put(std.testing.allocator, name, {});

    var partial_extra_fields: std.ArrayList([]const u8) = .empty;
    defer partial_extra_fields.deinit(std.testing.allocator);
    try getDifferenceOf(partial_field_name_set, base_field_name_set, &partial_extra_fields);

    if (partial_extra_fields.items.len > 0) {
        std.debug.print("Type {s} is not a partial type of {s}\n", .{ @typeName(PartialT), @typeName(BaseT) });
        std.debug.print("  Partial Type {s} contains the following extra fields: {s}", .{ @typeName(PartialT), partial_extra_fields.items });
        return error.UnmatchingFieldNames;
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

fn getDifferenceOf(lhs: std.StringHashMapUnmanaged(void), rhs: std.StringHashMapUnmanaged(void), difference: *std.ArrayList([]const u8)) !void {
    var iter = lhs.keyIterator();
    while (iter.next()) |field_name| {
        if (!rhs.contains(field_name.*)) {
            try difference.append(std.testing.allocator, field_name.*);
        }
    }
}
