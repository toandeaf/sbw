const rl = @import("raylib");
const std = @import("std");
const ss = @import("sprite_sheet.zig");
const p = @import("player.zig");
const c = @import("camera.zig");
const m = @import("map.zig");

const GameObject = struct {
    updateFn: *const fn() void,
    renderFn: *const fn() void,

    pub fn update(self: GameObject) void {
        self.updateFn();
    }
    pub fn render(self: GameObject) void {
        self.renderFn();
    }
};

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;

    c.initCamera(screenWidth, screenHeight);

    rl.initWindow(screenWidth, screenHeight, "SBW Zig POC");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    m.Map.init();
    p.Player.init();

    const gameObjects = [_]GameObject{
        GameObject{
            .updateFn = m.update,
            .renderFn = m.render,
        },
        GameObject{
            .updateFn = p.update,
            .renderFn = p.render,
        },
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
