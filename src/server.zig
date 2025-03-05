const std = @import("std");
const net = std.net;

pub fn main() !void {
    const page_allocator = std.heap.page_allocator;

    // Connect to the audio stream source
    var conn = try net.tcpConnectToHost(page_allocator, "127.0.0.1", 9001);
    defer conn.stream.close();

    std.debug.print("Connected to audio stream!\n", .{});

    var audio_buffer: [44100]i16 = undefined; // 1 second buffer at 44.1kHz (16-bit PCM)
    var buffer_index: usize = 0;

    while (true) {
        // Read data in chunks to fill the buffer
        var temp_buffer: [1024]u8 = undefined;
        const bytes_read = conn.stream.read(&temp_buffer) catch |err| {
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

        std.debug.print("Received {} bytes, buffer index: {}\n", .{ bytes_read, buffer_index });

        // If buffer is full, process audio data (e.g., write to a file, playback, etc.)
        if (buffer_index >= audio_buffer.len) {
            std.debug.print("Buffer full, processing audio...\n", .{});
            buffer_index = 0; // Reset for new data
        }
    }
}
