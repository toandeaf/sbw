const rl = @import("raylib");
const std = @import("std");
const alloactor = std.heap.page_allocator;

var camera: rl.Camera2D = undefined;
var game_objects: std.ArrayList = undefined;

const SpriteSheetAnimation = struct {
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

const Player = struct {
    position: rl.Vector2,
    animation: SpriteSheetAnimation,

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
                self.animation.currentFrame += @rem(self.animation.currentFrame + 1, self.animation.frameCount);
            }
        } else {
            self.animation.currentFrame = 0;
        }

        camera.target = self.position;
    }

    pub fn render(self: Player) void {
        const source_rec = rl.Rectangle.init(
            self.animation.frameWidth * @as(f32, @floatFromInt(self.animation.currentFrame)),
            self.animation.frameHeight *  @as(f32, @floatFromInt(self.animation.currentRow)),
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

fn initCamera(screenWidth: f32, screenHeight: f32) rl.Camera2D {
    return rl.Camera2D{
        .offset = rl.Vector2.init(screenWidth / 2, screenHeight / 2),
        .target = rl.Vector2.init(0, 0),
        .rotation = 0.0,
        .zoom = 1.0,
    };
}

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;

    camera = initCamera(screenWidth, screenHeight);

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    const texture = rl.loadTexture("assets/walk.png");

    const frameWidth: f32 = @floatFromInt(texture.width);
    const frameHeight: f32 = @floatFromInt(texture.height);

    const divFrameWidth = frameWidth / 9;
    const divFrameHeight = frameHeight / 4;

    var player = Player{ .position = rl.Vector2.init(0, 0), .animation = SpriteSheetAnimation{
        .texture = texture,
        .frameWidth = divFrameWidth,
        .frameHeight = divFrameHeight,
        .frameCount = 9,
        .frameTime = 0.05,
        .currentFrame = 0,
        .currentRow = 1,
        .timer = 0.0,
        .rotation = 0.0,
    } };

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        player.update();

        rl.beginMode2D(camera);
        defer rl.endMode2D();

        player.render();

        rl.clearBackground(rl.Color.init(240, 230, 140, 255));
        rl.drawText("Sand, blood, water.", 50, 100, 20, rl.Color.red);
    }
}
