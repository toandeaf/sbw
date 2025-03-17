const std = @import("std");
const audio = @import("../src/resources/audio.zig");

pub fn main() !void {
    const loopback = try std.net.Ip4Address.parse("127.0.0.1", 9001);
    const localhost = std.net.Address{ .in = loopback };
    var server = try localhost.listen(.{
        .reuse_address = true,
    });
    defer server.deinit();

    std.debug.print("Server acceptance", .{});

    var audio_file = try std.fs.cwd().createFile("audio_output_server.wav", .{ .truncate = true });
    defer audio.finalize_wav_header(&audio_file) catch {};

    try audio.write_wav_header(&audio_file, 44100, 0);

    var client = try server.accept();
    defer client.stream.close();

    var audio_buffer: [44100]i16 = undefined; // 1 second buffer at 44.1kHz (16-bit PCM)
    var buffer_index: usize = 0;

    const reader = client.stream.reader();

    while (true) {
        // Read data in chunks to fill the buffer
        var temp_buffer: [1024]u8 = undefined;
        const bytes_read = reader.read(&temp_buffer) catch |err| {
            std.debug.print("Read error: {}\n", .{err});
            break;
        };

        if (bytes_read == 0) break; // Stream closed by sender

        // Ensure we don't overflow audio_buffer
        const samples_to_store = @min(bytes_read / @sizeOf(i16), audio_buffer.len - buffer_index);

        if (samples_to_store > 0) {
            const ptr: [*]u8 = @ptrCast(&audio_buffer[buffer_index]);
            @memcpy(ptr[0 .. samples_to_store * @sizeOf(i16)], temp_buffer[0 .. samples_to_store * @sizeOf(i16)]);
            buffer_index += samples_to_store;
        }

        // If buffer is full, write to file - TODO replace with write to audio device.
        if (buffer_index >= audio_buffer.len) {
            _ = audio_file.write(std.mem.sliceAsBytes(&audio_buffer)) catch {};
            buffer_index = 0; // Reset for new data
        }
    }
}
