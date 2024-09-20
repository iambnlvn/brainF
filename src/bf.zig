const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
pub const Op = union(enum) {
    add: i8,
    move: i32,
    jiz: u32,
    jbinz: u32,
    read,
    write,
};

const tapeSize = 4 * 1024 * 1024;
const tape = [tapeSize]u8;

pub fn parse(allocator: *Allocator, code: []const u8) !ArrayList(Op) {
    var ops = ArrayList(Op).init(allocator);
    for (code) |c| {
        const opt: ?Op = switch (c) {
            '+' => Op{ .add = 1 },
            '-' => Op{ .add = -1 },
            '<' => Op{ .move = -1 },
            '>' => Op{ .move = 1 },
            '[' => Op{ .jiz = 0xDEADBEEF },
            ']' => Op{ .jbinz = 0xDEADBEEF },
            '.' => Op.write,
            ',' => Op.read,
            else => null,
        };

        if (opt) |o| {
            try ops.append(o);
        }
    }
    return ops;
}
