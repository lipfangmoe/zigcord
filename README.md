# zigcord

A Discord API for the Zig programming language.

Currently built off of Zig Version `0.16.0`. If you notice that it is broken
on a more recent version of Zig, please create an [issue](https://codeberg.org/lipfang/zigcord/issues)!

# Including in your project

To include this in your zig project, use the Zig Package Manager:

```sh
# you can get a lock a specific version by replacing "#main" with the version number, ie "#v0.13.0"
zig fetch --save 'git+https://codeberg.org/lipfang/zigcord#main'
```

Then, make sure something similar to the following is in your `build.zig`:

```zig
    const zigcord_dependency = b.dependency("zigcord", .{});
    const zigcord_module = zigcord_dependency.module("zigcord");

    const mybot_module = b.addModule("myBot", .{
        .root_source_file = "src/main.zig",
        .imports = &.{.{ .name = "zigcord", .module = zigcord_module }},
    });
    const my_bot_exe = b.addExecutable(.{ .name = "myBot", .root_module = mybot_module });
	b.installArtifact(gateway_bot);
```

# Feature Support

 - All Discord API features up to March 30th, 2026
 - [User-installable Apps](https://discord.com/developers/docs/tutorials/developing-a-user-installable-app#developing-a-userinstallable-app)
 - [Components V2](https://discord.com/developers/docs/components/overview)
 - WebSocket Gateway Client
 - Interaction Server
 - Rest Client

# Basic Usage

This project is still in development, so formal documentation isn't made yet.

The [list of examples](./examples/) are always kept up-to-date. These are located under the [examples](./examples/) directory.
These examples can be built using `zig build examples:<example-name>` (or simply `zig build examples` to build all examples),
and then execute the example using the `zig-out/bin/<example-name>` executable. They all take `TOKEN` as an environment variable.

# Changelog

This project is still in development, so breaking changes happen often. However,
all changes are recorded in the [CHANGELOG.md](./CHANGELOG.md) file, which should make upgrading versions easy.

# Logging

Because zigcord relies on Discord conforming to a strongly-typed contract, it does log errors when they occur.

All logging for both zigcord and dependencies of zigcord use `std.log`, so you can disable it by defining a `std_options` in your `main.zig` file:

```zig
pub const std_options: std.Options = .{ .logFn = myLogFn };

pub fn myLogFn(
    comptime message_level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    switch(scope) {
        .zigcord, .websocket => return,
        else => std.log.defaultLog(message_level, scope, format, args),
    }
}
```

# TODO (things i'd like to do before tagging 1.0.0)

 - Proper namespacing for EndpointClient so code generation is not needed
   - (ie `endpoint_client.editCurrentApplication()` would instead be `endpoint_client.application.editCurrentApplication()`)
   - Can be done by making `application.zig` take `@This()` instead of `EndpointClient`, then using `@fieldParentPtr` to get the EndpointClient?
 - Better error handling to allow to get a `std.json.Value` from http responses if we fail to parse into a static type, similar to gateway
   - Would allow support for caller handling their own logging, instead of the library logging for them
 - Formal documentation site once the API is stabilized
 - Some way to test endpoints
 - Voice Support
 - HTTP Interaction Server:
   - Standalone HTTPS support (for now, you will need a reverse-proxy to provide HTTPS support)
   - Cloud function support (i.e. Cloudflare Workers)
 - [Lobby Resource](https://docs.discord.com/developers/resources/lobby)
 - Redo the MessageComponent API. Just let all MessageComponents have a `type` and `id` field, not sure why I decided to have this weird almost-polymorphic design.
