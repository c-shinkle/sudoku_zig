const std = @import("std");
const ArrayList = std.ArrayList;
const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator;
const getStdOut = std.io.getStdOut;

const Board = @import("./board.zig").Board;

pub fn main() !void {
    const stdout = getStdOut().writer();
    var gpa = GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var board = Board.init();
    try Board.setBoardByFile(&board, allocator, "./res/board.txt");

    var list = try board.printBoard(allocator);
    defer list.deinit();

    try stdout.print("{s}", .{list.items});
}
