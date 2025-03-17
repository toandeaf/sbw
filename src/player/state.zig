const rl = @import("raylib");
const ss = @import("../sprites/sprite_sheet.zig");
const Player = @import("types.zig").Player;
const constants = @import("constants.zig");

pub var player: Player = undefined;

pub fn init() anyerror!void {
    const texture = try rl.loadTexture("assets/walk.png");

    const frameWidth = @as(f32, @floatFromInt(texture.width)) / constants.NUMBER_OF_FRAMES;
    const frameHeight = @as(f32, @floatFromInt(texture.height)) / constants.NUMBER_OF_ROWS;

    const position = rl.Vector2.init(0, 0);
    const animation = ss.SpriteSheetAnimation{
        .texture = texture,
        .frameWidth = frameWidth,
        .frameHeight = frameHeight,
        .frameCount = constants.NUMBER_OF_FRAMES,
        .frameTime = constants.FRAME_TIME,
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