const std = @import("std");
const jconfig = @import("jconfig");

provider_type: []const u8,
provider_id: ?[]const u8 = null,
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
    season: ?[]const u8 = null,
    rank_name: ?[]const u8 = null,
    rank_image: ?MediaValue = null,
    highest_rank: ?[]const u8 = null,
    highest_rank_image: ?MediaValue = null,
    featured_played_character: ?[]const u8 = null,
    featured_played_character_image: ?MediaValue = null,
    playtime_hours: ?u64 = null,
    total_wins: ?u64 = null,
    current_period_wins: ?u64 = null,
    total_games: ?u64 = null,
    current_period_games: ?u64 = null,
    total_kills: ?u64 = null,
    current_period_kills: ?u64 = null,
    total_assists: ?u64 = null,
    current_period_assists: ?u64 = null,
    total_deaths: ?u64 = null,
    current_period_deaths: ?u64 = null,

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
