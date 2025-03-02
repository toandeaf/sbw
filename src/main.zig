const rl = @import("raylib");
const std = @import("std");
const ss = @import("sprite_sheet.zig");
const p = @import("player.zig");
const c = @import("camera.zig");
const m = @import("map.zig");

const GameObject = struct {
    updateFn: fn (self: anytype) void,
    renderFn: fn (self: anytype) void,
    data: ?*anyopaque,
};

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;

    c.initCamera(screenWidth, screenHeight);

    rl.initWindow(screenWidth, screenHeight, "SBW Zig POC");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var player = p.Player.init();
    const map = m.Map.init();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        player.update();

        rl.beginMode2D(c.camera);
        defer rl.endMode2D();

        map.render();
        player.render();

        rl.clearBackground(rl.Color.init(240, 230, 140, 255));
        rl.drawText("Sand, blood, water.", 50, 100, 20, rl.Color.red);
    }
}
