const std = @import("std");
const Lexer = @import("./lexer.zig").Lexer();

pub fn Repl() type {
    return struct {
        prompt: []const u8,

        pub fn init(prompt: []const u8) @This() {
            return .{
                .prompt = prompt,
            };
        }

        pub fn run(self: @This()) !void {
            var stdout_buffer: [1024]u8 = undefined;
            var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
            const stdout = &stdout_writer.interface;

            while (true) {
                try stdout.print("{s} ", .{self.prompt});
                try stdout.flush();

                var stdin_buffer: [1024]u8 = undefined;
                var stdin = std.fs.File.stdin().reader(&stdin_buffer);
                var line_buffer: [1024]u8 = undefined;
                var writer: std.io.Writer = .fixed(&line_buffer);

                const len = try stdin.interface.streamDelimiterLimit(&writer, '\n', .unlimited);

                const line = line_buffer[0..len];

                var lexer = Lexer.init(line);

                while (true) {
                    const token = lexer.nextToken() catch {
                        break;
                    };

                    if (token.identifier == .EOF or token.identifier == .ILLEGAL) {
                        break;
                    }
                    std.debug.print("{any}\n", .{token});
                }
            }
        }
    };
}
