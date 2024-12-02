const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var args_iter = try std.process.argsWithAllocator(allocator);
    defer args_iter.deinit();
    _ = args_iter.skip();

    const file_name = args_iter.next().?;

    const file_content = try std.fs.cwd().readFileAlloc(allocator, file_name, 0xffffffffffffffff);

    const solution = try solve(std.mem.trim(u8, file_content, " \n"), allocator);
    const stdout = std.io.getStdOut();
    const output_buf = try std.fmt.allocPrint(allocator, "Solution: {}\n", .{solution});
    try stdout.writeAll(output_buf);
}

fn solve(file_content: []const u8, allocator: std.mem.Allocator) !usize {
    var it = std.mem.splitSequence(u8, file_content, "\n");
    var total: usize = 0;
    var nums = try std.ArrayList(usize).initCapacity(allocator, 8);
    defer nums.deinit();

    while (it.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        nums.clearRetainingCapacity();
        var nums_strs = std.mem.splitScalar(u8, line, ' ');
        while (nums_strs.next()) |num_str| {
            const num = try std.fmt.parseInt(usize, num_str, 10);
            try nums.append(num);
        }
        if (is_safe(nums.items)) {
            total += 1;
        } else {
            for (0..nums.items.len) |i| {
                const value = nums.orderedRemove(i);
                if (is_safe(nums.items)) {
                    total += 1;
                    break;
                }
                try nums.insert(i, value);
            }
        }
    }

    return total;
}

fn is_safe(items: []usize) bool {
    var sign: i8 = 0;
    for (items[0..(items.len - 1)], items[1..]) |a, b| {
        if (a == b) {
            return false;
        }
        if (a > b and (sign == -1 or a - b > 3)) {
            return false;
        }
        if (a < b and (sign == 1 or b - a > 3)) {
            return false;
        }
        sign = if (a > b) 1 else -1;
    }
    return true;
}
