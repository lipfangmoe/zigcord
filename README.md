# zigcord

A Discord API for the Zig programming language.

Currently built off of Zig Version `0.15.2`. If you notice that it is broken
on a more recent version of Zig, please create an [issue](https://codeberg.org/lipfang/zigcord/issues)!

# Including in your project

To include this in your zig project, use the Zig Package Manager:

```sh
# you can get a lock a specific version by replacing "#main" with the version number, ie "#v0.8.0"
zig fetch --save 'git+https://codeberg.org/lipfang/zigcord#main'
```

Then, make sure something similar to the following is in your `build.zig`:

```rs
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

 - All Discord API features up to January 1st, 2026
 - Uses Zig 0.15.x `std.Io.Reader` and `std.Io.Writer` interfaces
 - [User-installable Apps](https://discord.com/developers/docs/tutorials/developing-a-user-installable-app#developing-a-userinstallable-app)
 - [Components V2](https://discord.com/developers/docs/components/overview)
 - WebSocket Gateway Client
 - Interaction Server
 - Rest Client

# Basic Usage

This project is still in early development, so formal documentation isn't made yet. but the [list of curated examples](./examples/) are always kept up-to-date. These are located under the [examples](./examples/) directory.

These examples are runnable with `zig build examples:gateway` and `zig build examples:interaction` (or simply `zig build examples` to build all examples), and then execute the example using the `zig-out/bin/<examplename>` executable.

# Changelog

This project is still in early development, so breaking changes happen often. However, all changes are recorded in the [CHANGELOG.md](./CHANGELOG.md) file, which should make upgrading versions easy.

# TODO
 - Formal documentation site once the API is stabilized
 - Some way to test endpoints
 - Better error handling to allow to get a `std.json.Value` from http responses if we fail to parse into a static type, similar to gateway
 - HTTP Interaction Server:
   - Standalone HTTPS support (for now, you will need a reverse-proxy to provide HTTPS support)
   - Native cloud function support (i.e. Cloudflare Workers)
