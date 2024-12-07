const std = @import("std");
const advent_utils = @import("advent_utils");
const LineParser = advent_utils.LineParser;
pub const input_txt = @embedFile("input.txt");
pub const example_txt = @embedFile("example.txt");

pub fn solve1(
    file_content: []const u8,
    allocator: std.mem.Allocator,
) !usize {
    _ = allocator;
    const input = std.mem.trim(u8, file_content, "\n ");
    var nums = try std.BoundedArray(u32, 200).init(0);

    try parse(200, input, &nums);

    modify(nums.slice());

    try execute(nums.slice());

    return nums.buffer[0];
}

fn modify(nums: []u32) void {
    nums[1] = 12;
    nums[2] = 2;
}
fn execute(nums: []u32) !void {
    var ip: usize = 0;
    while (nums[ip] != 99) {
        if (ip > nums.len) {
            return error.InvalidGoto;
        }
        const op = nums[ip];
        const a = nums[ip + 1];
        if (a >= nums.len) {
            return error.InvalidFirstParameterAddress;
        }
        const b = nums[ip + 2];
        if (b >= nums.len) {
            return error.IvalidSecondParameterAddress;
        }
        const c = nums[ip + 3];
        if (c >= nums.len) {
            return error.InvalidDestinationAddress;
        }
        switch (op) {
            1 => nums[c] = nums[a] + nums[b],
            2 => nums[c] = nums[a] * nums[b],
            else => unreachable,
        }
        ip += 4;
    }
}

fn parse(comptime buffer_capacity: usize, input: []const u8, nums: *std.BoundedArray(u32, buffer_capacity)) !void {
    var parser = LineParser.init(input);
    while (true) {
        const num = try parser.parseDecimalInt(u32);
        _ = parser.parseKnownChar(',') catch |err| switch (err) {
            error.EndOfFile => {
                break;
            },
            error.ExpectedCharNotFound => {
                return error.ExpectedCharNotFound;
            },
        };
        try nums.append(num);
    }
}

pub fn solve2(
    file_content: []const u8,
    allocator: std.mem.Allocator,
) !usize {
    _ = allocator;
    const input = std.mem.trim(u8, file_content, "\n ");
    var nums = try std.BoundedArray(u32, 200).init(0);
    var original = try std.BoundedArray(u32, 200).init(0);

    try parse(200, input, &original);

    const target: usize = 19690720;
    for (0..100) |noun| {
        for (0..100) |verb| {
            try nums.resize(0);
            for (original.constSlice()) |n| {
                try nums.append(n);
            }
            nums.buffer[1] = @intCast(noun);
            nums.buffer[2] = @intCast(verb);
            execute(nums.slice()) catch {
                continue;
            };
            if (nums.buffer[0] == target) {
                return noun * 100 + verb;
            }
        }
    }
    return error.DidntFound;
}

test "part1-example" {
    var nums = [_]u32{ 1, 9, 10, 3, 2, 3, 11, 0, 99, 30, 40, 50 };
    try execute(&nums);
    try std.testing.expectEqual(.{ 3500, 9, 10, 70, 2, 3, 11, 0, 99, 30, 40, 50 }, nums);
}
test "part2-example" {}
test "part1-actual" {
    try std.testing.expectEqual(6087827, solve1(input_txt, std.testing.allocator));
}
test "part2-actual" {
    try std.testing.expectEqual(5379, solve2(input_txt, std.testing.allocator));
}
