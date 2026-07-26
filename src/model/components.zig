const std = @import("std");
const model = @import("../root.zig").model;
const jconfig = @import("../root.zig").jconfig;
const omittable_util = @import("../jconfig/omit.zig");

pub const AnyComponentType = enum(u8) {
    action_row = 1,
    button = 2,
    string_select = 3,
    text_input = 4,
    user_select = 5,
    role_select = 6,
    mentionable_select = 7,
    channel_select = 8,
    section = 9,
    text_display = 10,
    thumbnail = 11,
    media_gallery = 12,
    file = 13,
    separator = 14,
    container = 17,
    label = 18,
    file_upload = 19,
    radio_group = 21,
    checkbox_group = 22,
    checkbox = 23,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};

pub const TopLevelMessageComponent = union(Type) {
    action_row: ActionRow,
    section: Section,
    text_display: TextDisplay,
    media_gallery: MediaGallery,
    file: File,
    separator: Separator,
    container: Container,

    pub fn initActionRow(action_row: ActionRow) TopLevelMessageComponent {
        return .{ .action_row = action_row };
    }

    pub fn initSection(section: Section) TopLevelMessageComponent {
        return .{ .section = section };
    }

    pub fn initText(text: []const u8) TopLevelMessageComponent {
        return .initTextDisplay(.{ .content = text });
    }
    pub fn initTextDisplay(text_display: TextDisplay) TopLevelMessageComponent {
        return .{ .text_display = text_display };
    }

    pub fn initMediaGallery(media_gallery: MediaGallery) TopLevelMessageComponent {
        return .{ .media_gallery = media_gallery };
    }

    pub fn initFile(file: File) TopLevelMessageComponent {
        return .{ .file = file };
    }

    pub fn initSeparator(separator: Separator) TopLevelMessageComponent {
        return .{ .separator = separator };
    }

    pub fn initContainer(container: Container) TopLevelMessageComponent {
        return .{ .container = container };
    }

    pub const Type = enum(u8) {
        action_row = @intFromEnum(AnyComponentType.action_row),
        section = @intFromEnum(AnyComponentType.section),
        text_display = @intFromEnum(AnyComponentType.text_display),
        media_gallery = @intFromEnum(AnyComponentType.media_gallery),
        file = @intFromEnum(AnyComponentType.file),
        separator = @intFromEnum(AnyComponentType.separator),
        container = @intFromEnum(AnyComponentType.container),

        pub const jsonStringify = jconfig.stringifyEnumAsInt;
    };
    pub const InteractionData = union(InteractionData.Type) {
        button: model.components.Button.MessageInteractionData,
        string_select: model.components.StringSelect.MessageInteractionData,
        user_select: model.components.UserSelect.MessageInteractionData,
        role_select: model.components.RoleSelect.MessageInteractionData,
        mentionable_select: model.components.MentionableSelect.MessageInteractionData,
        channel_select: model.components.ChannelSelect.MessageInteractionData,

        pub const Type = enum(u8) {
            button = @intFromEnum(AnyComponentType.button),
            string_select = @intFromEnum(AnyComponentType.string_select),
            user_select = @intFromEnum(AnyComponentType.user_select),
            role_select = @intFromEnum(AnyComponentType.role_select),
            mentionable_select = @intFromEnum(AnyComponentType.mentionable_select),
            channel_select = @intFromEnum(AnyComponentType.channel_select),

            pub const jsonStringify = jconfig.stringifyEnumAsInt;
        };

        const Mixin = jconfig.DiscriminatedUnionMixin(InteractionData, "component_type");
        pub const jsonStringify = InteractionData.Mixin.jsonStringify;
        pub const jsonParse = InteractionData.Mixin.jsonParse;
        pub const jsonParseFromValue = InteractionData.Mixin.jsonParseFromValue;
    };

    const Mixin = jconfig.DiscriminatedUnionMixin(TopLevelMessageComponent, "type");
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;
    pub const jsonStringify = Mixin.jsonStringify;
};

pub const TopLevelModalComponent = union(Type) {
    label: Label,

    pub fn initLabel(label: Label) TopLevelModalComponent {
        return .{ .label = label };
    }
    pub fn initPlainLabel(label: []const u8, child: LabelChildComponent) TopLevelModalComponent {
        return .initLabel(.initPlain(label, child));
    }
    pub fn initLabelWithDescription(label: []const u8, description: []const u8, child: LabelChildComponent) TopLevelModalComponent {
        return .initLabel(.initWithDescription(label, description, child));
    }

    pub const Type = enum(u8) {
        label = @intFromEnum(AnyComponentType.label),

        pub const jsonStringify = jconfig.stringifyEnumAsInt;
    };

    pub const InteractionData = union(Type) {
        label: Label.ModalInteractionData,

        const Mixin = jconfig.DiscriminatedUnionMixin(InteractionData, "type");
        pub const jsonParse = InteractionData.Mixin.jsonParse;
        pub const jsonParseFromValue = InteractionData.Mixin.jsonParseFromValue;
        pub const jsonStringify = InteractionData.Mixin.jsonStringify;
    };

    const Mixin = jconfig.DiscriminatedUnionMixin(TopLevelModalComponent, "type");
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;
    pub const jsonStringify = Mixin.jsonStringify;
};

pub const ActionRowChildComponent = union(Type) {
    button: Button,
    string_select: StringSelect,
    user_select: UserSelect,
    role_select: RoleSelect,
    mentionable_select: MentionableSelect,
    channel_select: ChannelSelect,

    pub fn initButton(button: Button) ActionRowChildComponent {
        return .{ .button = button };
    }
    pub fn initStringSelect(string_select: StringSelect) ActionRowChildComponent {
        return .{ .string_select = string_select };
    }
    pub fn initUserSelect(user_select: UserSelect) ActionRowChildComponent {
        return .{ .user_select = user_select };
    }
    pub fn initRoleSelect(role_select: RoleSelect) ActionRowChildComponent {
        return .{ .role_select = role_select };
    }
    pub fn initMentionableSelect(mentionable_select: MentionableSelect) ActionRowChildComponent {
        return .{ .mentionable_select = mentionable_select };
    }
    pub fn initChannelSelect(channel_select: ChannelSelect) ActionRowChildComponent {
        return .{ .channel_select = channel_select };
    }

    pub fn initPrimaryButton(custom_id: []const u8, options: Button.InitButtonOptions) ActionRowChildComponent {
        return .initButton(.initPrimaryButton(custom_id, options));
    }
    pub fn initSecondaryButton(custom_id: []const u8, options: Button.InitButtonOptions) ActionRowChildComponent {
        return .initButton(.initSecondaryButton(custom_id, options));
    }
    pub fn initSuccessButton(custom_id: []const u8, options: Button.InitButtonOptions) ActionRowChildComponent {
        return .initButton(.initSuccessButton(custom_id, options));
    }
    pub fn initDangerButton(custom_id: []const u8, options: Button.InitButtonOptions) ActionRowChildComponent {
        return .initButton(.initDangerButton(custom_id, options));
    }
    pub fn initPremiumButton(sku_id: []const u8, options: Button.InitButtonOptions) ActionRowChildComponent {
        return .initButton(.initPremiumButton(sku_id, options));
    }
    pub fn initLinkButton(url: []const u8, options: Button.InitButtonOptions) ActionRowChildComponent {
        return .initButton(.initLinkButton(url, options));
    }

    pub const Type = enum(u8) {
        button = @intFromEnum(AnyComponentType.button),
        string_select = @intFromEnum(AnyComponentType.string_select),
        user_select = @intFromEnum(AnyComponentType.user_select),
        role_select = @intFromEnum(AnyComponentType.role_select),
        mentionable_select = @intFromEnum(AnyComponentType.mentionable_select),
        channel_select = @intFromEnum(AnyComponentType.channel_select),

        pub const jsonStringify = jconfig.stringifyEnumAsInt;
    };

    const Mixin = jconfig.DiscriminatedUnionMixin(ActionRowChildComponent, "type");
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;
    pub const jsonStringify = Mixin.jsonStringify;
};

pub const SectionAccessoryComponent = union(Type) {
    button: Button,
    thumbnail: Thumbnail,

    pub fn initButton(button: Button) SectionAccessoryComponent {
        return .{ .button = button };
    }
    pub fn initThumbnail(thumbnail: Thumbnail) SectionAccessoryComponent {
        return .{ .thumbnail = thumbnail };
    }

    pub fn initPrimaryButton(custom_id: []const u8, options: Button.InitButtonOptions) SectionAccessoryComponent {
        return .initButton(.initPrimaryButton(custom_id, options));
    }
    pub fn initSecondaryButton(custom_id: []const u8, options: Button.InitButtonOptions) SectionAccessoryComponent {
        return .initButton(.initSecondaryButton(custom_id, options));
    }
    pub fn initSuccessButton(custom_id: []const u8, options: Button.InitButtonOptions) SectionAccessoryComponent {
        return .initButton(.initSuccessButton(custom_id, options));
    }
    pub fn initDangerButton(custom_id: []const u8, options: Button.InitButtonOptions) SectionAccessoryComponent {
        return .initButton(.initDangerButton(custom_id, options));
    }
    pub fn initPremiumButton(sku_id: []const u8, options: Button.InitButtonOptions) SectionAccessoryComponent {
        return .initButton(.initPremiumButton(sku_id, options));
    }
    pub fn initLinkButton(url: []const u8, options: Button.InitButtonOptions) SectionAccessoryComponent {
        return .initButton(.initLinkButton(url, options));
    }

    pub const Type = enum(u8) {
        button = @intFromEnum(AnyComponentType.button),
        thumbnail = @intFromEnum(AnyComponentType.thumbnail),

        pub const jsonStringify = jconfig.stringifyEnumAsInt;
    };

    const Mixin = jconfig.DiscriminatedUnionMixin(SectionAccessoryComponent, "type");
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;
    pub const jsonStringify = Mixin.jsonStringify;
};

pub const SectionChildComponent = union(Type) {
    text_display: TextDisplay,

    pub fn initText(text: []const u8) SectionChildComponent {
        return .{ .text_display = .{ .content = text } };
    }
    pub fn initTextDisplay(text_display: TextDisplay) SectionChildComponent {
        return .{ .text_display = text_display };
    }

    pub const Type = enum(u8) {
        text_display = @intFromEnum(AnyComponentType.text_display),

        pub const jsonStringify = jconfig.stringifyEnumAsInt;
    };

    const Mixin = jconfig.DiscriminatedUnionMixin(SectionChildComponent, "type");
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;
    pub const jsonStringify = Mixin.jsonStringify;
};

pub const ContainerChildComponent = union(Type) {
    action_row: ActionRow,
    text_display: TextDisplay,
    section: Section,
    media_gallery: MediaGallery,
    separator: Separator,
    file: File,

    pub fn initActionRow(action_row: ActionRow) ContainerChildComponent {
        return .{ .action_row = action_row };
    }
    pub fn initText(text: []const u8) ContainerChildComponent {
        return .{ .text_display = .{ .content = text } };
    }
    pub fn initTextDisplay(text_display: TextDisplay) ContainerChildComponent {
        return .{ .text_display = text_display };
    }
    pub fn initSection(section: Section) ContainerChildComponent {
        return .{ .section = section };
    }
    pub fn initMediaGallery(media_gallery: MediaGallery) ContainerChildComponent {
        return .{ .media_gallery = media_gallery };
    }
    pub fn initSeparator(separator: Separator) ContainerChildComponent {
        return .{ .separator = separator };
    }
    pub fn initFile(file: File) ContainerChildComponent {
        return .{ .file = file };
    }

    pub const Type = enum(u8) {
        action_row = @intFromEnum(AnyComponentType.action_row),
        text_display = @intFromEnum(AnyComponentType.text_display),
        section = @intFromEnum(AnyComponentType.section),
        media_gallery = @intFromEnum(AnyComponentType.media_gallery),
        separator = @intFromEnum(AnyComponentType.separator),
        file = @intFromEnum(AnyComponentType.file),

        pub const jsonStringify = jconfig.stringifyEnumAsInt;
    };

    const Mixin = jconfig.DiscriminatedUnionMixin(ContainerChildComponent, "type");
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;
    pub const jsonStringify = Mixin.jsonStringify;
};

pub const LabelChildComponent = union(Type) {
    text_input: TextInput,
    string_select: StringSelect,
    user_select: UserSelect,
    role_select: RoleSelect,
    mentionable_select: MentionableSelect,
    channel_select: ChannelSelect,
    file_upload: FileUpload,
    radio_group: RadioGroup,
    checkbox_group: CheckboxGroup,
    checkbox: Checkbox,

    pub fn initTextInput(text_input: TextInput) LabelChildComponent {
        return .{ .text_input = text_input };
    }
    pub fn initShortTextInput(custom_id: []const u8) LabelChildComponent {
        return .initTextInput(.{ .custom_id = custom_id });
    }
    pub fn initParagraphTextInput(custom_id: []const u8) LabelChildComponent {
        return .initTextInput(.{ .custom_id = custom_id });
    }
    pub fn initStringSelect(string_select: StringSelect) LabelChildComponent {
        return .{ .string_select = string_select };
    }
    pub fn initUserSelect(user_select: UserSelect) LabelChildComponent {
        return .{ .user_select = user_select };
    }
    pub fn initRoleSelect(role_select: RoleSelect) LabelChildComponent {
        return .{ .role_select = role_select };
    }
    pub fn initMentionableSelect(mentionable_select: MentionableSelect) LabelChildComponent {
        return .{ .mentionable_select = mentionable_select };
    }
    pub fn initChannelSelect(channel_select: ChannelSelect) LabelChildComponent {
        return .{ .channel_select = channel_select };
    }
    pub fn initRadioGroup(radio_group: RadioGroup) FileUpload {
        return .{ .radio_group = radio_group };
    }
    pub fn initCheckboxGroup(checkbox_group: CheckboxGroup) FileUpload {
        return .{ .checkbox_group = checkbox_group };
    }
    pub fn initCheckbox(checkbox: Checkbox) FileUpload {
        return .{ .checkbox = checkbox };
    }

    pub const Type = enum(u8) {
        text_input = @intFromEnum(AnyComponentType.text_input),
        string_select = @intFromEnum(AnyComponentType.string_select),
        user_select = @intFromEnum(AnyComponentType.user_select),
        role_select = @intFromEnum(AnyComponentType.role_select),
        mentionable_select = @intFromEnum(AnyComponentType.mentionable_select),
        channel_select = @intFromEnum(AnyComponentType.channel_select),
        file_upload = @intFromEnum(AnyComponentType.file_upload),
        radio_group = @intFromEnum(AnyComponentType.radio_group),
        checkbox_group = @intFromEnum(AnyComponentType.checkbox_group),
        checkbox = @intFromEnum(AnyComponentType.checkbox),

        pub const jsonStringify = jconfig.stringifyEnumAsInt;
    };

    pub const ModalInteractionData = union(Type) {
        text_input: TextInput.ModalInteractionData,
        string_select: StringSelect.ModalInteractionData,
        user_select: UserSelect.ModalInteractionData,
        role_select: RoleSelect.ModalInteractionData,
        mentionable_select: MentionableSelect.ModalInteractionData,
        channel_select: ChannelSelect.ModalInteractionData,
        file_upload: FileUpload.ModalInteractionData,
        radio_group: RadioGroup.ModalInteractionData,
        checkbox_group: CheckboxGroup.ModalInteractionData,
        checkbox: Checkbox.ModalInteractionData,

        const Mixin = jconfig.DiscriminatedUnionMixin(ModalInteractionData, "type");
        pub const jsonParse = ModalInteractionData.Mixin.jsonParse;
        pub const jsonParseFromValue = ModalInteractionData.Mixin.jsonParseFromValue;
        pub const jsonStringify = ModalInteractionData.Mixin.jsonStringify;
    };

    const Mixin = jconfig.DiscriminatedUnionMixin(LabelChildComponent, "type");
    pub const jsonParse = Mixin.jsonParse;
    pub const jsonParseFromValue = Mixin.jsonParseFromValue;
    pub const jsonStringify = Mixin.jsonStringify;
};

pub const ActionRow = struct {
    id: jconfig.Omittable(u64) = .omit,
    type: AnyComponentType = .action_row,
    components: []const ActionRowChildComponent,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const Button = struct {
    id: jconfig.Omittable(u64) = .omit,
    type: AnyComponentType = .button,
    custom_id: jconfig.Omittable([]const u8) = .omit,
    style: ButtonStyle,
    label: jconfig.Omittable([]const u8) = .omit,
    emoji: jconfig.Omittable(jconfig.Partial(model.Emoji)) = .omit,
    sku_id: jconfig.Omittable(model.Snowflake) = .omit,
    url: jconfig.Omittable([]const u8) = .omit,
    disabled: jconfig.Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub fn initPrimaryButton(custom_id: []const u8, options: InitButtonOptions) Button {
        return .{
            .custom_id = .initSome(custom_id),
            .style = .primary,
            .label = .initNullable(options.label),
            .emoji = .initNullable(options.emoji),
            .disabled = .initNullable(options.disabled),
        };
    }

    pub fn initSecondaryButton(custom_id: []const u8, options: InitButtonOptions) Button {
        return .{
            .custom_id = .initSome(custom_id),
            .style = .secondary,
            .label = .initNullable(options.label),
            .emoji = .initNullable(options.emoji),
            .disabled = .initNullable(options.disabled),
        };
    }

    pub fn initSuccessButton(custom_id: []const u8, options: InitButtonOptions) Button {
        return .{
            .custom_id = .initSome(custom_id),
            .style = .success,
            .label = .initNullable(options.label),
            .emoji = .initNullable(options.emoji),
            .disabled = .initNullable(options.disabled),
        };
    }

    pub fn initDangerButton(custom_id: []const u8, options: InitButtonOptions) Button {
        return .{
            .custom_id = .initSome(custom_id),
            .style = .danger,
            .label = .initNullable(options.label),
            .emoji = .initNullable(options.emoji),
            .disabled = .initNullable(options.disabled),
        };
    }

    pub fn initLinkButton(url: []const u8, options: InitButtonOptions) Button {
        return .{
            .url = .initSome(url),
            .style = .link,
            .label = .initNullable(options.label),
            .emoji = .initNullable(options.emoji),
            .disabled = .initNullable(options.disabled),
        };
    }

    pub fn initPremiumButton(sku_id: model.Snowflake, options: InitButtonOptions) Button {
        return .{
            .sku_id = .initSome(sku_id),
            .style = .premium,
            .label = .initNullable(options.label),
            .emoji = .initNullable(options.emoji),
            .disabled = .initNullable(options.disabled),
        };
    }

    pub const InitButtonOptions = struct {
        label: ?[]const u8 = null,
        emoji: ?jconfig.Partial(model.Emoji) = null,
        disabled: ?bool = null,
    };

    // https://discord.com/developers/docs/interactions/message-components#button-object-button-styles
    pub const ButtonStyle = enum(u8) {
        primary = 1,
        secondary = 2,
        success = 3,
        danger = 4,
        link = 5,
        premium = 6,

        pub const jsonStringify = jconfig.stringifyEnumAsInt;
    };

    pub const MessageInteractionData = struct {
        component_type: AnyComponentType,
        id: u64,
        custom_id: []const u8,
    };
};

pub const ChannelSelect = struct {
    id: jconfig.Omittable(u64) = .omit,
    type: AnyComponentType = .channel_select,
    custom_id: []const u8,
    channel_types: jconfig.Omittable([]const model.Channel.Type) = .omit,
    placeholder: jconfig.Omittable([]const u8) = .omit,
    default_values: jconfig.Omittable(DefaultValue) = .omit,
    min_values: jconfig.Omittable(i64) = .omit,
    max_values: jconfig.Omittable(i64) = .omit,
    disabled: jconfig.Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const DefaultValue = struct {
        id: model.Snowflake,
        type: enum { user, role, channel },
    };

    pub const ModalInteractionData = struct {
        type: AnyComponentType,
        id: u64,
        custom_id: []const u8,
        values: []const model.Snowflake,
    };

    pub const MessageInteractionData = struct {
        component_type: AnyComponentType,
        id: u64,
        custom_id: []const u8,
        values: []const model.Snowflake,
        resolved: jconfig.Omittable(model.interaction.ResolvedData) = .omit,

        pub const jsonStringify = jconfig.stringifyWithOmit;
    };
};

pub const StringSelect = struct {
    id: jconfig.Omittable(u64) = .omit,
    type: AnyComponentType = .string_select,
    custom_id: []const u8,
    options: []const Option,
    placeholder: jconfig.Omittable([]const u8) = .omit,
    min_values: jconfig.Omittable(i64) = .omit,
    max_values: jconfig.Omittable(i64) = .omit,
    disabled: jconfig.Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const Option = struct {
        label: []const u8,
        value: []const u8,
        description: jconfig.Omittable([]const u8) = .omit,
        emoji: jconfig.Omittable(model.Emoji) = .omit,
        default: jconfig.Omittable(bool) = .omit,

        pub const jsonStringify = jconfig.stringifyWithOmit;
    };

    pub const ModalInteractionData = struct {
        type: AnyComponentType,
        id: i32,
        custom_id: []const u8,
        values: []const []const u8,
    };

    pub const MessageInteractionData = struct {
        type: AnyComponentType,
        id: i32,
        custom_id: []const u8,
        values: []const []const u8,
    };
};

pub const TextInput = struct {
    id: jconfig.Omittable(u64) = .omit,
    type: AnyComponentType = .text_input,
    custom_id: []const u8,
    style: Style,
    min_length: jconfig.Omittable(u12) = .omit,
    max_length: jconfig.Omittable(u12) = .omit,
    required: jconfig.Omittable(bool) = .omit,
    value: jconfig.Omittable([]const u8) = .omit,
    placeholder: jconfig.Omittable([]const u8) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const Style = enum(u2) {
        short = 1,
        paragraph = 2,

        pub const jsonStringify = jconfig.stringifyEnumAsInt;
    };

    pub const ModalInteractionData = struct {
        type: AnyComponentType,
        id: i32,
        custom_id: []const u8,
        value: []const u8,
    };
};

pub const UserSelect = struct {
    id: jconfig.Omittable(u64) = .omit,
    type: AnyComponentType = .user_select,
    custom_id: []const u8,
    placeholder: jconfig.Omittable([]const u8) = .omit,
    default_values: jconfig.Omittable(DefaultValue) = .omit,
    min_values: jconfig.Omittable(i64) = .omit,
    max_values: jconfig.Omittable(i64) = .omit,
    disabled: jconfig.Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const DefaultValue = struct {
        id: model.Snowflake,
        type: enum { user, role, channel },
    };

    pub const ModalInteractionData = struct {
        type: AnyComponentType,
        id: u64,
        custom_id: []const u8,
        values: []const model.Snowflake,
    };

    pub const MessageInteractionData = struct {
        component_type: AnyComponentType,
        id: u64,
        custom_id: []const u8,
        values: []const model.Snowflake,
        resolved: jconfig.Omittable(model.interaction.ResolvedData) = .omit,

        pub const jsonStringify = jconfig.stringifyWithOmit;
    };
};

pub const RoleSelect = struct {
    id: jconfig.Omittable(u64) = .omit,
    type: AnyComponentType = .role_select,
    custom_id: []const u8,
    placeholder: jconfig.Omittable([]const u8) = .omit,
    default_values: jconfig.Omittable(DefaultValue) = .omit,
    min_values: jconfig.Omittable(i64) = .omit,
    max_values: jconfig.Omittable(i64) = .omit,
    disabled: jconfig.Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const DefaultValue = struct {
        id: model.Snowflake,
        type: enum { user, role, channel },
    };

    pub const ModalInteractionData = struct {
        type: AnyComponentType,
        id: u64,
        custom_id: []const u8,
        values: []const model.Snowflake,
    };

    pub const MessageInteractionData = struct {
        component_type: AnyComponentType,
        id: u64,
        custom_id: []const u8,
        values: []const model.Snowflake,
        resolved: jconfig.Omittable(model.interaction.ResolvedData) = .omit,

        pub const jsonStringify = jconfig.stringifyWithOmit;
    };
};

pub const MentionableSelect = struct {
    id: jconfig.Omittable(u64) = .omit,
    type: AnyComponentType = .mentionable_select,
    custom_id: []const u8,
    placeholder: jconfig.Omittable([]const u8) = .omit,
    default_values: jconfig.Omittable(DefaultValue) = .omit,
    min_values: jconfig.Omittable(i64) = .omit,
    max_values: jconfig.Omittable(i64) = .omit,
    disabled: jconfig.Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const DefaultValue = struct {
        id: model.Snowflake,
        type: enum { user, role, channel },
    };

    pub const ModalInteractionData = struct {
        type: AnyComponentType,
        id: u64,
        custom_id: []const u8,
        values: []const model.Snowflake,
    };

    pub const MessageInteractionData = struct {
        component_type: AnyComponentType,
        id: u64,
        custom_id: []const u8,
        values: []const model.Snowflake,
        resolved: jconfig.Omittable(model.interaction.ResolvedData) = .omit,

        pub const jsonStringify = jconfig.stringifyWithOmit;
    };
};

/// Message.Flag.is_components_v2 must be set to use this
pub const Section = struct {
    id: jconfig.Omittable(u64) = .omit,
    type: AnyComponentType = .section,
    components: []const SectionChildComponent,
    accessory: SectionAccessoryComponent,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub fn initTextSectionWithPrimaryButton(text: []const u8, custom_id: []const u8, button_opts: Button.InitButtonOptions) Section {
        return .{ .components = &.{.initText(text)}, .accessory = .initPrimaryButton(custom_id, button_opts) };
    }
    pub fn initTextSectionWithSecondaryButton(text: []const u8, custom_id: []const u8, button_opts: Button.InitButtonOptions) Section {
        return .{ .components = &.{.initText(text)}, .accessory = .initSecondaryButton(custom_id, button_opts) };
    }
    pub fn initTextSectionWithSuccessButton(text: []const u8, custom_id: []const u8, button_opts: Button.InitButtonOptions) Section {
        return .{ .components = &.{.initText(text)}, .accessory = .initSuccessButton(custom_id, button_opts) };
    }
    pub fn initTextSectionWithDangerButton(text: []const u8, custom_id: []const u8, button_opts: Button.InitButtonOptions) Section {
        return .{ .components = &.{.initText(text)}, .accessory = .initDangerButton(custom_id, button_opts) };
    }
    pub fn initTextSectionWithLinkButton(text: []const u8, url: []const u8, button_opts: Button.InitButtonOptions) Section {
        return .{ .components = &.{.initText(text)}, .accessory = .initLinkButton(url, button_opts) };
    }
    pub fn initTextSectionWithPremiumButton(text: []const u8, custom_id: []const u8, button_opts: Button.InitButtonOptions) Section {
        return .{ .components = &.{.initText(text)}, .accessory = .initPremiumButton(custom_id, button_opts) };
    }

    pub fn initTextSectionWithThumbnail(text: []const u8, thumbnail: Thumbnail) Section {
        return .{ .components = &.{.initText(text)}, .accessory = .initThumbnail(thumbnail) };
    }
    pub fn initTextSectionWithThumbnailUrl(text: []const u8, thumbnail: Thumbnail) Section {
        return .{ .components = &.{.initText(text)}, .accessory = .initThumbnail(.initWithUrl(thumbnail)) };
    }
};

/// Message.Flag.is_components_v2 must be set to use this
pub const TextDisplay = struct {
    id: jconfig.Omittable(u64) = .omit,
    type: AnyComponentType = .text_display,
    content: []const u8,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const ModalInteractionData = struct {
        type: AnyComponentType,
        id: u64,
    };
};

/// Message.Flag.is_components_v2 must be set to use this
pub const Thumbnail = struct {
    id: jconfig.Omittable(u64) = .omit,
    type: AnyComponentType = .thumbnail,
    media: UnfurledMediaItem,
    description: jconfig.Omittable(?[]const u8) = .omit,
    spoiler: jconfig.Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub fn initWithUrl(url: []const u8) Thumbnail {
        return .{ .media = .{ .url = url } };
    }
};

/// Message.Flag.is_components_v2 must be set to use this
pub const MediaGallery = struct {
    id: jconfig.Omittable(u64) = .omit,
    type: AnyComponentType = .media_gallery,
    items: []const Item,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const Item = struct {
        media: UnfurledMediaItem,
        description: jconfig.Omittable(?[]const u8) = .omit,
        spoiler: jconfig.Omittable(bool) = .omit,

        pub const jsonStringify = jconfig.stringifyWithOmit;
    };
};

/// Message.Flag.is_components_v2 must be set to use this
pub const File = struct {
    id: jconfig.Omittable(u64) = .omit,
    type: AnyComponentType = .file,
    file: UnfurledMediaItem,
    spoiler: jconfig.Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

/// Message.Flag.is_components_v2 must be set to use this
pub const Separator = struct {
    id: jconfig.Omittable(u64) = .omit,
    type: AnyComponentType = .separator,
    divider: jconfig.Omittable(bool) = .omit,
    spacing: jconfig.Omittable(Spacing) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const Spacing = enum(u8) {
        small = 1,
        large = 2,

        pub const jsonStringify = jconfig.stringifyEnumAsInt;
    };
};

/// Message.Flag.is_components_v2 must be set to use this
pub const Container = struct {
    id: jconfig.Omittable(u64) = .omit,
    type: AnyComponentType = .container,
    components: []const ContainerChildComponent,
    accent_color: jconfig.Omittable(?i64) = .omit,
    spoiler: jconfig.Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const Label = struct {
    id: jconfig.Omittable(u64) = .omit,
    type: AnyComponentType = .label,
    label: []const u8,
    description: jconfig.Omittable([]const u8) = .omit,
    /// must be one of text_input, string_select, user_select, role_select, mentionable_select, channel_select, file_upload.
    component: LabelChildComponent,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub fn initPlain(label: []const u8, child: LabelChildComponent) Label {
        return .{ .label = label, .component = child };
    }
    pub fn initWithDescription(label: []const u8, description: []const u8, child: LabelChildComponent) Label {
        return .{ .label = label, .description = description, .component = child };
    }

    pub const ModalInteractionData = struct {
        type: AnyComponentType,
        id: u64,
        component: LabelChildComponent.ModalInteractionData,
    };
};

pub const FileUpload = struct {
    id: jconfig.Omittable(u64) = .omit,
    type: AnyComponentType = .file_upload,
    custom_id: []const u8,
    min_values: jconfig.Omittable(i64) = .omit,
    max_values: jconfig.Omittable(i64) = .omit,
    required: jconfig.Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const ModalInteractionData = struct {
        type: AnyComponentType,
        id: u64,
        custom_id: []const u8,
        values: []const model.Snowflake,
    };
};

pub const RadioGroup = struct {
    id: jconfig.Omittable(u64) = .omit,
    type: AnyComponentType = .radio_group,
    custom_id: []const u8,
    options: []const Option,
    required: jconfig.Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const Option = struct {
        value: []const u8,
        label: []const u8,
        description: jconfig.Omittable([]const u8) = .omit,
        default: jconfig.Omittable(bool) = .omit,

        pub const jsonStringify = jconfig.stringifyWithOmit;
    };

    pub const ModalInteractionData = struct {
        type: AnyComponentType,
        id: u64,
        custom_id: []const u8,
        value: []const u8,
    };
};

pub const CheckboxGroup = struct {
    id: jconfig.Omittable(u64) = .omit,
    type: AnyComponentType = .checkbox_group,
    custom_id: []const u8,
    options: []const Option,
    min_values: jconfig.Omittable(i64) = .omit,
    max_values: jconfig.Omittable(i64) = .omit,
    required: jconfig.Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const Option = struct {
        value: []const u8,
        label: []const u8,
        description: jconfig.Omittable([]const u8) = .omit,
        default: jconfig.Omittable(bool) = .omit,

        pub const jsonStringify = jconfig.stringifyWithOmit;
    };

    pub const ModalInteractionData = struct {
        type: AnyComponentType,
        id: u64,
        custom_id: []const u8,
        values: []const []const u8,
    };
};

pub const Checkbox = struct {
    id: jconfig.Omittable(u64) = .omit,
    type: AnyComponentType = .checkbox,
    custom_id: []const u8,
    default: jconfig.Omittable(bool) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub const ModalInteractionData = struct {
        type: AnyComponentType,
        id: u64,
        custom_id: []const u8,
        value: bool,
    };
};

pub const UnfurledMediaItem = struct {
    url: []const u8,
    proxy_url: jconfig.Omittable([]const u8) = .omit,
    height: jconfig.Omittable(?i64) = .omit,
    width: jconfig.Omittable(?i64) = .omit,
    content_type: jconfig.Omittable([]const u8) = .omit,
    attachment_id: jconfig.Omittable(model.Snowflake) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

test "discord example" {
    const input =
        \\[
        \\    {
        \\      "type": 10,
        \\      "content": "This is a message with components."
        \\    },
        \\    {
        \\        "type": 1,
        \\        "components": [
        \\            {
        \\                "type": 2,
        \\                "label": "Click me!",
        \\                "style": 1,
        \\                "custom_id": "click_one"
        \\            }
        \\        ]
        \\    }
        \\]
    ;

    const expected: []const TopLevelMessageComponent = &.{
        .initTextDisplay(.{ .content = "This is a message with components." }),
        .initActionRow(.{ .components = &.{
            .initPrimaryButton("click_one", .{ .label = "Click me!" }),
        } }),
    };

    const actual = try std.json.parseFromSlice([]const TopLevelMessageComponent, std.testing.allocator, input, .{});
    defer actual.deinit();
    try std.testing.expectEqualDeep(expected, actual.value);
}

test "actual example" {
    const input = @embedFile("./test/components.test.json");
    try jconfig.testing.expectParsedSuccessfully(TopLevelMessageComponent, std.testing.allocator, input, .{ .ignore_unknown_fields = true });
}
