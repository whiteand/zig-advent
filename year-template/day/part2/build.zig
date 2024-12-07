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

    const lib_dep = b.dependency("lib", .{
        .target = target,
        .optimize = optimize,
    });

    const lib_mod = b.addModule("lib", .{
        .root_source_file = lib_dep.path("lib.zig"),
    });

    const exe = b.addExecutable(.{
        .name = "part2",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("advent_utils", advent_utils_mod);
    exe.root_module.addImport("lib", lib_mod);

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const test_compile = b.addTest(.{
        .root_source_file = b.path("../lib/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    test_compile.root_module.addImport("advent_utils", advent_utils_mod);

    const test_cmd = b.addRunArtifact(test_compile);

    const test_step = b.step("test", "Run the tests");
    test_step.dependOn(&test_cmd.step);
}