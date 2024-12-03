const std = @import("std");
const LineParser = @import("./LineParser.zig");

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
    var parser = LineParser.init(file_content);
    while (!parser.finished()) {
        if (parser.parsePrefix("mul(") catch false) {
            const a = parser.parseDecimalInt(u32) catch {
                parser.skip(1);
                continue;
            };
            if (!(parser.parseKnownChar(',') catch false)) {
                parser.skip(1);
                continue;
            }
            const b = parser.parseDecimalInt(u32) catch {
                parser.skip(1);
                continue;
            };
            if (!(parser.parseKnownChar(')') catch false)) {
                parser.skip(1);
                continue;
            }

            total += a * b;

            continue;
        }

        parser.skip(1);
    }
    return total;
}

test "works" {
    const res = solve("xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))");
    try std.testing.expectEqual(res, 161);
}

test "actual" {
    const fileContent = @embedFile("./input.txt");
    try std.testing.expectEqual(solve(fileContent), 180233229);
}
