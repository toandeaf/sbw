const rl = @import("raylib");
const std = @import("std");
const alloactor = std.heap.page_allocator;
const ss = @import("sprite_sheet.zig");
const Player = @import("player.zig").Player;
const c = @import("camera.zig");

var game_objects: std.ArrayList = undefined;

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;

    c.initCamera(screenWidth, screenHeight);

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var player = Player.init();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        player.update();

        rl.beginMode2D(c.camera);
        defer rl.endMode2D();

        player.render();

        rl.clearBackground(rl.Color.init(240, 230, 140, 255));
        rl.drawText("Sand, blood, water.", 50, 100, 20, rl.Color.red);
    }
}
