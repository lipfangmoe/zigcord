# v0.14.0

There are incoming major breaking changes.
* **major breaking change**: interactions and components have been significantly refactored.
  * if you were mostly using the `.init` methods for components, and using unnamed structs, you will be minimally impacted.
  * components have moved from `model.MessageComponent` to `model.components`
  * there is no more equivalent to `model.MessageComponent` which, was a union containing all message components
  * instead, you are now given unions only containing the possible components that can be returned (or used) for individual types.
  * for instance, `model.Message.components` is now a `[]const model.component.TopLevelMessageComponent`, and container components now contain a `[]const ContainerChildComponent`
  * additionally, many renames and relocations have been done for interactions.
    * any component-specific interaction data is now located in `model.components`
    * in general "Interaction Response" structures are now called "Interaction Data" structures.
    * for instance, `model.interaction.StringSelectModalInteractionResponse` is now moved to `model.components.StringSelect.ModalInteractionResponse`
  * the `.init` functions for creating components no longer take the `id: ?u64` argument.
* **big fix, non-breaking**: zig's self-hosted compiler backend (debug compile) no longer crashes when compiling zigcord!
  * weebsocket (the websocket library used by zigcord) had a strange compiler crash when using the self-hosted compiler backend
  * i identified which part of the library was causing the compiler to crash
  * i refactored that part of the code to be much simpler, no longer causing a crash
  * i additionally sent an MRE to the zig team: https://codeberg.org/ziglang/zig/issues/36321 for anyone who is curious
  * anyway, zigcord (and therefore zigcord bots!) should compile a lot faster now!
* **minor breaking change**: the type of `model.component.Section` has been corrected to be more accurate.
* **minor breaking change**: the type of `model.guild.Member.permissions` has been changed to `Omittable(model.Permission)` instead of `Omittable([]const u8)`.
* **minor breaking change**: the type of `model.interaction.ResolvedData.channels` has been changed to `ArrayHashMap(model.Channel)` instead of `ArrayHashMap(Partial(model.Channel))`.
* for action rows and section accessories, additional `.init` functions (ie `.initPrimaryButton()`) have been created to make creating buttons easier.
* for modal components, new functions `initPlainLabel()` and `initLabelWithDescription` have been added as a simpler contract for creating a labeled input
* fixed guild_member_update events where avatar_decoration_data is not provided
* added collectibles to both user objects and guild_member_update events
* fixed up the interaction server and added an example (it didn't even compile before, so not considering this a breaking change)
* added `Lobby` resource
* bitflag types (ie `model.Message.Flags`) can now be printed with number specifiers (ie `{d}`)

# v0.13.0

This release contains breaking changes.

 * **minor breaking change**: JsonErrorCodes has been regenerated, and one error has changed names.
   * i really shouldn't be doing errors this way, huh?
 * added [Voice Channel Status and Start Time Documentation](https://docs.discord.com/developers/change-log#voice-channel-status-and-start-time-documentation) APIs
   * new endpoint: `channel.setVoiceChannelStatus`
   * new permission: `set_voice_channel_status`
 * added [New `flags_new` Field on Application Object](https://docs.discord.com/developers/change-log#new-flags_new-field-on-application-object)
   * as the Discord changelog linked above states, the REST API is not impacted. since zigcord uses custom structs for bitfields, it is not impacted.
 * fixed [subscription status values](https://docs.discord.com/developers/change-log#documentation-fix-subscription-status-values) in accordance with the documentation update
 * added [Attachment Editing and is_spoiler Param](https://docs.discord.com/developers/change-log#attachment-editing-and-is_spoiler-param)
   * **minor breaking change**: `model.Message.Attachment.flags` was incorrectly typed as Message Flags, they are now correctly typed as Attachment Flags.
   * **major breaking change**: Attachment-related request structures have been reworked to now use the `AttachmentRequest` or `PartialAttachmentRequest` as documented above.

# v0.12.1

This release contains a minor breaking change.
(A type contract has changed, but if you used the old contract, you would encounter an error)

 * solves #17 - for Presence Update events, `client_status` was incorrectly
   typed as `[]const ClientStatus`, when it should be `ClientStatus`.

# v0.12.0

This release contains breaking changes.

 * **breaking change**: All EndpointClient methods now may return `error.Canceled`
 * minor breaking change: `ApplicationCommandInteractionDataOption` now correctly takes `type: ApplicationCommandOptionType`
 * minor breaking change: removed `discordApiCallUri`; it did not function correctly anyway
 * removed potential memory leak that could occur when reconnecting

# v0.11.1, v0.11.2, v0.11.3

This release contains no breaking changes.

0.11.1: Fixes #12, a comparison was reversed causing `error.Disconnected` to be returned more often than it should be.
0.11.2: Removes all .info logging, moving it to .debug so that it doesn't appear in release modes
0.11.3: Hopefully fixes reconnect logic again, as it was still faulty

# v0.11.0

The Zig 0.16.0 update!

This release contains breaking changes.

 * Minimum zig version has been raised to 0.16.0
 * As you may expect, many init methods now take a `std.Io` parameter
 * Many methods' error unions have `error.Canceled` added to them
 * Updated websocket library to a more stable version

# v0.10.2

This release contains minor breaking changes.

 * Adding new features of the Discord API:
 * [New Invite Endpoints](https://docs.discord.com/developers/change-log#new-invite-endpoints)
   * minor breaking change: `CreateChannelInvite` struct in EndpointClient has been renamed to `CreateChannelInviteJsonBody`
   * minor breaking change: fixed typo of `target_type` (used to be `target_tpe`)
   * added `EndpointClient.createChannelInviteMultipart`, allowing CSV upload of users allowed to use this invite
   * added `EndpointClient.getTargetUsers`, allowing downloading a CSV of allowed users to use an invite
   * added `EndpointClient.updateTargetUsers`, allowing updating the CSV of allowed users to use an invite
   * added `EndpointClient.getTargetUsersJobStatus`, allowing you to check on the status of a CSV being processed
 * [Community Invites Update](https://docs.discord.com/developers/change-log#community-invites-update)
   * minor breaking change: `model.Invite.Role` is now a `[]PartialRole` instead of `[]Role` (as documented by Discord)
 * [Radio Groups, Checkbox Groups, and Checkboxes in Modals](https://docs.discord.com/developers/change-log#radio-groups-checkbox-groups-and-checkboxes-in-modals)
   * added these components to MessageComponent (for creating components) and interaction (for reading interaction response values)
 * Regenerated `JsonErrorCodes.zig`

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
