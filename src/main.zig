const rl = @import("raylib");

const g = @import("game/types.zig");

const m = @import("map/index.zig");
const p = @import("player/index.zig");
const c = @import("resources/camera.zig");

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;

    c.Init(screenWidth, screenHeight);

    rl.initWindow(screenWidth, screenHeight, "SBW Zig POC");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

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
