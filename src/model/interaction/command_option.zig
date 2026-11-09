const std = @import("std");
const jconfig = @import("jconfig");
const Channel = @import("../Channel.zig");
const Omittable = jconfig.Omittable;

pub const ApplicationCommandOptionType = enum(u8) {
    subcommand = 1,
    subcommand_group,
    string,
    integer,
    boolean,
    user,
    channel,
    role,
    mentionable,
    number,
    attachment,

    pub const jsonStringify = jconfig.stringifyEnumAsInt;
};

/// An option ("argument") for an application command.
pub const ApplicationCommandOption = struct {
    const Self = @This();

    type: ApplicationCommandOptionType,
    name: []const u8,
    name_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    description: []const u8,
    description_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    required: ?bool = null,
    choices: ?Choices = null,
    options: ?[]const ApplicationCommandOption = null,
    channel_types: ?[]const Channel.Type = null,
    min_value: ?union(enum) {
        double: f64,
        integer: i64,

        const Mixin = jconfig.InlineUnionMixin(@This());
        pub const jsonStringify = Mixin.jsonStringify;
        pub const jsonParse = Mixin.jsonParse;
        pub const jsonParseFromValue = Mixin.jsonParseFromValue;
    } = null,
    max_value: ?union(enum) {
        double: f64,
        integer: i64,

        const Mixin = jconfig.InlineUnionMixin(@This());
        pub const jsonStringify = Mixin.jsonStringify;
        pub const jsonParse = Mixin.jsonParse;
        pub const jsonParseFromValue = Mixin.jsonParseFromValue;
    } = null,
    min_length: ?i64 = null,
    max_length: ?i64 = null,
    autocomplete: ?bool = null,
    file_types: ?[]const []const u8 = null,

    pub const Choices = union(enum) {
        string: []const StringChoice,
        integer: []const IntegerChoice,
        double: []const DoubleChoice,

        const Mixin = jconfig.InlineUnionMixin(@This());
        pub const jsonStringify = Mixin.jsonStringify;
        pub const jsonParse = Mixin.jsonParse;
        pub const jsonParseFromValue = Mixin.jsonParseFromValue;
    };

    pub const jsonStringify = jconfig.stringifyWithOmit;

    pub fn initSubCommandOption(builder: SubcommandOptionBuilder) ApplicationCommandOption {
        return builder.build();
    }

    pub fn initSubCommandGroupOption(builder: SubcommandGroupOptionBuilder) ApplicationCommandOption {
        return builder.build();
    }

    pub fn initStringOption(builder: StringOptionBuilder) ApplicationCommandOption {
        return builder.build();
    }

    pub fn initIntegerOption(builder: IntegerOptionBuilder) ApplicationCommandOption {
        return builder.build();
    }

    pub fn initBooleanOption(builder: GenericOptionBuilder(.boolean)) ApplicationCommandOption {
        return builder.build();
    }

    pub fn initUserOption(builder: GenericOptionBuilder(.user)) ApplicationCommandOption {
        return builder.build();
    }

    pub fn initChannelOption(builder: GenericOptionBuilder(.channel)) ApplicationCommandOption {
        return builder.build();
    }

    pub fn initRoleOption(builder: GenericOptionBuilder(.role)) ApplicationCommandOption {
        return builder.build();
    }

    pub fn initMentionableOption(builder: GenericOptionBuilder(.mentionable)) ApplicationCommandOption {
        return builder.build();
    }

    pub fn initNumberOption(builder: NumberOptionBuilder) ApplicationCommandOption {
        return builder.build();
    }

    pub fn initAttachmentOption(builder: AttachmentOptionBuilder) ApplicationCommandOption {
        return builder.build();
    }
};

pub const SubcommandOptionBuilder = struct {
    name: []const u8,
    name_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    description: []const u8,
    description_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    required: ?bool = null,
    options: ?[]const ApplicationCommandOption = null,
    channel_types: ?[]const Channel.Type = null,

    fn build(self: @This()) ApplicationCommandOption {
        return .{
            .type = .subcommand,
            .name = self.name,
            .name_localizations = self.name_localizations,
            .description = self.description,
            .description_localizations = self.description_localizations,
            .required = self.required,
            .choices = null,
            .options = self.options,
            .channel_types = self.channel_types,
            .min_value = null,
            .max_value = null,
            .min_length = null,
            .max_length = null,
            .autocomplete = null,
        };
    }
};

pub const SubcommandGroupOptionBuilder = struct {
    name: []const u8,
    name_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    description: []const u8,
    description_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    required: ?bool = null,
    options: ?[]const ApplicationCommandOption = null,
    channel_types: ?[]const Channel.Type = null,

    fn build(self: @This()) ApplicationCommandOption {
        return .{
            .type = .subcommand_group,
            .name = self.name,
            .name_localizations = self.name_localizations,
            .description = self.description,
            .description_localizations = self.description_localizations,
            .required = self.required,
            .choices = null,
            .options = self.options,
            .channel_types = self.channel_types,
            .min_value = null,
            .max_value = null,
            .min_length = null,
            .max_length = null,
            .autocomplete = null,
        };
    }
};

pub const StringOptionBuilder = struct {
    name: []const u8,
    name_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    description: []const u8,
    description_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    required: ?bool = null,
    choices: ?[]const StringChoice = null,
    channel_types: ?[]const Channel.Type = null,
    min_length: ?i64 = null,
    max_length: ?i64 = null,
    autocomplete: ?bool = null,

    fn build(self: @This()) ApplicationCommandOption {
        return ApplicationCommandOption{
            .type = .string,
            .name = self.name,
            .name_localizations = self.name_localizations,
            .description = self.description,
            .description_localizations = self.description_localizations,
            .required = self.required,
            .choices = if (self.choices) |choices| .{ .string = choices } else null,
            .options = null,
            .channel_types = self.channel_types,
            .min_value = null,
            .max_value = null,
            .min_length = self.min_length,
            .max_length = self.max_length,
            .autocomplete = self.autocomplete,
        };
    }
};

pub const IntegerOptionBuilder = struct {
    name: []const u8,
    name_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    description: []const u8,
    description_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    required: ?bool = null,
    choices: ?[]const IntegerChoice = null,
    channel_types: ?[]const Channel.Type = null,
    min_value: ?i64 = null,
    max_value: ?i64 = null,
    autocomplete: ?bool = null,

    fn build(self: @This()) ApplicationCommandOption {
        return ApplicationCommandOption{
            .type = .integer,
            .name = self.name,
            .name_localizations = self.name_localizations,
            .description = self.description,
            .description_localizations = self.description_localizations,
            .required = self.required,
            .choices = if (self.choices) |choices| .{ .integer = choices } else null,
            .options = null,
            .channel_types = self.channel_types,
            .min_value = null,
            .max_value = null,
            .min_length = null,
            .max_length = null,
            .autocomplete = self.autocomplete,
        };
    }
};

pub const NumberOptionBuilder = struct {
    name: []const u8,
    name_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    description: []const u8,
    description_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    required: ?bool = null,
    choices: ?[]const DoubleChoice = null,
    channel_types: ?[]const Channel.Type = null,
    min_value: ?f64 = null,
    max_value: ?f64 = null,
    autocomplete: ?bool = null,

    fn build(self: @This()) ApplicationCommandOption {
        return ApplicationCommandOption{
            .type = .number,
            .name = self.name,
            .name_localizations = self.name_localizations,
            .description = self.description,
            .description_localizations = self.description_localizations,
            .required = self.required,
            .choices = if (self.choices) |choices| .{ .double = choices } else null,
            .options = null,
            .channel_types = self.channel_types,
            .min_value = null,
            .max_value = null,
            .min_length = null,
            .max_length = null,
            .autocomplete = self.autocomplete,
        };
    }
};

pub const AttachmentOptionBuilder = struct {
    name: []const u8,
    name_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    description: []const u8,
    description_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    required: ?bool = null,
    channel_types: ?[]const Channel.Type = null,
    file_types: ?[]const []const u8 = null,

    fn build(self: @This()) ApplicationCommandOption {
        return ApplicationCommandOption{
            .type = .attachment,
            .name = self.name,
            .name_localizations = self.name_localizations,
            .description = self.description,
            .description_localizations = self.description_localizations,
            .required = self.required,
            .choices = null,
            .options = null,
            .channel_types = self.channel_types,
            .min_value = null,
            .max_value = null,
            .min_length = null,
            .max_length = null,
            .autocomplete = self.autocomplete,
            .file_types = self.file_types,
        };
    }
};

pub fn GenericOptionBuilder(optType: ApplicationCommandOptionType) type {
    return struct {
        name: []const u8,
        name_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
        description: []const u8,
        description_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
        required: ?bool = null,
        channel_types: ?[]const Channel.Type = null,

        fn build(self: @This()) ApplicationCommandOption {
            return ApplicationCommandOption{
                .type = optType,
                .name = self.name,
                .name_localizations = self.name_localizations,
                .description = self.description,
                .description_localizations = self.description_localizations,
                .required = self.required,
                .choices = null,
                .options = null,
                .channel_types = self.channel_types,
                .min_value = null,
                .max_value = null,
                .min_length = null,
                .max_length = null,
                .autocomplete = null,
            };
        }
    };
}

/// A possible choice for an ApplicationCommandOption of type `string`.
pub const StringChoice = struct {
    name: []const u8,
    name_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    value: []const u8,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

/// A possible choice for an ApplicationCommandOption of type `integer`.
pub const IntegerChoice = struct {
    name: []const u8,
    name_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    value: i64,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

/// A possible choice for an ApplicationCommandOption of type `double`.
pub const DoubleChoice = struct {
    name: []const u8,
    name_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    value: f64,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};
