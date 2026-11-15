const std = @import("std");

pub fn expectEqualJsonValues(expected: std.json.Value, actual: std.json.Value) !void {
    try expectEqualJsonValuesRecursive("", expected, actual);
}

fn expectEqualJsonValuesRecursive(path: []const u8, expected: std.json.Value, actual: std.json.Value) !void {
    const gpa = std.testing.allocator;

    switch (exp) {}
}
