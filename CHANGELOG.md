# v0.10.1

This release contains a minor breaking change.

 * The `Application` struct has slightly changed, allowing it to be correctly parsed by the Get Current Application endpoint.
   * Existing omittable field `interactions_endpoint_url` was also made nullable
   * Existing omittable field `role_connections_verification_url` was also made nullable
   * New omittable fields `event_webhooks_url`, `event_webhooks_status`, `event_webhooks_types`, and `integration_types_config` were added
   * The type `Application.TeamMember` has also changed:
     * Existing field `user` was changed from `model.User` to `jconfig.Partial(model.User)`
     * New omittable field `permissions` was added. While this field isn't documented under [Team Member Object](https://discord.com/developers/docs/topics/teams#data-models-team-member-object), it is documented under [Example Application Object](https://discord.com/developers/docs/resources/application#application-object-example-application-object)

# v0.10.0

This release contains breaking changes related to Attachments

 * Instances of `jconfig.Partial(model.Message.Attachment)` have been replaced with `PartialAttachment`
   * Migration: use the new struct. `jconfig.Partial` sucked to use anyway, and the new struct only accepts fields useful for attachment uploads.

# v0.9.4

This release contains no breaking changes.

 * A new optional field has been added to EditMessageJsonBody and EditMessageFormBody: `components` for use with Message Components V2

# v0.9.3

This release contains a minor breaking change.

 * Media descriptions in Message Components were considered omittable, but not nullable. They are now considered nullable.
   * This is a minor breaking change that I don't think will actually break anyone, since unfortunately media descriptions
     are seldomn used.

# v0.9.2

This release contains no breaking changes.

 * `EditWebhookMessageFormBody` and `EditWebhookMessageJsonBody` now both have a `flags` field.

# v0.9.1

This release contains a minor breaking change to followup messages.

Because this is a relatively minor change and may not even break many people (and zigcord is still `v0`),
I've decided to make this a patch bump instead of a minor version bump.

 * **breaking** `EndpointClient.editOriginalInteractionResponse` has been changed from taking a `EditWebhookMessageFormBody` to a `EditWebhookMessageJsonBody`
   * There are two ways you can choose to migrate:
     * Change from `EndpointClient.editOriginalInteractionResponse` to `EndpointClient.editOriginalInteractionResponseMultipart`
     * Continue using `EndpointClient.editOriginalInteractionResponse`, but change optional fields to use `.initSome(...)` to match the JSON-based contract

# v0.9.0

This release contains breaking changes to the interaction model and error printing.

 * **breaking**: `rest.RestClient.DiscordError` now implements `format`
   * migration: printing `rest.RestClient.DiscordError` must be done with `{}` to `{f}`
   * this prints the discord error in JSON format, which is useful since that is the format it was orginally presented in.
 * **breaking**: `model.MessageComponent.id` now takes a `u64` instead of a `i32`
   * i mean, it just makes sense. it isn't even allowed to be zero
 * **breaking**: `model.interaction.MessageComponentData` is now a union instead of a struct
   * this was added to make distinctions between different kinds of message components
 * non-breaking: `model.interaction.ModalComponentData` has been added for modal components
 * non-breaking: more types which use the tagged-data pattern have been given `initXyz` construction methods similar to `InteractionResponse`

# v0.8.0

This release contains breaking changes to the interaction model.

 * **breaking**: `model.interaction.Interaction.data` is no longer assumed to be a message interaction.
 * **breaking**: `model.interaction.InteractionResponse` is now a union type, rather than a struct.
   * InteractionResponse now has an `initXyz` construction method for each type of interaction response.
   * This allows InteractionResponse to allow for more than just Message responses.
 * **breaking**: `EndpointClient.CreateInteractionResponseFormBody.data` now takes `InteractionCallbackAny` instead of `InteractionCallbackData`

# v0.7.2

This release contains no breaking changes.

 * bug fixed where using `setupMultipartRequestWithAuditLogReason` could segfault since
   the extra_headers is not sent until `request.sendBody*()` is called

# v0.7.1

This release contains no breaking changes.

 * new permission added: bypass_slowmode
 * new endpoint added: getGuildRoleMemberCounts

# v0.7.0

This release contains major breaking changes.

 * **breaking**: the gateway's ReadEventData union fields have been renamed to be snake_case instead of UpperCamelCase
   * this is more consistent with how union fields are traditionally named
   * migration: rename to use snake_case. For instance:
        ```
        const event = try client.readEvent();
        defer event.deinit();
        switch (event.event) {
            // OLD: .InteractionCreate => |interaction_create| { ... }
            .interaction_create => |interaction_create| { ... }
        }
        ```
 * ReadEventData is now hand-typed instead of generated by comptime
   * this allows IDEs to be able to read types much easier
   * this also is much more human-readable as well, apologies for anyone who had to look at that :)
 * EndpointClient (generated file) now has a stable order, so diffs won't be gigantic when
   the file is generated from different platforms

# v0.6.0

This release contains minor breaking changes.

 * **breaking(?)**: fixes an issue where EndpointClient methods which allowed uploading files did not work properly
   * this is only questionably a breaking change because affected methods used to panic.
   * these methods now require you supply a `zigcord.rest.Upload` instead of an `*std.Io.Reader` for the file.
   * this involves specifying both the filename and content-type of the file.
   * Noteworthy that `zigcord.rest.Upload` contains several functions to allow easily creating uploads
     * `.fromBytes(filename: []const u8, content_type: []const u8, bytes: []const u8)`
     * `.fromFileReader(filename: []const u8, content_type: []const u8, file_reader: *std.fs.File.Reader)`
     * `.fromReaderWithSize(filename: []const u8, content_type: []const u8, reader: *std.Io.Reader, size: u64)`
     * `.fromUnsizedReader(filename: []const u8, content_type: []const u8, reader: *std.Io.Reader)`
       * Noteworthy that this last method should be avoided if at all possible, as this forces transfer_encoding to be
         `chunked`, which can be undesirable since `content_length` is much simpler (also, it seems Discord may have
         an issue with how Zig encodes chunked requests, but it may be user-error) 
 * **breaking**: low-level function `setupMultipartRequest` no longer accepts a list of extra headers.
   you will need to use `setupRequest` if you want access to extra headers (other than audit log reason, detailed next).
 * new low-level function: `setupMultipartRequestWithAuditLogReason` to allow for easy mutlipart
   requests with the `X-Audit-Log-Reason` header set.
 * **breaking**: renames low-level function `requestWithValueBody` to `requestWithJsonBody`
