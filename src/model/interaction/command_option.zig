const std = @import("std");
const model = @import("../../root.zig").model;
const Channel = model.Channel;
const deanson = model.deanson;
const Omittable = deanson.Omittable;

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

    pub const jsonStringify = deanson.stringifyEnumAsInt;
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
    options: Omittable([]ApplicationCommandOption) = .omit,
    channel_types: Omittable([]const Channel.Type) = .omit,
    min_value: Omittable(union(enum) {
        double: f64,
        integer: i64,
        pub usingnamespace deanson.InlineUnionJsonMixin(@This());
    }) = .omit,
    max_value: Omittable(union(enum) {
        double: f64,
        integer: i64,
        pub usingnamespace deanson.InlineUnionJsonMixin(@This());
    }) = .omit,
    min_length: Omittable(i64) = .omit,
    max_length: Omittable(i64) = .omit,
    autocomplete: Omittable(bool) = .omit,

    pub const Builder = union(ApplicationCommandOptionType) {
        subcommand: SubcommandOptionBuilder,
        subcommand_group: SubcommandGroupOptionBuilder,
        string: StringOptionBuilder,
        integer: IntegerOptionBuilder,
        boolean: GenericOptionBuilder(.boolean),
        user: GenericOptionBuilder(.user),
        channel: GenericOptionBuilder(.channel),
        role: GenericOptionBuilder(.role),
        mentionable: GenericOptionBuilder(.mentionable),
        number: NumberOptionBuilder,
        attachment: GenericOptionBuilder(.attachment),
    };

    pub const Choices = union(enum) {
        string: []StringChoice,
        integer: []IntegerChoice,
        double: []DoubleChoice,

        pub usingnamespace deanson.InlineUnionJsonMixin(@This());
    };

    pub const jsonStringify = deanson.stringifyWithOmit;

    /// Creates an ApplicationCommandOption from a builder. See `Builder` for a list of allowed builders.
    pub fn new(builder: Builder) ApplicationCommandOption {
        return switch (builder) {
            inline else => |value| value.build(),
        };
    }
};

pub const SubcommandOptionBuilder = struct {
    name: []const u8,
    name_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    description: []const u8,
    description_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    required: Omittable(bool) = .omit,
    options: Omittable([]ApplicationCommandOption) = .omit,
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
    options: Omittable([]ApplicationCommandOption) = .omit,
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
    choices: Omittable([]StringChoice) = .omit,
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
            .choices = if (self.choices == .some) .{ .some = .{ .string = self.choices.some } } else .omit,
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
    choices: Omittable([]IntegerChoice) = .omit,
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
            .choices = if (self.choices == .some) .{ .some = .{ .integer = self.choices.some } } else .omit,
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
    choices: Omittable([]DoubleChoice) = .omit,
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
            .choices = if (self.choices == .some) .{ .some = .{ .double = self.choices.some } } else .omit,
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

    pub const jsonStringify = deanson.stringifyWithOmit;
};

/// A possible choice for an ApplicationCommandOption of type `integer`.
pub const IntegerChoice = struct {
    name: []const u8,
    name_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    value: i64,

    pub const jsonStringify = deanson.stringifyWithOmit;
};

/// A possible choice for an ApplicationCommandOption of type `double`.
pub const DoubleChoice = struct {
    name: []const u8,
    name_localizations: Omittable(?std.json.ArrayHashMap([]const u8)) = .omit,
    value: f64,

    pub const jsonStringify = deanson.stringifyWithOmit;
};
