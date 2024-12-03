const std = @import("std");

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
}

fn solve(file_content: []const u8) !usize {
    var total: u32 = 0;
    var activated: bool = true;
    next: for (0..file_content.len) |i| {
        var slice = file_content[i..];
        if (std.mem.startsWith(u8, slice, "mul(")) {
            slice = slice[4..];
            var a: u32 = 0;
            var b: u32 = 0;
            for (0..slice.len) |j| {
                if (std.ascii.isDigit(slice[j])) {
                    a = a * 10 + (slice[j] - '0');
                } else {
                    slice = slice[j..];
                    break;
                }
            } else {
                continue :next;
            }
            if (slice[0] != ',') {
                continue :next;
            }
            slice = slice[1..];
            for (0..slice.len) |j| {
                if (std.ascii.isDigit(slice[j])) {
                    b = b * 10 + (slice[j] - '0');
                } else {
                    slice = slice[j..];
                    break;
                }
            } else {
                continue :next;
            }
            if (slice[0] != ')') {
                continue :next;
            }
            slice = slice[1..];
            if (activated) {
                total += a * b;
            }
        } else if (std.mem.startsWith(u8, slice, "don't()")) {
            activated = false;
        } else if (std.mem.startsWith(u8, slice, "do()")) {
            activated = true;
        }
    }
    return total;
}

test "works" {
    const res = solve("xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))\n");
    try std.testing.expectEqual(res, 48);
}

test "actual" {
    const fileContent = @embedFile("./input.txt");
    try std.testing.expectEqual(solve(fileContent), 95411583);
}
