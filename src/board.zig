const std = @import("std");
const fs = std.fs;
const OpenMode = fs.File.OpenMode;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

// const cwd = fs.cwd;
pub const BOARD_SIZE: u32 = 9;

pub const History = struct { board: Board, guess: u8, row: u32, col: u32 };

const Cell = struct {
    val: u8,
    poss: [BOARD_SIZE]bool,

    fn isBlank(self: *const Cell) bool {
        return self.val == 0;
    }
};

pub const Board = struct {
    const Self = @This();
    grid: [BOARD_SIZE][BOARD_SIZE]Cell,

    pub fn init() Board {
        const cell = Cell{
            .val = 0,
            .poss = .{true} ** BOARD_SIZE,
        };

        return Board{ .grid = .{.{cell} ** BOARD_SIZE} ** BOARD_SIZE };
    }

    pub fn printBoard(self: *Self, allocator: Allocator) !std.array_list.Managed(u8) {
        var chars = std.array_list.Managed(u8).init(allocator);

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

    fn addIthRow(row: [BOARD_SIZE]Cell, chars: *std.array_list.Managed(u8)) !void {
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

    pub fn setBoardByString(self: *Self, values: []const u8) void {
        var iter = CharIterator{ .string = values };
        for (0..BOARD_SIZE) |row| {
            for (0..BOARD_SIZE) |col| {
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

    pub fn setBoardByFile(self: *Self, allocator: Allocator, sub_path: []const u8) !void {
        var file = try std.fs.cwd().openFile(sub_path, .{ .mode = .read_only });
        defer file.close();
        var values = std.array_list.Managed(u8).init(allocator);
        defer values.deinit();
        var buffer: [1024]u8 = undefined;

        var reader = file.reader(&buffer);
        while (reader.interface.takeDelimiterExclusive('\n')) |line| {
            try values.appendSlice(line);
        } else |err| switch (err) {
            error.EndOfStream => {},
            else => return err,
        }

        self.setBoardByString(values.items);
    }

    pub fn setAllPoss(self: *Self) void {
        for (0..BOARD_SIZE) |row| {
            for (0..BOARD_SIZE) |col| {
                //update row
                for (0..BOARD_SIZE) |i| {
                    var cell = self.grid[row][i];
                    if (!cell.isBlank()) {
                        self.grid[row][col].poss[cell.val - 1] = false;
                    }
                }
                //update col
                for (0..BOARD_SIZE) |i| {
                    var cell = self.grid[i][col];
                    if (!cell.isBlank()) {
                        self.grid[row][col].poss[cell.val - 1] = false;
                    }
                }
                //update box
                const box_row = row / 3;
                const box_col = col / 3;
                for (0..BOARD_SIZE) |i| {
                    const grid_row = box_row * 3 + (i / 3);
                    const grid_col = box_col * 3 + (i % 3);
                    var cell = self.grid[grid_row][grid_col];
                    if (!cell.isBlank()) {
                        self.grid[row][col].poss[cell.val - 1] = false;
                    }
                }
            }
        }
    }

    pub fn findFewestPoss(self: *Self) ?struct { u32, u32 } {
        var smallestCount: u32 = 10;
        var fewestSoFar: ?struct { usize, usize } = null;
        for (0..BOARD_SIZE) |row| {
            for (0..BOARD_SIZE) |col| {
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

    pub fn findFewestPossCount(self: *Self) ?struct { u32, u32, u32 } {
        var smallestCount: u32 = 10;
        var fewestSoFar: ?struct { u32, u32, u32 } = null;
        for (0..BOARD_SIZE) |row| {
            for (0..BOARD_SIZE) |col| {
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

    pub fn updateAffectedPoss(self: *Self, row: usize, col: usize, val: u8) void {
        //update row
        for (0..BOARD_SIZE) |i| {
            var cell = &self.grid[row][i];
            if (cell.isBlank()) {
                cell.poss[val - 1] = false;
            }
        }
        //update col
        for (0..BOARD_SIZE) |i| {
            var cell = &self.grid[i][col];
            if (cell.isBlank()) {
                cell.poss[val - 1] = false;
            }
        }
        //update box
        const box_row = row / 3;
        const box_col = col / 3;
        for (0..BOARD_SIZE) |i| {
            const grid_row = box_row * 3 + (i / 3);
            const grid_col = box_col * 3 + (i % 3);
            var cell = &self.grid[grid_row][grid_col];
            if (cell.isBlank()) {
                cell.poss[val - 1] = false;
            }
        }
    }
};
