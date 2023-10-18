const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const boardModule = @import("./board.zig");
const Cell = boardModule.Cell;
const Board = boardModule.Board;
const BOARD_SIZE = boardModule.BOARD_SIZE;
const History = boardModule.History;

pub fn recursiveCombo(board: *Board) bool {
    board.setAllPoss();
    const solvedBoard = helper(board) orelse return false;
    board.* = solvedBoard;
    return true;
}

fn helper(board: *Board) ?Board {
    const rowCol = board.findFewestPoss() orelse return board.*;
    const row = rowCol[0];
    const col = rowCol[1];
    for (0..BOARD_SIZE) |i| {
        if (board.grid[row][col].poss[i]) {
            var copiedBoard = board.*;
            const guess: u8 = @as(u8, @truncate(i)) + 1;
            copiedBoard.grid[row][col].val = guess;
            copiedBoard.updateAffectedPoss(row, col, guess);
            if (helper(&copiedBoard)) |solution| {
                return solution;
            }
        }
    }
    return null;
}

pub fn interativeCombo(board: *Board, allocator: Allocator) !bool {
    board.setAllPoss();
    var historyBoard = ArrayList(History).init(allocator);
    while (board.findFewestPossCount()) |rowColCount| {
        const count = rowColCount[2];
        if (count == 0) {
            const history = historyBoard.popOrNull() orelse return false;
            board.* = history.board;
            board.grid[history.row][history.col].poss[history.guess - 1] = false;
        } else {
            const row = rowColCount[0];
            const col = rowColCount[1];
            if (position(&board.grid[row][col].poss)) |i| {
                const guess = i + 1;
                const newHistory = History{
                    .board = board.*,
                    .guess = guess,
                    .row = row,
                    .col = col,
                };
                try historyBoard.append(newHistory);
                board.grid[row][col].val = guess;
                board.updateAffectedPoss(row, col, guess);
            }
        }
    }
    return true;
}

fn position(poss: *const [BOARD_SIZE]bool) ?u8 {
    inline for (poss, 0..) |p, i| {
        if (p) {
            return @truncate(i);
        }
    }
    return null;
}
