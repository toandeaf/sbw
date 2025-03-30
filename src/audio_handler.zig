const std = @import("std");
const zaudio = @import("zaudio");

const SAMPLE_RATE = 44100;
const CHANNELS = 2;
const SAMPLE_SIZE = @sizeOf(i16);
const RING_CAPACITY = SAMPLE_RATE * CHANNELS * 2; // ~2 seconds of buffer

const RingBuffer = struct {
    buffer: []i16,
    head: std.atomic.Value(usize),
    tail: std.atomic.Value(usize),
    capacity: usize,

    pub fn init(buffer: []i16) RingBuffer {
        return RingBuffer{
            .buffer = buffer,
            .head = std.atomic.Value(usize).init(0),
            .tail = std.atomic.Value(usize).init(0),
            .capacity = buffer.len,
        };
    }

    pub fn write(self: *RingBuffer, data: []const i16) void {
        for (data) |sample| {
            const head = self.head.load(.acquire);
            const tail = self.tail.load(.acquire);
            const next_head = (head + 1) % self.capacity;

            if (next_head == tail) {
                // Buffer full, drop sample
                break;
            }

            self.buffer[head] = sample;
            self.head.store(next_head, .release);
        }
    }

    pub fn read(self: *RingBuffer, out: []i16) usize {
        var i: usize = 0;
        while (i < out.len) {
            const head = self.head.load(.acquire);
            var tail = self.tail.load(.acquire);

            if (tail == head) break; // Empty

            out[i] = self.buffer[tail];
            tail = (tail + 1) % self.capacity;
            self.tail.store(tail, .release);

            i += 1;
        }

        // Zero-pad the rest
        for (out[i..]) |*s| s.* = 0;

        return i;
    }
};

var raw_ring: [RING_CAPACITY]i16 = undefined;
var ring = RingBuffer.init(&raw_ring);

pub fn main() !void {
    const loopback = try std.net.Ip4Address.parse("0.0.0.0", 9001);
    const localhost = std.net.Address{ .in = loopback };

    var server = try localhost.listen(.{ .reuse_address = true });
    defer server.deinit();

    std.debug.print("Listening on 0.0.0.0:9001...\n", .{});

    var client = try server.accept();
    defer client.stream.close();
    std.debug.print("Client connected!\n", .{});

    // Needed for zaudio
    const allocator = std.heap.page_allocator;
    zaudio.init(allocator);

    var config = zaudio.Device.Config.init(zaudio.Device.Type.playback);
    config.playback.format = zaudio.Format.signed16;
    config.playback.channels = CHANNELS;
    config.sample_rate = SAMPLE_RATE;
    config.data_callback = audio_callback;
    config.user_data = null;

    var device = try zaudio.Device.create(null, config);
    try device.start();
    defer device.destroy();

    const reader = client.stream.reader();

    while (true) {
        var temp: [4096]u8 align(@alignOf(i16)) = undefined;

        const bytes_read = reader.read(&temp) catch |err| {
            std.debug.print("Read error: {}\n", .{err});
            break;
        };

        if (bytes_read == 0) break;

        const samples_read = bytes_read / SAMPLE_SIZE;
        const ptr: [*]i16 = @ptrCast(&temp);
        const samples: [*]i16 = @alignCast(ptr);

        ring.write(samples[0..samples_read]);
    }
}

fn audio_callback(
    _: *zaudio.Device,
    output: ?*anyopaque,
    _: ?*const anyopaque,
    frame_count: u32,
) callconv(.C) void {
    if (output == null) return;

    const out: [*]i16 = @ptrCast(@alignCast(output.?));
    const sample_count = frame_count * CHANNELS;

    _ = ring.read(out[0..sample_count]);
}