# deancord (WIP)

A Discord API for the Zig programming language.

Currently built off of Zig Version `0.12.0-dev.2928+6fddc9cd3`. If you notice that it is broken
on a more recent patch of Zig, please create an issue!

To include this in your zig project, use the Zig Package Manager:

```sh
zig fetch --save {TODO: PUT TARBALL URL HERE}
```

# Basic Usage

untested but it should look something like this:

```zig
const std = @import("std");
const deancord = @import("deancord");
const rest = deancord.rest;

pub fn main() !void {
    const gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    defer gpa.deinit();

    const ctx = rest.Client.init(gpa.allocator(), .{ .bot = std.os.getenv("TOKEN") });
    defer client.deinit();

    // === calling an endpoint which is already in deancord ===

    const command = try rest.application_commands.createGlobalApplicationCommand(
        ctx,
        Snowflake.fromU64(APPLICATION_ID),
        .{ .name = "hello-world" },
    );
    std.debug.print("{}\n", .{command});

    // === calling an endpoint which not in deancord yet ===

    const path = "/some/random/path";

    const uri_str = try rest.allocDiscordUriStr(client.allocator, "/some/random/path", .{});
    defer client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    const body: SomeStruct = .{ .foo = 10 };

    const response: Result(ResponseBodyType) = try client.requestWithValueBody(ResponseBodyType, .GET, url, body, .{});
	defer response.deinit();

    std.debug.print("{}\n", .{response.value()});
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
