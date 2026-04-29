const std = @import("std");

const version = std.SemanticVersion.parse("0.11.2") catch unreachable; // TODO: get from build.zig.zon
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

    const example_imports: []const std.Build.Module.Import = &.{.{ .name = "zigcord", .module = zigcord_module }};

    // zig build examples:interaction
    const example_interaction_step = b.step("examples:interaction", "Builds an example interaction bot");
    const interaction_module = b.createModule(.{ .root_source_file = b.path("./examples/interaction_bot.zig"), .optimize = optimize, .target = target, .imports = example_imports });
    const interaction_artifact = createExample(b, "interaction", interaction_module);
    example_interaction_step.dependOn(&interaction_artifact.step);
    example_interaction_step.dependOn(generate_step);

    // zig build examples:gateway
    const example_gateway_step = b.step("examples:gateway", "Builds an example gateway bot");
    const gateway_module = b.createModule(.{ .root_source_file = b.path("./examples/gateway_bot.zig"), .optimize = optimize, .target = target, .imports = example_imports });
    const gateway_artifact = createExample(b, "gateway", gateway_module);
    example_gateway_step.dependOn(&gateway_artifact.step);
    example_gateway_step.dependOn(generate_step);

    // zig build examples:gateway_logger
    const example_gateway_logger_step = b.step("examples:gateway_logger", "Builds an example gateway bot");
    const gateway_logger_module = b.createModule(.{ .root_source_file = b.path("./examples/gateway_logger_bot.zig"), .optimize = optimize, .target = target, .imports = example_imports });
    const gateway_logger_artifact = createExample(b, "gateway-logger", gateway_logger_module);
    example_gateway_logger_step.dependOn(&gateway_logger_artifact.step);
    example_gateway_logger_step.dependOn(generate_step);

    // zig build examples:thumbsup
    const example_thumbsup_step = b.step("examples:thumbsup", "Builds an example thumbs-up reaction bot");
    const thumbsup_module = b.createModule(.{ .root_source_file = b.path("./examples/thumbsup_bot.zig"), .optimize = optimize, .target = target, .imports = example_imports });
    const thumbsup_artifact = createExample(b, "thumbsup", thumbsup_module);
    example_thumbsup_step.dependOn(&thumbsup_artifact.step);
    example_thumbsup_step.dependOn(generate_step);

    // zig build examples:createsticker
    const example_createsticker_step = b.step("examples:createsticker", "Builds an example createsticker reaction bot");
    const createsticker_module = b.createModule(.{ .root_source_file = b.path("./examples/createsticker_bot.zig"), .optimize = optimize, .target = target, .imports = example_imports });
    const createsticker_artifact = createExample(b, "createsticker", createsticker_module);
    example_createsticker_step.dependOn(&createsticker_artifact.step);
    example_createsticker_step.dependOn(generate_step);

    // zig build examples
    const examples_step = b.step("examples", "Builds all examples");
    examples_step.dependOn(example_gateway_logger_step);
    examples_step.dependOn(example_interaction_step);
    examples_step.dependOn(example_gateway_step);
    examples_step.dependOn(example_thumbsup_step);

    // zig build check
    const check_step = b.step("check", "Run the compiler without building");
    const check_tests_compile = b.addTest(.{ .name = "zigcord-check-tests", .root_module = zigcord_module, .use_llvm = use_llvm });
    check_tests_compile.root_module.addOptions("build", options);
    check_step.dependOn(&check_tests_compile.step);
    dependOnBuildingModules(b, check_step, &.{
        interaction_module,
        gateway_module,
        gateway_logger_module,
        thumbsup_module,
        createsticker_module,
    });
}

fn createExample(
    b: *std.Build,
    comptime name: []const u8,
    module: *std.Build.Module,
) *std.Build.Step.InstallArtifact {
    const example_executable = b.addExecutable(.{ .name = std.fmt.comptimePrint("{s}-example", .{name}), .root_module = module, .use_llvm = use_llvm });
    return b.addInstallArtifact(example_executable, .{});
}

fn dependOnBuildingModules(b: *std.Build, step: *std.Build.Step, modules: []const *std.Build.Module) void {
    for (modules, 0..) |mod, idx| {
        var buf: [100]u8 = undefined;
        const exe = b.addExecutable(.{ .name = std.fmt.bufPrint(&buf, "check-example-{d}", .{idx}) catch unreachable, .root_module = mod, .use_llvm = use_llvm });
        step.dependOn(&exe.step);
    }
}
