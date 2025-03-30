const net = @import("std").net;
const heap = @import("std").heap;
const mem = @import("std").mem;

const constants = @import("constants.zig");

pub var conn: ?net.Stream = null;

pub fn Init() anyerror!void {
    const allocator = heap.page_allocator;
    conn = try net.tcpConnectToHost(allocator, "0.0.0.0", 9001);
}

pub fn writeToServer(audioBuffer: [constants.BUFFER_SIZE]i16) anyerror!void {
    const bufferSlice = mem.toBytes(audioBuffer);

    try conn.?.writeAll(&bufferSlice);
}
