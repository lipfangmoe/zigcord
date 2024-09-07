const std = @import("std");
const jconfig = @import("../root.zig").jconfig;

pub const send_events = @import("./event_data/send_events.zig");
pub const receive_events = @import("./event_data/receive_events.zig");

fn AnyNamespaceDecl(namespace: type) type {
    const module_decls = @typeInfo(namespace).Struct.decls;

    const Enum = std.meta.DeclEnum(namespace);

    var union_fields: [module_decls.len]std.builtin.Type.UnionField = undefined;
    for (module_decls, 0..) |decl, idx| {
        const decl_value = @field(namespace, decl.name);
        union_fields[idx] = std.builtin.Type.UnionField{
            .name = decl.name,
            .type = decl_value,
            .alignment = 0,
        };
    }

    return @Type(std.builtin.Type{ .Union = std.builtin.Type.Union{
        .tag_type = Enum,
        .fields = &union_fields,
        .layout = .auto,
        .decls = &.{},
    } });
}

pub const AnyReceiveEvent = AnyNamespaceDecl(receive_events);

pub const AnySendEvent = AnyNamespaceDecl(send_events);

pub const Opcode = enum(u64) {
    dispatch = 0,
    heartbeat = 1,
    identify = 2,
    presence_update = 3,
    voice_state_update = 4,
    @"resume" = 6,
    reconnect = 7,
    request_guild_members = 8,
    invalid_session = 9,
    hello = 10,
    heartbeat_ack = 11,
    _,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};

test "AnyNamespaceDecl" {
    const TestNamespace = struct {
        pub const Foo = struct { foo: []const u8 };
        pub const Bar = struct { bar: i64 };
    };
    const AnyTest = AnyNamespaceDecl(TestNamespace);

    _ = AnyTest{ .Foo = TestNamespace.Foo{ .foo = "lol" } };
    _ = AnyTest{ .Bar = TestNamespace.Bar{ .bar = 5 } };
}
