const std = @import("std");
const ArrayList = std.ArrayList;
const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator;
const getStdOut = std.io.getStdOut;

const Board = @import("./board.zig");

pub fn main() !void {
    var board = Board.init();

    for (0..9) |i| {
        for (0..9) |j| {
            board.grid[i][j].val = @truncate(j);
        }
    }

    var gpa = GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var list = try Board.printBoard(allocator, board);
    defer list.deinit();

    const stdout = getStdOut().writer();
    try stdout.print("{s}", .{list.items});
}
