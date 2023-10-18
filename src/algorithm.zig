const boardModule = @import("./board.zig");
const Board = boardModule.Board;
const BOARD_SIZE = boardModule.BOARD_SIZE;

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
            const maybeSolution = helper(&copiedBoard);
            if (maybeSolution != null) {
                return maybeSolution;
            }
        }
    }
    return null;
}
