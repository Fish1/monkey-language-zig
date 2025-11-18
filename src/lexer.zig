const Token = @import("./token.zig").Token;
const TokenIdentifier = @import("./token.zig").TokenIdentifier;
const IdentLookup = @import("./token.zig").IdentLookup();
const ascii = @import("std").ascii;

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

        pub fn nextToken(self: *@This()) !Token() {
            const allocator = @import("std").testing.allocator;
            var il = try IdentLookup.init(allocator);
            defer il.deinit();
            const token = switch (self.ch) {
                '=' => Token().init(TokenIdentifier.ASSIGN, "="),
                '+' => Token().init(TokenIdentifier.PLUS, "+"),
                '(' => Token().init(TokenIdentifier.LPAREN, "("),
                ')' => Token().init(TokenIdentifier.RPAREN, ")"),
                '{' => Token().init(TokenIdentifier.LBRACE, "{"),
                '}' => Token().init(TokenIdentifier.RBRACE, "}"),
                ',' => Token().init(TokenIdentifier.COMMA, ","),
                ';' => Token().init(TokenIdentifier.SEMICOLON, ";"),
                else => {
                    if (ascii.isAlphabetic(self.ch)) {
                        return Token().init(TokenIdentifier.IDENT, self.readIdentifier());
                    } else {
                        return Token().init(TokenIdentifier.ILLEGAL, &[1]u8{self.ch});
                    }
                },
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

        fn readIdentifier(self: *@This()) []const u8 {
            const start = self.position;
            while (ascii.isAlphabetic(self.ch)) {
                self.readChar();
            }
            const end = self.position;
            return self.input[start..end];
        }
    };
}

test "next token" {
    const testing = @import("std").testing;
    const mem = @import("std").mem;
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
        const t = try lexer.nextToken();
        try testing.expectEqual(e.identifier, t.identifier);
        try testing.expect(mem.eql(u8, e.literal, t.literal));
    }
}

test "real code" {
    const testing = @import("std").testing;
    const mem = @import("std").mem;

    const input =
        \\ let five = 5;
        \\ let ten = 10;
        \\ let add = fn(x, y) {
        \\  x + y;
        \\ };
    ;

    const expectedTokens = [_]Token(){
        Token().init(TokenIdentifier.LET, "let"),
        Token().init(TokenIdentifier.IDENT, "five"),
        Token().init(TokenIdentifier.ASSIGN, "="),
        Token().init(TokenIdentifier.INT, "5"),
        Token().init(TokenIdentifier.SEMICOLON, ";"),
        Token().init(TokenIdentifier.LET, "let"),
        Token().init(TokenIdentifier.IDENT, "ten"),
        Token().init(TokenIdentifier.ASSIGN, "="),
        Token().init(TokenIdentifier.INT, "10"),
        Token().init(TokenIdentifier.SEMICOLON, ";"),
        Token().init(TokenIdentifier.LET, "let"),
        Token().init(TokenIdentifier.IDENT, "add"),
        Token().init(TokenIdentifier.ASSIGN, "="),
        Token().init(TokenIdentifier.FUNCTION, "fn"),
        Token().init(TokenIdentifier.LPAREN, "("),
        Token().init(TokenIdentifier.IDENT, "x"),
        Token().init(TokenIdentifier.COMMA, ","),
        Token().init(TokenIdentifier.IDENT, "y"),
        Token().init(TokenIdentifier.RPAREN, ")"),
        Token().init(TokenIdentifier.LBRACE, "{"),
        Token().init(TokenIdentifier.IDENT, "x"),
        Token().init(TokenIdentifier.PLUS, "+"),
        Token().init(TokenIdentifier.IDENT, "y"),
        Token().init(TokenIdentifier.SEMICOLON, ";"),
        Token().init(TokenIdentifier.RBRACE, "}"),
        Token().init(TokenIdentifier.SEMICOLON, ";"),
    };

    var lexer = Lexer().init(input);
    for (expectedTokens) |e| {
        const t = try lexer.nextToken();
        try testing.expectEqual(e.identifier, t.identifier);
        try testing.expect(mem.eql(u8, e.literal, t.literal));
    }
}
