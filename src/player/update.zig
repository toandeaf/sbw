const rl = @import("raylib");
const p = @import("state.zig");
const c = @import("../resources/camera.zig");

pub fn update() void {
    var moving = true;

    const speed = 1.2;

    if (rl.isKeyDown(rl.KeyboardKey.w)) {
        p.player.animation.currentRow = 0;
        p.player.position.y -= speed;
    } else if (rl.isKeyDown(rl.KeyboardKey.s)) {
        p.player.animation.currentRow = 1;
        p.player.position.y += speed;
    } else if (rl.isKeyDown(rl.KeyboardKey.a)) {
        p.player.animation.currentRow = 2;
        p.player.position.x -= speed;
    } else if (rl.isKeyDown(rl.KeyboardKey.d)) {
        p.player.animation.currentRow = 3;
        p.player.position.x += speed;
    } else {
        moving = false;
    }

    if (moving) {
        const deltaTime = rl.getFrameTime();

        p.player.animation.timer += deltaTime;

        if (p.player.animation.timer >= p.player.animation.frameTime) {
            p.player.animation.timer -= p.player.animation.frameTime;
            p.player.animation.currentFrame = @rem(p.player.animation.currentFrame + 1, p.player.animation.frameCount);
        }
    } else {
        p.player.animation.currentFrame = 0;
    }

    c.camera.target = p.player.position;
}