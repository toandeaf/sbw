const rl = @import("raylib");
const p = @import("state.zig");

pub fn render() void {
    const source_rec = rl.Rectangle.init(
        p.player.animation.frameWidth * @as(f32, @floatFromInt(p.player.animation.currentFrame)),
        p.player.animation.frameHeight * @as(f32, @floatFromInt(p.player.animation.currentRow)),
        p.player.animation.frameWidth,
        p.player.animation.frameHeight,
    );

    const dest_rec = rl.Rectangle.init(
        p.player.position.x,
        p.player.position.y,
        p.player.animation.frameWidth,
        p.player.animation.frameHeight,
    );

    const origin = rl.Vector2.init(p.player.animation.frameWidth / 2, p.player.animation.frameHeight / 2);

    rl.drawTexturePro(p.player.animation.texture, source_rec, dest_rec, origin, p.player.animation.rotation, rl.Color.white);
}