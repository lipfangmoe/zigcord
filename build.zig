const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const weebsocket_dependency = b.dependency("weebsocket", .{});
    const weebsocket_module = weebsocket_dependency.module("weebsocket");

    const deancord_module = b.addModule("deancord", .{
        .root_source_file = b.path("./src/root.zig"),
        .imports = &.{
            .{ .name = "weebsocket", .module = weebsocket_module },
        },
        .target = target,
        .optimize = optimize,
    });

    // zig build test
    const test_runner = b.addTest(.{
        .root_source_file = b.path("./src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    test_runner.root_module.addImport("weebsocket", weebsocket_module);
    const test_run_artifact = b.addRunArtifact(test_runner);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&test_run_artifact.step);

    // zig build examples:interaction
    const interaction_bot = b.addExecutable(.{
        .name = "interaction-example",
        .optimize = optimize,
        .target = target,
        .root_source_file = b.path("./examples/interaction_bot.zig"),
    });
    interaction_bot.root_module.addImport("deancord", deancord_module);
    const interaction_artifact = b.addInstallArtifact(interaction_bot, .{});
    const example_interaction_step = b.step("examples:interaction", "Builds an example interaction bot");
    example_interaction_step.dependOn(&interaction_artifact.step);

    // zig build examples:gateway
    const gateway_bot = b.addExecutable(.{
        .name = "gateway-example",
        .optimize = optimize,
        .target = target,
        .root_source_file = b.path("./examples/gateway_bot.zig"),
    });
    gateway_bot.root_module.addImport("deancord", deancord_module);
    const gateway_artifact = b.addInstallArtifact(gateway_bot, .{});
    const example_gateway_step = b.step("examples:gateway", "Builds an example gateway bot");
    example_gateway_step.dependOn(&gateway_artifact.step);

    // zig build examples
    const examples_step = b.step("examples", "Builds all examples");
    examples_step.dependOn(example_interaction_step);
    examples_step.dependOn(example_gateway_step);

    // zig build check
    const check_tests_compile = b.addTest(.{
        .root_source_file = b.path("./src/root.zig"),
        .name = "deancord",
        .target = target,
        .optimize = optimize,
    });
    check_tests_compile.root_module.addImport("weebsocket", weebsocket_module);
    const check_step = b.step("check", "Run the compiler without building");
    check_step.dependOn(&check_tests_compile.step);
    check_step.dependOn(&interaction_bot.step);
    check_step.dependOn(&gateway_bot.step);
}
