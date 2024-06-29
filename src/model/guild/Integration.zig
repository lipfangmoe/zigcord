const model = @import("../../model.zig");
const deanson = model.deanson;
const Omittable = deanson.Omittable;

id: model.Snowflake,
name: []const u8,
type: []const u8,
enabled: bool,
syncing: Omittable(bool) = .omit,
role_id: Omittable(model.Snowflake) = .omit,
enable_emoticons: Omittable(bool) = .omit,
expire_behavior: Omittable(ExpireBehavior) = .omit,
expire_grace_period: Omittable(i64) = .omit,
user: Omittable(model.User) = .omit,
account: Omittable(Account) = .omit,
synced_at: Omittable([]const u8) = .omit,
subscriber_count: Omittable(i64) = .omit,
revoked: Omittable(bool) = .omit,
application: Omittable(Application) = .omit,
scopes: Omittable([]const []const u8) = .omit,

pub const ExpireBehavior = enum(u1) {
    remove_role = 0,
    kick = 1,
};

pub const Account = struct {
    id: []const u8,
    name: []const u8,
};

pub const Application = struct {};
