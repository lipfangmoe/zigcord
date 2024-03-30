# deancord (WIP)

A Discord API for the Zig programming language.

Currently built off of Zig Version `0.12.0-dev.2928+6fddc9cd3`. If you notice that it is broken
on a more recent patch of Zig, please create an issue!

To include this in your zig project, use the Zig Package Manager:

```sh
zig fetch --save {TODO: PUT TARBALL URL HERE}
```

# Basic Usage

super basic example for calling the discord API, untested but it should look something like this:

```zig
const std = @import("std");
const deancord = @import("deancord");

pub fn main() !void {
    const gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    defer gpa.deinit();

    const ctx = deancord.rest.Client.init(gpa.allocator(), .{ .bot = std.os.getenv("TOKEN") });
    defer ctx.deinit();

    // === calling an endpoint which is already in deancord ===

    const command = try deancord.rest.application_commands.createGlobalApplicationCommand(
        ctx,
        Snowflake.fromU64(APPLICATION_ID),
        .{ .name = "hello-world" },
    );
    std.debug.print("{}\n", .{command});

    // === calling an endpoint which not in deancord yet ===

    const path = "/some/random/path"
    const query = "with_localizations=true";

    const url = try rest.discordApiCallUri(ctx.allocator, path, query);
    defer ctx.allocator.free(url);

    const body: SomeStruct = .{ .foo = 10 };

    const response: ResponseBodyType = ctx.requestWithValueBody(ResponseBodyType, .GET, url, body, .{});
    std.debug.print("{}\n", .{response});
}
```

# TODO

still like 99% uncompleted
 - should probably refactor `src/rest`
   - `rest.Client` -> `rest.Config`
   - `rest.*.endpointName(ctx, ...)` -> `rest.ApiClient.init(rest.Client).endpointName(...)`
 - still needs more structures in `src/model`
 - still needs more endpoints in `src/rest`
 - http server implementation for interactions at `src/interaction_server`
 - websocket client implementation for typical websocket stuff at `src/websocket`
