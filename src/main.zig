const rl = @import("raylib");
const std = @import("std");
const zaudio = @import("zaudio");

const g = @import("game/types.zig");
const m = @import("map/index.zig");
const p = @import("player/index.zig");
const c = @import("resources/camera.zig");
const a = @import("resources/audio.zig");
const n = @import("resources/network.zig");

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;

    // Camera init
    c.Init(screenWidth, screenHeight);

    // Audio init
    try a.Init();
    defer a.Deinit() catch |err| {
        std.debug.print("Error deiniting audio: {}\n", .{err});
    };

    // Window init
    rl.initWindow(screenWidth, screenHeight, "SBW Zig POC");
    defer rl.closeWindow();

    const gameObjects = [_]g.GameObject{
        m.Init(),
        p.Init(),
    };

    // Trigger this on action orrr?
    try n.Init();
    try a.Listen();

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
