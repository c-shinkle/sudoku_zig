const std = @import("std");
const fs = std.fs;
const cwd = fs.cwd;
const OpenMode = fs.File.OpenMode;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const BOARD_SIZE: u32 = 9;

const Cell = struct {
    val: u8,
    poss: [BOARD_SIZE]bool,
};

const Board = struct {
    grid: [BOARD_SIZE][BOARD_SIZE]Cell,
};

pub fn init() Board {
    const cell = Cell{
        .val = 0,
        .poss = .{true} ** BOARD_SIZE,
    };

    return Board{ .grid = .{.{cell} ** BOARD_SIZE} ** BOARD_SIZE };
}

pub fn printBoard(allocator: Allocator, board: Board) !ArrayList(u8) {
    var chars = ArrayList(u8).init(allocator);

    try addIthRow(board.grid[0], &chars);
    try addIthRow(board.grid[1], &chars);
    try addIthRow(board.grid[2], &chars);

    try chars.appendSlice("---+---+---\n");

    try addIthRow(board.grid[3], &chars);
    try addIthRow(board.grid[4], &chars);
    try addIthRow(board.grid[5], &chars);

    try chars.appendSlice("---+---+---\n");

    try addIthRow(board.grid[6], &chars);
    try addIthRow(board.grid[7], &chars);
    try addIthRow(board.grid[8], &chars);

    return chars;
}

fn addIthRow(row: [BOARD_SIZE]Cell, chars: *ArrayList(u8)) !void {
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

pub fn setBoardByString(board: *Board, values: []const u8) void {
    var iter = CharIterator{ .string = values };
    for (0..BOARD_SIZE) |row| {
        for (0..BOARD_SIZE) |col| {
            const val = iter.next() orelse @panic("Should be exactly 81 chars in string slice.");
            board.grid[row][col].val = val - '0';
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

pub fn setBoardByFile(board: *Board, allocator: Allocator, path: []const u8) !void {
    var file = try cwd().openFile(path, .{ .mode = OpenMode.read_only });
    defer file.close();
    var values = ArrayList(u8).init(allocator);
    defer values.deinit();

    var reader = file.reader();

    while (try reader.readUntilDelimiterOrEofAlloc(allocator, '\n', 10)) |line| {
        if (@import("builtin").os.tag == .windows) {
            line = std.mem.trimRight(u8, line, "\r");
        }
        try values.appendSlice(line);
    }
    setBoardByString(board, values.items);
}
