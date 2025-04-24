const zigcord = @import("../../root.zig");
const std = @import("std");
const model = zigcord.model;
const rest = zigcord.rest;

pub fn listVoiceRegions(
    client: *rest.EndpointClient,
) !rest.RestClient.Result([]const model.voice.Region) {
    const url = try std.Uri.parse(rest.base_url ++ "/voice/regions");

    return client.rest_client.request([]const model.voice.Region, .GET, url);
}
