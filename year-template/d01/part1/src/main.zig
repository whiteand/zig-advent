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

fn solve(file_content: []const u8, allocator: std.mem.Allocator) !usize {
    std.debug.print("allocator: {any}\n", .{allocator});
    std.debug.print("file_content:\n{s}\n", .{file_content});
    return 0;
}

test "actual" {
    const allocator = std.testing.allocator;
    const input = @embedFile("./input.txt");
    std.testing.expectEqual(solve(input, allocator), 0);
}
