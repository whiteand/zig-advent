const std = @import("std");

pub fn SliceGrid(comptime T: type) type {
    return struct {
        const Inner = []const []const T;
        const Self = @This();
        cells: Inner,
        pub fn get(self: *const Self, pos: @Vector(2, i32)) ?*const T {
            if (pos[0] < 0 or pos[0] >= self.cells.len or pos[1] < 0 or pos[1] >= self.cells[@intCast(pos[0])].len) {
                return null;
            }
            return &self.cells[@intCast(pos[0])][@intCast(pos[1])];
        }
        pub fn get_mut(self: *Self, pos: @Vector(2, i32)) ?*T {
            if (pos[0] < 0 or pos[0] >= self.len or pos[1] < 0 or pos[1] >= self[@intCast(pos[0])].len) {
                return null;
            }
            return &self[@intCast(pos[0])][@intCast(pos[1])];
        }

        pub fn to_owned(self: *const Self, allocator: std.mem.Allocator) !Grid(T) {
            var list = try std.ArrayList(std.ArrayList(T)).initCapacity(allocator, self.cells.len);
            for (0..self.cells.len) |i| {
                const row_slice = self.cells[i];
                var row = try std.ArrayList(T).initCapacity(allocator, row_slice.len);
                for (row_slice) |x| {
                    try row.append(x);
                }
                try list.append(row);
            }
            return Grid(T).init(list);
        }
        pub fn init(cells: []const []const T) SliceGrid(T) {
            return .{ .cells = cells };
        }
    };
}
pub fn Grid(comptime T: type) type {
    return struct {
        const Inner = std.ArrayList(std.ArrayList(T));
        const Self = @This();

        cells: Inner,

        pub fn get(self: *const Self, pos: @Vector(2, i32)) ?*const T {
            if (pos[0] < 0 or pos[0] >= self.cells.items.len or pos[1] < 0 or pos[1] >= self.cells.items[@intCast(pos[0])].items.len) {
                return null;
            }
            return &self.cells.items[@intCast(pos[0])].items[@intCast(pos[1])];
        }
        pub fn map(self: *const Self, comptime U: type, allocator: std.mem.Allocator, f: fn (*const T) U) !Grid(U) {
            var list = try std.ArrayList(std.ArrayList(U)).initCapacity(allocator, self.cells.items.len);
            for (0..self.cells.items.len) |i| {
                const row_slice = self.cells.items[i].items;
                var row = try std.ArrayList(U).initCapacity(allocator, row_slice.len);
                for (row_slice) |x| {
                    try row.append(f(&x));
                }
                try list.append(row);
            }
            return Grid(U).init(list);
        }
        pub fn get_mut(self: *Self, pos: @Vector(2, i32)) ?*T {
            if (pos[0] < 0) return null;
            if (pos[0] >= self.cells.items.len) return null;
            if (pos[1] < 0) return null;
            const r: usize = @intCast(pos[0]);
            if (pos[1] >= self.cells.items[r].items.len) return null;
            const c: usize = @intCast(pos[1]);
            return &self.cells.items[r].items[c];
        }
        pub fn set(self: *Self, pos: @Vector(2, i32), value: T) T {
            const prev_ptr = self.get_mut(pos).?;
            const res = prev_ptr.*;
            prev_ptr.* = value;
            return res;
        }
        pub fn init(cells: std.ArrayList(std.ArrayList(T))) Self {
            return .{ .cells = cells };
        }
        pub fn deinit(self: *Self) void {
            while (self.cells.popOrNull()) |x| {
                x.deinit();
            }
            self.cells.deinit();
        }
    };
}
