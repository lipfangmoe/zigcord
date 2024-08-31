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

Then, make sure the following is in your `build.zig`:

```rs
    const gateway_bot = b.addExecutable(.{
        .name = "gateway-example",
        .optimize = optimize,
        .target = target,
        .root_source_file = b.path("./examples/gateway_bot.zig"),
    });
    gateway_bot.root_module.addImport("deancord", deancord_module);
	b.installArtifact(gateway_bot);
```

# Basic Usage

The best way to look at examples is to look at the [examples](./examples/) directory.

The examples are also runnable with `zig build examples:gateway` and `zig build examples:interaction` (or simply `zig build examples` to build all examples)

# TODO

 - should probably add a wrapper for `rest.Client` to make calling endpoints a bit more obvious.
   - `rest.Client` -> `rest.JsonClient`
   - `rest.*.endpointName(client, ...)` -> `rest.ApiClient.init(rest.JsonClient).endpointName(...)`
