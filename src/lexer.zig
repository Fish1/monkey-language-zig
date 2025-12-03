const Token = @import("./token.zig").Token;
const TokenIdentifier = @import("./token.zig").TokenIdentifier;
const IdentLookup = @import("./token.zig").IdentLookup;
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
            const allocator = @import("std").heap.page_allocator;
            var il = try IdentLookup().init(allocator);
            defer il.deinit();
            self.skipWhitespace();
            const token = switch (self.ch) {
                '=' => {
                    if (self.peekChar()) |c| {
                        if (c == '=') {
                            self.readChar();
                            self.readChar();
                            return Token().init(TokenIdentifier.EQ, "==");
                        }
                    }
                    self.readChar();
                    return Token().init(TokenIdentifier.ASSIGN, "=");
                },
                '+' => Token().init(TokenIdentifier.PLUS, "+"),
                '-' => Token().init(TokenIdentifier.MINUS, "-"),
                '*' => Token().init(TokenIdentifier.ASTERISK, "*"),
                '/' => Token().init(TokenIdentifier.SLASH, "/"),
                '!' => {
                    if (self.peekChar()) |c| {
                        if (c == '=') {
                            self.readChar();
                            self.readChar();
                            return Token().init(TokenIdentifier.NOT_EQ, "!=");
                        }
                    }
                    self.readChar();
                    return Token().init(TokenIdentifier.BANG, "!");
                },
                '<' => Token().init(TokenIdentifier.LT, "<"),
                '>' => Token().init(TokenIdentifier.GT, ">"),
                '(' => Token().init(TokenIdentifier.LPAREN, "("),
                ')' => Token().init(TokenIdentifier.RPAREN, ")"),
                '{' => Token().init(TokenIdentifier.LBRACE, "{"),
                '}' => Token().init(TokenIdentifier.RBRACE, "}"),
                ',' => Token().init(TokenIdentifier.COMMA, ","),
                ';' => Token().init(TokenIdentifier.SEMICOLON, ";"),
                else => {
                    if (self.isLetter(self.ch)) {
                        const literal = self.readIdentifier();
                        if (il.lookup(literal)) |t| {
                            return Token().init(t, literal);
                        }
                        return Token().init(TokenIdentifier.IDENT, literal);
                    } else if (self.isNumber(self.ch)) {
                        const literal = self.readNumber();
                        return Token().init(TokenIdentifier.INT, literal);
                    } else {
                        return Token().init(TokenIdentifier.ILLEGAL, &[1]u8{self.ch});
                    }
                },
            };
            self.readChar();
            return token;
        }

        fn skipWhitespace(self: *@This()) void {
            while (self.ch == ' ' or self.ch == '\t' or self.ch == '\n' or self.ch == '\r') {
                self.readChar();
            }
        }

        fn peekChar(self: @This()) ?u8 {
            if (self.readPosition >= self.input.len) {
                return null;
            }
            const out = self.input[self.readPosition];
            return out;
        }

        fn prevChar(self: @This()) u8 {
            if (self.readPosition == 0) {
                return 0;
            }
            const out = self.input[self.readPosition - 1];
            return out;
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
            while (self.isLetter(self.ch)) {
                self.readChar();
            }
            const end = self.position;
            return self.input[start..end];
        }

        fn readNumber(self: *@This()) []const u8 {
            const start = self.position;
            while (self.isNumber(self.ch)) {
                self.readChar();
            }
            const end = self.position;
            return self.input[start..end];
        }

        fn isLetter(_: @This(), c: u8) bool {
            return ascii.isAlphabetic(c) or c == '_';
        }

        fn isNumber(_: @This(), c: u8) bool {
            return ascii.isDigit(c);
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
        \\ let result = add(file, ten);
        \\ !-/*5;
        \\ 5 < 10 > 5;
        \\ if (5 < 10) {
        \\  return true;
        \\ } else {
        \\  return false;
        \\ }
        \\ 10 == 10;
        \\ 10 != 9;
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
        Token().init(TokenIdentifier.LET, "let"),
        Token().init(TokenIdentifier.IDENT, "result"),
        Token().init(TokenIdentifier.ASSIGN, "="),
        Token().init(TokenIdentifier.IDENT, "add"),
        Token().init(TokenIdentifier.LPAREN, "("),
        Token().init(TokenIdentifier.IDENT, "file"),
        Token().init(TokenIdentifier.COMMA, ","),
        Token().init(TokenIdentifier.IDENT, "ten"),
        Token().init(TokenIdentifier.RPAREN, ")"),
        Token().init(TokenIdentifier.SEMICOLON, ";"),
        Token().init(TokenIdentifier.BANG, "!"),
        Token().init(TokenIdentifier.MINUS, "-"),
        Token().init(TokenIdentifier.SLASH, "/"),
        Token().init(TokenIdentifier.ASTERISK, "*"),
        Token().init(TokenIdentifier.INT, "5"),
        Token().init(TokenIdentifier.SEMICOLON, ";"),
        Token().init(TokenIdentifier.INT, "5"),
        Token().init(TokenIdentifier.LT, "<"),
        Token().init(TokenIdentifier.INT, "10"),
        Token().init(TokenIdentifier.GT, ">"),
        Token().init(TokenIdentifier.INT, "5"),
        Token().init(TokenIdentifier.SEMICOLON, ";"),
        Token().init(TokenIdentifier.IF, "if"),
        Token().init(TokenIdentifier.LPAREN, "("),
        Token().init(TokenIdentifier.INT, "5"),
        Token().init(TokenIdentifier.LT, "<"),
        Token().init(TokenIdentifier.INT, "10"),
        Token().init(TokenIdentifier.RPAREN, ")"),
        Token().init(TokenIdentifier.LBRACE, "{"),
        Token().init(TokenIdentifier.RETURN, "return"),
        Token().init(TokenIdentifier.TRUE, "true"),
        Token().init(TokenIdentifier.SEMICOLON, ";"),
        Token().init(TokenIdentifier.RBRACE, "}"),
        Token().init(TokenIdentifier.ELSE, "else"),
        Token().init(TokenIdentifier.LBRACE, "{"),
        Token().init(TokenIdentifier.RETURN, "return"),
        Token().init(TokenIdentifier.FALSE, "false"),
        Token().init(TokenIdentifier.SEMICOLON, ";"),
        Token().init(TokenIdentifier.RBRACE, "}"),
        Token().init(TokenIdentifier.INT, "10"),
        Token().init(TokenIdentifier.EQ, "=="),
        Token().init(TokenIdentifier.INT, "10"),
        Token().init(TokenIdentifier.SEMICOLON, ";"),
        Token().init(TokenIdentifier.INT, "10"),
        Token().init(TokenIdentifier.NOT_EQ, "!="),
        Token().init(TokenIdentifier.INT, "9"),
        Token().init(TokenIdentifier.SEMICOLON, ";"),
    };

    var lexer = Lexer().init(input);
    for (expectedTokens) |e| {
        const t = try lexer.nextToken();
        try testing.expectEqual(e.identifier, t.identifier);
        try testing.expect(mem.eql(u8, e.literal, t.literal));
    }
}
