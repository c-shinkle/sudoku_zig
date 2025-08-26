const std = @import("std");
const ArrayList = std.ArrayList;
const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator;

const algorithm = @import("./algorithm.zig");
const Board = @import("./board.zig").Board;

pub fn main() !void {
    var buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&buffer);
    var stdout = &stdout_writer.interface;

    var gpa = GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var board = Board.init();
    try Board.setBoardByFile(&board, allocator, "./res/board.txt");
    const before = try board.printBoard(allocator);
    defer before.deinit();
    try stdout.print("Before\n{s}", .{before.items});

    _ = try algorithm.interativeCombo(&board, allocator);

    var after = try board.printBoard(allocator);
    defer after.deinit();
    try stdout.print("After\n{s}", .{after.items});

    try stdout.flush();
}
