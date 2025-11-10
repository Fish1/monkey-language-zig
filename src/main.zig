const std = @import("std");
const lexer = @import("lexer.zig");

pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
}

comptime {
    _ = @import("lexer.zig");
    _ = @import("token.zig");
}
