const std = @import("std");
const advent_utils = @import("advent_utils");
const benchmark = advent_utils.benchmark;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var args_iter = try std.process.argsWithAllocator(allocator);
    defer args_iter.deinit();
    _ = args_iter.skip();

    const file_name = args_iter.next().?;

    const file_content = try std.fs.cwd().readFileAlloc(allocator, file_name, 1024 * 1024 * 8);

    const solution = try solve(std.mem.trim(u8, file_content, " \n"), allocator);
    const stdout = std.io.getStdOut();
    const output_buf = try std.fmt.allocPrint(allocator, "Solution: {}\n", .{solution});
    try stdout.writeAll(output_buf);

    try benchmark.bench("solve", solve_bench, allocator);
}

fn solve_bench(allocator: std.mem.Allocator) void {
    const input = @embedFile("./input.txt");
    _ = solve(input, allocator) catch unreachable;
}

fn solve(file_content: []const u8, allocator: std.mem.Allocator) !usize {
    var lines_iter = std.mem.splitScalar(u8, file_content, '\n');
    var grid = try std.ArrayList([]const u8).initCapacity(allocator, 200);
    defer grid.deinit();

    while (lines_iter.next()) |line| {
        try grid.append(line);
    }

    const Dir = struct { i32, i32 };
    const dirs = [_]Dir{
        .{ -1, -1 },
        .{ -1, 0 },
        .{ -1, 1 },
        .{ 0, -1 },
        .{ 0, 1 },
        .{ 1, -1 },
        .{ 1, 0 },
        .{ 1, 1 },
    };

    var total: usize = 0;
    for (0..grid.items.len) |i| {
        for (0..grid.items[i].len) |j| {
            if (get(grid.items, @intCast(i), @intCast(j)) != 'X') {
                continue;
            }
            for (dirs) |dir| {
                const dr = dir[0];
                const dc = dir[1];
                const row: i32 = @intCast(i);
                const col: i32 = @intCast(j);
                if (get(grid.items, row + dr, col + dc) != 'M') {
                    continue;
                }
                if (get(grid.items, row + dr * 2, col + dc * 2) != 'A') {
                    continue;
                }
                if (get(grid.items, row + dr * 3, col + dc * 3) != 'S') {
                    continue;
                }
                total += 1;
            }
        }
    }

    return total;
}

fn get(grid: []const []const u8, i: i32, j: i32) u8 {
    if (i < 0 or i >= grid.len or j < 0 or j >= grid[@intCast(i)].len) {
        return '.';
    }
    return grid[@intCast(i)][@intCast(j)];
}

test "actual" {
    const allocator = std.testing.allocator;
    const input = @embedFile("./input.txt");
    try std.testing.expectEqual(solve(input, allocator), 2344);
}
