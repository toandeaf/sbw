const rl = @import("raylib");
const ss = @import("../sprites/sprite_sheet.zig");
const c = @import("../resources/camera.zig");

const constants = @import("constants.zig");

pub const Player = struct {
    position: rl.Vector2,
    animation: ss.SpriteSheetAnimation,
};
