const std = @import("std");
const ArrayList = std.ArrayList;
const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator;
const getStdOut = std.io.getStdOut;

const Board = @import("./board.zig");

pub fn main() !void {
    const stdout = getStdOut().writer();
    var board = Board.init();

    const values = "123456789" ** 9;

    Board.set_board_string(&board, values);

    var gpa = GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var list = try Board.printBoard(allocator, board);
    defer list.deinit();

    try stdout.print("{s}", .{list.items});
}
