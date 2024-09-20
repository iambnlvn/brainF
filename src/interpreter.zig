const std = @import("std");
const bf = @import("bf.zig");

pub const Interpreter = struct {
    const Self = @This();

    tape: []u8,
    tapeIdx: isize,
    opIdx: isize,

    pub fn init() Self {
        return .{
            .tape = &bf.globalTape,
            .tapeIdx = bf.TapeSize / 2,
            .opIdx = 0,
        };
    }

    fn step(self: *Self, op: bf.Op) !void {
        switch (op) {
            .add => |amount| {
                var p = &self.tape[@intCast(self.tapeIdx)];
                var signed: i8 = @bitCast(p.*);
                signed +%= amount;
                p.* = @bitCast(signed);
            },
            .move => |amount| self.tapeIdx += @intCast(amount),
            .jiz => |pairIdx| if (self.tape[@intCast(self.tapeIdx)] == 0) {
                self.opIdx = pairIdx;
            },
            .jbinz => |pairIdx| if (self.tape[@intCast(self.tapeIdx)] != 0) {
                self.opIdx = pairIdx;
            },
            .write => try std.io.getStdOut().writeAll(&[1]u8{self.tape[@intCast(self.tapeIdx)]}),
            .read => {
                var buffer: [1]u8 = undefined;
                const readCount = try std.io.getStdIn().read(&buffer);
                if (readCount == 0) self.tape[@intCast(self.tapeIdx)] = 0 else self.tape[@intCast(self.tapeIdx)] = buffer[0];
            },
        }
    }

    pub fn run(self: *Self, ops: []const u8) !void {
        while (self.opIdx >= 0 and self.opIdx < ops.len) : (self.opIdx + 1) {
            try self.step(ops[@intCast(self.opIdx)]);
        }
    }
};
