const std = @import("std");

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
    try @import("benchmark.zig").bench("solve", solve_bench, allocator);
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

    var total: usize = 0;
    for (0..grid.items.len) |i| {
        for (0..grid.items[i].len) |j| {
            // a _ b
            //   c
            // d _ e
            const c = get(grid.items, @intCast(i + 1), @intCast(j + 1));
            if (c != 'A') {
                continue;
            }
            const a = get(grid.items, @intCast(i), @intCast(j));
            const e = get(grid.items, @intCast(i + 2), @intCast(j + 2));
            if (a == e) {
                continue;
            }
            const b = get(grid.items, @intCast(i), @intCast(j + 2));
            const d = get(grid.items, @intCast(i + 2), @intCast(j));
            if (b == d) {
                continue;
            }
            if (a != 'M' and a != 'S') {
                continue;
            }
            if (b != 'M' and b != 'S') {
                continue;
            }
            if (d != 'M' and d != 'S') {
                continue;
            }
            if (e != 'M' and e != 'S') {
                continue;
            }
            total += 1;
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
    try std.testing.expectEqual(solve(input, allocator), 1815);
}
