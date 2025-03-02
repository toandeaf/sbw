const rl = @import("raylib");
const std = @import("std");
const zaudio = @import("zaudio");

const g = @import("game/types.zig");

const m = @import("map/index.zig");
const p = @import("player/index.zig");
const c = @import("resources/camera.zig");

const BUFFER_SIZE = 44100; // 1 second at 44.1kHz
var audio_buffer: [BUFFER_SIZE]i16 = undefined;
var buffer_index: usize = 0;

fn audio_callback(
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
            if (buffer_index >= BUFFER_SIZE) {
                buffer_index = 0;
            }
        }
    }
}

fn listening() anyerror!void {
    const allocator = std.heap.page_allocator;
    zaudio.init(allocator);

    var config = zaudio.Device.Config.init(zaudio.Device.Type.capture);
    config.capture.device_id = null;
    config.capture.format = zaudio.Format.signed16;
    config.capture.channels = 1;
    config.sample_rate = 44100;
    config.data_callback = audio_callback;
    config.user_data = null;

    const device = try zaudio.Device.create(null, config);

    try device.start();
}

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;

    c.Init(screenWidth, screenHeight);

    rl.initWindow(screenWidth, screenHeight, "SBW Zig POC");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    try listening();

    const gameObjects = [_]g.GameObject{
        m.Init(),
        p.Init(),
    };

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        for (gameObjects) |gameObject| {
            gameObject.update();
        }

        rl.beginMode2D(c.camera);
        defer rl.endMode2D();

        for (gameObjects) |gameObject| {
            gameObject.render();
        }

        rl.clearBackground(rl.Color.init(240, 230, 140, 255));
        rl.drawText("Sand, blood, water.", 50, 100, 20, rl.Color.red);
    }
}
