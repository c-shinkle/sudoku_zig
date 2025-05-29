const std = @import("std");
const algorithm = @import("./algorithm.zig");
const Board = @import("./Board.zig");

pub fn main() !void {
    // std.debug.print("History\nsize: {d}\nalign: {d}\n", .{
    //     @sizeOf(Board.History),
    //     @alignOf(Board.History),
    // });
    // std.debug.print("Cell\nsize: {d}\nalign: {d}\n", .{ @sizeOf(Board.Cell), @alignOf(Board.Cell) });
    const stdout = std.io.getStdOut().writer();
    var board = Board.init();
    try board.setBoardByFile("./res/board.txt");

    var buffer: [132]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const alloc = fba.allocator();
    var chars = try std.ArrayListUnmanaged(u8).initCapacity(alloc, 132);

    board.printBoard(&chars);
    try stdout.print("Before\n{s}", .{chars.items});

    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();
    // if (!algorithm.recursiveCombo(&board)) {
    if (!algorithm.interativeCombo(&board, allocator)) {
        try stdout.print("Failed to solve board!\n", .{});
        return;
    }

    chars.clearRetainingCapacity();
    board.printBoard(&chars);
    try stdout.print("After\n{s}", .{chars.items});
}
