const std = @import("std");
const ArrayList = std.ArrayList;
const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator;
const getStdOut = std.io.getStdOut;

const printBoard = @import("./board.zig").printBoard;

pub fn main() !void {
    var gpa = GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var list = printBoard(allocator);
    defer list.deinit();

    try list.appendSlice("World!");

    const stdout = getStdOut().writer();
    try stdout.print("Hello, {s}\n", .{list.items});
}
