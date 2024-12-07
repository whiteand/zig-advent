const std = @import("std");
const advent_utils = @import("advent_utils");
const benchmark = advent_utils.benchmark;
const lib = @import("lib");
const Op = lib.Op;
const solve_with_ops = lib.solve_with_ops;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var args_iter = try std.process.argsWithAllocator(allocator);
    defer args_iter.deinit();
    _ = args_iter.skip();

    const file_name = args_iter.next().?;

    const file_content = try std.fs.cwd().readFileAlloc(allocator, file_name, 1024 * 1024 * 8);

    const solution = try lib.solve2(std.mem.trim(u8, file_content, " \n"));
    const stdout = std.io.getStdOut();
    const output_buf = try std.fmt.allocPrint(allocator, "Solution: {}\n", .{solution});
    try stdout.writeAll(output_buf);

    try benchmark.bench("solve", solve_bench, allocator);
}

fn solve_bench(allocator: std.mem.Allocator) void {
    _ = allocator;
    const input = @embedFile("./input.txt");
    _ = lib.solve2(input) catch unreachable;
}
