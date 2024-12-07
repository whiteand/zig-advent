const std = @import("std");
const advent_utils = @import("advent_utils");
pub const input_txt = @embedFile("input.txt");
pub const example_txt = @embedFile("example.txt");

pub const Op = enum {
    add,
    mul,
    concat,
};

pub fn solve1(
    file_content: []const u8,
    allocator: std.mem.Allocator,
) !usize {
    _ = allocator;
    return try solve(file_content, fuel);
}
pub fn solve2(
    file_content: []const u8,
    allocator: std.mem.Allocator,
) !usize {
    _ = allocator;
    return try solve(file_content, recursive);
}
pub fn solve(
    file_content: []const u8,
    get_fuel: fn (u64) u64,
) !usize {
    var lines = std.mem.splitScalar(u8, file_content, '\n');
    var total: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        const num = try std.fmt.parseInt(u64, line, 10);
        total += get_fuel(num);
    }
    return total;
}

fn fuel(n: u64) u64 {
    const res: u64 = n / 3;
    if (res <= 2) {
        return 0;
    }
    return res - 2;
}
fn recursive(n: u64) u64 {
    var additional = n;
    var total: u64 = 0;
    while (additional > 0) {
        additional = fuel(additional);
        total += additional;
    }
    return total;
}

test "part1-example" {
    try std.testing.expectEqual(33583, solve1(example_txt, std.testing.allocator));
}
test "part1-actual" {
    try std.testing.expectEqual(
        3332538,
        solve1(input_txt, std.testing.allocator),
    );
}
test "part2-example" {
    try std.testing.expectEqual(
        50346,
        solve2(example_txt, std.testing.allocator),
    );
}
test "part2-actual" {
    try std.testing.expectEqual(4995942, solve2(input_txt, std.testing.allocator));
}
