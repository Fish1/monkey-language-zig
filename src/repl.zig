const std = @import("std");

pub fn Repl() type {
    return struct {
        pub fn init() @This() {
            return .{};
        }

        pub fn run(_: @This()) !void {
            var stdin_buffer: [1024]u8 = undefined;
            var stdin = std.fs.File.stdin().reader(&stdin_buffer);

            var line_buffer: [1024]u8 = undefined;
            var writer: std.io.Writer = .fixed(&line_buffer);

            const len = try stdin.interface.streamDelimiterLimit(&writer, '\n', .unlimited);

            const line = line_buffer[0..len];

            std.debug.print("line = {s}\n", .{line});
        }
    };
}
