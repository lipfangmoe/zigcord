const std = @import("std");
const model = @import("zigcord").model;
const http = std.http;

pub const RestClient = @import("./rest/RestClient.zig");
pub const EndpointClient = @import("./rest/EndpointClient.zig");
pub const upload = @import("./rest/upload.zig");
pub const Upload = upload.Upload;
pub const Authorization = @import("./rest/authorization.zig").Authorization;

const multipart = @import("./rest/multipart.zig");
pub const multipart_boundary = multipart.boundary;
pub const MultipartFormDataBody = multipart.FormDataBody;
pub const getTransferEncoding = multipart.getTransferEncoding;

const discord_uri = @import("./rest/discord_uri.zig");
pub const base_url = discord_uri.base_url;
pub const allocDiscordUriStr = discord_uri.allocDiscordUriStr;

const query_strings = @import("./rest/query_strings.zig");
pub const queryFmt = query_strings.fmt;
pub const formatAsQueryString = query_strings.formatAsQueryString;

test {
    std.testing.refAllDecls(@This());
}
