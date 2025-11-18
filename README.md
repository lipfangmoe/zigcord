# zigcord

A Discord API for the Zig programming language.

Currently built off of Zig Version `0.15.2`. If you notice that it is broken
on a more recent patch of Zig, please create an [issue](https://codeberg.org/lipfang/zigcord/issues)!

# Including in your project

To include this in your zig project, use the Zig Package Manager:

```sh
# you can get a specific version by replacing "main" with the version number, ie #v0.2.3
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

 - All Discord API features up to October 15, 2025
 - Uses Zig 0.15.x `std.Io.Reader` and `std.Io.Writer` interfaces
 - [User-installable Apps](https://discord.com/developers/docs/tutorials/developing-a-user-installable-app#developing-a-userinstallable-app)
 - [Components V2](https://discord.com/developers/docs/components/overview)
 - WebSocket Gateway
 - Interaction Server
 - Rest Client

# Basic Usage

The best way to look at examples is to look at the [examples](./examples/) directory.

The examples are also runnable with `zig build examples:gateway` and `zig build examples:interaction` (or simply `zig build examples` to build all examples)

# TODO

 - HTTP Interaction Server:
   - Standalone HTTPS support (for now, you will need a reverse-proxy to provide HTTPS support)
   - Cloud function support (i.e. Cloudflare Workers)
