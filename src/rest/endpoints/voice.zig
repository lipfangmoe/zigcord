const deancord = @import("../../root.zig");
const std = @import("std");
const model = deancord.model;
const rest = deancord.rest;

pub fn listVoiceRegions(
    client: *rest.ApiClient,
) !rest.Client.Result([]const model.voice.Region) {
    const url = try std.Uri.parse(rest.base_url ++ "/voice/regions");

    return client.rest_client.request([]const model.voice.Region, .GET, url);
}
