const rl = @import("raylib");
const ss = @import("sprite_sheet.zig");
const c = @import("camera.zig");

const NUMBER_OF_FRAMES = 9;
const NUMBER_OF_ROWS = 4;
const FRAME_TIME = 0.05;

pub const Player = struct {
    position: rl.Vector2,
    animation: ss.SpriteSheetAnimation,

    pub fn init() Player {
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

        const player = Player{
            .position = position,
            .animation = animation,
        };

        return player;
    }

    pub fn update(self: *Player) void {
        var moving = true;

        const speed = 1.2;

        if (rl.isKeyDown(rl.KeyboardKey.w)) {
            self.animation.currentRow = 0;
            self.position.y -= speed;
        } else if (rl.isKeyDown(rl.KeyboardKey.s)) {
            self.animation.currentRow = 1;
            self.position.y += speed;
        } else if (rl.isKeyDown(rl.KeyboardKey.a)) {
            self.animation.currentRow = 2;
            self.position.x -= speed;
        } else if (rl.isKeyDown(rl.KeyboardKey.d)) {
            self.animation.currentRow = 3;
            self.position.x += speed;
        } else {
            moving = false;
        }

        if (moving) {
            const deltaTime = rl.getFrameTime();

            self.animation.timer += deltaTime;

            if (self.animation.timer >= self.animation.frameTime) {
                self.animation.timer -= self.animation.frameTime;
                self.animation.currentFrame = @rem(self.animation.currentFrame + 1, self.animation.frameCount);
            }
        } else {
            self.animation.currentFrame = 0;
        }

        c.camera.target = self.position;
    }

    pub fn render(self: Player) void {
        const source_rec = rl.Rectangle.init(
            self.animation.frameWidth * @as(f32, @floatFromInt(self.animation.currentFrame)),
            self.animation.frameHeight * @as(f32, @floatFromInt(self.animation.currentRow)),
            self.animation.frameWidth,
            self.animation.frameHeight,
        );

        const dest_rec = rl.Rectangle.init(
            self.position.x,
            self.position.y,
            self.animation.frameWidth,
            self.animation.frameHeight,
        );

        const origin = rl.Vector2.init(self.animation.frameWidth / 2, self.animation.frameHeight / 2);

        rl.drawTexturePro(self.animation.texture, source_rec, dest_rec, origin, self.animation.rotation, rl.Color.white);
    }
};
