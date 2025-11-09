const std = @import("std");
const Token = @import("./token.zig").Token;
const TokenIdentifier = @import("./token.zig").TokenIdentifier;

pub fn Lexer() type {
    return struct {
        input: []const u8,
        position: usize,
        readPosition: usize,
        ch: u8,

        pub fn init(input: []const u8) @This() {
            var lexer = @This(){
                .input = input,
                .position = 0,
                .readPosition = 0,
                .ch = 0,
            };

            lexer.readChar();

            return lexer;
        }

        pub fn nextToken(self: *@This()) Token() {
            const token = switch (self.ch) {
                '=' => Token().init(TokenIdentifier.ASSIGN, "="),
                '+' => Token().init(TokenIdentifier.PLUS, "+"),
                '(' => Token().init(TokenIdentifier.LPAREN, "("),
                ')' => Token().init(TokenIdentifier.RPAREN, ")"),
                '{' => Token().init(TokenIdentifier.LBRACE, "{"),
                '}' => Token().init(TokenIdentifier.RBRACE, "}"),
                ',' => Token().init(TokenIdentifier.COMMA, ","),
                ';' => Token().init(TokenIdentifier.SEMICOLON, ";"),
                else => Token().init(TokenIdentifier.ILLEGAL, &[_]u8{self.ch}),
            };
            self.readChar();
            return token;
        }

        fn readChar(self: *@This()) void {
            if (self.readPosition >= self.input.len) {
                self.ch = 0;
            } else {
                self.ch = self.input[self.readPosition];
            }
            self.position = self.readPosition;
            self.readPosition = self.readPosition + 1;
        }
    };
}

test "next token" {
    const input = "=+(){},;";
    const expectedTokens = [_]Token(){
        Token().init(TokenIdentifier.ASSIGN, &[_]u8{'='}),
        Token().init(TokenIdentifier.PLUS, "+"),
        Token().init(TokenIdentifier.LPAREN, "("),
        Token().init(TokenIdentifier.RPAREN, ")"),
        Token().init(TokenIdentifier.LBRACE, "{"),
        Token().init(TokenIdentifier.RBRACE, "}"),
        Token().init(TokenIdentifier.COMMA, ","),
        Token().init(TokenIdentifier.SEMICOLON, ";"),
    };

    var lexer = Lexer().init(input);
    for (expectedTokens) |e| {
        const t = lexer.nextToken();
        try std.testing.expectEqual(e.identifier, t.identifier);
        std.debug.print("e = {any} t = {any}\n", .{ e, t });
        try std.testing.expect(std.mem.eql(u8, e.literal, t.literal));
        // try std.testing.expectEqual(e.literal, t.literal);
    }
}
