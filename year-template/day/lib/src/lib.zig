const std = @import("std");
const advent_utils = @import("advent_utils");
pub const input_txt = @embedFile("input.txt");
pub const example_txt = @embedFile("example.txt");

pub fn solve1(
    file_content: []const u8,
    allocator: std.mem.Allocator,
) !usize {
    _ = allocator;
    std.debug.print("{s}\n\n", .{file_content});
    return 0;
}

pub fn solve2(
    file_content: []const u8,
    allocator: std.mem.Allocator,
) !usize {
    _ = allocator;
    _ = file_content;
    return 0;
}

test "part1-example" {
    try std.testing.expectEqual(0, solve1(example_txt, std.testing.allocator));
}
test "part2-example" {
    try std.testing.expectEqual(0, solve2(example_txt, std.testing.allocator));
}
test "part1-actual" {
    try std.testing.expectEqual(0, solve1(input_txt, std.testing.allocator));
}
test "part2-actual" {
    try std.testing.expectEqual(0, solve2(input_txt, std.testing.allocator));
}
