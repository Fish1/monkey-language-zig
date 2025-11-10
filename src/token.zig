pub fn Token() type {
    return struct {
        identifier: TokenIdentifier,
        literal: []const u8,

        pub fn init(identifier: TokenIdentifier, literal: []const u8) @This() {
            return .{
                .identifier = identifier,
                .literal = literal,
            };
        }
    };
}

pub const TokenIdentifier = enum {
    ILLEGAL,
    EOF,
    IDENT,
    INT,
    ASSIGN,
    PLUS,
    COMMA,
    SEMICOLON,
    LPAREN,
    RPAREN,
    LBRACE,
    RBRACE,
    FUNCTION,
    LET,
};

test "create token" {
    const testing = @import("std").testing;
    const token = Token().init(.SEMICOLON, ";");
    try testing.expectEqual(TokenIdentifier.SEMICOLON, token.identifier);
    try testing.expectEqual(";", token.literal);
}
