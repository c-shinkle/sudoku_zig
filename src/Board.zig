const std = @import("std");
const fs = std.fs;
const cwd = fs.cwd;
const OpenMode = fs.File.OpenMode;
const Allocator = std.mem.Allocator;

const Board = @This();
grid: [SIZE][SIZE]Cell,

pub const SIZE: u32 = 9;

pub const History = struct { board: Board, guess: u8, row: u8, col: u8 };

pub const Cell = struct {
    val: u8,
    poss: [SIZE]bool,

    fn isBlank(self: *const Cell) bool {
        return self.val == 0;
    }
};

pub fn init() Board {
    const cell = Cell{ .val = 0, .poss = .{true} ** SIZE };

    return Board{ .grid = ([1][SIZE]Cell{([1]Cell{cell}) ** SIZE}) ** SIZE };
}

pub fn printBoard(self: *Board, chars: *std.ArrayListUnmanaged(u8)) void {
    std.debug.assert(chars.capacity >= 132);
    addIthRow(self.grid[0], chars);
    addIthRow(self.grid[1], chars);
    addIthRow(self.grid[2], chars);

    chars.appendSliceAssumeCapacity("---+---+---\n");

    addIthRow(self.grid[3], chars);
    addIthRow(self.grid[4], chars);
    addIthRow(self.grid[5], chars);

    chars.appendSliceAssumeCapacity("---+---+---\n");

    addIthRow(self.grid[6], chars);
    addIthRow(self.grid[7], chars);
    addIthRow(self.grid[8], chars);
}

fn addIthRow(row: [SIZE]Cell, chars: *std.ArrayListUnmanaged(u8)) void {
    chars.appendAssumeCapacity(row[0].val + 48);
    chars.appendAssumeCapacity(row[1].val + 48);
    chars.appendAssumeCapacity(row[2].val + 48);

    chars.appendAssumeCapacity('|');

    chars.appendAssumeCapacity(row[3].val + 48);
    chars.appendAssumeCapacity(row[4].val + 48);
    chars.appendAssumeCapacity(row[5].val + 48);

    chars.appendAssumeCapacity('|');

    chars.appendAssumeCapacity(row[6].val + 48);
    chars.appendAssumeCapacity(row[7].val + 48);
    chars.appendAssumeCapacity(row[8].val + 48);

    chars.appendAssumeCapacity('\n');
}

pub fn setBoardByFile(self: *Board, path: []const u8) !void {
    var file_input: [90]u8 = undefined;
    const file = try std.fs.cwd().openFile(path, std.fs.File.OpenFlags{});
    const bytes_read = try file.read(&file_input);
    if (bytes_read < 90) {
        return error.FileTooShort;
    }

    var input_index: usize = 0;
    for (0..81) |output_index| {
        const char = file_input[input_index];
        std.debug.assert(std.ascii.isDigit(char));
        self.grid[output_index / SIZE][output_index % SIZE].val = char - '0';

        input_index += 1;
        if (input_index % 10 == 9) {
            std.debug.assert(file_input[input_index] == '\n');
            input_index += 1;
        }
    }
}

pub fn setAllPoss(self: *Board) void {
    for (0..SIZE) |row| {
        for (0..SIZE) |col| {
            //update row
            for (0..SIZE) |i| {
                const cell = self.grid[row][i];
                if (!cell.isBlank()) {
                    self.grid[row][col].poss[cell.val - 1] = false;
                }
            }
            //update col
            for (0..SIZE) |i| {
                const cell = self.grid[i][col];
                if (!cell.isBlank()) {
                    self.grid[row][col].poss[cell.val - 1] = false;
                }
            }
            //update box
            const box_row = row / 3;
            const box_col = col / 3;
            for (0..SIZE) |i| {
                const grid_row = box_row * 3 + (i / 3);
                const grid_col = box_col * 3 + (i % 3);
                const cell = &self.grid[grid_row][grid_col];
                if (!cell.isBlank()) {
                    self.grid[row][col].poss[cell.val - 1] = false;
                }
            }
        }
    }
}

pub fn findFewestPoss(self: *Board) ?struct { u32, u32 } {
    var smallestCount: u32 = 10;
    var fewestSoFar: ?struct { usize, usize } = null;
    for (0..SIZE) |row| {
        for (0..SIZE) |col| {
            const cell = self.grid[row][col];
            if (!cell.isBlank()) continue;

            var count: u32 = 0;
            for (cell.poss) |p| {
                count += @intFromBool(p);
            }

            if (smallestCount > count) {
                smallestCount = count;
                fewestSoFar = .{
                    @truncate(row),
                    @truncate(col),
                };
            }
        }
    }
    return fewestSoFar;
}

pub fn findFewestPossCount(self: *Board) ?struct { u4, u4, u4 } {
    var smallestCount: u4 = 10;
    var fewestSoFar: ?struct { u4, u4, u4 } = null;
    for (0..SIZE) |row| {
        for (0..SIZE) |col| {
            const cell = self.grid[row][col];
            if (cell.isBlank()) {
                var count: u4 = 0;
                for (cell.poss) |p| {
                    count += @intFromBool(p);
                }
                if (smallestCount > count) {
                    smallestCount = count;
                    fewestSoFar = .{ count, @truncate(row), @truncate(col) };
                }
            }
        }
    }
    return fewestSoFar;
}

pub fn updateAffectedPoss(self: *Board, row: usize, col: usize, val: u8) void {
    //update row
    for (0..SIZE) |i| {
        var cell = &self.grid[row][i];
        if (cell.isBlank()) {
            cell.poss[val - 1] = false;
        }
    }
    //update col
    for (0..SIZE) |i| {
        var cell = &self.grid[i][col];
        if (cell.isBlank()) {
            cell.poss[val - 1] = false;
        }
    }
    //update box
    const box_row = row / 3;
    const box_col = col / 3;
    for (0..SIZE) |i| {
        const grid_row = box_row * 3 + (i / 3);
        const grid_col = box_col * 3 + (i % 3);
        var cell = &self.grid[grid_row][grid_col];
        if (cell.isBlank()) {
            cell.poss[val - 1] = false;
        }
    }
}
