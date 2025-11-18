const std = @import("std");

pub fn main() !void {
    std.debug.print("Monkey Language!\n", .{});
}

comptime {
    _ = @import("lexer.zig");
    _ = @import("token.zig");
}
