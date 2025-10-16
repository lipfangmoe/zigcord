const std = @import("std");

pub fn verify(headers: SignatureHeaders, body: []const u8, application_public_key: std.crypto.sign.Ed25519.PublicKey) error{ InvalidPublicKey, SignatureVerificationError }!void {
    const signature = std.crypto.sign.Ed25519.Signature.fromBytes(headers.signature_bytes);
    var verifier = signature.verifier(application_public_key) catch return error.InvalidPublicKey;
    verifier.update(headers.timestamp.items);
    verifier.update(body);
    verifier.verify() catch return error.SignatureVerificationError;
}

pub const SignatureHeaders = struct {
    signature_bytes: [signature_len]u8,
    timestamp: std.ArrayList(u8),

    const signature_len = std.crypto.sign.Ed25519.Signature.encoded_length;

    pub fn initFromHttpRequest(http_request: *std.http.Server.Request, buf: *[64]u8) error{ InvalidHeader, MissingHeader }!SignatureHeaders {
        var timestamp = std.ArrayList(u8).initBuffer(buf);
        var signature_buf: [signature_len]u8 = undefined;
        var signature_set = false;

        var headers = http_request.iterateHeaders();
        while (headers.next()) |header| {
            if (std.mem.eql(u8, header.name, "X-Signature-Ed25519")) {
                const slice = std.fmt.hexToBytes(&signature_buf, header.value) catch return error.InvalidHeader;
                if (slice.len != signature_len) {
                    return error.InvalidHeader;
                }
                signature_set = true;
            }
            if (std.mem.eql(u8, header.name, "X-Signature-Timestamp")) {
                timestamp.appendSliceBounded(header.value) catch return error.InvalidHeader;
            }
        }
        if (timestamp.items.len == 0 or !signature_set) {
            return error.MissingHeader;
        }
        return SignatureHeaders{
            .signature_bytes = signature_buf,
            .timestamp = timestamp,
        };
    }
};
