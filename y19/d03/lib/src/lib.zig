const std = @import("std");
const advent_utils = @import("advent_utils");
pub const input_txt = @embedFile("input.txt");
pub const example_txt = @embedFile("example.txt");

const Segment = struct {
    /// Exclusive to not intersect at the start
    start: @Vector(2, i32),
    end: @Vector(2, i32),
    const Self = @This();
    fn init(start: @Vector(2, i32), end: @Vector(2, i32)) Self {
        return .{ .start = start, .end = end };
    }
    fn len(self: *const Self) u32 {
        return @intCast(self.max_x() - self.min_x() + self.max_y() - self.min_y() + 1);
    }
    fn min_x(self: *const Self) i32 {
        if (self.start[0] == self.end[0]) {
            return self.start[0];
        } else {
            if (self.end[0] > self.start[0]) {
                return @min(self.start[0] + 1, self.end[0]);
            } else {
                return @min(self.start[0] - 1, self.end[0]);
            }
        }
    }
    fn min_y(self: *const Self) i32 {
        if (self.start[0] == self.end[0]) {
            if (self.end[1] > self.start[1]) {
                return @min(self.start[1] + 1, self.end[1]);
            } else {
                return @min(self.start[1] - 1, self.end[1]);
            }
        } else {
            return self.start[1];
        }
    }
    fn max_x(self: *const Self) i32 {
        if (self.start[0] == self.end[0]) {
            return self.start[0];
        } else {
            if (self.end[0] > self.start[0]) {
                return @max(self.start[0] + 1, self.end[0]);
            } else {
                return @max(self.start[0] - 1, self.end[0]);
            }
        }
    }
    fn max_y(self: *const Self) i32 {
        if (self.start[0] == self.end[0]) {
            if (self.end[1] > self.start[1]) {
                return @max(self.start[1] + 1, self.end[1]);
            } else {
                return @max(self.start[1] - 1, self.end[1]);
            }
        } else {
            return self.start[1];
        }
    }
    fn intersection(self: *const Self, other: *const Self) ?@Vector(2, i32) {
        const self_min_x = self.min_x();
        const self_max_x = self.max_x();
        const self_min_y = self.min_y();
        const self_max_y = self.max_y();
        const other_min_x = other.min_x();
        const other_max_x = other.max_x();
        const other_min_y = other.min_y();
        const other_max_y = other.max_y();

        if (self_min_x == self_max_x) {
            if (other_min_x == other_max_x) {
                // two verticals
                if (self_min_x != other_min_x) {
                    return null;
                }
                if (self_max_y < other_min_y) {
                    return null;
                }
                if (self_min_y > other_max_y) {
                    return null;
                }
                unreachable;
            } else {
                // self - vertical
                // other - horizontal
                if (self_min_x < other_min_x) {
                    return null;
                }
                if (self_min_x > other_max_x) {
                    return null;
                }
                if (self_min_y > other_min_y) {
                    return null;
                }
                if (self_max_y < other_min_y) {
                    return null;
                }
                return .{ self_min_x, other_min_y };
            }
        } else {
            // self = horizontal;
            if (other_max_y == other_min_y) {
                // both - horizontal
                if (other_max_y != self_max_y) {
                    return null;
                }
                unreachable;
            }
            return other.intersection(self);
        }
    }
};

pub fn solve1(
    file_content: []const u8,
    allocator: std.mem.Allocator,
) !usize {
    _ = allocator;
    var first_wire = try std.BoundedArray(Segment, 320).init(0);
    var second_wire = try std.BoundedArray(Segment, 320).init(0);
    var lines = std.mem.splitScalar(u8, file_content, '\n');
    if (lines.next()) |line| {
        try parse_wire(line, &first_wire);
    } else {
        unreachable;
    }
    if (lines.next()) |line| {
        try parse_wire(line, &second_wire);
    } else {
        unreachable;
    }

    return find_closest_intersection_distance(first_wire.slice(), second_wire.slice()) orelse error.DidntFound;
}

pub fn solve2(
    file_content: []const u8,
    allocator: std.mem.Allocator,
) !usize {
    _ = allocator;
    var first_wire = try std.BoundedArray(Segment, 320).init(0);
    var second_wire = try std.BoundedArray(Segment, 320).init(0);
    var lines = std.mem.splitScalar(u8, file_content, '\n');
    if (lines.next()) |line| {
        try parse_wire(line, &first_wire);
    } else {
        unreachable;
    }
    if (lines.next()) |line| {
        try parse_wire(line, &second_wire);
    } else {
        unreachable;
    }

    return find_minimal_delay(first_wire.slice(), second_wire.slice()) orelse error.DidntFound;
}

fn find_closest_intersection_distance(a: []const Segment, b: []const Segment) ?u32 {
    var closest: @Vector(2, i32) = .{ std.math.maxInt(i32), std.math.maxInt(i32) };
    for (a) |first| {
        for (b) |second| {
            const intersection = first.intersection(&second) orelse {
                continue;
            };
            if (@abs(intersection[0]) + @abs(intersection[1]) < @abs(closest[0]) + @abs(closest[1])) {
                closest = intersection;
            }
        }
    }

    if (closest[0] == std.math.maxInt(i32)) {
        return null;
    }
    return @abs(closest[0]) + @abs(closest[1]);
}
fn find_minimal_delay(a: []const Segment, b: []const Segment) ?u32 {
    var first_distance: u32 = 0;
    var second_distance: u32 = 0;
    var shortest_distance: u32 = std.math.maxInt(u32);
    for (a) |first| {
        second_distance = 0;
        for (b) |second| {
            const intersection = first.intersection(&second) orelse {
                second_distance += second.len();
                continue;
            };
            const first_add = Segment.init(first.start, intersection).len();
            const second_add = Segment.init(second.start, intersection).len();
            const sum = first_distance + second_distance + first_add + second_add;
            if (sum < shortest_distance) {
                shortest_distance = sum;
            }
            second_distance += second.len();
        }
        first_distance += first.len();
    }

    if (shortest_distance == std.math.maxInt(u32)) {
        return null;
    }
    return shortest_distance;
}

fn parse_wire(input: []const u8, wire: *std.BoundedArray(Segment, 320)) !void {
    try wire.resize(0);
    var segments_strings = std.mem.tokenizeScalar(u8, input, ',');
    var pos: @Vector(2, i32) = .{ 0, 0 };
    while (segments_strings.next()) |segment_str| {
        if (segment_str.len == 0) {
            continue;
        }
        const dir: @Vector(2, i32) = switch (segment_str[0]) {
            'R' => .{ 0, 1 },
            'L' => .{ 0, -1 },
            'U' => .{ 1, 0 },
            'D' => .{ -1, 0 },
            else => unreachable,
        };
        const abs: @Vector(2, i32) = @splat(try std.fmt.parseInt(i32, segment_str[1..], 10));
        const end = pos + dir * abs;
        try wire.append(Segment{ .start = pos, .end = end });
        pos = end;
    }
}

test "part1-example" {
    var first_wire = try std.BoundedArray(Segment, 320).init(0);
    var second_wire = try std.BoundedArray(Segment, 320).init(0);

    try parse_wire("R75,D30,R83,U83,L12,D49,R71,U7,L72", &first_wire);
    try parse_wire("U62,R66,U55,R34,D71,R55,D58,R83", &second_wire);
    try std.testing.expectEqual(159, find_closest_intersection_distance(first_wire.slice(), second_wire.slice()));

    try parse_wire("R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51", &first_wire);
    try parse_wire("U98,R91,D20,R16,D67,R40,U7,R15,U6,R7", &second_wire);
    try std.testing.expectEqual(135, find_closest_intersection_distance(first_wire.slice(), second_wire.slice()));
}
test "part2-example" {
    var first_wire = try std.BoundedArray(Segment, 320).init(0);
    var second_wire = try std.BoundedArray(Segment, 320).init(0);

    try parse_wire("R8,U5,L5,D3", &first_wire);
    try parse_wire("U7,R6,D4,L4", &second_wire);
    try std.testing.expectEqual(30, find_minimal_delay(first_wire.slice(), second_wire.slice()));

    try parse_wire("R75,D30,R83,U83,L12,D49,R71,U7,L72", &first_wire);
    try parse_wire("U62,R66,U55,R34,D71,R55,D58,R83", &second_wire);
    try std.testing.expectEqual(610, find_minimal_delay(first_wire.slice(), second_wire.slice()));

    try parse_wire("R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51", &first_wire);
    try parse_wire("U98,R91,D20,R16,D67,R40,U7,R15,U6,R7", &second_wire);
    try std.testing.expectEqual(410, find_minimal_delay(first_wire.slice(), second_wire.slice()));
}

test "part1-actual" {
    try std.testing.expectEqual(529, solve1(input_txt, std.testing.allocator));
}
test "part2-actual" {
    try std.testing.expectEqual(20386, solve2(input_txt, std.testing.allocator));
}
