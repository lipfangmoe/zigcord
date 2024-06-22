const model = @import("../../model.zig");
const deanson = model.deanson;
const Omittable = deanson.Omittable;

id: model.Snowflake,
name: []const u8,
type: []const u8,
enabled: bool,
syncing: Omittable(bool) = .{ .omitted = void{} },
role_id: Omittable(model.Snowflake) = .{ .omitted = void{} },
enable_emoticons: Omittable(bool) = .{ .omitted = void{} },
expire_behavior: Omittable(ExpireBehavior) = .{ .omitted = void{} },
expire_grace_period: Omittable(i64) = .{ .omitted = void{} },
user: Omittable(model.User) = .{ .omitted = void{} },
account: Omittable(Account) = .{ .omitted = void{} },
synced_at: Omittable([]const u8) = .{ .omitted = void{} },
subscriber_count: Omittable(i64) = .{ .omitted = void{} },
revoked: Omittable(bool) = .{ .omitted = void{} },
application: Omittable(Application) = .{ .omitted = void{} },
scopes: Omittable([]const []const u8) = .{ .omitted = void{} },

pub const ExpireBehavior = enum(u1) {
    remove_role = 0,
    kick = 1,
};

pub const Account = struct {
    id: []const u8,
    name: []const u8,
};

pub const Application = struct {};
