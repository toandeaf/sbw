const rl = @import("raylib");

pub const SpriteSheetAnimation = struct {
    texture: rl.Texture2D,
    frameWidth: f32,
    frameHeight: f32,
    frameCount: i32,
    frameTime: f32,
    currentFrame: i32,
    currentRow: i32,
    timer: f32,
    rotation: f32,
};