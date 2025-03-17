const std = @import("std");
const zaudio = @import("zaudio");
const audio = @import("../src/resources/audio.zig");

const SAMPLE_RATE = 44100;
const CHANNELS = 2;
const BUFFER_SIZE = SAMPLE_RATE * CHANNELS * @sizeOf(i16);

var audio_buffer: [BUFFER_SIZE]u8 = undefined;
var buffer_index: usize = 0;
var buffer_size: usize = 0;

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

// TODO integrate this with the network call
fn audio_callback(
    _: *zaudio.Device,
    output: ?*anyopaque,
    _: ?*const anyopaque,
    frame_count: u32,
) callconv(.C) void {
    if (output == null) return;

    const samples: [*]i16 = @ptrCast(@alignCast(output.?));
    const sample_count = frame_count * CHANNELS;
    const byte_count = sample_count * @sizeOf(i16);

    // Ensure we don't read out of bounds
    const copy_size = @min(audio_buffer.len, byte_count);
    @memcpy(samples[0..(copy_size / @sizeOf(i16))], @as([*]const i16, @ptrCast(@alignCast(&audio_buffer))));
}