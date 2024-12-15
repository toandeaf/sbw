package example

import rl "vendor:raylib"

INTERVAL : f32 = 2.0
SPEED : f32 = 1.2
FRAME_TIME : f32 = 0.05

GameObject :: struct {
    position: rl.Vector2,
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

update_sprite_index :: proc(anim: ^SpriteSheetAnimation) {
    deltaTime := rl.GetFrameTime()

    anim.timer += deltaTime

    if anim.timer >= anim.frameTime {
        anim.timer -= anim.frameTime
        anim.currentFrame = (anim.currentFrame + 1) % anim.frameCount
    }
}

evaluate_input_and_update_animation :: proc(anim: ^SpriteSheetAnimation, position: ^rl.Vector2) {
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
}

draw_sprite_animation :: proc(anim: ^SpriteSheetAnimation, position: ^rl.Vector2) {
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

    anim := SpriteSheetAnimation{
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

    camera2d := rl.Camera2D{
        target  = rl.Vector2{ halfWidth, halfHeight },
        offset  = rl.Vector2{ halfWidth, halfHeight },
        rotation= 0.0,
        zoom    = 1.0,
    }

    for !rl.WindowShouldClose() {
        deltaTime := rl.GetFrameTime()

        // Evaluate input and update animation
        evaluate_input_and_update_animation(&anim, &position)

        // Render scene
        rl.BeginDrawing()
        defer rl.EndDrawing()

        rl.BeginMode2D(camera2d)
        defer rl.EndMode2D()

        rl.ClearBackground(rl.BLACK)
        rl.DrawText("Sand, blood, water.", 100, 200, 20, rl.GOLD)

        draw_sprite_animation(&anim, &position)

        // Update camera position
        camera2d.target = rl.Vector2{ position.x, position.y }
    }
}