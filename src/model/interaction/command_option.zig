const std = @import("std");
const model = @import("../../root.zig").model;
const jconfig = @import("../../root.zig").jconfig;
const Channel = model.Channel;
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
    required: Omittable(bool) = .omit,
    choices: Omittable(Choices) = .omit,
    options: Omittable([]const ApplicationCommandOption) = .omit,
    channel_types: Omittable([]const Channel.Type) = .omit,
    min_value: Omittable(union(enum) {
        double: f64,
        integer: i64,
        pub usingnamespace jconfig.InlineUnionMixin(@This());
    }) = .omit,
    max_value: Omittable(union(enum) {
        double: f64,
        integer: i64,
        pub usingnamespace jconfig.InlineUnionMixin(@This());
    }) = .omit,
    min_length: Omittable(i64) = .omit,
    max_length: Omittable(i64) = .omit,
    autocomplete: Omittable(bool) = .omit,

    pub const Choices = union(enum) {
        string: []const StringChoice,
        integer: []const IntegerChoice,
        double: []const DoubleChoice,

        pub usingnamespace jconfig.InlineUnionMixin(@This());
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

    pub fn initAttachmentOption(builder: GenericOptionBuilder(.attachment)) ApplicationCommandOption {
        return builder.build();
    }
};

pub const SubcommandOptionBuilder = struct {
    name: []const u8,
    name_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    description: []const u8,
    description_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    required: Omittable(bool) = .omit,
    options: Omittable([]const ApplicationCommandOption) = .omit,
    channel_types: Omittable([]const Channel.Type) = .omit,

    fn build(self: @This()) ApplicationCommandOption {
        return ApplicationCommandOption{
            .type = .subcommand,
            .name = self.name,
            .name_localizations = self.name_localizations,
            .description = self.description,
            .description_localizations = self.description_localizations,
            .required = self.required,
            .choices = .omit,
            .options = self.options,
            .channel_types = self.channel_types,
            .min_value = .omit,
            .max_value = .omit,
            .min_length = .omit,
            .max_length = .omit,
            .autocomplete = .omit,
        };
    }
};

pub const SubcommandGroupOptionBuilder = struct {
    name: []const u8,
    name_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    description: []const u8,
    description_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    required: Omittable(bool) = .omit,
    options: Omittable([]const ApplicationCommandOption) = .omit,
    channel_types: Omittable([]const Channel.Type) = .omit,

    fn build(self: @This()) ApplicationCommandOption {
        return ApplicationCommandOption{
            .type = .subcommand_group,
            .name = self.name,
            .name_localizations = self.name_localizations,
            .description = self.description,
            .description_localizations = self.description_localizations,
            .required = self.required,
            .choices = .omit,
            .options = self.options,
            .channel_types = self.channel_types,
            .min_value = .omit,
            .max_value = .omit,
            .min_length = .omit,
            .max_length = .omit,
            .autocomplete = .omit,
        };
    }
};

pub const StringOptionBuilder = struct {
    name: []const u8,
    name_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    description: []const u8,
    description_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    required: Omittable(bool) = .omit,
    choices: Omittable([]const StringChoice) = .omit,
    channel_types: Omittable([]const Channel.Type) = .omit,
    min_length: Omittable(i64) = .omit,
    max_length: Omittable(i64) = .omit,
    autocomplete: Omittable(bool) = .omit,

    fn build(self: @This()) ApplicationCommandOption {
        return ApplicationCommandOption{
            .type = .string,
            .name = self.name,
            .name_localizations = self.name_localizations,
            .description = self.description,
            .description_localizations = self.description_localizations,
            .required = self.required,
            .choices = if (self.choices == .some) .initSome(.{ .string = self.choices.some }) else .omit,
            .options = .omit,
            .channel_types = self.channel_types,
            .min_value = .omit,
            .max_value = .omit,
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
    required: Omittable(bool) = .omit,
    choices: Omittable([]const IntegerChoice) = .omit,
    channel_types: Omittable([]const Channel.Type) = .omit,
    min_value: Omittable(i64) = .omit,
    max_value: Omittable(i64) = .omit,
    autocomplete: Omittable(bool) = .omit,

    fn build(self: @This()) ApplicationCommandOption {
        return ApplicationCommandOption{
            .type = .integer,
            .name = self.name,
            .name_localizations = self.name_localizations,
            .description = self.description,
            .description_localizations = self.description_localizations,
            .required = self.required,
            .choices = if (self.choices == .some) .initSome(.{ .integer = self.choices.some }) else .omit,
            .options = .omit,
            .channel_types = self.channel_types,
            .min_value = .omit,
            .max_value = .omit,
            .min_length = .omit,
            .max_length = .omit,
            .autocomplete = self.autocomplete,
        };
    }
};

pub const NumberOptionBuilder = struct {
    name: []const u8,
    name_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    description: []const u8,
    description_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    required: Omittable(bool) = .omit,
    choices: Omittable([]const DoubleChoice) = .omit,
    channel_types: Omittable([]const Channel.Type) = .omit,
    min_value: Omittable(f64) = .omit,
    max_value: Omittable(f64) = .omit,
    autocomplete: Omittable(bool) = .omit,

    fn build(self: @This()) ApplicationCommandOption {
        return ApplicationCommandOption{
            .type = .number,
            .name = self.name,
            .name_localizations = self.name_localizations,
            .description = self.description,
            .description_localizations = self.description_localizations,
            .required = self.required,
            .choices = if (self.choices == .some) .initSome(.{ .double = self.choices.some }) else .omit,
            .options = .omit,
            .channel_types = self.channel_types,
            .min_value = .omit,
            .max_value = .omit,
            .min_length = .omit,
            .max_length = .omit,
            .autocomplete = self.autocomplete,
        };
    }
};

pub fn GenericOptionBuilder(optType: ApplicationCommandOptionType) type {
    return struct {
        name: []const u8,
        name_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
        description: []const u8,
        description_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
        required: Omittable(bool) = .omit,
        channel_types: Omittable([]const Channel.Type) = .omit,

        fn build(self: @This()) ApplicationCommandOption {
            return ApplicationCommandOption{
                .type = optType,
                .name = self.name,
                .name_localizations = self.name_localizations,
                .description = self.description,
                .description_localizations = self.description_localizations,
                .required = self.required,
                .choices = .omit,
                .options = .omit,
                .channel_types = self.channel_types,
                .min_value = .omit,
                .max_value = .omit,
                .min_length = .omit,
                .max_length = .omit,
                .autocomplete = .omit,
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
