const std = @import("std");
const channel = @import("../guild/channel.zig");
const model = @import("../../model.zig");
const Localizations = model.Localizations;
const deanson = @import("../deanson.zig");
const Omittable = model.deanson.Omittable;

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
    name_localizations: Omittable(?Localizations) = .{ .omitted = void{} },
    description: []const u8,
    description_localizations: Omittable(?Localizations) = .{ .omitted = void{} },
    required: Omittable(bool) = .{ .omitted = void{} },
    choices: Omittable(Choices) = .{ .omitted = void{} },
    options: Omittable([]ApplicationCommandOption) = .{ .omitted = void{} },
    channel_types: Omittable([]const channel.Type) = .{ .omitted = void{} },
    min_value: Omittable(union(enum) {
        double: f64,
        integer: i64,
        pub const jsonStringify = deanson.stringifyUnionInline;
    }) = .{ .omitted = void{} },
    max_value: Omittable(union(enum) {
        double: f64,
        integer: i64,
        pub const jsonStringify = deanson.stringifyUnionInline;
    }) = .{ .omitted = void{} },
    min_length: Omittable(i64) = .{ .omitted = void{} },
    max_length: Omittable(i64) = .{ .omitted = void{} },
    autocomplete: Omittable(bool) = .{ .omitted = void{} },

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

        pub const jsonStringify = deanson.stringifyUnionInline;
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
    name_localizations: Omittable(?Localizations) = .{ .omitted = void{} },
    description: []const u8,
    description_localizations: Omittable(?Localizations) = .{ .omitted = void{} },
    required: Omittable(bool) = .{ .omitted = void{} },
    options: Omittable([]ApplicationCommandOption) = .{ .omitted = void{} },
    channel_types: Omittable([]const channel.Type) = .{ .omitted = void{} },

    fn build(self: @This()) ApplicationCommandOption {
        return ApplicationCommandOption{
            .type = .subcommand,
            .name = self.name,
            .name_localizations = self.name_localizations,
            .description = self.description,
            .description_localizations = self.description_localizations,
            .required = self.required,
            .choices = .{ .omitted = void{} },
            .options = self.options,
            .channel_types = self.channel_types,
            .min_value = .{ .omitted = void{} },
            .max_value = .{ .omitted = void{} },
            .min_length = .{ .omitted = void{} },
            .max_length = .{ .omitted = void{} },
            .autocomplete = .{ .omitted = void{} },
        };
    }
};

pub const SubcommandGroupOptionBuilder = struct {
    name: []const u8,
    name_localizations: Omittable(?Localizations) = .{ .omitted = void{} },
    description: []const u8,
    description_localizations: Omittable(?Localizations) = .{ .omitted = void{} },
    required: Omittable(bool) = .{ .omitted = void{} },
    options: Omittable([]ApplicationCommandOption) = .{ .omitted = void{} },
    channel_types: Omittable([]const channel.Type) = .{ .omitted = void{} },

    fn build(self: @This()) ApplicationCommandOption {
        return ApplicationCommandOption{
            .type = .subcommand_group,
            .name = self.name,
            .name_localizations = self.name_localizations,
            .description = self.description,
            .description_localizations = self.description_localizations,
            .required = self.required,
            .choices = .{ .omitted = void{} },
            .options = self.options,
            .channel_types = self.channel_types,
            .min_value = .{ .omitted = void{} },
            .max_value = .{ .omitted = void{} },
            .min_length = .{ .omitted = void{} },
            .max_length = .{ .omitted = void{} },
            .autocomplete = .{ .omitted = void{} },
        };
    }
};

pub const StringOptionBuilder = struct {
    type: ApplicationCommandOptionType,
    name: []const u8,
    name_localizations: Omittable(?Localizations) = .{ .omitted = void{} },
    description: []const u8,
    description_localizations: Omittable(?Localizations) = .{ .omitted = void{} },
    required: Omittable(bool) = .{ .omitted = void{} },
    choices: Omittable([]StringChoice) = .{ .omitted = void{} },
    channel_types: Omittable([]const channel.Type) = .{ .omitted = void{} },
    min_length: Omittable(i64) = .{ .omitted = void{} },
    max_length: Omittable(i64) = .{ .omitted = void{} },
    autocomplete: Omittable(bool) = .{ .omitted = void{} },

    fn build(self: @This()) ApplicationCommandOption {
        return ApplicationCommandOption{
            .type = .string,
            .name = self.name,
            .name_localizations = self.name_localizations,
            .description = self.description,
            .description_localizations = self.description_localizations,
            .required = self.required,
            .choices = if (self.choices == .some) .{ .some = .{ .string = self.choices.some } } else .{ .omitted = void{} },
            .options = .{ .omitted = void{} },
            .channel_types = self.channel_types,
            .min_value = .{ .omitted = void{} },
            .max_value = .{ .omitted = void{} },
            .min_length = self.min_length,
            .max_length = self.max_length,
            .autocomplete = self.autocomplete,
        };
    }
};

pub const IntegerOptionBuilder = struct {
    type: ApplicationCommandOptionType,
    name: []const u8,
    name_localizations: Omittable(?Localizations) = .{ .omitted = void{} },
    description: []const u8,
    description_localizations: Omittable(?Localizations) = .{ .omitted = void{} },
    required: Omittable(bool) = .{ .omitted = void{} },
    choices: Omittable([]IntegerChoice) = .{ .omitted = void{} },
    channel_types: Omittable([]const channel.Type) = .{ .omitted = void{} },
    min_value: Omittable(i64) = .{ .omitted = void{} },
    max_value: Omittable(i64) = .{ .omitted = void{} },
    autocomplete: Omittable(bool) = .{ .omitted = void{} },

    fn build(self: @This()) ApplicationCommandOption {
        return ApplicationCommandOption{
            .type = .integer,
            .name = self.name,
            .name_localizations = self.name_localizations,
            .description = self.description,
            .description_localizations = self.description_localizations,
            .required = self.required,
            .choices = if (self.choices == .some) .{ .some = .{ .integer = self.choices.some } } else .{ .omitted = void{} },
            .options = .{ .omitted = void{} },
            .channel_types = self.channel_types,
            .min_value = .{ .omitted = void{} },
            .max_value = .{ .omitted = void{} },
            .min_length = .{ .omitted = void{} },
            .max_length = .{ .omitted = void{} },
            .autocomplete = self.autocomplete,
        };
    }
};

pub const NumberOptionBuilder = struct {
    type: ApplicationCommandOptionType,
    name: []const u8,
    name_localizations: Omittable(?Localizations) = .{ .omitted = void{} },
    description: []const u8,
    description_localizations: Omittable(?Localizations) = .{ .omitted = void{} },
    required: Omittable(bool) = .{ .omitted = void{} },
    choices: Omittable([]DoubleChoice) = .{ .omitted = void{} },
    channel_types: Omittable([]const channel.Type) = .{ .omitted = void{} },
    min_value: Omittable(f64) = .{ .omitted = void{} },
    max_value: Omittable(f64) = .{ .omitted = void{} },
    autocomplete: Omittable(bool) = .{ .omitted = void{} },

    fn build(self: @This()) ApplicationCommandOption {
        return ApplicationCommandOption{
            .type = .number,
            .name = self.name,
            .name_localizations = self.name_localizations,
            .description = self.description,
            .description_localizations = self.description_localizations,
            .required = self.required,
            .choices = if (self.choices == .some) .{ .some = .{ .double = self.choices.some } } else .{ .omitted = void{} },
            .options = .{ .omitted = void{} },
            .channel_types = self.channel_types,
            .min_value = .{ .omitted = void{} },
            .max_value = .{ .omitted = void{} },
            .min_length = .{ .omitted = void{} },
            .max_length = .{ .omitted = void{} },
            .autocomplete = self.autocomplete,
        };
    }
};

pub fn GenericOptionBuilder(optType: ApplicationCommandOptionType) type {
    return struct {
        name: []const u8,
        name_localizations: Omittable(?Localizations) = .{ .omitted = void{} },
        description: []const u8,
        description_localizations: Omittable(?Localizations) = .{ .omitted = void{} },
        required: Omittable(bool) = .{ .omitted = void{} },
        channel_types: Omittable([]const channel.Type) = .{ .omitted = void{} },

        fn build(self: @This()) ApplicationCommandOption {
            return ApplicationCommandOption{
                .type = optType,
                .name = self.name,
                .name_localizations = self.name_localizations,
                .description = self.description,
                .description_localizations = self.description_localizations,
                .required = self.required,
                .choices = .{ .omitted = void{} },
                .options = .{ .omitted = void{} },
                .channel_types = self.channel_types,
                .min_value = .{ .omitted = void{} },
                .max_value = .{ .omitted = void{} },
                .min_length = .{ .omitted = void{} },
                .max_length = .{ .omitted = void{} },
                .autocomplete = .{ .omitted = void{} },
            };
        }
    };
}

/// A possible choice for an ApplicationCommandOption of type `string`.
pub const StringChoice = struct {
    name: []const u8,
    name_localizations: Omittable(?Localizations) = .{ .omitted = void{} },
    value: []const u8,

    pub const jsonStringify = deanson.stringifyWithOmit;
};

/// A possible choice for an ApplicationCommandOption of type `integer`.
pub const IntegerChoice = struct {
    name: []const u8,
    name_localizations: Omittable(?Localizations) = .{ .omitted = void{} },
    value: i64,

    pub const jsonStringify = deanson.stringifyWithOmit;
};

/// A possible choice for an ApplicationCommandOption of type `double`.
pub const DoubleChoice = struct {
    name: []const u8,
    name_localizations: Omittable(?Localizations) = .{ .omitted = void{} },
    value: f64,

    pub const jsonStringify = deanson.stringifyWithOmit;
};
