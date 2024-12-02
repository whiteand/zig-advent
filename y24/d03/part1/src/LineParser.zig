input: []const u8,
ptr: usize,

const std = @import("std");
const LineParser = @This();

pub fn init(input: []const u8) LineParser {
    return LineParser{ .input = input, .ptr = 0 };
}

pub fn parseKnownChar(self: *LineParser, expected: u8) !bool {
    if (self.ptr >= self.input.len) {
        return error.EndOfFile;
    }
    if (self.input[self.ptr] != expected) {
        return error.ExpectedCharNotFound;
    }
    self.ptr += 1;
    return true;
}
pub fn parsePrefix(self: *LineParser, needle: []const u8) !bool {
    if (std.mem.startsWith(u8, self.input[self.ptr..], needle)) {
        self.ptr += needle.len;
        return true;
    } else {
        return error.ExpectedPrefixNotFound;
    }
}
pub fn parseDecimalInt(self: *LineParser, comptime T: type) !T {
    if (self.ptr >= self.input.len) {
        return error.EndOfFile;
    }
    if (!std.ascii.isDigit(self.input[self.ptr])) {
        return error.ExpectedDigit;
    }
    var result: T = 0;
    while (self.ptr < self.input.len) : (self.ptr += 1) {
        if (!std.ascii.isDigit(self.input[self.ptr])) {
            break;
        }
        result = result * 10 + (self.input[self.ptr] - '0');
    }
    return result;
}
pub fn skip(self: *LineParser, n: usize) void {
    self.ptr += n;
    if (self.ptr > self.input.len) {
        self.ptr = self.input.len;
    }
}
pub fn finished(self: *LineParser) bool {
    return self.ptr >= self.input.len;
}
