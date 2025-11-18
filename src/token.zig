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
            try map.put("FUNCTION", .FUNCTION);
            try map.put("LET", .LET);
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

test "ident lookup" {
    const testing = @import("std").testing;
    const allocator = @import("std").testing.allocator;
    const debug = @import("std").debug;

    var il = try IdentLookup().init(allocator);
    defer il.deinit();
    const ident = il.lookup("FUNCTION");

    debug.print("THING: {any}\n", .{ident});
    if (ident) |y| {
        debug.print("THING: {any}\n", .{y});
        try testing.expectEqual(TokenIdentifier.FUNCTION, y);
    } else {
        try testing.expect(false);
    }
}
