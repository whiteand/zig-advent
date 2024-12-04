const std = @import("std");
const time = std.time;

fn printTiming(ns: f64) void {
    var buf: [53]u8 = undefined;
    if (ns < 1000) {
        const formatted_ns = std.fmt.formatFloat(buf[0..], ns, .{ .precision = 3, .mode = .decimal }) catch unreachable;
        std.debug.print("{s} ns/op\n", .{formatted_ns});
        return;
    }

    const us = ns / 1000;
    if (us < 1000) {
        const formatted_us = std.fmt.formatFloat(buf[0..], us, .{ .precision = 3, .mode = .decimal }) catch unreachable;
        std.debug.print("{s} µs/op\n", .{formatted_us});
        return;
    }

    const ms = us / 1000;
    if (ms < 1000) {
        const formatted_ms = std.fmt.formatFloat(buf[0..], ms, .{ .precision = 3, .mode = .decimal }) catch unreachable;
        std.debug.print("{s} ms/op\n", .{formatted_ms});
        return;
    }

    const s = ms / 1000;
    if (s < 1000) {
        const formatted_s = std.fmt.formatFloat(buf[0..], s, .{ .precision = 3, .mode = .decimal }) catch unreachable;
        std.debug.print("{s} s/op\n", .{formatted_s});
        return;
    }
}

const bench_cap = time.ns_per_s / 5;

// run the function for min(100000 loops, ~0.2 seconds) or at least once, whichever is longer
pub fn bench(comptime name: []const u8, F: fn (allocator: std.mem.Allocator) void, allocator: std.mem.Allocator) !void {
    var timer = try time.Timer.start();

    var loops: usize = 0;
    while (timer.read() < bench_cap) : (loops += 1) {
        // this would either take a void function (easy with local functions)
        // or comptime varargs in the general args
        _ = F(allocator);

        if (loops > 100000) {
            break;
        }
    }

    const ns: f64 = @floatFromInt(timer.lap() / loops);

    const mgn = std.math.log10(loops);
    var loop_mgn: usize = 10;
    var i: usize = 0;
    while (i < mgn) : (i += 1) {
        loop_mgn *= 10;
    }

    std.debug.print("{s}: {} loops\n   ", .{ name, loop_mgn });
    printTiming(ns);
}
