const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const websocket_dependency = b.dependency("websocket", .{});
    const websocket_module = websocket_dependency.module("websocket");

    const lib = b.addStaticLibrary(.{
        .name = "deancord",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib.root_module.addImport("websocket", websocket_module);

    _ = b.addModule("deancord", .{
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "websocket", .module = websocket_module },
        },
    });

    const test_step = b.step("test", "Run unit tests");

    // `test_step` runs tests on all .zig files under `src`.
    // making dependency trees with test blocks is too easy to mess up,
    // and `std.testing.refAllDeclsRecursive` is a straight-up hack that causes infinite loops.
    var src_dir = try std.fs.cwd().openDir("src", .{ .iterate = true });
    defer src_dir.close();
    var walker = try src_dir.walk(b.allocator);
    defer walker.deinit();

    while (try walker.next()) |entry| {
        if (entry.kind == .file and std.mem.endsWith(u8, entry.path, ".zig")) {
            const with_src_prefix = try std.fs.path.join(b.allocator, &[2][]const u8{ "src", entry.path });
            const file_runner = b.addTest(.{
                .root_source_file = .{ .path = with_src_prefix },
                .target = target,
                .optimize = optimize,
            });
            file_runner.root_module.addImport("websocket", websocket_module);
            const run_file = b.addRunArtifact(file_runner);
            test_step.dependOn(&run_file.step);
        }
    }
}
