package types

import rl "vendor:raylib"

GameObject :: struct {
    position: rl.Vector2,
    animation: SpriteSheetAnimation,
    update: proc(obj: ^GameObject, dt: f32),
}

SpriteSheetAnimation :: struct {
    texture     : rl.Texture2D,
    frameWidth  : i32,
    frameHeight : i32,
    frameCount  : i32,
    frameTime   : f32,
    currentFrame: i32,
    currentRow  : i32,
    timer       : f32,
    rotation    : f32,
}