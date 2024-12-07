const std = @import("std");

pub const Op = enum {
    add,
    mul,
    concat,
};

pub fn solve1(
    file_content: []const u8,
    allocator: std.mem.Allocator,
) !usize {
    std.debug.print("{s}\n\n^ it is a puzzle input", .{file_content});
    _ = allocator;
    return 0;
}

pub fn solve2(
    file_content: []const u8,
    allocator: std.mem.Allocator,
) !usize {
    std.debug.print("{s}\n\n^ it is a puzzle input", .{file_content});
    _ = allocator;
    return 0;
}

test "part1" {
    const input = @embedFile("./input.txt");
    try std.testing.expectEqual(try solve1(input, std.testing.allocator), 0);
}
test "part2" {
    const input = @embedFile("./input.txt");
    try std.testing.expectEqual(try solve2(input, std.testing.allocator), 0);
}
