package player

import c "../camera"
import t "../types"
import rl "vendor:raylib"

FRAME_TIME : f32 = 0.05
INTERVAL : f32 = 2.0
SPEED : f32 = 1.2

update :: proc(obj: ^t.GameObject, dt: f32) {
    evaluate_input_and_update_animation(&obj.animation, &obj.position)
}

evaluate_input_and_update_animation :: proc(anim: ^t.SpriteSheetAnimation, position: ^rl.Vector2) {
    moving := true
    running := rl.IsKeyDown(rl.KeyboardKey.LEFT_SHIFT)

    prospectiveSpeed := SPEED

    if running {
        prospectiveSpeed = SPEED * 2.0
    }

    if rl.IsKeyDown(rl.KeyboardKey.W) {
        anim.currentRow = 0
        position.y -= prospectiveSpeed
    } else if rl.IsKeyDown(rl.KeyboardKey.S) {
        anim.currentRow = 1
        position.y += prospectiveSpeed
    } else if rl.IsKeyDown(rl.KeyboardKey.A) {
        anim.currentRow = 2
        position.x -= prospectiveSpeed
    } else if rl.IsKeyDown(rl.KeyboardKey.D) {
        anim.currentRow = 3
        position.x += prospectiveSpeed
    } else {
        moving = false
    }

    if moving {
        update_sprite_index(anim, running)
    } else {
        anim.currentFrame = 0
    }

    c.global_camera.target = position^
}

update_sprite_index :: proc(anim: ^t.SpriteSheetAnimation, running: bool) {
    deltaTime := rl.GetFrameTime()

    if running {
        anim.frameTime = anim.frameTime / 1.5
    } else {
        anim.frameTime = FRAME_TIME
    }

    anim.timer += deltaTime

    if anim.timer >= anim.frameTime {
        anim.timer -= anim.frameTime
        anim.currentFrame = (anim.currentFrame + 1) % anim.frameCount
    }
}