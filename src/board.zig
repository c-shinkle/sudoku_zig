const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const Cell = struct {
    value: u8,
    possibilities: []bool,
};

const Board = struct {
    grid: [][]Cell,
};

pub fn printBoard(allocator: Allocator) ArrayList(u8) {
    return ArrayList(u8).init(allocator);
}
