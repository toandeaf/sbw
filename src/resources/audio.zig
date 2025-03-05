const std = @import("std");
const net = @import("std").net;
const fs = @import("std").fs;

const zaudio = @import("zaudio");

const n = @import("network.zig");
const constants = @import("constants.zig");


var audio_buffer: [constants.BUFFER_SIZE]i16 = undefined;
var buffer_index: usize = 0;
var audio_file: ?std.fs.File = null;

var device: *zaudio.Device = undefined; // Nullable pointer

pub fn Init() anyerror!void {
    const allocator = std.heap.page_allocator;
    zaudio.init(allocator);

    var config = zaudio.Device.Config.init(zaudio.Device.Type.capture);

    config.capture.device_id = null;
    config.capture.format = zaudio.Format.signed16;
    config.capture.channels = 1;
    config.sample_rate = 44100;
    config.data_callback = audioCallback;
    config.user_data = null;

    device = try zaudio.Device.create(null, config);
    try InitFile();
}

pub fn Deinit() anyerror!void {
    if (audio_file) |*f| {
        const file_size = try f.getEndPos();
        try f.seekTo(4);

        const block: u32 = @intCast(file_size - 8);
        try f.writeAll(&std.mem.toBytes(block)); // RIFF chunk size
        //
        try f.seekTo(40);
        const sure: u32 = @intCast(file_size - 44);
        try f.writeAll(&std.mem.toBytes(sure)); // Data chunk size
        f.close();
        audio_file = null;
    }

    device.destroy();
    zaudio.deinit();
}

pub fn Listen() anyerror!void {
    try device.start();
}

pub fn StopListening() void {
    device.stop();
}

fn InitFile() anyerror!void {
    var f = try std.fs.cwd().createFile("audio_output.wav", .{ .truncate = true });
    try write_wav_header(&f, 44100, 0);
    audio_file = f;
}

fn audioCallback(
    _: *zaudio.Device,
    _: ?*anyopaque,
    input: ?*const anyopaque,
    frame_count: u32,
) callconv(.C) void {
    if (input != null) {
        const samples: [*]const i16 = @ptrCast(@alignCast(input.?));

        for (0..frame_count) |i| {
            audio_buffer[buffer_index] = samples[i];
            buffer_index += 1;

            if (buffer_index >= constants.BUFFER_SIZE) {
                // if (audio_file) |*f| {
                //     // Eventually gonna replace this with writing to network.
                //     _ = f.write(std.mem.sliceAsBytes(&audio_buffer)) catch {};
                // }
                if (n.conn != null) {
                    n.writeToServer(audio_buffer) catch |err| {
                        std.debug.print("Error writing to server: {}\n", .{err});
                    };
                }
                buffer_index = 0; // Reset buffer
            }
        }
    }
}

// Obviously I don't have a fucking clue what a WAV header is, but I found this loose structure online.
fn write_wav_header(f: *std.fs.File, sample_rate: u32, num_samples: u32) !void {
    const bits_per_sample: u16 = 16;
    const num_channels: u16 = 1;
    const byte_rate = sample_rate * num_channels * (bits_per_sample / 8);
    const block_align = num_channels * (bits_per_sample / 8);
    const data_size = num_samples * num_channels * (bits_per_sample / 8);
    const file_size = 36 + data_size;

    var header = [_]u8{
        'R',                  'I',                       'F',                        'F',
        @truncate(file_size), @truncate(file_size >> 8), @truncate(file_size >> 16), @truncate(file_size >> 24),
        'W',                  'A',                       'V',                        'E',
        'f',                  'm',                       't',                        ' ',
        16, 0, 0, 0, // Subchunk1Size (16 for PCM)
        1, 0, // AudioFormat (1 = PCM)
        @truncate(num_channels),      0, // NumChannels
        @truncate(sample_rate),       @truncate(sample_rate >> 8),
        @truncate(sample_rate >> 16), @truncate(sample_rate >> 24),
        @truncate(byte_rate),         @truncate(byte_rate >> 8),
        @truncate(byte_rate >> 16),   @truncate(byte_rate >> 24),
        @truncate(block_align),       0,
        @truncate(bits_per_sample),   0,
        'd',                          'a',
        't',                          'a',
        @truncate(data_size),         @truncate(data_size >> 8),
        @truncate(data_size >> 16),   @truncate(data_size >> 24),
    };

    try f.writeAll(&header);
}
