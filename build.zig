const std = @import("std");

const version = std.SemanticVersion.parse("0.5.5") catch unreachable; // TODO: get from build.zig.zon
const use_llvm = true;

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    var options = b.addOptions();
    options.addOption(std.SemanticVersion, "version", version);

    const test_filters: []const []const u8 = b.option(
        []const []const u8,
        "test_filter",
        "Skip tests that do not match any of the specified filters",
    ) orelse &.{};

    // zig build generate
    const generator_module = b.createModule(.{
        .root_source_file = b.path("./generate_endpoint_client.zig"),
        .optimize = .Debug,
        .target = b.graph.host,
    });
    const generator_exe = b.addExecutable(.{
        .name = "generate_endpoint_client",
        .root_module = generator_module,
    });
    const run_generator = b.addRunArtifact(generator_exe);
    const output = run_generator.addOutputFileArg("EndpointClient.zig");
    const copy_endpoint_client = b.addUpdateSourceFiles();
    copy_endpoint_client.addCopyFileToSource(output, "src/rest/EndpointClient.zig");
    const generate_step = b.step("generate", "generate EndpointClient file");
    generate_step.dependOn(&copy_endpoint_client.step);

    const weebsocket_dependency = b.dependency("weebsocket", .{});
    const weebsocket_module = weebsocket_dependency.module("weebsocket");

    const zigcord_module = b.addModule("zigcord", .{
        .root_source_file = b.path("./src/root.zig"),
        .imports = &.{.{ .name = "weebsocket", .module = weebsocket_module }},
        .target = target,
        .optimize = optimize,
    });
    zigcord_module.addOptions("build", options);

    // zig build test
    const test_runner = b.addTest(.{ .root_module = zigcord_module, .filters = test_filters, .use_llvm = use_llvm });
    const test_run_artifact = b.addRunArtifact(test_runner);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&test_run_artifact.step);
    test_step.dependOn(generate_step);

    // zig build examples:interaction
    const interaction_bot_module = b.createModule(.{
        .root_source_file = b.path("./examples/interaction_bot.zig"),
        .optimize = optimize,
        .target = target,
        .imports = &.{.{ .name = "zigcord", .module = zigcord_module }},
    });
    const interaction_bot = b.addExecutable(.{ .name = "interaction-example", .root_module = interaction_bot_module, .use_llvm = use_llvm });
    const interaction_artifact = b.addInstallArtifact(interaction_bot, .{});
    const example_interaction_step = b.step("examples:interaction", "Builds an example interaction bot");
    example_interaction_step.dependOn(&interaction_artifact.step);
    example_interaction_step.dependOn(generate_step);

    // zig build examples:gateway
    const gateway_bot_module = b.createModule(.{
        .root_source_file = b.path("./examples/gateway_bot.zig"),
        .optimize = optimize,
        .target = target,
        .imports = &.{.{ .name = "zigcord", .module = zigcord_module }},
    });
    const gateway_bot = b.addExecutable(.{ .name = "gateway-example", .root_module = gateway_bot_module, .use_llvm = use_llvm });
    const gateway_artifact = b.addInstallArtifact(gateway_bot, .{});
    const example_gateway_step = b.step("examples:gateway", "Builds an example gateway bot");
    example_gateway_step.dependOn(&gateway_artifact.step);
    example_gateway_step.dependOn(generate_step);

    // zig build examples:gateway_logger
    const gateway_logger_bot_module = b.createModule(.{
        .root_source_file = b.path("./examples/gateway_logger_bot.zig"),
        .optimize = optimize,
        .target = target,
        .imports = &.{.{ .name = "zigcord", .module = zigcord_module }},
    });
    const gateway_logger_bot = b.addExecutable(.{ .name = "gateway-logger-example", .root_module = gateway_logger_bot_module, .use_llvm = use_llvm });
    const gateway_logger_artifact = b.addInstallArtifact(gateway_logger_bot, .{});
    const example_gateway_logger_step = b.step("examples:gateway_logger", "Builds an example gateway bot");
    example_gateway_logger_step.dependOn(&gateway_logger_artifact.step);
    example_gateway_logger_step.dependOn(generate_step);

    // zig build examples
    const examples_step = b.step("examples", "Builds all examples");
    examples_step.dependOn(example_gateway_logger_step);
    examples_step.dependOn(example_interaction_step);
    examples_step.dependOn(example_gateway_step);

    // zig build check
    const check_tests_compile = b.addTest(.{ .name = "zigcord", .root_module = zigcord_module, .use_llvm = use_llvm });
    check_tests_compile.root_module.addOptions("build", options);
    check_tests_compile.root_module.addImport("weebsocket", weebsocket_module);
    const check_step = b.step("check", "Run the compiler without building");
    check_step.dependOn(&check_tests_compile.step);
    check_step.dependOn(&interaction_bot.step);
    check_step.dependOn(&gateway_bot.step);
    check_step.dependOn(&gateway_logger_bot.step);
}
