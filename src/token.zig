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
