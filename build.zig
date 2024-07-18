const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const websocket_dependency = b.dependency("websocket", .{});
    const websocket_module = websocket_dependency.module("websocket");
    const zigtime_dependency = b.dependency("zig-time", .{});
    const zigtime_module = zigtime_dependency.module("time");

    _ = b.addModule("deancord", .{
        .root_source_file = b.path("./src/root.zig"),
        .imports = &.{
            .{ .name = "websocket", .module = websocket_module },
            .{ .name = "zig-time", .module = zigtime_module },
        },
        .target = target,
        .optimize = optimize,
    });

    const test_step = b.step("test", "Run unit tests");
    const test_runner = b.addTest(.{
        .root_source_file = b.path("./src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    test_runner.root_module.addImport("websocket", websocket_module);
    test_runner.root_module.addImport("zig-time", zigtime_module);
    const test_run_artifact = b.addRunArtifact(test_runner);
    test_step.dependOn(&test_run_artifact.step);

    const lib_check = b.addStaticLibrary(.{
        .root_source_file = b.path("./src/root.zig"),
        .name = "deancord",
        .target = target,
        .optimize = optimize,
    });
    lib_check.root_module.addImport("websocket", websocket_module);
    lib_check.root_module.addImport("zig-time", zigtime_module);
    const check = b.step("check", "Run the compiler without building a library");
    check.dependOn(&lib_check.step);
}
