const model = @import("../model.zig");
const Snowflake = model.Snowflake;
const deanson = model.deanson;
const Omittable = deanson.Omittable;
const channel = model.guild.channel;

pub const MessageComponentType = enum(u8) {
    action_row = 1,
    button = 2,
    string_select = 3,
    text_input = 4,
    user_select = 5,
    role_select = 6,
    mentionable_select = 7,
    channel_select = 8,
};

pub const MessageComponent = union(MessageComponentType) {
    action_row: ActionRowComponent,
    button: ButtonComponent,
    string_select: StringSelectComponent,
    text_input: TextInputComponent,
    user_select: UserSelectComponent,
    role_select: RoleSelectComponent,
    mentionable_select: MentionableSelectComponent,
    channel_select: ChannelSelectComponent,
};

pub const ActionRowComponent = struct {
    components: []MessageComponent,
};
pub const ButtonComponent = struct {
    style: ButtonStyle,
    label: Omittable([]const u8) = .omit,
    emoji: Omittable(PartialEmoji) = .omit,
    custom_id: Omittable([]const u8) = .omit,
    url: Omittable([]const u8) = .omit,
    disabled: Omittable(bool) = .omit,
};
pub const StringSelectComponent = struct {
    custom_id: []const u8,
    options: Omittable([]const SelectOption) = .omit,
    channel_types: Omittable([]const channel.Type) = .omit,
    placeholder: Omittable([]const u8) = .omit,
    default_values: Omittable([]const DefaultValue) = .omit,
    min_values: Omittable(i64) = .omit,
    max_values: Omittable(i64) = .omit,
    disabled: Omittable(bool) = .omit,
};

// TODO
pub const TextInputComponent = struct {};
pub const UserSelectComponent = struct {};
pub const RoleSelectComponent = struct {};
pub const MentionableSelectComponent = struct {};
pub const ChannelSelectComponent = struct {};

pub const ButtonStyle = enum {};
pub const PartialEmoji = struct {
    id: ?Snowflake,
    name: ?[]const u8,
    animated: Omittable(bool) = .omit,
};

pub const SelectOption = struct {
    label: []const u8,
    value: []const u8,
    description: Omittable([]const u8) = .omit,
    emoji: Omittable(PartialEmoji) = .omit,
    default: Omittable(bool) = .omit,
};

pub const DefaultValue = struct {
    id: Snowflake,
    type: enum(u2) {
        user,
        role,
        channel,

        pub fn jsonStringify(self: DefaultValue, jw: anytype) !void {
            switch (self) {
                .user => try jw.write("user"),
                .role => try jw.write("role"),
                .channel => try jw.write("channel"),
            }
        }
    },
};
