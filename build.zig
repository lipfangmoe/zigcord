const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const model_module = b.createModule(.{
        .root_source_file = .{ .path = "src/model.zig" },
        .target = target,
        .optimize = optimize,
    });
    const rest_module = b.createModule(.{
        .root_source_file = .{ .path = "src/rest.zig" },
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "model", .module = model_module }},
    });
    const lib = b.addStaticLibrary(.{
        .name = "deancord",
        .target = target,
        .optimize = optimize,
        .root_source_file = .{ .path = "src/root.zig" },
    });
    lib.root_module.addImport("model", model_module);
    lib.root_module.addImport("rest", rest_module);

    b.installArtifact(lib);

    const test_step = b.step("test", "Run unit tests");

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
            const run_file = b.addRunArtifact(file_runner);
            test_step.dependOn(&run_file.step);
        }
    }
}
