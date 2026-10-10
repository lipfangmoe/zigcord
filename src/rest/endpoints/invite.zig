const std = @import("std");
const model = @import("model");
const jconfig = @import("jconfig");
const EndpointClient = @import("../EndpointClient.zig");
const RestClient = @import("../RestClient.zig");
const Result = RestClient.Result;
const allocDiscordUriStr = @import("../discord_uri.zig").allocDiscordUriStr;
const Upload = @import("../upload.zig").Upload;
const multipart = @import("../multipart.zig");
const query_strings = @import("../query_strings.zig");

pub fn getInvite(
    client: *EndpointClient,
    code: []const u8,
    query: GetInviteQuery,
) !Result(model.Invite) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/invites/{s}?{f}", .{ code, query });
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(model.Invite, .GET, uri);
}

pub fn deleteInvite(
    client: *EndpointClient,
    code: []const u8,
    audit_log_reason: ?[]const u8,
) !Result(model.Invite) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/invites/{s}", .{code});
    defer client.rest_client.allocator.free(uri_str);
    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.requestWithAuditLogReason(model.Invite, .DELETE, uri, audit_log_reason);
}

pub fn getTargetUsers(
    client: *EndpointClient,
    invite_code: []const u8,
) !GetTargetUsersResponse {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/invites/{s}/target-users", .{invite_code});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    const pending_result = try client.rest_client.request(RestClient.RawBody, .GET, uri);

    return .{ .rest_result = pending_result };
}

pub fn addTargetUser(
    client: *EndpointClient,
    invite_code: []const u8,
    user_id: model.Snowflake,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/invites/{s}/target-users/{f}", .{ invite_code, user_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return try client.rest_client.request(void, .PUT, uri);
}

pub fn removeTargetUser(
    client: *EndpointClient,
    invite_code: []const u8,
    user_id: model.Snowflake,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/invites/{s}/target-users/{f}", .{ invite_code, user_id });
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return try client.rest_client.request(void, .DELETE, uri);
}

pub fn updateTargetUsers(
    client: *EndpointClient,
    invite_code: []const u8,
    body: UpdateTargetUsersFormBody,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/invites/{s}/target-users", .{invite_code});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    const transfer_encoding = try multipart.getTransferEncoding(body, "target_users_file");

    // https://codeberg.org/ziglang/zig/issues/30623 - for now, we will write the file
    // to an allocatingwriter and send it all in one shot. once streaming to body_writer is fixed,
    // this should be updated to write directly to body_writer instead of allocating the entire file.
    var aw: std.Io.Writer.Allocating = switch (transfer_encoding) {
        .content_length => |len| try .initCapacity(client.rest_client.allocator, len),
        .chunked => .init(client.rest_client.allocator),
        .none => unreachable,
    };
    defer aw.deinit();

    try aw.writer.print("{f}", .{body.fmt("target_users_file")});

    var buf: [1028]u8 = undefined;
    var pending_request = try client.rest_client.beginMultipartRequest(void, .PUT, uri, transfer_encoding, multipart.boundary, &buf);

    try pending_request.request.sendBodyComplete(aw.written());

    return try pending_request.waitForResponse();
}

pub fn bulkAddTargetUser(
    client: *EndpointClient,
    invite_code: []const u8,
    body: BulkAddTargetUsersBody,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/invites/{s}/target-users/bulk-add", .{invite_code});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return try client.rest_client.requestWithJsonBody(void, .POST, uri, body, .{});
}

pub fn bulkDeleteTargetUser(
    client: *EndpointClient,
    invite_code: []const u8,
    body: BulkDeleteTargetUsersBody,
) !Result(void) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/invites/{s}/target-users/bulk-delete", .{invite_code});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return try client.rest_client.requestWithJsonBody(void, .POST, uri, body, .{});
}

pub fn getTargetUsersJobStatus(
    client: *EndpointClient,
    invite_code: []const u8,
) !Result(JobStatus) {
    const uri_str = try allocDiscordUriStr(client.rest_client.allocator, "/invites/{s}/target-users/job-status", .{invite_code});
    defer client.rest_client.allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);

    return client.rest_client.request(JobStatus, .GET, uri);
}

pub const GetInviteQuery = struct {
    with_counts: ?bool,
    with_expiration: ?bool,
    guild_scheduled_event_id: ?model.Snowflake,

    pub const format = query_strings.formatAsQueryString;
};

pub const GetTargetUsersResponse = struct {
    rest_result: Result(RestClient.RawBody),

    /// same as iterUsers, but returns an easier-to-use but harder-to-debug error union instead of a DiscordError when an error occurs.
    pub fn iterUsersOk(self: *GetTargetUsersResponse) !UsersIterator {
        const raw_body = try self.rest_result.valueOk();
        return .{ .reader = raw_body.reader, .header_read = false };
    }

    pub fn iterUsers(self: *GetTargetUsersResponse) Result(UsersIterator) {
        return switch (self.rest_result) {
            .ok => |ok| .{ .ok = .{ .status = ok.status, .value = UsersIterator{ .reader = ok.value.reader, .header_read = false }, .parsed = null } },
            .err => |err| .{ .err = .{ .status = err.status, .value = err.value, .parsed = err.parsed } },
        };
    }
};

pub const UpdateTargetUsersFormBody = multipart.FormDataBody(Upload, void);

pub const UsersIterator = struct {
    reader: *std.Io.Reader,
    header_read: bool,

    pub fn next(self: *UsersIterator) !?model.Snowflake {
        if (!self.header_read) {
            const header = self.reader.takeDelimiter('\n') catch |err| switch (err) {
                error.ReadFailed => return error.ReadFailed,
                error.StreamTooLong => return error.HeaderLineTooLong,
            } orelse return error.InvalidHeader;
            if (!std.mem.eql(u8, header, "user_id")) {
                return error.InvalidHeader;
            }
            self.header_read = true;
        }

        const user_id_str_opt = self.reader.takeDelimiter('\n') catch |err| switch (err) {
            error.ReadFailed => return error.ReadFailed,
            error.StreamTooLong => return error.UserIdLineTooLong,
        };
        const user_id_str = user_id_str_opt orelse return null;
        return try model.Snowflake.fromString(user_id_str);
    }
};

pub const JobStatus = struct {
    status: StatusCode,
    total_users: i64,
    processed_users: i64,
    created_at: model.IsoTime,
    completed_at: ?model.IsoTime,
    // TODO - verify whether this is omitted or null if no error occurs
    error_message: jconfig.Omittable(?[]const u8) = .omit,

    pub const StatusCode = enum(u32) {
        unspecified = 0,
        processing = 1,
        completed = 2,
        failed = 3,

        pub const jsonStringify = jconfig.stringifyEnumAsInt;
    };
};

pub const BulkAddTargetUsersBody = struct {
    user_ids: []const model.Snowflake,
};

pub const BulkDeleteTargetUsersBody = struct {
    user_ids: []const model.Snowflake,
};
