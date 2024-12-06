const std = @import("std");
const advent_utils = @import("advent_utils");
const Grid = advent_utils.grid.Grid;
const SliceGrid = advent_utils.grid.SliceGrid;
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

    var pos: @Vector(2, i32) = .{ 0, 0 };
    var r: i32 = 0;
    while (lines_iter.next()) |line| {
        if (line.len != 0) {
            for (line, 0..) |c, j| {
                if (c == '^') {
                    pos = .{ r, @intCast(j) };
                }
            }
            try grid.append(line);
            r += 1;
        }
    }

    var char_grid = try SliceGrid(u8).init(grid.items).to_owned(allocator);

    const traverse_result = try traverse(&char_grid, allocator, pos, .up);

    var total: usize = 0;
    var positions = traverse_result.positions;
    defer positions.deinit();

    var candidates = try std.BoundedArray(@Vector(2, i32), 6000).init(0);
    for (positions.cells.items, 0..) |row, i| {
        for (row.items, 0..) |cell, j| {
            if (cell == true) {
                try candidates.append(.{ @intCast(i), @intCast(j) });
            }
        }
    }

    for (candidates.slice()) |candidate| {
        const prev = char_grid.set(candidate, '#');
        const res = try traverse(&char_grid, allocator, pos, .up);
        if (res.loop) {
            total += 1;
        }
        _ = char_grid.set(candidate, prev);
    }

    return total;
}

const Dir = enum(u2) {
    up,
    right,
    down,
    left,
    fn next(dir: *const Dir) Dir {
        switch (dir.*) {
            .up => return .right,
            .right => return .down,
            .down => return .left,
            .left => return .up,
        }
    }
    fn apply(dir: *const Dir, pos: @Vector(2, i32)) @Vector(2, i32) {
        switch (dir.*) {
            .up => return .{ pos[0] - 1, pos[1] },
            .right => return .{ pos[0], pos[1] + 1 },
            .down => return .{ pos[0] + 1, pos[1] },
            .left => return .{ pos[0], pos[1] - 1 },
        }
    }
};

const State = struct {
    up: bool,
    down: bool,
    right: bool,
    left: bool,

    fn add(state: *State, dir: Dir) bool {
        switch (dir) {
            .up => {
                const prev = state.up;
                state.up = true;
                return prev;
            },
            .right => {
                const prev = state.right;
                state.right = true;
                return prev;
            },
            .down => {
                const prev = state.down;
                state.down = true;
                return prev;
            },
            .left => {
                const prev = state.left;
                state.left = true;
                return prev;
            },
        }
    }
};

const TraverseResult = struct {
    positions: Grid(bool),
    loop: bool,
};

fn get_false(_: *const u8) bool {
    return false;
}
fn default_state(_: *const u8) State {
    return .{
        .up = false,
        .right = false,
        .down = false,
        .left = false,
    };
}
fn traverse(grid: *const Grid(u8), allocator: std.mem.Allocator, initial: @Vector(2, i32), initial_dir: Dir) !TraverseResult {
    var pos = initial;
    var dir = initial_dir;

    var positions = try grid.map(bool, allocator, get_false);
    var states = try grid.map(State, allocator, default_state);
    defer states.deinit();
    var has_loop = false;
    while (true) {
        var ch: u8 = '.';
        if (grid.get(pos)) |x| {
            ch = x.*;
        }
        if (states.get_mut(pos)) |state| {
            if (state.add(dir)) {
                has_loop = true;
                break;
            }
        }
        if (positions.get_mut(pos)) |p| {
            p.* = true;
        }
        const next_pos = dir.apply(pos);
        const cell = grid.get(next_pos) orelse break;
        if (cell.* != '#') {
            pos = next_pos;
            continue;
        }
        dir = dir.next();
    }
    return .{ .positions = positions, .loop = has_loop };
}

test "actual" {
    const allocator = std.testing.allocator;
    const input = @embedFile("./input.txt");
    try std.testing.expectEqual(solve(input, allocator), 5086);
}
