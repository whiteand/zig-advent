const std = @import("std");

pub const Op = enum {
    add,
    mul,
    concat,
};

pub fn solve1(
    file_content: []const u8,
) !usize {
    return try solve_with_ops(file_content, comptime &[_]Op{ .add, .mul });
}

pub fn solve2(
    file_content: []const u8,
) !usize {
    return try solve_with_ops(file_content, comptime &[_]Op{ .add, .mul, .concat });
}

pub fn solve_with_ops(file_content: []const u8, comptime ops: []const Op) !usize {
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

test "part1" {
    const input = @embedFile("./input.txt");
    try std.testing.expectEqual(solve_with_ops(input, &[_]Op{
        .add,
        .mul,
    }), 1620690235709);
}
test "part2" {
    const input = @embedFile("./input.txt");
    try std.testing.expectEqual(solve_with_ops(input, &[_]Op{ .add, .mul, .concat }), 145397611075341);
}
