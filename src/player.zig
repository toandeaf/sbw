const rl = @import("raylib");
const ss = @import("sprite_sheet.zig");
const c = @import("camera.zig");

const NUMBER_OF_FRAMES = 9;
const NUMBER_OF_ROWS = 4;
const FRAME_TIME = 0.05;

var player: Player = undefined;

pub const Player = struct {
    position: rl.Vector2,
    animation: ss.SpriteSheetAnimation,

    pub fn init() void {
        const texture = rl.loadTexture("assets/walk.png");

        const frameWidth = @as(f32, @floatFromInt(texture.width)) / NUMBER_OF_FRAMES;
        const frameHeight = @as(f32, @floatFromInt(texture.height)) / NUMBER_OF_ROWS;

        const position = rl.Vector2.init(0, 0);
        const animation = ss.SpriteSheetAnimation{
            .texture = texture,
            .frameWidth = frameWidth,
            .frameHeight = frameHeight,
            .frameCount = NUMBER_OF_FRAMES,
            .frameTime = FRAME_TIME,
            .currentFrame = 0,
            .currentRow = 1,
            .timer = 0.0,
            .rotation = 0.0,
        };

        player = Player{
            .position = position,
            .animation = animation,
        };
    }
};

pub fn update() void {
    var moving = true;

    const speed = 1.2;

    if (rl.isKeyDown(rl.KeyboardKey.w)) {
        player.animation.currentRow = 0;
        player.position.y -= speed;
    } else if (rl.isKeyDown(rl.KeyboardKey.s)) {
        player.animation.currentRow = 1;
        player.position.y += speed;
    } else if (rl.isKeyDown(rl.KeyboardKey.a)) {
        player.animation.currentRow = 2;
        player.position.x -= speed;
    } else if (rl.isKeyDown(rl.KeyboardKey.d)) {
        player.animation.currentRow = 3;
        player.position.x += speed;
    } else {
        moving = false;
    }

    if (moving) {
        const deltaTime = rl.getFrameTime();

        player.animation.timer += deltaTime;

        if (player.animation.timer >= player.animation.frameTime) {
            player.animation.timer -= player.animation.frameTime;
            player.animation.currentFrame = @rem(player.animation.currentFrame + 1, player.animation.frameCount);
        }
    } else {
        player.animation.currentFrame = 0;
    }

    c.camera.target = player.position;
}

pub fn render() void {
    const source_rec = rl.Rectangle.init(
        player.animation.frameWidth * @as(f32, @floatFromInt(player.animation.currentFrame)),
        player.animation.frameHeight * @as(f32, @floatFromInt(player.animation.currentRow)),
        player.animation.frameWidth,
        player.animation.frameHeight,
    );

    const dest_rec = rl.Rectangle.init(
        player.position.x,
        player.position.y,
        player.animation.frameWidth,
        player.animation.frameHeight,
    );

    const origin = rl.Vector2.init(player.animation.frameWidth / 2, player.animation.frameHeight / 2);

    rl.drawTexturePro(player.animation.texture, source_rec, dest_rec, origin, player.animation.rotation, rl.Color.white);
}
