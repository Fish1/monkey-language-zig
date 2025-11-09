const std = @import("std");
const monkey_language = @import("monkey_language");

pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    try monkey_language.bufferedPrint();
}
