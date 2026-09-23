const std = @import("std");
const jconfig = @import("jconfig");

provider_type: []const u8,
provider_id: jconfig.Omittable([]const u8) = .omit,
provider_issued_user_id: []const u8,

pub const jsonStringify = jconfig.stringifyWithOmit;

pub const Profile = struct {
    username: ?[]const u8,
    metadata: ?std.json.ArrayHashMap(std.json.Value),
    data: ?ProfileData,
};

pub const ProfileData = struct {
    primary: PrimaryProfileData,
    dynamic: []const DynamicProfileField,
};

pub const PrimaryProfileData = struct {
    season: jconfig.Omittable([]const u8) = .omit,
    rank_name: jconfig.Omittable([]const u8) = .omit,
    rank_image: jconfig.Omittable(MediaValue) = .omit,
    highest_rank: jconfig.Omittable([]const u8) = .omit,
    highest_rank_image: jconfig.Omittable(MediaValue) = .omit,
    featured_played_character: jconfig.Omittable([]const u8) = .omit,
    featured_played_character_image: jconfig.Omittable(MediaValue) = .omit,
    playtime_hours: jconfig.Omittable(u64) = .omit,
    total_wins: jconfig.Omittable(u64) = .omit,
    current_period_wins: jconfig.Omittable(u64) = .omit,
    total_games: jconfig.Omittable(u64) = .omit,
    current_period_games: jconfig.Omittable(u64) = .omit,
    total_kills: jconfig.Omittable(u64) = .omit,
    current_period_kills: jconfig.Omittable(u64) = .omit,
    total_assists: jconfig.Omittable(u64) = .omit,
    current_period_assists: jconfig.Omittable(u64) = .omit,
    total_deaths: jconfig.Omittable(u64) = .omit,
    current_period_deaths: jconfig.Omittable(u64) = .omit,

    pub const jsonStringify = jconfig.stringifyWithOmit;
};

pub const DynamicProfileField = struct {
    type: Type,
    name: []const u8,
    value: Value,

    pub fn initStringField(name: []const u8, value: []const u8) DynamicProfileField {
        return .{ .type = .string, .name = name, .value = .{ .string = value } };
    }

    pub fn initNumberField(name: []const u8, value: u64) DynamicProfileField {
        return .{ .type = .number, .name = name, .value = .{ .number = value } };
    }

    pub fn initMediaField(name: []const u8, url: []const u8) DynamicProfileField {
        return .{ .type = .media, .name = name, .value = .{ .media = .{ .url = url } } };
    }

    const Type = enum(u8) { string = 1, number = 2, media = 3 };

    const Value = union(Type) {
        string: []const u8,
        number: u64,
        media: MediaValue,
    };
};

const MediaValue = struct {
    url: []const u8,
};
