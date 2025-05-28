const std = @import("std");
const ArrayList = std.ArrayList;
const DebugAllocator = std.heap.DebugAllocator;
const getStdOut = std.io.getStdOut;
const algorithm = @import("./algorithm.zig");
const Board = @import("./Board.zig");

pub fn main() !void {
    const stdout = getStdOut().writer();
    var board = Board.init();
    try board.setBoardByFile("./res/board.txt");

    var buffer: [132]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    var chars = ArrayList(u8).initCapacity(fba.allocator(), 132) catch unreachable;

    const before = board.printBoard(&chars) catch unreachable;
    try stdout.print("Before\n{s}", .{before});

    var gpa = DebugAllocator(.{}){};
    const allocator = gpa.allocator();
    // if (!algorithm.recursiveCombo(&board)) {
    if (!try algorithm.interativeCombo(&board, allocator)) {
        try stdout.print("Failed to solve board!\n", .{});
        return;
    }

    fba.reset();
    chars = ArrayList(u8).initCapacity(fba.allocator(), 132) catch unreachable;
    const after = try board.printBoard(&chars);
    try stdout.print("After\n{s}", .{after});
}
