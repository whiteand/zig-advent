const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const advent_utils_dep = b.dependency("advent_utils", .{
        .target = target,
        .optimize = optimize,
    });

    const advent_utils_mod = b.addModule("advent_utils", .{
        .root_source_file = advent_utils_dep.path("utils.zig"),
    });

    const lib_mod = b.addModule("lib", .{
        .root_source_file = b.path("src/lib.zig"),
    });

    lib_mod.addImport("advent_utils", advent_utils_mod);

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".

    const test_compile = b.addTest(.{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    test_compile.root_module.addImport("advent_utils", advent_utils_mod);

    const test_cmd = b.addRunArtifact(test_compile);

    const test_step = b.step("test", "Run the tests");
    test_step.dependOn(&test_cmd.step);
}
