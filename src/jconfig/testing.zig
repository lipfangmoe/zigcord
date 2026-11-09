const std = @import("std");

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
        std.debug.print("Type {s} is not a partial type of {s}\n", .{ @typeName(PartialT), @typeName(BaseT) });
        std.debug.print("  Unequal number of fields:\n    {s}: {d}\n    {s}: {d}", .{ @typeName(PartialT), partial_info.field_names.len, @typeName(BaseT), base_info.field_names.len });
        return error.
    }

    for (partial_info.field_names, partial_info.field_types, partial_info.field_attrs) |partial_field_name, PartialFieldType, partial_field_attrs| {}
}
