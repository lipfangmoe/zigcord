# v0.7.0

# v0.6.0

 * **main feature**: fixes an issue where EndpointClient methods which allowed uploading files did not work properly
   * **breaking(?)**: these methods now have you supply a `zigcord.rest.Upload` instead of an `*std.Io.Reader` for the file.
   * this involves specifying both the filename and content-type of the file.
   * this is only questionably a breaking change because these methods used to panic or error if used.
   * Noteworthy that `zigcord.rest.Upload` contains several functions to allow easily creating uploads
     * `.fromBytes(filename: []const u8, content_type: []const u8, bytes: []const u8)`
     * `.fromFileReader(filename: []const u8, content_type: []const u8, file_reader: *std.fs.File.Reader)`
     * `.fromReaderWithSize(filename: []const u8, content_type: []const u8, reader: *std.Io.Reader, size: u64)`
 * **breaking**: low-level function `setupMultipartRequest` no longer accepts a list of extra headers. you will need to use `setupRequest` if you want access to extra headers (other than audit log reason, detailed next).
 * new low-level function: `setupMultipartRequestWithAuditLogReason` to allow for easy mutlipart requests with the `X-Audit-Log-Reason` header set.
 * **breaking**: renames low-level function `requestWithValueBody` to `requestWithJsonBody`
