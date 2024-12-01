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

    const solution = try solve(file_content, allocator);
    const stdout = std.io.getStdOut();
    const output_buf = try std.fmt.allocPrint(allocator, "Solution: {}\n", .{solution});
    try stdout.writeAll(output_buf);
}

fn solve(file_content: []const u8, allocator: std.mem.Allocator) !usize {
    var lines = std.mem.split(u8, std.mem.trimRight(u8, file_content, " \n"), "\n");
    var xs = std.ArrayList(usize).init(allocator);
    defer xs.deinit();

    var ys = std.ArrayList(usize).init(allocator);
    defer ys.deinit();

    while (lines.next()) |line| {
        var nums_iter = std.mem.split(u8, line, "   ");

        while (true) {
            if (nums_iter.next()) |num_str| {
                const x = try std.fmt.parseInt(usize, num_str, 10);
                try xs.append(x);
                const y = try std.fmt.parseInt(usize, nums_iter.next().?, 10);
                try ys.append(y);
            } else {
                break;
            }
        }
    }

    std.mem.sortUnstable(usize, xs.items, {}, std.sort.asc(usize));
    std.mem.sortUnstable(usize, ys.items, {}, std.sort.asc(usize));

    var total: usize = 0;

    for (xs.items, ys.items) |x, y| {
        if (x > y) {
            total += x - y;
        } else {
            total += y - x;
        }
    }

    return total;
}
