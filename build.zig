const std = @import("std");

const version = std.SemanticVersion.parse("0.13.0") catch unreachable; // TODO: get from build.zig.zon
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

    // zig build examples
    const examples_step = b.step("examples", "Builds all examples");
    // note: createExample makes `examples_step` depend on the created example

    // zig build check
    const check_step = b.step("check", "Run the compiler without building");
    const check_tests_compile = b.addTest(.{ .name = "zigcord-check-tests", .root_module = zigcord_module, .use_llvm = use_llvm });
    check_tests_compile.root_module.addOptions("build", options);
    check_step.dependOn(&check_tests_compile.step);
    // note: createExample makes `check_step` depend on the created example

    const common: CreateExample.Common = .{
        .optimize = optimize,
        .target = target,
        .zigcord_module = zigcord_module,
        .generate_step = generate_step,
        .examples_step = examples_step,
        .check_step = check_step,
    };

    // zig build examples:interaction
    createExample(b, "interaction", .{ .description = "Builds an example interaction bot", .root_source_file = b.path("./examples/interaction_bot.zig"), .common = common });

    // zig build examples:gateway
    createExample(b, "gateway", .{ .description = "Builds an example gateway bot", .root_source_file = b.path("./examples/gateway_bot.zig"), .common = common });

    // zig build examples:gateway_logger
    createExample(b, "gateway_logger", .{ .description = "Builds an example gateway bot", .root_source_file = b.path("./examples/gateway_logger_bot.zig"), .common = common });

    // zig build examples:thumbsup
    createExample(b, "thumbsup", .{ .description = "Builds an example thumbs-up reaction bot", .root_source_file = b.path("./examples/thumbsup_bot.zig"), .common = common });

    // zig build examples:createsticker
    createExample(b, "createsticker", .{ .description = "Builds an example createsticker reaction bot", .root_source_file = b.path("./examples/createsticker_bot.zig"), .common = common });

    // zig build examples:async
    createExample(b, "async", .{ .description = "Builds an bot that uses asynchrony", .root_source_file = b.path("./examples/asynchrony.zig"), .common = common });

    // zig build examples:postattachment
    createExample(b, "postattachment", .{ .description = "Builds a bot that posts an attachment", .root_source_file = b.path("./examples/post_attachment.zig"), .common = common });
}

fn createExample(b: *std.Build, comptime name: []const u8, params: CreateExample) void {
    const example_step = b.step(std.fmt.comptimePrint("examples:{s}", .{name}), params.description);
    const example_module = b.createModule(.{
        .root_source_file = params.root_source_file,
        .optimize = params.common.optimize,
        .target = params.common.target,
        .imports = &.{.{ .name = "zigcord", .module = params.common.zigcord_module }},
    });

    const example_executable = b.addExecutable(.{ .name = std.fmt.comptimePrint("{s}-example", .{name}), .root_module = example_module, .use_llvm = use_llvm });
    const example_artifact = b.addInstallArtifact(example_executable, .{});
    example_step.dependOn(&example_artifact.step);
    example_step.dependOn(params.common.generate_step);

    params.common.examples_step.dependOn(example_step);

    const example_executable_check = b.addExecutable(.{ .name = std.fmt.comptimePrint("{s}-example-check", .{name}), .root_module = example_module, .use_llvm = use_llvm });
    params.common.check_step.dependOn(&example_executable_check.step);
}

const CreateExample = struct {
    description: []const u8,
    root_source_file: std.Build.LazyPath,
    common: Common,

    const Common = struct {
        optimize: std.builtin.OptimizeMode,
        target: std.Build.ResolvedTarget,
        zigcord_module: *std.Build.Module,
        generate_step: *std.Build.Step,
        examples_step: *std.Build.Step,
        check_step: *std.Build.Step,
    };
};
