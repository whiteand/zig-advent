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

    const all_tests = b.addTest(.{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    const all_tests_cmd = b.addRunArtifact(all_tests);

    const all_tests_step = b.step("test", "Run the tests");
    all_tests_step.dependOn(&all_tests_cmd.step);

    const tests: []const struct {
        filter: []const u8,
        description: []const u8,
        cmd: []const u8,
    } = &.{ .{ .filter = "part1-example", .description = "Run Part 1 Example Tests", .cmd = "test-p1-example" }, .{ .filter = "part2-example", .description = "Run Part 2 Example Tests", .cmd = "test-p2-example" }, .{ .filter = "part1-actual", .description = "Run Part 1 Actual Tests", .cmd = "test-p1" }, .{ .filter = "part2-actual", .description = "Run Part 2 Actual Tests", .cmd = "test-p2" } };

    for (tests) |t| {
        const t_compile = b.addTest(.{
            .root_source_file = b.path("src/lib.zig"),
            .target = target,
            .optimize = optimize,
            .filters = &.{t.filter},
        });
        const t_run = b.addRunArtifact(t_compile);
        const t_step = b.step(t.cmd, t.description);
        t_step.dependOn(&t_run.step);
    }
}
