const std = @import("std");

const REPL = @import("./repl.zig").Repl();

pub fn main() !void {
    std.debug.print("Monkey Language!\n", .{});

    const repl = REPL.init();

    try repl.run();
}

comptime {
    _ = @import("lexer.zig");
    _ = @import("token.zig");
}
