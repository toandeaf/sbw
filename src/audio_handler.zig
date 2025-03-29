const std = @import("std");
const zaudio = @import("zaudio");

const SAMPLE_RATE = 44100;
const CHANNELS = 2;
const BUFFER_SIZE = SAMPLE_RATE * CHANNELS * @sizeOf(i16);

var audio_buffer: [BUFFER_SIZE]u8 = undefined;
var buffer_size: usize = 0;

pub fn main() !void {
    const loopback = try std.net.Ip4Address.parse("127.0.0.1", 9001);
    const localhost = std.net.Address{ .in = loopback };
    var server = try localhost.listen(.{ .reuse_address = true });
    defer server.deinit();

    std.debug.print("Server listening on 127.0.0.1:9001\n", .{});

    var client = try server.accept();
    defer client.stream.close();
    std.debug.print("Client connected!\n", .{});

    var deviceConfig = zaudio.Device.Config.init(zaudio.Device.Type.playback);
    deviceConfig.capture.format = zaudio.Format.signed16;
    deviceConfig.capture.channels = 1;
    deviceConfig.sample_rate = 44100;
    deviceConfig.data_callback = audio_callback;
    deviceConfig.user_data = null;

    var device = try zaudio.Device.create(null, deviceConfig);
    try device.start();
    defer device.destroy();

    const reader = client.stream.reader();

    while (true) {
        var temp_buffer: [1024]u8 = undefined;
        const bytes_read = reader.read(&temp_buffer) catch |err| {
            std.debug.print("Read error: {}\n", .{err});
            break;
        };

        if (bytes_read == 0) break; // Client disconnected

        const space_available = BUFFER_SIZE - buffer_size;
        const bytes_to_copy = @min(bytes_read, space_available);

        @memcpy(audio_buffer[buffer_size..][0..bytes_to_copy], temp_buffer[0..bytes_to_copy]);
        buffer_size += bytes_to_copy;
    }
}

fn audio_callback(
    _: *zaudio.Device,
    output: ?*anyopaque,
    _: ?*const anyopaque,
    frame_count: u32,
) callconv(.C) void {
    if (output == null) return;

    std.debug.print("receiving!", .{});


    const samples: [*]i16 = @ptrCast(@alignCast(output.?));
    const sample_count = frame_count * CHANNELS;
    const byte_count = sample_count * @sizeOf(i16);

    // Ensure we don't read out of bounds
    const copy_size = @min(audio_buffer.len, byte_count);
    @memcpy(samples[0..(copy_size / @sizeOf(i16))], @as([*]const i16, @ptrCast(@alignCast(&audio_buffer))));
}
