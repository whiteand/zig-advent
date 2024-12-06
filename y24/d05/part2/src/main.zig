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

    const solution = try solve(std.mem.trim(u8, file_content, " \n"));
    const stdout = std.io.getStdOut();
    const output_buf = try std.fmt.allocPrint(allocator, "Solution: {}\n", .{solution});
    try stdout.writeAll(output_buf);

    try benchmark.bench("solve", solve_bench, allocator);
}

const test_input = std.mem.trim(u8, @embedFile("./input.txt"), "\n ");
fn solve_bench(allocator: std.mem.Allocator) void {
    _ = allocator;
    _ = solve(test_input) catch unreachable;
}
fn solve(file_content: []const u8) !usize {
    var pages_it = std.mem.split(u8, file_content, "\n\n");
    const first_page = pages_it.next() orelse unreachable;
    const second_page = pages_it.next() orelse unreachable;
    var res: usize = 0;
    var comparisons = try std.BoundedArray(struct { usize, usize }, 1200).init(0);
    var pages = try std.BoundedArray(usize, 100).init(0);
    var buf = try std.BoundedArray(usize, 100).init(0);
    var comparisons_it = std.mem.splitScalar(u8, first_page, '\n');
    while (comparisons_it.next()) |line| {
        var parts_it = std.mem.splitScalar(u8, line, '|');
        const first = parts_it.next() orelse unreachable;
        const second = parts_it.next() orelse unreachable;
        const first_num = std.fmt.parseInt(usize, first, 10) catch unreachable;
        const second_num = std.fmt.parseInt(usize, second, 10) catch unreachable;
        try comparisons.append(.{ first_num, second_num });
    }
    var lists_it = std.mem.splitScalar(u8, second_page, '\n');
    while (lists_it.next()) |list_str| {
        try buf.resize(0);
        try pages.resize(0);
        var num_iter = std.mem.splitScalar(u8, list_str, ',');
        while (num_iter.next()) |num_s| {
            const num = std.fmt.parseInt(usize, num_s, 10) catch unreachable;
            try pages.append(num);
            try buf.append(num);
        }
        std.sort.pdq(usize, buf.slice(), comparisons.constSlice(), cmp_by_comparison);
        if (!std.mem.eql(usize, pages.constSlice(), buf.constSlice())) {
            res += buf.get(buf.len / 2);
        }
    }
    return res;
}

fn cmp_by_comparison(comparisons: []const struct { usize, usize }, a: usize, b: usize) bool {
    for (comparisons) |cmp| {
        if (cmp[0] == a and cmp[1] == b) {
            return true;
        }
        if (cmp[1] == a and cmp[0] == b) {
            return false;
        }
    }
    return false;
}

test "actual" {
    const input = @embedFile("./input.txt");
    try std.testing.expectEqual(solve(std.mem.trim(u8, input, " \n")), 6257);
}
