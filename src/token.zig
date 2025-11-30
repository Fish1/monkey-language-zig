const StringHashMap = @import("std").StringHashMap(TokenIdentifier);
const Allocator = @import("std").mem.Allocator;

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

pub fn IdentLookup() type {
    return struct {
        map: StringHashMap,

        pub fn init(allocator: Allocator) !@This() {
            var map = StringHashMap.init(allocator);
            try map.put("fn", .FUNCTION);
            try map.put("if", .IF);
            try map.put("else", .ELSE);
            try map.put("return", .RETURN);
            try map.put("let", .LET);
            try map.put("true", .TRUE);
            try map.put("false", .FALSE);
            return .{
                .map = map,
            };
        }

        pub fn deinit(self: *@This()) void {
            self.map.deinit();
        }

        pub fn lookup(self: @This(), input: []const u8) ?TokenIdentifier {
            return self.map.get(input);
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
    MINUS,
    BANG,
    ASTERISK,
    SLASH,
    COMMA,
    SEMICOLON,
    LPAREN,
    RPAREN,
    LBRACE,
    RBRACE,
    LT,
    GT,
    EQ,
    NOT_EQ,
    FUNCTION,
    LET,
    IF,
    ELSE,
    RETURN,
    TRUE,
    FALSE,
};

test "create token" {
    const testing = @import("std").testing;
    const token = Token().init(.SEMICOLON, ";");
    try testing.expectEqual(TokenIdentifier.SEMICOLON, token.identifier);
    try testing.expectEqual(";", token.literal);
}

test "ident lookup" {
    const testing = @import("std").testing;
    const allocator = @import("std").testing.allocator;
    // const debug = @import("std").debug;

    var il = try IdentLookup().init(allocator);
    defer il.deinit();
    const ident = il.lookup("fn");

    if (ident) |i| {
        try testing.expectEqual(TokenIdentifier.FUNCTION, i);
    } else {
        try testing.expect(false);
    }
}
