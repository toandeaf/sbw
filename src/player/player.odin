package player

import rl "vendor:raylib"

import t "../types"
import c "../camera"

INTERVAL : f32 = 2.0
SPEED : f32 = 1.2

update :: proc(obj: ^t.GameObject, dt: f32) {
    evaluate_input_and_update_animation(&obj.animation, &obj.position)
}

evaluate_input_and_update_animation :: proc(anim: ^t.SpriteSheetAnimation, position: ^rl.Vector2) {
    moving := true

    if rl.IsKeyDown(rl.KeyboardKey.W) {
        anim.currentRow = 0
        position.y -= SPEED
    } else if rl.IsKeyDown(rl.KeyboardKey.S) {
        anim.currentRow = 1
        position.y += SPEED
    } else if rl.IsKeyDown(rl.KeyboardKey.A) {
        anim.currentRow = 2
        position.x -= SPEED
    } else if rl.IsKeyDown(rl.KeyboardKey.D) {
        anim.currentRow = 3
        position.x += SPEED
    } else {
        moving = false
    }

    if moving {
        update_sprite_index(anim)
    } else {
        anim.currentFrame = 0
    }

    c.global_camera.target = position^
}

update_sprite_index :: proc(anim: ^t.SpriteSheetAnimation) {
    deltaTime := rl.GetFrameTime()

    anim.timer += deltaTime

    if anim.timer >= anim.frameTime {
        anim.timer -= anim.frameTime
        anim.currentFrame = (anim.currentFrame + 1) % anim.frameCount
    }
}