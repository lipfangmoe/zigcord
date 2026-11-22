const std = @import("std");

pub fn expectEqualJsonValues(expected: std.json.Value, actual: std.json.Value) !void {
    var arena: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena.deinit();

    var first: StackEntry = .{ .node = .{}, .name = ".", .expected = expected, .actual = actual };
    var stack: std.SinglyLinkedList = .{ .first = &first.node };

    while (stack.popFirst()) |node| {
        const entry: *StackEntry = @fieldParentPtr("node", node);

        expectEqualJsonValuesInner(&stack, arena.allocator(), entry.name, entry.expected, entry.actual, false) catch |err| {
            std.testing.failPrint("above error occurred at path `{s}`", .{entry.name});
            return err;
        };
    }
}

pub fn expectEqualJsonValuesLoose(expected: std.json.Value, actual: std.json.Value) !void {
    var arena: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena.deinit();

    const first: StackEntry = .{ .node = .{}, .name = ".", .expected = expected, .actual = actual };
    var stack: std.SinglyLinkedList = .{ .first = &first.node };

    while (stack.popFirst()) |node| {
        const entry: *StackEntry = @fieldParentPtr("node", node);

        expectEqualJsonValuesInner(&stack, arena.allocator(), entry.name, entry.expected, entry.actual, true) catch |err| {
            std.testing.failPrint("above error occurred at path `{s}`", .{entry.name});
            return err;
        };
    }
}

const StackEntry = struct {
    node: std.SinglyLinkedList.Node,
    name: []const u8,
    expected: std.json.Value,
    actual: std.json.Value,
};

fn expectEqualJsonValuesInner(
    stack: *std.SinglyLinkedList,
    arena: std.mem.Allocator,
    path: []const u8,
    expected: std.json.Value,
    actual: std.json.Value,
    ignore_extra_fields: bool,
) !void {
    switch (expected) {
        .null, .bool, .integer, .float => {
            try std.testing.expectEqual(expected, actual);
        },
        .number_string => |ns| {
            try std.testing.expectEqualStrings("number_string", @tagName(actual));
            try std.testing.expectEqualStrings(ns, actual.number_string);
        },
        .string => |s| {
            try std.testing.expectEqualStrings("string", @tagName(actual));
            try std.testing.expectEqualStrings(s, actual.string);
        },
        .array => |arr| {
            try std.testing.expectEqualStrings("array", @tagName(actual));
            try std.testing.expectEqual(arr.items.len, actual.array.items.len); // test length equality

            var idx: usize = arr.items.len - 1;
            while (idx >= 0) : (idx -= 1) {
                const new_expected = arr.items[idx];
                const new_actual = actual.array.items[idx];
                const new_name = try arena.print("{s}[{d}]", .{ path, idx });
                const new_entry = try arena.create(StackEntry);
                new_entry.* = .{
                    .name = new_name,
                    .node = .{},
                    .expected = new_expected,
                    .actual = new_actual,
                };
                stack.prepend(&new_entry.node);
            }
        },
        .object => |obj| {
            try std.testing.expectEqualStrings("object", @tagName(actual));

            var iter = obj.iterator();
            while (iter.next()) |obj_entry| {
                const field_name = obj_entry.key_ptr.*;
                const new_expected = obj_entry.value_ptr.*;
                const new_actual = actual.object.get(field_name) orelse {
                    std.testing.failPrint("object does not contain field {s}\n", .{field_name});
                    return error.MissingField;
                };
                const new_name = try arena.print("{s}.{s}", .{ path, field_name });
                const new_entry = try arena.create(StackEntry);
                new_entry.* = .{
                    .name = new_name,
                    .node = .{},
                    .expected = new_expected,
                    .actual = new_actual,
                };
                stack.prepend(&new_entry.node);
            }

            if (!ignore_extra_fields) {
                for (actual.object.keys()) |field_name| {
                    if (!obj.contains(field_name)) {
                        std.testing.failPrint("object contains extra field {s}\n", .{field_name});
                        return error.ExtraField;
                    }
                }
            }
        },
    }
}
