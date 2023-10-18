const std = @import("std");
const ArrayList = std.ArrayList;
const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator;
const getStdOut = std.io.getStdOut;

const recursiveCombo = @import("./algorithm.zig").recursiveCombo;

const Board = @import("./board.zig").Board;

pub fn main() !void {
    const stdout = getStdOut().writer();
    var gpa = GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var board = Board.init();
    try Board.setBoardByFile(&board, allocator, "./res/board.txt");
    var before = try board.printBoard(allocator);
    defer before.deinit();
    try stdout.print("Before\n{s}", .{before.items});

    if (!recursiveCombo(&board)) {
        try stdout.print("Failed to solve board!\n", .{});
        return;
    }

    var after = try board.printBoard(allocator);
    defer after.deinit();
    try stdout.print("After\n{s}", .{after.items});
}
