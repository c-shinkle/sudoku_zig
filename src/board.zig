const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const Cell = struct {
    val: u8,
    poss: [9]bool,
};

const Board = struct {
    grid: [9][9]Cell,
};

pub fn init() Board {
    const cell = Cell {
        .val = 0,
        .poss = [9]bool{true, true, true, true, true, true, true, true, true},
    };
    var board = Board {
        .grid = undefined
    };
    var i: u8 = 0;
    while (i < 9) {
        var j: u8 = 0;
        while (j < 9) {
            board.grid[i][j] = cell;
            j += 1;
        }
        i += 1;
    }

    return board;
}

pub fn printBoard(allocator: Allocator, board: Board) !ArrayList(u8) {
    var chars = ArrayList(u8).init(allocator);

    try addIthRow(board.grid[0], &chars);
    try addIthRow(board.grid[1], &chars);
    try addIthRow(board.grid[2], &chars);

    try chars.appendSlice("--- --- ---\n");

    try addIthRow(board.grid[3], &chars);
    try addIthRow(board.grid[4], &chars);
    try addIthRow(board.grid[5], &chars);

    try chars.appendSlice("--- --- ---\n");
    
    try addIthRow(board.grid[6], &chars);
    try addIthRow(board.grid[7], &chars);
    try addIthRow(board.grid[8], &chars);

    return chars;
}

fn addIthRow(row: [9]Cell, chars: *ArrayList(u8)) !void {
    try chars.append(row[0].val + 48);
    try chars.append(row[1].val + 48);
    try chars.append(row[2].val + 48);

    try chars.append('|');

    try chars.append(row[3].val + 48);
    try chars.append(row[4].val + 48);
    try chars.append(row[5].val + 48);
 
    try chars.append('|');
     
    try chars.append(row[6].val + 48);
    try chars.append(row[7].val + 48);
    try chars.append(row[8].val + 48);

    try chars.append('\n');
}