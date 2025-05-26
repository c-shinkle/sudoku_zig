const std = @import("std");
const fs = std.fs;
const cwd = fs.cwd;
const OpenMode = fs.File.OpenMode;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const Board = @This();
grid: [SIZE][SIZE]Cell,

pub const SIZE: u32 = 9;

pub const History = struct { board: Board, guess: u8, row: u32, col: u32 };

const Cell = struct {
    val: u8,
    poss: [SIZE]bool,

    fn isBlank(self: *const Cell) bool {
        return self.val == 0;
    }
};

pub fn init() Board {
    const cell = Cell{
        .val = 0,
        .poss = .{true} ** SIZE,
    };

    return Board{ .grid = ([1][SIZE]Cell{([1]Cell{cell}) ** SIZE}) ** SIZE };
}

pub fn printBoard(self: *Board, allocator: Allocator) !ArrayList(u8) {
    var chars = ArrayList(u8).init(allocator);

    try addIthRow(self.grid[0], &chars);
    try addIthRow(self.grid[1], &chars);
    try addIthRow(self.grid[2], &chars);

    try chars.appendSlice("---+---+---\n");

    try addIthRow(self.grid[3], &chars);
    try addIthRow(self.grid[4], &chars);
    try addIthRow(self.grid[5], &chars);

    try chars.appendSlice("---+---+---\n");

    try addIthRow(self.grid[6], &chars);
    try addIthRow(self.grid[7], &chars);
    try addIthRow(self.grid[8], &chars);

    return chars;
}

fn addIthRow(row: [SIZE]Cell, chars: *ArrayList(u8)) !void {
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

pub fn setBoardByString(self: *Board, values: []const u8) void {
    var iter = CharIterator{ .string = values };
    for (0..SIZE) |row| {
        for (0..SIZE) |col| {
            const val = iter.next() orelse @panic("Should be exactly 81 chars in string slice.");
            self.grid[row][col].val = val - '0';
        }
    }
}

const CharIterator = struct {
    string: []const u8,
    index: u32 = 0,
    fn next(self: *CharIterator) ?u8 {
        if (self.index >= self.string.len) {
            return null;
        }
        self.index += 1;
        return self.string[self.index - 1];
    }
};

pub fn setBoardByFile(self: *Board, _: Allocator, path: []const u8) !void {
    var file_input: [90]u8 = undefined;
    const file = try std.fs.cwd().openFile(path, std.fs.File.OpenFlags{});
    const bytes_read = try file.read(&file_input);
    if (bytes_read < 90) {
        return error.FileTooShort;
    }

    var values: [81]u8 = undefined;
    var input_index: usize = 0;
    for (0..81) |output_index| {
        const char = file_input[input_index];
        std.debug.assert(std.ascii.isDigit(char));
        values[output_index] = char - 48;
        input_index += 1;
        if (input_index % 10 == 9) {
            std.debug.assert(file_input[input_index] == '\n');
            input_index += 1;
        }
    }

    self.setBoardByString(&values);
}

pub fn setAllPoss(self: *Board) void {
    for (0..SIZE) |row| {
        for (0..SIZE) |col| {
            //update row
            for (0..SIZE) |i| {
                var cell = self.grid[row][i];
                if (!cell.isBlank()) {
                    self.grid[row][col].poss[cell.val - 1] = false;
                }
            }
            //update col
            for (0..SIZE) |i| {
                var cell = self.grid[i][col];
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
                var cell = &self.grid[grid_row][grid_col];
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
            if (cell.isBlank()) {
                var count: u32 = 0;
                inline for (cell.poss) |p| count += @intFromBool(p);
                if (smallestCount > count) {
                    smallestCount = count;
                    fewestSoFar = .{
                        @truncate(row),
                        @truncate(col),
                    };
                }
            }
        }
    }
    return fewestSoFar;
}

pub fn findFewestPossCount(self: *Board) ?struct { u32, u32, u32 } {
    var smallestCount: u32 = 10;
    var fewestSoFar: ?struct { u32, u32, u32 } = null;
    for (0..SIZE) |row| {
        for (0..SIZE) |col| {
            const cell = self.grid[row][col];
            if (cell.isBlank()) {
                var count: u32 = 0;
                inline for (cell.poss) |p| count += @intFromBool(p);
                if (count == 0) {
                    return .{ 0, @truncate(row), @truncate(col) };
                } else if (smallestCount > count) {
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
