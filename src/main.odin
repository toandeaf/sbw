package main

import rl "vendor:raylib"

import p "player"
import t "types"
import c "camera"

FRAME_TIME : f32 = 0.05


main :: proc() {
    screenWidth : i32 = 800
    screenHeight : i32 = 400

    halfWidth : f32 = cast(f32)screenWidth / 2.0
    halfHeight : f32 = cast(f32)screenHeight / 2.0

    rl.InitWindow(screenWidth, screenHeight, "Sand, Blood, Water.")
    defer rl.CloseWindow()

    rl.SetTargetFPS(60)

    spriteSheet := rl.LoadTexture("assets/walk.png")
    defer rl.UnloadTexture(spriteSheet)

    animation := t.SpriteSheetAnimation{
        texture      = spriteSheet,
        frameWidth   = spriteSheet.width / 9,
        frameHeight  = spriteSheet.height / 4,
        frameCount   = 9,
        frameTime    = FRAME_TIME,
        currentFrame = 0,
        currentRow   = 1,
        timer        = 0.0,
    }

    position := rl.Vector2{ halfWidth, halfHeight }

    c.camera_init(position)

    gameObjects := []t.GameObject{
        t.GameObject{
            position = position,
            animation = animation,
            update = p.update,
        },
    }

    for !rl.WindowShouldClose() {
        deltaTime := rl.GetFrameTime()

        for &gameObject in gameObjects {
            gameObject.update(&gameObject, deltaTime)
        }

        rl.BeginDrawing()
        defer rl.EndDrawing()

        rl.BeginMode2D(c.global_camera)
        defer rl.EndMode2D()

        rl.ClearBackground(rl.BLACK)
        rl.DrawText("Sand, blood, water.", 100, 200, 20, rl.GOLD)

        for &gameObject in &gameObjects {
            draw_sprite_animation(&gameObject)
        }
    }
}

draw_sprite_animation :: proc(obj: ^t.GameObject) {
    anim := &obj.animation
    position := obj.position

    sourceRec := rl.Rectangle{
        x      = cast(f32)(anim.currentFrame * anim.frameWidth),
        y      = cast(f32)(anim.currentRow * anim.frameHeight),
        width  = cast(f32)anim.frameWidth,
        height = cast(f32)anim.frameHeight,
    }

    destRec := rl.Rectangle{
        x      = position.x,
        y      = position.y,
        width  = cast(f32)anim.frameWidth,
        height = cast(f32)anim.frameHeight,
    }

    origin := rl.Vector2{
        cast(f32)anim.frameWidth / 2, cast(f32)anim.frameHeight / 2,
    }

    rl.DrawTexturePro(anim.texture, sourceRec, destRec, origin, 0.0, rl.WHITE)
}