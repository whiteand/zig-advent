const std = @import("std");
const advent_utils = @import("advent_utils");
pub const input_txt = @embedFile("input.txt");
pub const example_txt = @embedFile("example.txt");

const InvalidPassword = error {
NoTwoTheSame,
NotIncreasing,
NotSixDigit,
NotInRange,
};

fn solve(file_content: []const u8, is_valid_cb: fn(u32, @Vector(2, u32)) InvalidPassword!void) !usize {
    const range = parse(file_content);
    var x = range[0];
    const end = range[1];
  
    var total: usize = 0;
    while (x < end) : (x = next(x) orelse break) {
        is_valid_cb(x, range) catch continue;
        total += 1;
    }
    return total;
}

pub fn solve1(
    file_content: []const u8,
    allocator: std.mem.Allocator,
) !usize {
    _ = allocator;
    return try solve(file_content, is_valid);
}
pub fn solve2(
    file_content: []const u8,
    allocator: std.mem.Allocator,
) !usize {
    _ = allocator;
    return try solve(file_content, is_valid2);
}

fn is_valid(pass: u32, range: @Vector(2, u32)) InvalidPassword!void  {
    if (!two_same(pass)) return error.NoTwoTheSame;
    if (!increasing(pass)) return error.NotIncreasing;
    if (!six_digit(pass)) return error.NotSixDigit;
    if (!(pass >= range[0] and pass <= range[1])) return error.NotInRange;
}
fn is_valid2(pass: u32, range: @Vector(2, u32)) InvalidPassword!void  {
    if (!two_same_exact(pass)) return error.NoTwoTheSame;
    if (!increasing(pass)) return error.NotIncreasing;
    if (!six_digit(pass)) return error.NotSixDigit;
    if (!(pass >= range[0] and pass <= range[1])) return error.NotInRange;
}
fn two_same(pass: u32) bool {
    if (pass < 10) {
        return false;
    }
    const first = ((pass / 10) % 10) == (pass % 10);
    return first or two_same(pass / 10);
}
fn two_same_exact(password: u32) bool {
    var pass: u32 = password;
    if (pass < 10) {
        return false;
    }
    if (pass < 100) {
        return ((pass / 10) % 10) == (pass % 10);
    }
    
    const first = ((pass / 10) % 10) == (pass % 10);
    if (!first) return two_same_exact(pass / 10);
    if ((pass / 100) % 10 != pass % 10) {
        return true;
    }
    const digit = pass % 10;
    
    while (pass % 10 == digit and pass > 0) {
        pass /= 10;
    }

    return two_same_exact(pass);
}

fn six_digit(pass: u32) bool {
    return pass >= 100000 and pass <= 999999;
}
fn increasing(num: u32) bool {
    if (num < 10) return true;
    return increasing(num / 10) and (num%10 >= (num / 10) % 10);
}

fn next(value: u32) ?u32 {
    switch (value) {
        0...8 => {
            return value + 1;
        },
        9 => {
            return null;
        },
        else => {
            if (value % 10 < 9) {
                return value + 1;
            }
            const prev = next(value/10) orelse return null;
            return prev * 10 + prev % 10;
        }
    }
}


fn parse(input: []const u8) @Vector(2, u32) {
    var res =[_]u32{0, 0};
    var ptr: usize = 0;

    for (input) |b| {
        if (b >= '0' and b <= '9') {
            res[ptr] *= 10;
            res[ptr] += @intCast(b - '0');
        } else if (b == '-') {
            ptr = 1;
        }
    }

    return .{res[0], res[1]};
}

test "part1-example" {
    try is_valid(111111, .{0, 1000000});
    try std.testing.expectError(error.NotIncreasing, is_valid(223450,.{0, 1000000} ));
    try std.testing.expectError(error.NoTwoTheSame, is_valid(123789,.{0, 1000000} ));
    try std.testing.expectEqual(1033, solve1(example_txt, std.testing.allocator));
}
test "part1-actual" {
    try std.testing.expectEqual(1033, solve1(input_txt, std.testing.allocator));
}
test "part2-example" {
    try std.testing.expectEqual(670, solve2(example_txt, std.testing.allocator));
}
test "part2-actual" {
    try std.testing.expectEqual(670, solve2(example_txt, std.testing.allocator));
}
