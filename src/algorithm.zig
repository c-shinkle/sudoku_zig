const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const Board = @import("./Board.zig");

pub fn recursiveCombo(board: *Board) bool {
    board.setAllPoss();
    const solvedBoard = helper(board) orelse return false;
    board.* = solvedBoard;
    return true;
}

fn helper(board: *Board) ?Board {
    const row, const col = board.findFewestPoss() orelse return board.*;
    for (0..Board.SIZE) |i| {
        if (board.grid[row][col].possibilities[i]) {
            var copiedBoard = board.*;
            const guess: Board.BaseIntFit = @truncate(i + 1);
            copiedBoard.grid[row][col].value = guess;
            copiedBoard.updateAffectedPoss(row, col, guess);
            if (helper(&copiedBoard)) |solution| {
                return solution;
            }
        }
    }
    return null;
}

pub fn interativeCombo(originalBoard: *Board, allocator: Allocator) bool {
    originalBoard.setAllPoss();
    var historyStack = ArrayList(Board.History).init(allocator);
    while (originalBoard.findFewestPossCount()) |rowColCount| {
        const count, const row, const col = rowColCount;
        if (count == 0) {
            const previous = historyStack.pop() orelse return false;
            originalBoard.* = previous.board;
            originalBoard.grid[previous.row][previous.col].possibilities.unset(previous.guess - 1);
        } else {
            for (0..Board.SIZE) |i| {
                if (!originalBoard.grid[row][col].possibilities.isSet(i)) continue;

                const guess: Board.BaseIntFit = @truncate(i + 1);
                const new_history = Board.History{
                    .board = originalBoard.*,
                    .guess = guess,
                    .row = row,
                    .col = col,
                };
                historyStack.append(new_history) catch unreachable;
                originalBoard.grid[row][col].value = guess;
                originalBoard.updateAffectedPoss(row, col, guess);
            }
        }
    }
    return true;
}
