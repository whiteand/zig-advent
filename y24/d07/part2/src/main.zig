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
const Op = enum {
    add,
    mul,
    concat,
};

fn solve(file_content: []const u8, allocator: std.mem.Allocator) !usize {
    return solve_with_ops(file_content, allocator, &[_]Op{ .add, .mul, .concat });
}
fn solve_with_ops(file_content: []const u8, allocator: std.mem.Allocator, comptime ops: []const Op) !usize {
    _ = allocator;
    var operands = try std.BoundedArray(u64, 16).init(0);
    var lines = std.mem.splitScalar(u8, file_content, '\n');
    var total: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        try operands.resize(0);
        const test_value = try parse(line, &operands);

        if (representable(test_value, operands.slice(), ops)) {
            // std.debug.print("Test = {}, ops = {any}\n", .{ test_value, operands.slice() });
            total += test_value;
        }
    }
    return total;
}

fn representable(value: u64, operands: []const u64, comptime ops: []const Op) bool {
    switch (operands.len) {
        0 => {
            return false;
        },
        1 => {
            return operands[0] == value;
        },
        else => {
            const last = operands[operands.len - 1];
            for (ops) |op| {
                switch (op) {
                    .add => {
                        if (value >= last and representable(value - last, operands[0..(operands.len - 1)], ops)) {
                            return true;
                        }
                    },
                    .mul => {
                        if (value % last == 0 and representable(value / last, operands[0..(operands.len - 1)], ops)) {
                            return true;
                        }
                    },
                    .concat => {
                        if (trim_suffix(u64, value, last, 10)) |prefix| {
                            if (representable(prefix, operands[0..(operands.len - 1)], ops)) {
                                return true;
                            }
                        }
                    },
                }
            }
            return false;
        },
    }
}

fn trim_suffix(comptime T: type, haystack: T, needle: T, comptime base: u8) ?T {
    if (needle == 0) {
        if (haystack % base == 0) {
            return haystack / 10;
        } else {
            return null;
        }
    }
    var a = haystack;
    var b = needle;
    while (b > 0 and a > 0) {
        if (a % base != b % base) {
            return null;
        }
        a /= base;
        b /= base;
    }
    if (b > 0) {
        return null;
    }
    return a;
}
fn parse(file_content: []const u8, operands: *std.BoundedArray(u64, 16)) !u64 {
    const eq_sep = std.mem.indexOf(u8, file_content, ": ") orelse {
        return error.FailedToFindSeparator;
    };
    const test_value_str = file_content[0..eq_sep];
    const eq_str = file_content[eq_sep + 2 ..];
    const test_value = try std.fmt.parseInt(u64, test_value_str, 10);
    var eq_iter = std.mem.tokenizeScalar(u8, eq_str, ' ');
    while (eq_iter.next()) |token| {
        if (token.len == 0) {
            continue;
        }
        const operand = try std.fmt.parseInt(u64, token, 10);
        try operands.append(operand);
    }

    return test_value;
}

test "actual" {
    const allocator = std.testing.allocator;
    const input = @embedFile("./input.txt");
    try std.testing.expectEqual(solve(input, allocator), 145397611075341);
}
