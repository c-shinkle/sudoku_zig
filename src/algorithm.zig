const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const Board = @import("./Board.zig");
const Cell = Board.Cell;
const SIZE = Board.SIZE;
const History = Board.History;

pub fn recursiveCombo(board: *Board) bool {
    board.setAllPoss();
    const solvedBoard = helper(board) orelse return false;
    board.* = solvedBoard;
    return true;
}

fn helper(board: *Board) ?Board {
    const row, const col = board.findFewestPoss() orelse return board.*;
    for (0..SIZE) |i| {
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

pub fn interativeCombo(originalBoard: *Board, allocator: Allocator) !bool {
    originalBoard.setAllPoss();
    var historyStack = ArrayList(History).init(allocator);
    while (originalBoard.findFewestPossCount()) |rowColCount| {
        const count, const row, const col = rowColCount;
        if (count == 0) {
            const previous: History = historyStack.pop() orelse return false;
            originalBoard.* = previous.board;
            originalBoard.grid[previous.row][previous.col].poss[previous.guess - 1] = false;
        } else {
            for (0..SIZE) |i| {
                if (!originalBoard.grid[row][col].poss[i]) continue;

                const guess = @as(u8, @truncate(i)) + 1;
                const newHistory = History{
                    .board = originalBoard.*,
                    .guess = guess,
                    .row = row,
                    .col = col,
                };
                try historyStack.append(newHistory);
                originalBoard.grid[row][col].val = guess;
                originalBoard.updateAffectedPoss(row, col, guess);
            }
        }
    }
    return true;
}
