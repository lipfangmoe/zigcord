const std = @import("std");

pub const Upload = struct {
    content_type: []const u8,
    filename: []const u8,
    data: UploadData,

    /// Creates an `Upload` from a fixed number of bytes.
    pub fn fromBytes(filename: []const u8, content_type: []const u8, bytes: []const u8) Upload {
        return .{
            .filename = filename,
            .content_type = content_type,
            .data = .{ .bytes = bytes },
        };
    }

    /// Creates an `Upload` from a File Reader.
    pub fn fromFileReader(filename: []const u8, content_type: []const u8, file_reader: *std.fs.File.Reader) error{GetSizeError}!Upload {
        return .{
            .filename = filename,
            .content_type = content_type,
            .data = .{
                .reader_with_size = .{
                    .reader = &file_reader.interface,
                    .size = file_reader.getSize() catch return error.GetSizeError,
                },
            },
        };
    }

    /// Creates an `Upload` from an arbitrary reader where the caller knows how many bytes to read from the reader.
    pub fn fromReaderWithSize(filename: []const u8, content_type: []const u8, reader: *std.Io.Reader, size: u64) Upload {
        return .{
            .filename = filename,
            .content_type = content_type,
            .data = .{ .reader_with_size = .{ .reader = reader, .size = size } },
        };
    }

    /// Creates an `Upload` from an `std.Io.Reader`. Use one of the other constructor methods if possible, as sized readers allow the use of `content-length`.
    pub fn fromUnsizedReader(filename: []const u8, content_type: []const u8, reader: *std.Io.Reader) Upload {
        return .{
            .filename = filename,
            .content_type = content_type,
            .data = .{ .other_reader = reader },
        };
    }

    /// Returns the number of bytes contained in this upload, or `null` if the size cannot be known.
    pub fn getSize(self: Upload) ?u64 {
        return switch (self.data) {
            .bytes => |bytes| bytes.len,
            .reader_with_size => |reader_with_size| reader_with_size.size,
            .other_reader => null,
        };
    }
};

pub const UploadData = union(enum) {
    bytes: []const u8,
    reader_with_size: ReaderWithSize,
    other_reader: *std.Io.Reader,

    pub const ReaderWithSize = struct {
        reader: *std.Io.Reader,
        size: u64,
    };
};
