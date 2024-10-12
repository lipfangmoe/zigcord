# deancord (WIP)

> [!WARNING]
> This project is still a work in progress, and is not functional at the moment. I'm pretty close to completing though so check back in a few weeks (or feel free to contribute!)

A Discord API for the Zig programming language.

Currently built off of Zig Version `0.13.0`. If you notice that it is broken
on a more recent patch of Zig, please create an issue!

To include this in your zig project, use the Zig Package Manager:

```sh
zig fetch --save 'git+https://github.com/deanveloper/deancord.zig#main'
```

Then, make sure something similar to the following is in your `build.zig`:

```rs
	const deancord_dependency = b.dependency("deancord");
	const deancord_module = deancord_dependency.module("deancord");
    const my_bot = b.addExecutable(.{
        .name = "my-bot",
        .optimize = optimize,
        .target = target,
        .root_source_file = b.path("./src/main.zig"),
    });
    gateway_bot.root_module.addImport("deancord", deancord_module);
	b.installArtifact(gateway_bot);
```

# Basic Usage

The best way to look at examples is to look at the [examples](./examples/) directory.

The examples are also runnable with `zig build examples:gateway` and `zig build examples:interaction` (or simply `zig build examples` to build all examples)

# TODO

 - HTTP Interaction Server:
   - Standalone HTTPS support (for now, you will need a reverse-proxy to provide HTTPS support)
   - Cloud function support (Cloudflare Workers)
 - Make sure all data types are accurate