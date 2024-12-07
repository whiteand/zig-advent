const std = @import("std");
const advent_utils = @import("advent_utils");
const LineParser = advent_utils.LineParser;
pub const input_txt = @embedFile("input.txt");
pub const example_txt = @embedFile("example.txt");

pub fn solve1(
    file_content: []const u8,
    allocator: std.mem.Allocator,
) !i32 {
    return try run_program(allocator, file_content, 1);
}

pub fn solve2(
    file_content: []const u8,
    allocator: std.mem.Allocator,
) !usize {
    return try run_program(allocator, file_content, 5);
}

fn execute(memory: []i32, stdin: []const i32, stdout: *std.ArrayList(i32)) !void {
    var ip: usize = 0;
    var input = stdin;

    while (ip < memory.len) {
        const cmd = try parse_cmd(memory[ip]);
        switch (cmd.ty) {
            .add => {
                const a = deref(memory, ip + 1, cmd.immediate[0]);
                const b = deref(memory, ip + 2, cmd.immediate[1]);
                const output_ptr = memory[ip + 3];
                if (output_ptr < 0) {
                    std.debug.print("add a={}, b={}, output_ptr={}\n", .{ a, b, output_ptr });
                    return error.NegOutputPtr;
                }
                memory[@intCast(output_ptr)] = a + b;
                ip += 4;
            },
            .mul => {
                const a = deref(memory, ip + 1, cmd.immediate[0]);
                const b = deref(memory, ip + 2, cmd.immediate[1]);
                const output_ptr = memory[ip + 3];
                if (output_ptr < 0) {
                    return error.NegOutputPtr;
                }
                memory[@intCast(output_ptr)] = a * b;
                ip += 4;
            },
            .input => {
                const input_value = input[0];
                input = input[1..];
                const output_ptr = memory[ip + 1];
                if (output_ptr < 0) {
                    return error.NegOutputPtr;
                }
                memory[@intCast(output_ptr)] = input_value;
                ip += 2;
            },
            .output => {
                const a = deref(memory, ip + 1, cmd.immediate[0]);
                try stdout.append(a);
                ip += 2;
            },
            .jumpIfTrue => {
                // if the first parameter is non-zero, it sets the instruction pointer to the value from the second parameter. Otherwise, it does nothing.
                const a = deref(memory, ip + 1, cmd.immediate[0]);
                const b = deref(memory, ip + 2, cmd.immediate[1]);
                if (a != 0) {
                    if (b < 0) {
                        return error.NegOutputPtr;
                    }
                    ip = @intCast(b);
                } else {
                    ip += 3;
                }
            },
            .jumpIfFalse => {
                const a = deref(memory, ip + 1, cmd.immediate[0]);
                const b = deref(memory, ip + 2, cmd.immediate[1]);
                if (a == 0) {
                    if (b < 0) {
                        return error.NegOutputPtr;
                    }
                    ip = @intCast(b);
                } else {
                    ip += 3;
                }
            },
            .lessThen => {
                const a = deref(memory, ip + 1, cmd.immediate[0]);
                const b = deref(memory, ip + 2, cmd.immediate[1]);
                const output_ptr = memory[ip + 3];
                if (output_ptr < 0) {
                    return error.NegOutputPtr;
                }
                if (a < b) {
                    memory[@intCast(output_ptr)] = 1;
                } else {
                    memory[@intCast(output_ptr)] = 0;
                }
                ip += 4;
            },
            .equals => {
                const a = deref(memory, ip + 1, cmd.immediate[0]);
                const b = deref(memory, ip + 2, cmd.immediate[1]);
                const output_ptr = memory[ip + 3];
                if (output_ptr < 0) {
                    return error.NegOutputPtr;
                }
                if (a == b) {
                    memory[@intCast(output_ptr)] = 1;
                } else {
                    memory[@intCast(output_ptr)] = 0;
                }
                ip += 4;
            },
            .halt => {
                ip += 1;
                break;
            },
        }
    }
}

fn deref(memory: []const i32, ip: usize, immediate: bool) i32 {
    if (immediate) {
        return memory[ip];
    } else {
        return memory[@intCast(memory[ip])];
    }
}

const CmdType = enum {
    add,
    mul,
    input,
    output,
    halt,
    jumpIfTrue,
    jumpIfFalse,
    lessThen,
    equals,
};

const Cmd = struct {
    ty: CmdType,
    immediate: @Vector(3, bool),
};

fn parse_cmd(cmd: i32) !Cmd {
    if (cmd < 0) {
        return error.NegativeCmd;
    }

    const ty: CmdType = switch (@abs(cmd) % 100) {
        1 => .add,
        2 => .mul,
        3 => .input,
        4 => .output,
        5 => .jumpIfTrue,
        6 => .jumpIfFalse,
        7 => .lessThen,
        8 => .equals,
        99 => .halt,
        else => {
            std.debug.print("Unknown cmd: {}", .{cmd});
            return error.UnkonwnCmd;
        },
    };

    return .{ .ty = ty, .immediate = .{ (@abs(cmd) / 100) % 10 == 1, (@abs(cmd) / 1000) % 10 == 1, (@abs(cmd) / 10000) % 10 == 1 } };
}

fn parse(input: []const u8) !std.BoundedArray(i32, 768) {
    var res = try std.BoundedArray(i32, 768).init(0);
    var parser = advent_utils.LineParser.init(input);
    while (!parser.finished()) {
        const num = parser.parseDecimalInt(i32) catch |err| {
            switch (err) {
                error.EndOfFile => {
                    break;
                },
                error.ExpectedDigit => {
                    std.debug.print("{s}", .{parser.input[parser.ptr..]});
                    unreachable;
                },
            }
        };
        try res.append(num);
        if (!parser.finished()) {
            _ = try parser.parseKnownChar(',');
        }
    }
    return res;
}

fn run_program(allocator: std.mem.Allocator, code: []const u8, input: i32) !i32 {
    var memory = try parse(std.mem.trim(u8, code, " \n\r\t,"));
    const stdin = [_]i32{input};
    var stdout = try std.ArrayList(i32).initCapacity(allocator, 1024);
    defer stdout.deinit();
    try execute(memory.slice(), &stdin, &stdout);
    return stdout.getLast();
}

test "part1-actual" {
    try std.testing.expectEqual(6731945, solve1(input_txt, std.testing.allocator));
}
test "part2-actual" {
    const large = "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99";
    try std.testing.expectEqual(999, try run_program(std.testing.allocator, large, 7));
    try std.testing.expectEqual(1000, try run_program(std.testing.allocator, large, 8));
    try std.testing.expectEqual(1001, try run_program(std.testing.allocator, large, 9));
    try std.testing.expectEqual(1, try run_program(std.testing.allocator, "3,9,8,9,10,9,4,9,99,-1,8", 8));
    try std.testing.expectEqual(0, try run_program(std.testing.allocator, "3,9,8,9,10,9,4,9,99,-1,8", 9));
    try std.testing.expectEqual(1, try run_program(std.testing.allocator, "3,3,1108,-1,8,3,4,3,99", 8));
    try std.testing.expectEqual(0, try run_program(std.testing.allocator, "3,3,1108,-1,8,3,4,3,99", 9));
    try std.testing.expectEqual(1, try run_program(std.testing.allocator, "3,9,7,9,10,9,4,9,99,-1,8", 7));
    try std.testing.expectEqual(0, try run_program(std.testing.allocator, "3,9,7,9,10,9,4,9,99,-1,8", 8));
    try std.testing.expectEqual(1, try run_program(std.testing.allocator, "3,3,1107,-1,8,3,4,3,99", 7));
    try std.testing.expectEqual(0, try run_program(std.testing.allocator, "3,3,1107,-1,8,3,4,3,99", 8));

    try std.testing.expectEqual(9571668, try run_program(std.testing.allocator, input_txt, 5));
}
