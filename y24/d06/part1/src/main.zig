const std = @import("std");
const advent_utils = @import("advent_utils");
const SliceGrid = advent_utils.grid.SliceGrid;
const Grid = advent_utils.grid.Grid;

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

    const char_grid = SliceGrid(u8).init(grid.items);

    const res = try traverse(&char_grid, allocator, pos, .up);

    var total: usize = 0;
    var positions = res.positions;
    defer positions.deinit();

    for (positions.cells.items) |row| {
        for (row.items) |cell| {
            if (cell == true) {
                total += 1;
            }
        }
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

fn traverse(grid: *const SliceGrid(u8), allocator: std.mem.Allocator, initial: @Vector(2, i32), initial_dir: Dir) !TraverseResult {
    var pos = initial;
    var dir = initial_dir;

    var positions_list = try std.ArrayList(std.ArrayList(bool)).initCapacity(allocator, grid.cells.len);
    var states_list = try std.ArrayList(std.ArrayList(State)).initCapacity(allocator, grid.cells.len);
    for (0..grid.cells.len) |i| {
        var row = try std.ArrayList(bool).initCapacity(allocator, grid.cells[i].len);
        var states_row = try std.ArrayList(State).initCapacity(allocator, grid.cells[i].len);
        for (0..grid.cells[i].len) |_| {
            try row.append(false);
            try states_row.append(.{ .up = false, .down = false, .right = false, .left = false });
        }
        try positions_list.append(row);
        try states_list.append(states_row);
    }
    var positions = Grid(bool).init(positions_list);
    var states = Grid(State).init(states_list);
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
