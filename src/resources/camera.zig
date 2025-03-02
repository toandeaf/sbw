const rl = @import("raylib");

pub var camera: rl.Camera2D = undefined;

pub fn Init(screenWidth: f32, screenHeight: f32) void {
    camera = rl.Camera2D{
        .offset = rl.Vector2.init(screenWidth / 2, screenHeight / 2),
        .target = rl.Vector2.init(0, 0),
        .rotation = 0.0,
        .zoom = 1.0,
    };
}